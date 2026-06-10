# 国产/开源 ASR 替代 Whisper（词级时间戳硬约束版）— Research Brief

**调研日期**：2026-06-05
**时间窗**：2024-2026（重点 2025-12 ~ 2026 最新模型矩阵）
**深度**：完整对比报告
**整体可信度**：B+（词级时间戳支持靠官方文档/README 一手确认；code-switching 数字部分仅厂商自测集）
**前序调研**：`chinese-asr-2026-05-20.md`（本篇是它的增量 + 针对"词级时间戳/热词/微信引擎"三个新约束的深挖）

---

## 0. 关键前提：先搞清 Kevin 痛点的真实机制（读了 media/pipeline 源码）

读 `media/pipeline/tools/transcribe.py` + `align-script.py` 后纠正一个常见误解：

- **最终字幕文字不来自 ASR，来自 Kevin 的文案 `01-script.md`**。ASR 只负责"每个词说在哪个时间"。
- `align-script.py` 用 `SequenceMatcher` 把每个 script chunk 在 whisper 词流里找最佳匹配的连续词区间，借时间戳。
- 所以 **"java→加瓦"本身不会出现在字幕里**——真实危害是：ASR 把术语听错 → `normalize_for_match` 算相似度对不上 → 该 chunk 匹配失败（span=None）→ **这句字幕直接漏掉或时间戳错位**。痛点是"漏字幕/错位"，不是"错字"。
- **词级时间戳（每词 start/end）是真·硬约束**：`flatten_whisper_words` 强依赖。无词级时间戳的方案 = 对齐算法无法用 = 直接淘汰。
- 现状已是 `large-v3-turbo` (本地 `/opt/models/turbo`)，已在传 `hotwords` + `initial_prompt` 灌 30 个术语。

**结论先行**：换模型的收益 = "术语识别更准 → 对齐匹配率更高 → 漏字幕更少 + 时间戳更稳"。不是为了字幕文字本身。

---

## TL;DR（一句话）

国产开源**值得换，但分两步**：(1) 本地路线首选 **FunASR 的 Paraformer-zh / Fun-ASR-Nano**——原生词级时间戳 + 真热词（SeACo），中英术语靠热词强拉对齐匹配率，比 Whisper 的 prompt-hack 强一档；(2) 嫌本地集成麻烦就直接上**阿里云百炼 Fun-ASR/Paraformer API**——词级时间戳固定开启、`vocabulary_id` 热词、`language_hints=["zh","en"]`、约 ¥0.3-1.2/小时，Kevin 月音频 1-2.5h 等于白送。微信"很准"= 腾讯自研微信智聆 + 产品级后处理，**底层引擎=腾讯云 ASR（普粤英 16k_zh_en + 热词），可复用但要自己接 API，不是免费魔法**。

---

## 1. 候选对比表

