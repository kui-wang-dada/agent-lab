# 中文 / 中英混合 ASR 方案调研 — Research Brief

**调研日期**：2026-05-20
**时间窗**：2024-2026（重点 2025-2026）
**深度**：完整对比报告
**整体可信度**：B（多源印证，但部分 code-switching benchmark 仅单源）
**当前 pipeline**：`media/pipeline` Docker，默认 Whisper `medium`，挂 `/workspace` 出 srt

---

## TL;DR（3 句话）

- **中英混合场景**：SenseVoice-Small + 外挂 VAD/时间戳是当前免费方案里最好的；Whisper-large-v3 在 code-switching 上比中文 fine-tune 版（Belle）反而更稳，因为 Belle 把英文也"压"成了中文。
- **本地优先 + Mac Studio 64GB**：SenseVoice-Small（<1GB）+ FireRedASR2-AED（1.1B）双备份是甜点位；想最高精度上 Qwen3-ASR-1.7B（6-8GB）也轻松跑。
- **不推荐继续 Whisper medium**：换 large-v3-turbo（5× 快、精度接近）几乎零成本提升；想根治错字必须换底座。

---

## 关键事实

| 事实 | 来源 | 时间 | 可信度 |
|---|---|---|---|
| SenseVoice-Small 比 Whisper-Small 快 5×、比 Whisper-large-v3 快 15× | [SenseVoice GitHub](https://github.com/FunAudioLLM/SenseVoice) | 2024-07 | A |
| SenseVoice 中文/粤语 CER 优于 Whisper-large-v3（粤语：SenseVoice 7.09% vs Whisper-v3 10.41%） | [Whisper Notes blog](https://whispernotes.app/blog/sensevoice-fastest-cjk-transcription) | 2024 | B |
| **中英 code-switching（CS-Dialogue 104h 数据集）**：Paraformer CER 3.70%，SenseVoice-Small MER 6.71%（最低），Whisper-large-v2 落后 | [arxiv 2502.18913](https://arxiv.org/html/2502.18913v1) | 2025-02 | A |
| Belle-whisper-large-v3-zh 在 AISHELL/WenetSpeech 等中文 benchmark 上比原版 Whisper-v3 相对提升 24-65% | [Belle HF](https://huggingface.co/BELLE-2/Belle-whisper-large-v3-zh) | 2024 | A |
| **Belle 是"全中文 fine-tune"**，未明确优化英文/code-switching → 英文术语可能更差 | 模型卡片推断 | 2024 | C（推断） |
| FireRedASR2-AED AISHELL-1 CER 0.57% (SOTA)；FireRedASR2-LLM 真实场景 CER 4.32% | [Ruoqi Jin ASR 2025-2026](https://ruoqijin.com/blog/asr-deep-dive-2025-2026) | 2025 | B |
| 阿里云 Bailian Fun-ASR API ¥0.288/小时（云端最便宜） | 同上 | 2025 | B |
| Deepgram Nova-3 普通话简体 batch 比 Nova-2 WER 降 65.21%；$0.46/h | [Deepgram blog](https://deepgram.com/learn/deepgram-nova-3-expands-speech-to-text-support-across-asia-pacific) | 2025 | A |
| AssemblyAI Universal-2 基础 $0.15/h，加 speaker/summary 后实际 $0.35/h | [Brass Transcripts](https://brasstranscripts.com/blog/assemblyai-pricing-per-minute-2025-real-costs) | 2025 | A |
| whisper-large-v3-turbo 比 v3 快 2-5×，精度近似（809M vs 1.55B） | [Whisper Notes turbo](https://whispernotes.app/blog/introducing-whisper-large-v3-turbo) | 2024 | A |
| whisper.cpp + CoreML 在 Apple Silicon 上 large-v3-turbo q5_0 跑 ~1.23s（短音频）| [OpenBenchmarking](https://openbenchmarking.org/performance/test/pts/whisper-cpp/) | 2025 | B |
| SenseVoice 官方版**不原生输出时间戳**，需外挂 FSMN-VAD 分段或用社区方案 | [CSDN 解决方案](https://blog.csdn.net/m0_62852701/article/details/141606837) + [GitHub Issue 2324](https://github.com/modelscope/FunASR/issues/2324) | 2024-09 | A |
| FireRedASR2 已开源在 HF（FireRedTeam/FireRedASR2-AED、FireRedASR2-LLM），conda 安装即用 | [FireRedASR GitHub](https://github.com/FireRedTeam/FireRedASR) | 2025 | A |

---

## 候选方案对比表

| 方案 | 开源 | 本地 | 中文 CER | 中英混合 | 时间戳/SRT | 显存 | Mac MPS | 价格 |
|---|---|---|---|---|---|---|---|---|
| **Whisper medium**（当前）| 开源 | ✅ | 一般（~10%+） | 差（英文术语全错） | 原生 ✅ | 5GB | ✅ | 免费 |
| Whisper large-v3 | 开源 | ✅ | 较好 | 中等（混合 OK，但中文错字多） | 原生 ✅ | 10GB | ✅ whisper.cpp | 免费 |
| Whisper large-v3-turbo | 开源 | ✅ | 接近 v3 | 接近 v3 | 原生 ✅ | 6GB | ✅ | 免费 |
| Belle-whisper-large-v3-zh | 开源 | ✅ | **大幅提升**（CER -24~65%） | ⚠️ 英文可能变差 | 原生 ✅ | 10GB | ✅ | 免费 |
| **SenseVoice-Small** | 开源 | ✅ | **优秀**（粤语 7%） | **优秀**（MER 6.71%）| ⚠️ 需外挂 VAD | <1GB | ✅ | 免费 |
| Paraformer-Large（FunASR）| 开源 | ✅ | 优秀 | **CER 3.70%** | ✅（sentence 级） | 1-2GB | ⚠️ 主要 Linux | 免费 |
| FireRedASR2-AED (1.1B) | 开源 | ✅ | **SOTA**（AISHELL 0.57%） | 良好（含英文训练） | ✅ | ~4GB | ⚠️ 需测试 | 免费 |
| FireRedASR2-LLM (8.3B) | 开源 | ✅ | **SOTA**（真实 4.32%） | 优秀 | ✅ | ≥32GB（M4 Max 64G OK） | ⚠️ 需测试 | 免费 |
| Qwen3-ASR-1.7B | 开源 | ✅ | 优秀（真实 5.88%） | **52 语言+4 万英文词训练** | ✅ | 6-8GB | ⚠️ | 免费 |
| 阿里云 Bailian Fun-ASR | API | ❌ | 优秀 | 优秀 | ✅ | - | - | **¥0.288/h** |
| 通义听悟 | API | ❌ | 优秀 | 优秀 | ✅ | - | - | 按量 |
| Deepgram Nova-3 | 闭源 | ❌ | 较好（v3 大改进） | 一般 | ✅ | - | - | $0.46/h |
| AssemblyAI Universal-2 | 闭源 | ❌ | 中文支持弱 | 弱 | ✅ | - | - | $0.15-0.35/h |

---

## 趋势 / 解读（推断，非事实）

1. **2024 是 Whisper 一统天下，2025 是国产开源全面反超**：SenseVoice、Paraformer、FireRedASR、Qwen3-ASR 在中文/中英任务上集体把 Whisper 拉下马；这条赛道国产领先约 6-12 个月。
2. **"中文 fine-tune"是双刃剑**：Belle 这类纯中文 fine-tune 模型在 AISHELL 上数据好看，但 Kevin 的视频里英文术语（React/Next.js/Claude Code/MCP）几乎必现，**会被强行转成同音中文（如 "瑞克特"）**——这恰好是 Kevin 最痛的点。原版 Whisper-large-v3 或 SenseVoice 多语言基座反而更稳。
3. **时间戳是 SenseVoice 的短板**：官方不直接吐 srt，必须 VAD 预切+对齐，集成成本比 Whisper 高一档；社区已有 [pyVideoTrans](https://pyvideotrans.com/sensevoice) 方案可参考。
4. **Mac Studio M4 Max 64GB 几乎不挑模型**：FireRedASR2-LLM (8B+) 都跑得动；唯一变量是 MPS/CoreML 支持成熟度——SenseVoice/FireRedASR 在 Mac 上的实测较少，可能要 CPU fallback。
5. **云 API 经济模型**：Kevin 1 期 10-20 分钟视频，月产 4-8 期 = 80-160 分钟 = 1-2.5 小时音频/月。阿里云 Bailian ¥0.288/h × 2.5 = ¥0.72/月，**便宜到不值得本地化**——除非有隐私/离线需求。

---

## 矛盾 / 待验证

- **Paraformer CER 3.70% vs SenseVoice MER 6.71%（CS-Dialogue 数据集）**：表面看 Paraformer 更准，但 CER 和 MER 计算口径不同（MER 对英文按 word 计、CER 按字符计），不能直接比。**待 Kevin 用自己一期视频实测一次**才能下结论。
- **SenseVoice "比 Whisper 快 15×" 是论文数据，Mac 上未必能复现**：whispernotes 博客实测 27 分钟播客对比 SenseVoice vs Whisper Large V3 Turbo 在 M4 Pro 上速度差距远没那么夸张。
- **FireRedASR 在 Mac MPS 上的支持度未知**：官方文档只提 conda + Linux 工作流；可能需要 CPU 推理或社区 fork。

---

## 历史对比

无同主题历史调研（首次）。本次结果写入 `chinese-asr-2026-05-20.md`，未来 diff 用。

---

## 我的建议（3 个具体选项 + 推荐 + 理由）

### 选项 A（推荐 · 风险最低 · 立刻可做）：升级 Whisper → large-v3-turbo + 简单 prompt 优化

**做什么**：把 `docker-compose.yml` 里 `MODEL=medium` 改成 `large-v3-turbo`，并在 transcribe 时传 `initial_prompt="本视频涉及 React, Next.js, Claude Code, MCP, Whisper, TypeScript 等技术术语"`。

**理由**：
- 零架构变更，10 分钟改完
- turbo 在 Mac 上比 medium 慢不了多少（809M），精度接近 large-v3
- initial_prompt 是 Whisper 唯一"低成本拯救英文术语"的杠杆，已被反复验证

**Tradeoff**：上限有限，中英混合还是 Whisper 自身的弱点；prompt 长度有限（224 token）。

---

### 选项 B（推荐 · 平衡 · 中期目标）：本地部署 SenseVoice-Small + FSMN-VAD 出 srt

**做什么**：在 `media/pipeline` 加一个 `transcribe-sensevoice` 步骤，用 [pyVideoTrans 的 srt 实现](https://pyvideotrans.com/sensevoice) 或自己写 VAD 预切→SenseVoice→对齐时间戳。

**理由**：
- 中英混合是 SenseVoice 强项（MER 6.71%，CS-Dialogue 数据集 SOTA 之一）
- <1GB 模型，Mac 跑爆快，CPU 都能推
- 同时拿到情感/语种检测附加信息，未来做"自动加表情包/特效"有用

**Tradeoff**：时间戳要外挂方案，集成成本比 A 高一档（预估 1-2 天）；Mac MPS 支持要测；英文 word 级精度可能不如 Whisper。

---

### 选项 C（备选 · 极致精度 · 长期看）：FireRedASR2-LLM (8B+) 本地 + Qwen3-ASR 双跑

**做什么**：M4 Max 64GB 跑 FireRedASR2-LLM，把 SenseVoice 当快速 draft、FireRedASR 做 final pass；或两者跑，diff 高错率句子用 Claude 做仲裁。

**理由**：
- 真实场景 CER 4.32%，目前开源最强
- 64GB 内存能支撑
- 长期看是"自媒体 + freelance 字幕"通用底座

**Tradeoff**：工程量大（预估 1 周）；Mac MPS 支持未验证，可能要 CPU 推理→速度受影响；模型大下载慢（8B+ ~16GB）。

---

## 行动建议（3 行）

1. **本周先做 A**：改 `MODEL=large-v3-turbo` + initial_prompt 灌技术术语 → 1 小时见效，验证英文术语错字率是否降到可接受。
2. **备选 B**：A 还不够好（中文错字仍多），花 1-2 天集成 SenseVoice-Small + VAD 出 srt → 中英混合根治。
3. **长期 C**：每月音频量超过 10h 或对单期精度敏感（如商业视频客户字幕），上 FireRedASR2-LLM 本地。

---

## 来源全列表（按可信度排序）

- A 级（一手 / 多源印证）
  - [SenseVoice GitHub](https://github.com/FunAudioLLM/SenseVoice) — 抓取 2026-05-20 — 官方仓库
  - [CS-Dialogue 论文 arxiv 2502.18913](https://arxiv.org/html/2502.18913v1) — 2025-02 — 一手 benchmark
  - [Belle-whisper-large-v3-zh HF](https://huggingface.co/BELLE-2/Belle-whisper-large-v3-zh) — 模型一手
  - [FireRedASR GitHub](https://github.com/FireRedTeam/FireRedASR) — 官方仓库
  - [Deepgram Nova-3 APAC](https://deepgram.com/learn/deepgram-nova-3-expands-speech-to-text-support-across-asia-pacific) — 官方
  - [Whisper Notes turbo benchmark](https://whispernotes.app/blog/introducing-whisper-large-v3-turbo) — 实测
  - [AssemblyAI 真实定价](https://brasstranscripts.com/blog/assemblyai-pricing-per-minute-2025-real-costs)

- B 级（二手分析 / 单源）
  - [Ruoqi Jin ASR 2025-2026 综述](https://ruoqijin.com/blog/asr-deep-dive-2025-2026) — 综合性数据
  - [Whisper Notes SenseVoice 对比](https://whispernotes.app/blog/sensevoice-fastest-cjk-transcription) — 实测博客
  - [OpenBenchmarking whisper.cpp](https://openbenchmarking.org/performance/test/pts/whisper-cpp/bba40be5b54aebfa2f7be27b6d5384dadef5d6d0)
  - [FunAudioLLM 论文 arxiv 2407.04051](https://arxiv.org/html/2407.04051v1)

- C 级（推断 / 社区方案）
  - [pyVideoTrans SenseVoice 集成](https://pyvideotrans.com/sensevoice)
  - [SenseVoice 时间戳 CSDN 方案](https://blog.csdn.net/m0_62852701/article/details/141606837)
  - [GitHub Issue 2324 时间戳问题](https://github.com/modelscope/FunASR/issues/2324)