| 模型 | 开源/闭源 | 本地/云 | 词级时间戳 | 中文准确率 | 中英混读/术语 | 热词/术语注入 | Apple Silicon/CPU | 计费/许可 | 隐私(音频上传) |
|---|---|---|---|---|---|---|---|---|---|
| **Whisper large-v3-turbo**（现状） | 开源 MIT | 本地 | ✅ 原生 word_timestamps | 较好 | 中等（英文术语常错→漏匹配） | ⚠️ 弱：hotwords/initial_prompt 受 **448 token 上限**，且 initial_prompt 会**改 segment 时长甚至降精度** | ✅ 现在 Docker CPU int8 | 免费 | 否（全本地） |
| **FunASR Paraformer-zh** (220M) | 开源 | 本地 | ✅ README 标 "ASR+timestamps"（字级） | 优秀 | 良好（中文母语强，术语靠热词补） | ✅✅ **SeACo 真热词** `hotword="..."`，灵活定制 | ✅ CPU 支持；⚠️ **README 未提 Mac/MPS**，需实测 | 免费 | 否（本地） |
| **FunASR Fun-ASR-Nano** (800M, 31语言, 2025-12新) | 开源 | 本地 | ✅ README 标 "ASR+timestamps" | 优秀 | 良好（31 语言基座，英文更稳） | ✅ 热词 | ✅ CPU；⚠️ Mac 未确认 | 免费 | 否（本地） |
| **SenseVoice-Small** (234M) | 开源 | 本地 | ⚠️ **半成品**：2024-11 起有 CTC-alignment 时间戳，但官方 README 仍写 word-level "will be supported later"，2025 仍有 timestamp bug；需社区"Enhanced SenseVoice"增强 | 优秀 | **优秀**（CS-Dialogue MER 6.71%） | ⚠️ 弱于 SeACo | ✅ CPU 17x realtime | 免费 | 否（本地） |
| **阿里云百炼 Fun-ASR/Paraformer API** | 闭源 API | 云 | ✅✅ **词级固定开启**，`sentences[].words[]` 含 begin/end/text | 优秀 | 优秀 | ✅ `vocabulary_id` 自定义热词；`language_hints=["zh","en"]` | N/A（云） | 文本免费按音频时长计；Paraformer 旧 ~¥0.288/h，Qwen3-ASR-Flash $0.00192/min≈**¥0.83-1.2/h** | **是（音频上传境内）** |
| **Fun-ASR 大模型**（0.7B编码+7B LLM，技术报告版） | 闭源 | 云 | 报告未提 | SOTA | **code-switching WER 1.59%~4.50%**（带 RAG 热词+RL，厂商自测集） | ✅ RAG 热词 | N/A | API 计费 | 是 |
| **腾讯云 ASR**（=微信智聆同源） | 闭源 API | 云 | ⚠️ 文档说"词级粒度详细识别结果"但未直接确认 word start/end，需实测确认 | 优秀（微信级） | 优秀（16k_zh_en 中英大模型） | ✅ 热词增强版：临时 128 / 表 1000，每词≤10字；+自学习模型 | N/A | 后付费按时长，需查控制台 | 是 |
| **讯飞语音转写** | 闭源 API | 云 | 需 API 文档确认 | 优秀 | 默认中英混合 | ✅ 热词 | N/A | **机器转写 ¥0.33/分钟=¥19.8/h**（贵） | 是 |
| **火山引擎(豆包)ASR 2.0/大模型** | 闭源 API | 云 | ✅ 搜索摘要确认返回每词 start/end | 优秀 | 中英混合 | ✅ 热词增强 | N/A | 阶梯计时/并发版 ¥500/并发/月 | 是 |
| **Belle-whisper-large-v3-zh**（对照） | 开源 | 本地 | ✅ 原生 | AISHELL 大幅提升 | ❌ **纯中文 fine-tune，英文术语强转同音中文**（React→瑞克特），对 Kevin 反而更差 | 同 Whisper | ✅ | 免费 | 否 |

---

## 2. 三条候选路线（针对"中英混读 + 必须词级时间戳 + 优先本地"）

### 路线 A（推荐 · 最低风险 · 当天可做）：守住 Whisper-turbo，但把热词从 prompt 改成真热词机制 + 强化对齐容错
**做什么**：不换模型。两个微调：
1. 把术语表从 `initial_prompt`（受 448 token 限 + 会伤 segment 时长）的依赖降下来，主要靠 faster-whisper 的 `hotwords` 参数（现在两个都在用，但 initial_prompt 灌 30 词已接近 token 预算）。
2. **真正的杠杆其实在 `align-script.py` 不在 ASR**：术语听错导致 `normalize_for_match` 对不上时，可在 normalize 阶段对已知术语做"音近映射表"（如把 whisper 常错的"加瓦/瑞克特"预先映射回 java/react 再算相似度），匹配率立刻上去。
**集成成本**：0.5 天（纯改 align-script，不动 pipeline 架构）。
**优劣**：✅ 零模型迁移风险、本地、词级时间戳现成；❌ 治标不治本，Whisper 中英混读上限就在那。

### 路线 B（推荐 · 中期根治 · 本地）：本地换 FunASR Paraformer-zh / Fun-ASR-Nano，吃 SeACo 真热词
**做什么**：pipeline 加一个 `transcribe-funasr` 备选步骤，用 `funasr` 的 `AutoModel`，`hotword="Claude Code MCP React Next.js ..."`，输出字级时间戳 JSON（结构对齐现有 `whisper.json` 的 `segments[].words[]`）。
**集成成本**：1-2 天。**最大不确定性 = Mac/MPS 支持**：README 只确认 CPU（17x realtime 足够 Kevin 用），Mac GPU 未承诺，可能 CPU fallback——但 Kevin 音频量小，CPU 完全够。
**优劣**：✅ 真热词（SeACo）是 Whisper prompt-hack 比不了的，专治"Claude Code/MCP 漏匹配"；中文母语更强；本地免费、隐私零风险；✅ Fun-ASR-Nano 31 语言基座对英文术语更稳。❌ 需写新 transcribe 脚本 + 校验 word 时间戳格式（FunASR 有"text/timestamp 长度不匹配"历史坑，要测）；Mac 跑速度待实测。

### 路线 C（备选 · 最省事 · 云）：阿里云百炼 Fun-ASR/Paraformer API
**做什么**：把 `transcribe` 步骤换成调阿里云百炼录音文件识别，`vocabulary_id` 挂术语热词表，`language_hints=["zh","en"]`，直接拿 `sentences[].words[]`（begin_time/end_time/text）喂给 align-script。
**集成成本**：0.5-1 天（就是个 HTTP client + 热词表上传）。
**优劣**：✅ 词级时间戳官方固定开启、热词、中英混合**三件套官方背书**，最省心；月成本 Kevin 量级 < ¥3，可忽略。❌ **音频要上传境内云**（隐私/离线让步）；需联网；强依赖外部服务可用性。

**路线推荐排序**：先 **A**（今天，验证"音近映射补丁"能不能把漏字幕压下去）→ 不够再 **B**（本地根治，符合 Kevin 极简+本地+隐私偏好）→ 嫌 B 的 Mac 适配麻烦就直接 **C**（量小成本可忽略，但要接受音频上传）。

---

## 3. 微信"很准"的真相（能不能复用）

- **底层 = 腾讯自研"微信智聆"（2013 起）+ 腾讯云 ASR 大模型**，同一套引擎也服务王者荣耀等内部产品。来源：腾讯云开发者社区/腾讯云 ASR 产品页（厂商口径）。
- **"很准"的三个来源**：(1) 海量真实语音数据训练的强基座；(2) 中英大模型引擎 `16k_zh_en`（普粤英混合）；(3) **产品级后处理**——微信场景做了大量针对性优化和文本顺滑/纠错，这部分**不随 API 开放**。
- **可复用部分**：腾讯云 ASR 录音文件识别（热词增强版 + 自学习模型 + 16k_zh_en）能接 API 拿到接近的识别质量。**不可复用部分**：微信端那层产品后处理。
- **对 Kevin 的判断**：微信"很准"不是有什么独门模型 Kevin 拿不到，而是"强引擎 + 产品打磨"。Kevin 要的是**词级时间戳**——微信 App 转文字**不给时间戳**，所以微信本身不能用；要复用得走腾讯云 ASR API（路线 C 的腾讯版），但其录音文件识别是否吐 word-level start/end **官方文档未直接确认，需实测**——这点上**阿里云百炼比腾讯云的文档更明确**（阿里直接写了 `words[].begin_time/end_time`）。

---

## 4. 关键不确定性 / 需实测验证（厂商宣传 vs 第三方实测）

| 点 | 当前状态 | 来源性质 | 怎么验证 |
|---|---|---|---|
| FunASR Paraformer/Fun-ASR-Nano 在 **Mac/MPS** 上能否跑、速度 | README 只确认 CPU 17x realtime，未提 Mac | 厂商 README | Kevin 本机 `pip install funasr` 跑一期视频实测 |
| FunASR **词级时间戳格式**是否与现有 align-script 兼容 | README 标 "ASR+timestamps"，但有"text/timestamp 长度不匹配"历史 issue | 厂商+社区 issue | 实测一段，看 `words[]` 结构 |
| Fun-ASR **code-switching WER 1.59-4.50%** | **厂商自测集 + 带 RL/RAG**，无第三方、无与 Whisper 直接对比 | ⚠️ 厂商宣传 | 不可直接信，按"厂商上限"看 |
| SenseVoice 词级时间戳成熟度 | 官方 README 仍写 word-level "later"，靠社区 Enhanced 版 | 厂商+社区 | 若选 SenseVoice 必须验时间戳质量 |
| 腾讯云录音文件识别是否返回 **word start/end** | 文档说"词级粒度"但未直接给字段 | 厂商文档（模糊） | 调一次 API 看返回体 |
| SeACo 热词对术语 recall 的**具体提升数字** | 论文 PDF 抓取失败（二进制），未拿到 recall/F1 | 论文（未读到数字） | 需读 arxiv 2308.03266 HTML 版 |
| CS-Dialogue **MER 6.71%（SenseVoice）/ CER 3.70%（Paraformer）** | 第三方学术数据集 | ✅ 第三方实测（arxiv 2502.18913） | 口径不同（MER按词/CER按字），不能直接比，需 Kevin 自测集复核 |

**厂商宣传 vs 第三方实测分界**：
- ✅ **第三方/学术**（可信）：CS-Dialogue benchmark（arxiv 2502.18913）、faster-whisper 448 token 限制（GitHub issue）、whispernotes Mac 实测。
- ⚠️ **厂商自测/宣传**（打折看）：Fun-ASR WER 1.59-4.50%、各家"中英混合很强"、微信"业界领先"、阿里各模型 CER。

---

## 5. 关键来源全列表

**A 级（一手/官方文档/学术）**
- [FunASR GitHub README](https://github.com/modelscope/FunASR) — 模型矩阵+timestamps+热词+OpenAI兼容API（抓取 2026-06-05）
- [阿里云百炼 录音文件识别 Fun-ASR/Paraformer](https://help.aliyun.com/zh/model-studio/recording-file-recognition) — 词级时间戳固定开启/language_hints/vocabulary_id 一手确认
- [SeACo-Paraformer GitHub](https://github.com/R1ckShi/SeACo-Paraformer) + [arxiv 2308.03266](https://arxiv.org/pdf/2308.03266) — 热词 SOTA（论文数字未抓到）
- [CS-Dialogue code-switching benchmark arxiv 2502.18913](https://arxiv.org/html/2502.18913v1) — 第三方 MER/CER
- [Fun-ASR 技术报告 arxiv 2509.12508](https://arxiv.org/html/2509.12508v3) — code-switching WER（厂商自测）
- [faster-whisper transcribe.py](https://github.com/SYSTRAN/faster-whisper) + [issue#1313 hotwords/448token](https://github.com/SYSTRAN/faster-whisper/issues/1313) — Whisper 热词上限实证
- [腾讯云 ASR 产品功能](https://cloud.tencent.com/document/product/1093/35682) + [热词文档](https://cloud.tencent.com/document/product/1093/40996)
- [火山引擎 ASR 产品](https://www.volcengine.com/product/asr) + [录音文件识别极速版](https://www.volcengine.com/docs/6561/192519)

**B 级（厂商口径/二手）**
- 微信智聆=腾讯自研：腾讯云开发者社区 ASR 词条（厂商口径）
- [讯飞语音转写](https://www.xfyun.cn/services/lfasr) + 听见计费 ¥0.33/min
- [Qwen3-ASR-Flash 定价 OpenRouter](https://openrouter.ai/qwen/qwen3-asr-flash-2026-02-10) — $0.00192/min

**对照（避免）**
- [Belle-whisper-large-v3-zh HF](https://huggingface.co/BELLE-2/Belle-whisper-large-v3-zh) — 纯中文 fine-tune，英文术语反而更差，**不选**

---

## 6. vs 上次调研（2026-05-20）的增量

1. **新模型**：Fun-ASR-Nano（800M, 31语言, 2025-12）+ Fun-ASR 大模型（7B LLM）入场；FunASR 现已是 OpenAI 兼容 API。
2. **纠正**：上次说"SenseVoice 不原生输出时间戳"→ 更新为"2024-11 起有 CTC-alignment 时间戳，但 word-level 仍半成品 + 2025 有 bug"。
3. **新结论（本次核心）**：上次没死磕"词级时间戳是硬约束"。死磕后排序变了——**Paraformer-zh / Fun-ASR-Nano（原生词级时间戳+SeACo真热词）超过 SenseVoice 升为本地首选**；SenseVoice 因时间戳半成品降级。
4. **新增机制洞察**：读了 align-script 源码，确认 Kevin 痛点是"漏匹配"非"错字"，真正杠杆一半在 align-script 的音近映射，不全在换 ASR。
5. **微信引擎查清**：腾讯智聆+腾讯云 ASR，可走 API 复用引擎但拿不到产品后处理，且微信 App 本身不给时间戳。
