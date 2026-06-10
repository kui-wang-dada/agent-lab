# kevin-dev domain 工程经验积累

> 由 kevin-product / kevin-coder / kevin-qa 共享。
> 工程经验、踩过的坑、有效的调试套路、产品决策反思。

## 格式

```markdown
## YYYY-MM-DD — <一句话主题>
**情境**：什么场景
**经验**：什么有效 / 什么失败 / 为什么
**下次怎么做**：具体改进
**适用场景**：哪类项目 / 哪个 agent 用得上
```

---

<!-- agent 追加 -->

## 2026-05-24 — 客户给的"AI 工具型需求"必须先追问真实业务场景再做产品定义
**情境**：甲方原话"针对所有方言出一个自动识别的软件，用户说了方言后，软件能识别方言语言，并自动生成文案"。v1.0 当成"通用工具 SaaS"做了 10 个澄清问题 + 3 档功能 MVP。后来 Kevin 拿到关键信息——真实场景是"替代客服中心人力"——产品定位整个被推翻：从"工具型 SaaS"变成"客服 AI 业务系统"，报价区间从 ¥3-35w 上调到 ¥18-60w + 持续订阅，澄清问题大改一轮。
**经验**：客户描述需求时**最高频说法是"做一个 XX 工具"**——这是抽象表象，下面藏的几乎一定是具体业务场景（客服 / 销售 / 培训 / 数据采集 / ...）。产品定义阶段如果没问出"这工具替代谁的什么活、跟现有流程怎么对接、谁付钱、效果谁验收"——做出来的方案 80% 是错的。**通用工具方案 vs 业务系统方案在产品形态、技术架构、商业模式、报价区间都是数量级差异**。
**下次怎么做**：产品需求澄清第一轮 5 问必含——① 用户角色（不是"目标用户"这种宽问题，而是"具体是谁的什么场景")；② 现有怎么做的（替代什么人/什么系统/什么流程）；③ 集成对象（现有 IT 系统 / 工具链）；④ 谁付钱谁验收（甲方内部决策链）；⑤ "做完没人维护"是否可接受（决定一次性 vs 持续订阅）。这 5 问没答清楚不要进 PRD 阶段。
**适用场景**：所有"客户给一句话需求 + 产品助手要写 PRD"的项目；尤其国内 B 端 / Upwork 上模糊需求

## 2026-05-24 — "数据飞轮 + 人机协同"是 ASR/AI 类项目的高价值产品形态
**情境**：方言客服项目，Kevin 提出"软件先支持常用方言；遇到无法识别的方言时转人工客服；人工沟通时录音；沟通完成后由人工把对话内容做成文本 + 标注方言，喂给软件训练。随时间推移软件能识别的方言越来越多"——这是经典的人机协同数据飞轮。
**经验**：飞轮型产品对 freelance 是双刃剑：
- ✅ **正面**：客单价比"一次性交付"高 2-3 倍；持续订阅锁定收入；模型权重越用越值钱（Kevin 可复用到下个客户）；天然适配 ASR/LLM 类产品（云 API 是天花板，自训才有差异化）
- ⚠️ **负面**：飞轮三发动机（数据量 / 标注产能 / 训练上线）任一缺位飞轮转不起来；客户没标注产能 → Kevin 变标注外包；模型升级承诺易被甲方误解为"必然变聪明"；6 月以上长周期与 Kevin 时间分配硬约束冲突
**下次怎么做**：遇到 ASR / OCR / NLP 等"数据越多模型越好"的项目，**主动把飞轮端出来作为可选阶段**，但分两层报价：
1. Phase 1 不含飞轮（先跑通业务，¥18-35w）
2. Phase 2 启动飞轮（¥15-25w 一次性 + ¥3-5w/季运维）
合同必含 3 条飞轮护栏：① 标注产能由甲方承担；② 模型升级以甲方提供 ≥X 小时数据为前提；③ 通用模型权重 Kevin 持有，专属 LoRA 归甲方。详见 `research-notes/dialect-app-product-spec-v1.1-2026-05-24.md` §5。
**适用场景**：所有 ASR / OCR / 内容审核 / 推荐 / 任何"客户场景数据能反哺模型"的 AI 项目；尤其国内 B 端客户

## 2026-05-17 — FastAPI 后端一律用 async SQLAlchemy
**情境**：从 Venus 提炼默认技术栈时发现它用同步 SQLAlchemy Session（`sessionmaker` + 同步 `db: Session = Depends(get_db)`）。提炼报告把它标为"中确信，客户项目可兼容"。
**经验**：Kevin 明确反馈"async 模式更好，venus 里的同步方式不太好"。Venus 的同步 Session 是早期历史包袱，不是当前偏好。新 FastAPI 后端**无论个人或客户项目**，默认 async：`AsyncSession` + `async_sessionmaker` + `create_async_engine` + asyncpg driver。
**下次怎么做**：起脚手架直接抄 tianda-web 的 async 写法；不要把 Venus 同步 Session 当模板复制。已更新 venus-architecture.md 的决策表。
**适用场景**：所有新 FastAPI 后端项目；coder / product 在做技术选型时

## 2026-05-18 — 客户给的 xlsx 表设计稿必须先做 cleanup pass 才能进库
**情境**：东角山项目客户给了 3 个 xlsx 数据库表设计稿（52 张表 + 30 类字典）。第一反应是"直接 ruoyi 代码生成器一键生成"，但仔细看 xlsx 里有：3 处物理表名冲突（同名）、4-5 处字段名 typo（updat_id 全表错、draiage_condition、lrrigation_interval）、字段说明大量复制粘贴错位（产品名说明写"是否"）、跨域表名命名风格不统一（仓库 `t_ warehouse_xxx` 带前导空格）、审计字段与 ruoyi 默认（create_by/del_flag）不一致（用 create_id/is_del）。
**经验**：客户给的"数据库表设计"基本都是 ER 草图级别，**当作需求文档读，不当 DDL 用**。直接进代码生成器，CRUD 出来后字段注释错 30%、外键关系全靠业务层手补、跟 ruoyi 标准审计字段不兼容。**必须先做 cleanup pass**：① 统一表名/字段名 typo；② 统一审计字段为 ruoyi 风格；③ 显式标主键 / FK / 索引；④ 补字段类型（decimal 精度、varchar 长度）；⑤ 字典字段全部规划进 sys_dict_data。
**下次怎么做**：客户给 xlsx 后先写"数据库表分析.md"，按 § 严重度（阻塞/一般/建议）列问题，再写"物理设计.md"作为权威 DDL 来源；建模 cleanup pass 在 Phase 0 单独留 5-8 天工时；该工时算到报价里。
**适用场景**：所有客户提供"数据库表设计稿"的国内 B 端项目（freelance / domestic）；ruoyi 系项目尤其重要

## 2026-05-18 — 大型 xlsx 数据建模文件用 openpyxl 全 dump 后再人读
**情境**：解析 3 个 xlsx + 1 个字典 xlsx（共 55 sheet，2641 行）。如果用 pandas read_excel 一次性读到 DataFrame，列对齐会把"字段|说明|备注"三列展平，但 sheet 间字段数不一致（有的 3 列、有的 5 列、有的 6 列）。
**经验**：用 `openpyxl.load_workbook(data_only=True)` + `ws.iter_rows(values_only=True)` 直接 dump 成文本（每行 `R{i}: a | b | c`），人读最舒服 + LLM 也好处理。**注意**：列数不齐时要用 `[str(c) if c is not None else '']` 防 None；表名前导/尾随空格用 ls -la 直接看（项目里的"仓库数据库表设计 .xlsx" 文件名带尾随空格，bash 命令要全文件名引号包住）。
**下次怎么做**：遇到 5+ sheet 的 xlsx 分析任务，先写 `dump.py` 把全部内容写成 txt 到 /tmp，再用 Read 工具读 txt（每个 ~500-1500 行可控）；不要一次性把 xlsx 内容塞给 LLM。
**适用场景**：所有客户给的大型表设计稿 / 数据字典 / 业务规则 xlsx 分析

## 2026-05-19 — "AI 全写 + 人 review" 大型项目用 daily 文件夹体系组织
**情境**：东角山项目 70 ticket / 1.5 个月 / Kevin 派单 + 3 全栈 review + AI 全写。试过单一 doc/08-执行方案.md 长文档（764 行），但 3 全栈每天打开找当天任务太累，且无版本化。
**经验**：改为 `doc/daily/D<N>/` 每天一个子文件夹，含 6 类文件：`README.md`（当天目标 + ticket 清单 + DoD）/ `prompts/<TICKET>.md`（每 ticket 一个完整可 spawn 的 prompt）/ `testing.md`（API + UI + 集成测试 case）/ `progress.md`（实时进度表）/ `_inflight.md`（并发 AI 跟踪防撞车）/ `reports/<TICKET>.md`（AI 完工后写，每 ticket 独立文件避免写冲突）/ `summary.md`（全栈 A 17:30 收尾）。**3 全栈每天打开 D\<N\>/ 就能开始工作，零信息焦虑**。
**下次怎么做**：任何大型项目（>30 ticket / >2 周）默认用这套结构。Kevin 早上派单 = 复制 prompts/\<TICKET\>.md 到 Claude Code。**关键原则**：① prompt 必须自包含可独立 spawn（含 §0 状态自检 + §N 完工总结模板）② D1-D5 完整 + D6+ 骨架，跑完几天再细化下一批（依赖关系动态调整）③ Kevin 不写代码只派单 + 业务对齐 review。
**适用场景**：所有"AI 全写代码 + 人工 review 测试"的大型项目（freelance B 端 / Venus / tianda-web 重写等）

## 2026-05-19 — 需求会变的项目必须有 CR + OQ + _inflight 三件套
**情境**：东角山 v1.2 定稿后预判客户必然改主意（中国国内 B 端项目 100% 会变）。直接改 v1.2 → AI prompt 失去硬锚点；不改 → AI 实现错。
**经验**：三件套必备：① `doc/02-changes.md` **CR 单文件**（v1.2 冻结，所有改动按时间倒序追加，含影响 ticket + before/after + sign-off），AI prompt §0 必读；② `doc/_oq-tracking.md` **OQ 跟踪表**（残余客户待答问题，每条必带 Fallback 让开发不卡），Kevin 每周一批量推客户；③ `daily/D<N>/_inflight.md` **并发 zone 表**（5 AI 并行时 Kevin 派单前写一行 ticket + 改动文件 zone，AI §0 自检读它发现冲突立即 STOP）。三件套合计设计 + 模板 + 占位文件 ~2 小时，**消化 90% 需求漂移和并发冲突**。
**下次怎么做**：项目第 0 天先建三个表 + 模板；不要等出问题再补。CLAUDE.md 里写明"任何 v\<N\> 之后的需求改动 → 走 CR，不动 v\<N\> 正文"。
**适用场景**：所有需求会变 + 多 AI 并行写代码的项目；尤其国内 B 端客户

## 2026-05-19 — 项目级 .claude/settings.json 用 allow + deny 保护第三方源码 + 减 permission 打断
**情境**：dongjiaoshan 项目基于 ruoyi-plus 5.5.x 二开。需要让 AI 写业务代码不被"允许 mvn 吗？/ 允许 Edit 这个文件吗？"打断 N 次，但绝不能让 AI 改 ruoyi 自带模块（CLAUDE.md 写了但 prompt 文本约束不可靠）。
**经验**：写 `.claude/settings.json`：① `permissions.defaultMode: "acceptEdits"` ② `allow` 列常用 dev 命令（mvn / pnpm / git / curl / mysql）+ 业务模块路径（`ruoyi-djs-*` / `plus-ui/src/views` 等）③ **`deny` 第三方源码路径**（`ruoyi-admin/src/main/java` / `ruoyi-common` / `ruoyi-modules/ruoyi-system` 等）+ 危险命令（`rm -rf` / `git push --force` / `git reset --hard`）。AI 写代码飞快不被打断 + 想改 ruoyi 也改不了。
**下次怎么做**：任何基于第三方框架（ruoyi / SpringBoot starter / Next.js 模板）二开的项目，**第 0 天就写 settings.json**。allow 太宽 vs deny 太多之间，宁可 deny 多（出错让 AI 报告 Kevin），不可 allow 错（AI 写脏 ruoyi 源码后挽不回）。
**适用场景**：所有基于成熟框架二开的项目（ruoyi / hertz / nestjs starter / nextjs template）

## 2026-06-05 — ASR 字幕对齐：在"归一化匹配空间"打补丁比换模型 ROI 高一个量级
**情境**：media pipeline 用 Whisper 做词级时间戳，字幕文字用 Kevin 文案，align-script.py 做 script-first 对齐（SequenceMatcher 找最佳词区间借时间戳）。痛点是中英术语听错（Cursor→科舍 / java→加瓦 / Claude Code→Cloud Code），导致 normalize_for_match 算相似度对不上 → 字幕漏掉或时间戳错位。做了路线 A（术语音近映射表）。
**经验**：① **真正的杠杆在 align 阶段不在 ASR**——在归一化后、算 ratio 前对 whisper 串做"错听→规范"映射（只改 whisper 侧、不动文案侧、不改最终字幕文字），实测 W15 救回"重拾初心"漏匹配、W20 的 Cursor 句 ratio 0.72→0.92（时间戳更准）。改动 0.5 天、零模型迁移、零回归（diff 只动了被救的那几句）。② **whisper 把术语切成单字 word**（"科@.. 舍@.." 是两个 word，"Cloud@.. Code@.." 也是），所以映射必须作用在**多词拼接后的串**，不能对单 word 替换。③ **映射注入要保守**：只收"错听产物本身在正常语料里几乎不会作为真实词出现"的（科舍/加瓦/从始出新/cloudcode），grep 真实 whisper.json 确认规范形式从未被正确识别过再进表（如 cloudcode 出现在 6 期、claudecode 从未出现 → 映射零误伤）。④ **TDD 用真实缓存产物当 fixture**（episodes/*/whisper.json），别构造假数据——才能证明"加映射前漏、加后中"。⑤ 测试 harness 注意 find_best_word_span 受 MAX_SKIP_WORDS=200 限制，靠后的句子要模拟真实 next_word 推进才找得到，不能从 word 0 硬搜。
**下次怎么做**：遇到"ASR + 文案对齐"类任务，先读对齐算法源码定位"相似度在哪算"，在那一层加术语映射补丁，比换 ASR 模型快一个量级且零风险。换模型（路线 B）是中期根治，但 spike 前先确认词级时间戳格式契约 + Mac 能跑。
**适用场景**：media pipeline 字幕；任何"ASR 转写 + 已知正确文本对齐"的场景（播客字幕、课程字幕、配音对齐）

## 2026-06-05 — FunASR Mac spike：技术全绿，唯一卡点是 ModelScope 模型下载慢
**情境**：评估 FunASR (SeACo-Paraformer) 在 Mac M4 Max 替代 Whisper 做中文词级时间戳。host 原生用 uv 建独立 venv 装 funasr 1.3.9 + torch 2.12.0。
**经验**：① **安装/MPS 全通**：torch MPS available=True，funasr import 正常，`paraformer-zh` 别名自动解析为 SeACo-paraformer（带热词）+ 自动配 fsmn-vad + ct-punc。② **词级时间戳格式契约明确**（官方文档 + 已知）：输出 `[{'text':'...','timestamp':[[s_ms,e_ms],...]}]`，毫秒级，每个 timestamp 对应 text 的一个 token（中文空格分字、英文整词）。适配下游 `{"segments":[{"words":[{"text","start","end"}]}]}` 契约**确定可行**（ms/1000→秒，zip token）。③ **唯一 blocker 是网络**：model.pt 944M 从 ModelScope 下载只有 180-400kB/s，要 1 小时+，不是技术问题。④ **已知坑"text/timestamp 长度不匹配"必须实测**——适配器里写成显式 ValueError（不静默错位，错位的时间戳比报错难发现 10 倍）。
**下次怎么做**：FunASR 这类大模型 spike，**先后台启动模型下载**再干别的（下载是长尾），别同步阻塞等。适配器逻辑可脱离模型先用单测验证（ms→秒、长度校验、能否被下游消费）。Mac 上 FunASR 走 MPS 可行，值得作为 Whisper 的 opt-in backend，但默认仍 whisper（不破坏现有流水线）。
**适用场景**：本地 ASR 选型；任何"装重模型 + 验证输出格式"的可行性 spike

## 2026-06-05 — 【修正上一条】FunASR SeACo 热词对"英文术语"无效，B 路线不能根治术语错听
**情境**：模型实际下完了（~/.cache/modelscope 里 SeACo model.pt 989MB + fsmn-vad 完整，punc 还在 temp 没移好），用真实术语片段（W20"如果你用过 Cursor 或者 Claude Code"）实跑 FunASR + SeACo 热词。**上一条 learning 当时只验证了安装/格式，没实跑识别，写的"带热词术语 recall 更强 = go"是未经实测的假设。**
**经验**：实测推翻假设——① **FunASR 把术语听错的方式和 Whisper 完全一样**：Cursor→"科舍"、Claude Code→"cloud code"。② **热词三种传法（空格串/换行串/精简两词/空热词）输出逐字节相同**，热词偏置对这段零作用。③ 根因：SeACo 的 bias encoder 基于中文 vocab8404 token 词表，热词偏置作用在中文声学单元上；"Cursor"这类**纯英文术语模型没有对应中文 token 候选可偏置**——它把英文音翻成最近中文字，bias 机制够不着。SeACo 热词只对**中文热词**（如人名地名"魔搭"）有效。④ 但 FunASR 别的维度确实更好：**词级时间戳质量更干净**（单调、每字独立 ms 级、英文整词 cloud/code 各一 token）、**非术语中文字准率完美**、长度契约严格相等（已知坑没触发）。
**下次怎么做**：**B 路线的定位要改**——不是"根治术语错听"（做不到），而是"可能提升对齐时间戳精度"的 opt-in backend。术语错听这个真痛点，**不管 Whisper 还是 FunASR 都修不了 ASR 层**，只能在下游补：路线 A（归一化映射救匹配）+ 任务 1（display_map 改即兴显示文字）才是术语问题的真解。go/no-go：**作为时间戳后端 = 弱 go（边际收益，非刚需）；作为术语根治 = no-go（实测无效）**。教训：**"模型支持热词"≠"热词对你的术语有效"，必须用你自己的真实术语样本实跑，别信文档/别人的 benchmark。**
**适用场景**：所有"靠热词/biasing 解决专有名词识别"的 ASR 选型；中英混读 + 英文技术术语场景尤其要实测

## 2026-06-05 — 透传"类型元数据"过转换步骤：用 sidecar + 稳定索引主键，别在转换里塞字段
**情境**：media pipeline 即兴字幕 review 清单要从 align 阶段（subtitle.srt，剪辑前时间轴）挪到 auto-cut 之后（cut.srt，Kevin 实际编辑的剪辑后时间轴）。难点：cue 的 improv/script 类型标记只有 align 知道，但 cut.srt 是 auto-cut 产物，SRT 格式里不带类型。
**经验**：① **先验证转换步骤的不变量再设计主键**——grep 实测 7 期 subtitle.srt vs cut.srt：cue 数量 + 文字逐条 100% 一致，仅时间戳变（auto-cut 的 remap 只正则替换时间戳行，不增删/不重排）。所以**SRT 行号(1-based)就是稳定主键**，比"按文本/顺序模糊匹配"可靠（即兴里有重复短句时文本匹配歧义）。② **sidecar 比"往 SRT 塞类型字段"好**：不污染下游所有消费 SRT 的步骤（karaoke/burn 等），align 单写一个 `cue-types.json`（improv cue 的行号+文字），新步骤读 cut.srt+sidecar 按行号取。③ **sidecar 存文字做防御性校验**：行号取到的 cut.srt 文字必须==sidecar 文字，不一致→显式报错退出（auto-cut 改了结构的信号），不静默错位——错位时间戳比报错难发现 10 倍。④ **写 sidecar 必须在最终排序之后**：cue 写 SRT 前有 `.sort(key=start)`，sidecar 的行号要和 SRT 实际行号对齐，必须用排序后的同一份 cues 记录。⑤ **TDD 的 fixture 陈旧坑**：episode 磁盘上的 cut.srt 是旧版 align（无 display_map）产物，测试里 align 是新版→文字不一致触发强校验。解法不是放松生产校验（那是对的不变量），而是测试里**合成版本一致的 cut.srt**（fresh subtitle 文字 + 磁盘 cut 时间戳，按行号映射）——等价于"对 fresh subtitle 跑 auto-cut"，确定性、无需视频。⑥ **跨 cue 时间戳偶合**：~400 cue/11 分钟里不同 cue 时间戳可能撞，断言"清单没泄漏旧时间戳"要用 (时间戳,文字) 配对而非纯时间戳集合交集，否则误判。
**下次怎么做**：遇到"A 步骤有元数据、要在 B 步骤（A 的下游转换）用"的场景，先确认 B 是否保序/保结构→是则用稳定索引做主键 + sidecar 透传 + 文字/校验位双保险；别把元数据硬塞进中间产物格式污染其他消费者。
**适用场景**：media pipeline；任何"上游有标记、下游转换后要复用标记"的流水线（ASR/字幕、ETL 多阶段、编译 pass 间传 annotation）

## 2026-06-05 — run-steps.sh 加 --until：与 --from 对称，shell 层自检验证比跑 Docker 划算
**情境**：run-steps.sh（Docker 内流水线调度器，跑真实视频成本高）已有 --from/--only/--skip/--force，要加 --until STEP（跑到指定步骤含为止就停），让 Stage 2 用 `--until improv-review` 出字幕就停。
**经验**：① **新 flag 和已有 flag 的语义对称性要想清楚**：--from 是"起点(含)往后强制重跑"，--until 是"终点(含)之后跳过"，两个独立的步骤区间判断函数（step_at_or_after_from / step_after_until），在 should_run 里组合。② **--only 与 --until 组合的优先级要显式决策**：--only 是"只跑这一步"的强意图，让它不受 --until 影响（`[[ -z "$ONLY" ]] && step_after_until` 才跳）。③ **组合校验**：--from 下标 > --until 下标→区间空，多半手误，直接报错退出（抽 step_index 复用）。④ **Docker 里跑的 shell 逻辑用 shell 层自检验证**——把 ALL_STEPS + 三个区间函数抽出来写断言脚本（23 条 case 覆盖边界：终点=最后一步不跳、无 flag 全跑、from+until 组合、区间空），跑真实视频零必要。⑤ **插新步骤进 ALL_STEPS 数组的位置影响语义**：improv-review 紧跟 auto-cut，导致 `--until auto-cut` 会跳过 improv-review——Stage 2 要清单必须 `--until improv-review`，文档要写清这个反直觉点。
**下次怎么做**：给"步骤序列调度器"加区间 flag，先列全 ALL_STEPS 顺序→写对称的区间判断函数→shell 层断言脚本覆盖边界（含与已有 flag 的组合）→再考虑跑真实负载。报错信息列出合法步骤名（拼错高频）。
**适用场景**：任何 step-based pipeline 调度器（media run-steps.sh、CI 阶段控制、Makefile-like 编排）

## 2026-06-05 — 即兴字幕的术语纠正：display_map（改显示文字）和 term_map（改匹配）是两种用途，绝不能复用
**情境**：align-script.py 的即兴(improv) cue 字幕文字 = whisper 原文直出（`_emit_improv_chunk` 的 `"".join(w["text"])`），完全没纠正——Kevin 看到的"cloudcode""Next点击S"就在这。路线 A 的 term_map 救不了它（term_map 只作用在 normalize_for_match 之后的归一化匹配空间，不改最终字幕文字）。
**经验**：① **两张表本质不同用途，同一份 JSON 里分两段存**：`map`（term_map）= 归一化串→归一化串（'cloudcode'→'claudecode'），小写无空格，仅供 SequenceMatcher 匹配；`display_map` = 原始串子串→规范术语（'cloudcode'→'Claude Code'），带空格大写，**直接显示给观众**。复用错会产出"claudecode"当字幕（丑）或匹配失败。② **display_map 误伤代价更高**（直接被观众看到，不像 term_map 只影响匹配率波动），所以进表纪律更严：只收"错听形态绝不是合法词"的（cloudcode/Next点击S/CloudDesign），**坚决不收 'cloud' 单独**（指代 Claude 但 cloud 是合法英文词，会误伤"云"语义）。③ **实测即兴里 Cursor/java 反而被 whisper 识别对了**（grep all_improv.txt），所以它们不进 display_map——只有 cloudcode/Next.js 这俩在即兴里反复错。④ **大小写不敏感匹配**：即兴里同术语有 'CloudCode'(W16) 和 'cloudcode'(W19) 两形态，用 `re.sub(re.escape(key), ..., flags=re.IGNORECASE)`，re.escape 防 key 里的点（'Next.js'）被当正则通配，lambda 返回 value 防 value 里的 `\g` 等被当反向引用。⑤ **替换放在硬切前**：在完整即兴串上替换，避免术语横跨 MAX_CHARS_PER_CUE 硬切边界被切断漏改。⑥ **诚实边界**：display_map 只修反复出现的术语，即兴里随机同音字（"五脏俱全"→"股仗俱全"、气墙/传餐）修不了——靠任务 2 的 improv-review.md 人工兜底。
**下次怎么做**：遇到"ASR 直出文字要给人看 + 已知系统性错听"的场景，先分清"这次改的是匹配用的内部表示还是给人看的显示文字"——两者用两张表。进显示表前 grep 全量 dump 确认错听反复+正确形从未识别对+错听形态非合法词，三条都满足才进。TDD 从真实即兴段落抽 fixture，断言 base（空表）含错听、fixed（带表）归零，坐实"改前漏改后中"。
**适用场景**：media pipeline 即兴字幕；任何"ASR 转写直接当字幕展示 + 有已知系统性术语错听"的场景（直播字幕、会议纪要、口播视频）

## 2026-06-07 — ffmpeg overlay 静态 PNG 用 `-loop 1 -i` 不用 `movie=`；累积叠加卡片每状态一张 PNG
**情境**：media pipeline 加"左上角观点浮层"（[观点：…] marker 驱动，累积叠加：h1 起卡 / 每条 h2 往下追加一条圆角胶囊 / [观点，消失] 整卡淡出）。渲染选型在 ASS box vs Pillow-PNG overlay 之间选了 PNG——因为参考图要"深色圆角胶囊条目"，ASS BorderStyle=3 box 只能画直角整块底，画不出每条独立圆角+间距；Pillow rounded_rectangle + RGBA composite 能精确画，且 Pillow+fonts-noto-cjk 已在镜像里（cover-with-text.py 在用），零新依赖。
**经验**：① **`movie=png` 源加载单张 PNG 只产出一帧（PTS=0）**，`fade=in:st=8.1` / `overlay=enable='between(t,8.1,…)'` 引用的全局时间这条单帧流永远到不了 → 浮层根本不显示（烧出来啥也没有，且不报错，最坑）。**正解是 `-loop 1 -i png.png` 当真实输入**（overlay-images.py 同款），把 PNG 变成与输出同步的连续流，fade/enable 才按全局秒生效。配 `-shortest` 防无限循环撑长输出。② **"累积叠加"= 每个累积状态渲染成一张完整卡片 PNG**（h1 / h1+1条 / h1+2条…），在它的时间窗 overlay、到下一状态或消失才换——天然契合 marker 流展开成状态序列。代价：整卡一张 PNG 无法只让"新增那条"局部淡入，只能整卡短淡入折中（首帧/换 h1 用完整淡入，叠加帧用 0.18s 短淡入避免整卡闪）。③ **PNG 必须按视频实际分辨率渲染**（传 --video 探分辨率）——1080p PNG 叠 720p 视频虽然左上角卡仍可见但是浪费且边界行为不可控。④ **PNG overlay 直接拼进 burn-final 的同一条 vf/filter_complex**（不像 overlay-images.py 每张图独立 re-encode 一次），无浮层时退回原 `-vf` 单链逐字等价（向后兼容，无 marker 的 episode 行为零变化）；有浮层时切 filter_complex + 显式 map [outv]。⑤ **PNG 路径存"相对 manifest 目录"**（manifest 在 _work/viewpoints.json、PNG 在 _work/viewpoints/，存文件名会让 burn 找不到）。
**下次怎么做**：ffmpeg 叠静态图（水印/卡片/角标）一律 `-loop 1 -i` + `-shortest`，别用 `movie=`（除非确实要 filter 源且自己处理 loop+setpts）。"按内容逐步浮现"的浮层用"每状态一张完整 PNG + 时间窗 overlay"建模，比"一张图 + 动态显隐子元素"简单可靠。Pillow 画卡片优先抄项目里已有的渲染器（cover-with-text.py 的 font 加载/RGBA composite/textbbox 量字），house style 一致 + 零新依赖。改动后必须抽真实帧（ffmpeg -ss 在 -i 后做精确 seek）肉眼验证 overlay 真烧进去了——纯看命令成功+文件生成会漏掉"movie 源单帧不显示"这种静默失败。
**适用场景**：media pipeline 浮层/角标/水印；任何 ffmpeg 叠静态图 + 按时间显隐的需求；Pillow 渲染中文卡片

## 2026-06-07 — marker 内联进念稿正文：必须同步三处 strip 白名单（地基），逐字一致才能时间戳互换
**情境**：观点浮层 marker（[观点：…]）Kevin 拍板直接写念稿正文（不是报告推荐的独立小节）。现有 pipeline 的"文案位置→视频秒数"对齐依赖 align-script / script_markers / chapter-cards 三处 strip 逻辑逐字一致（都按同规则去 frontmatter/#标题/列表项/**/`/[图N]/[片段N]），三者算出的字符位置才指向同一条 SRT 的同一个字、时间戳可互换。
**经验**：① **内联 marker 不进 strip 白名单会双重污染**：(a) marker 那串中文被当口播对齐进 SRT、烧成字幕念出来；(b) marker 字符计入字符流 → 它之后所有 marker/[图N] 的字符位置整体偏移 → 时间戳全错。所以新 marker 必须在三处（实际本次是四处，含新写的 viewpoint-cards）同一位置加同一条 `re.sub(r"\[观点[：:，,].*?\]", "", s)`，**正则逐字节相同**。② **回归测试要直接断言"字符流一致"**：拿同一份带 marker 的文案喂四个 strip 函数，断言产出的纯字符流（去换行后）逐字相等——这比"跑出来看着对"可靠。再加一条"插 marker 后 [图N] 字符位置 == 没插 marker 时"坐实零污染。③ **半/全角容错**：Kevin 输入法会混 `[观点：…，类型…]`（全角冒号逗号）和半角，正则 `[：:，,]` 都收。④ **marker 不能被别的 marker 误吃**：`[观点…]` 和 `[图N]` 用 `[观点` 前缀天然区分，但测试要显式断言"`[图1:截图]` 不被当观点 marker、`[观点…]` 不被当图"。
**下次怎么做**：往"念稿正文/源文本里加内联工程 marker"的任务，第一件事是 grep 出所有消费"字符位置→时间/坐标"的 strip 逻辑（本项目是同一套 strip 复制在多文件），全部同步加白名单 + 写"字符流一致性"回归测试当地基。marker 语法用已有 marker 的前缀风格（[X：…]）天然互斥，省一层歧义。
**适用场景**：media pipeline 字幕/浮层 marker；任何"在源文本插内联标注 + 标注不能进最终输出 + 标注位置要映射到时间/坐标"的场景（字幕、弹幕轨、视频章节、富文本锚点）

## 2026-06-05 — RuoYi-Vue-Plus 抗高并发：瓶颈全在数据层不在 Web 层，"低并发跑得稳"≠"高并发能扛"
**情境**：正大集训系统（400 学员瞬时集体打卡）要复用 dongjiaoshan 的 RuoYi-Vue-Plus 5.6.1（小程序+admin），Kevin 唯一真不确定的是"500 并发 RuoYi 扛不扛得住"。读 dongjiaoshan 实际配置核实底座，dongjiaoshan 是 50 人级农业 B 端 SaaS（采购清单白纸黑字"约 50 人使用"+"本期不需要 SLB/WAF/CDN，这些是高并发才要"）。
**经验**：① **dongjiaoshan 实测技术栈（读代码核实）**：RuoYi-Vue-Plus 5.6.1 单体（非 Cloud 微服务）/ JDK21 / Spring Boot 3.5.14 / **Undertow**(非 Tomcat，io8 worker256) / **HikariCP**(非 Druid，maxPoolSize**20**) / MySQL8(阿里云 RDS) / Redis7+Redisson(重度：Sa-Token 登录态+缓存+lock4j 分布式锁+限流) / JVM 只 -Xmx1024m G1 / `virtual.enabled:false` / 多租户+逻辑删除+接口加密(SM2)+XSS 全开 / 单机单实例 宝塔+Docker Compose+nginx反代。② **"500 并发"必须拆三个数**："500 人在线"(Spring Boot 单体毫无压力)、"500 人均匀活跃"(轻)、"**500 人瞬时同时写**"(真考点，如早集合集体打卡)——含混当一个数谈是头号误判。③ **瓶颈全在数据层不在 Web 层**：Undertow 256 worker 对 500 在线绰绰有余；先崩的是 **Hikari 20 连接池**(瞬时 200 写挤 20 连接→排队→雪崩，头号必调 20→50)、**排行榜每请求 SQL 聚合 400 人**(必崩，改 Redis ZSet：ZINCRBY 加分/ZREVRANGE 读榜/ZREVRANK 查排名，DB 零压力)、**积分行锁**(同团队同学员并发 `score=score+x` 抢同一行锁→改"只 INSERT 积分流水不 UPDATE 汇总字段"，汇总=流水之和/ZSet 值，无锁)。④ **JDK21 虚拟线程是开箱杠杆**：dongjiaoshan 关着，开了(`virtual.enabled:true`)对"大量请求短暂阻塞在 DB I/O"的打卡尖峰天然友好，5.6.x 官方已适配(定时任务池已转虚拟线程、JVM 转 ZGC)。注意虚拟线程下别用 synchronized 锁 I/O(pin 载体线程)。⑤ **打卡幂等**：客户端幂等键 + Redis SETNX + 打卡表 `(student_id,point_id)` 唯一索引三重防线，弱网重试/双击只算一次。⑥ **削峰默认不上 MQ**：写逻辑简化成"INSERT 流水(无锁)+Redis 原子操作(无锁)"后，调好参数的 MySQL INSERT 扛得住 200 并发写，先压测达标就别引 MQ(集训 7 天一次性活动，多组件多故障点)。⑦ **临时升配省钱**：阿里云 ECS/RDS 支持临时升配，高配只在活动那几天开、完了降回，几百块搞定，不用按年买高配。
**下次怎么做**：遇到"复用某低并发项目的栈去扛高并发"，**第一件事是核实参照项目的真实并发量级**(读采购清单/用户量描述)，别被"它跑得稳"误导——量级和负载形态(平稳填表 vs 瞬时尖峰)可能差一个数量级。RuoYi-Vue-Plus 扛瞬时洪峰四件套：①规格够(8C16G ECS+4C8G RDS，临时升配)②调参(Hikari 20→50+开虚拟线程+堆 1G→4G+ZGC)③排行榜 Redis ZSet 绝不每请求聚合 ④打卡幂等+积分只 INSERT 流水/ZSet 累加避行锁。压测只压真尖峰(打卡 200 并发写/排行榜 300 并发读/登录尖峰)，达标线 P99<800ms+错误率<0.5%+积分对账零差异，必做"压测中重启 Redis 验证能从流水重建"。单机单实例就够 500 并发，够不着集群/微服务。
**适用场景**：所有基于 RuoYi-Vue-Plus（或类似 Spring Boot 单体）扛高并发的国内项目；尤其"打卡/抢答/秒杀/集体提交"类瞬时写洪峰；复用低并发项目栈去做高并发场景时的认知纠偏

## 2026-06-07 — ffmpeg 多 `-loop 1` PNG 挂多级 overlay 在长视频必 OOM；修法=预渲染单层透明叠加 + 单次 overlay
**情境**：观点浮层 v1 的 burn-final 把每张累积状态卡片各开一个 `-loop 1 -i png`（W22 这期 12 张），各自 `format=rgba,fade` 挂在一条 **12 级 overlay 链**上跑满整个 17 分钟编码。全片烧到 `time≈17:22`（末尾）被 `SIGKILL 9`。把 docker `mem_limit` 8g→16g **两次都在同一位置 OOM**——证明是烧录方式的内存病，不是配置给少了。
**经验**：① **`enable='between(t,a,b)'` 只控制"是否合成"，不阻止 ffmpeg 对 `-loop 1` 无限输入持续 demux/decode/缓冲帧**——12 路 720p RGBA buffer 常驻并累积，内存 ≈ O(输入路数 × 视频长度)，所以加内存只是推后爆点，治标。② **正解：把 N 路无限 PNG 收敛成"单层全时长透明叠加层" + 单次 overlay**（输入 13→2，内存与卡片数/视频长度彻底解耦）。实测峰值内存从爆 16g 降到 **463 MiB（16g 上限的 2.8%）**。③ **透明层低内存构建法**：因卡片状态时间上首尾相接，把 [0,video_dur] 规划成"前导透明段 + N 卡片段 + 尾透明段"，**每段只一个 `-loop 1 -t <段时长> -i`**（有限输入、内存极低），fade clamp 在段内（超短段如 0.177s 的 fade 不得超段长一半），编 qtrle，再 concat demuxer `-c copy` 无损拼成全时长 `viewpoints-layer.mov`。透明层自身承载"任一时刻只一张卡"语义，最终 overlay 不再需要 enable。④ **qtrle concat 撕裂坑**：透明段若不显式 `-vf format=rgba` 会被默认编成 rgb24（无 alpha），与卡片段 argb 不一致 → concat 后整屏撕裂。所有段统一 rgba/argb。⑤ **eq/unsharp/breath/subtitles=ASS 抽进共享的 main-chain builder**，有/无浮层两条路径逐字一致，保证视觉零回归。⑥ **OOM 类 bug 必须按全时长验证**——v1 只跑 30s smoke 没照出来（内存 O(时长) 累积，短片永远不爆），全片才暴露。
**下次怎么做**：ffmpeg 要叠 N 个按时间显隐的图层，**别开 N 个 `-loop 1` 输入挂 N 级 overlay**（长视频必 OOM）；若图层时间上互不重叠，预渲染成单层透明叠加（分段单输入构建 + concat）再一次 overlay。验证"内存/资源类"修复必须按真实全时长跑（用 `docker stats` 轮询记峰值），短 smoke 会假绿。透明视频层统一 rgba 编码（qtrle 对大片透明区 RLE 压得很好）。
**适用场景**：media pipeline 浮层/水印/角标按时间叠加；任何 ffmpeg 多图层按时间窗合成；以及"短样本验证通过但全量/长时运行才暴露"的资源累积型 bug（内存/句柄/连接泄漏）

## 2026-06-07 — 改 `pipeline/tools/` 后必须 `docker compose build`：工具是 build 时 COPY 进镜像，不是挂载
**情境**：修 burn-final.py 的 OOM 后直接 `docker compose run` 跑，差点验证到旧代码。media 的 docker-compose.yml 只挂了 EPISODE→/workspace 和 templates:ro，**`pipeline/tools/` 是 Dockerfile `COPY tools/` 在 build 时烤进镜像的**，run 不会带上 host 侧的最新改动。
**经验**：① 改了 `pipeline/tools/*` 或 Dockerfile 必须先 `docker compose build` 再 `docker compose run`，否则容器跑的是镜像里的旧代码——表现为"改了没生效"，最坑是不报错、行为照旧让人以为修复无效。docker-compose.yml 头部注释已写明这点。② 验证"修复是否生效"时连带核 final 产物时间戳 > 镜像 build 时间戳，坐实跑的是新代码。
**下次怎么做**：凡是"代码 COPY 进镜像（非挂载）"的 Docker 项目，改完代码第一步 `build` 再 `run`；分不清挂载还是 COPY 时，`grep -E 'COPY|volumes' Dockerfile docker-compose.yml` 确认。
**适用场景**：media pipeline 改 tools 后重跑；任何代码烤进镜像（非 bind mount）的容器化流水线的改码-验证循环

## 2026-06-07 — "自用工具产品化"先定位独占钩子，整个 MVP 围一根钉子立，其余功能默认砍
**情境**：Kevin 想把自用的 media 剪辑 pipeline（13 步 Docker，4737 行 Python + ffmpeg + whisper，已实战 10+ 期，功能繁多：对齐/去静音/音频处理/卡拉OK/观点浮层/呼吸点/BGM/封面）打包成桌面软件卖给"技术口播创作者"。
**经验**：① **把功能逐条过"是不是独占护城河"筛子**——这套里只有 **script-first 对齐**（文字 100% 来自文案、时间戳向 whisper 借）是剪映做不到的真钩子（剪映是"识别→人工校错字"95% 正确率）；其余全是通用剪辑软件都有的配菜。**价值主张和 MVP 必须收敛到这一根钉子**，多卖一个配菜就退化成"又一个剪辑软件"打不过免费剪映。② **MVP 砍到"砍了还买吗"为止**：目标用户已在用剪映做花字/BGM/封面，这些功能在新产品里是负担不是卖点；坚决不做时间线可视化编辑器（=重写一个剪映的无底洞）；导出标准 .srt 让用户拿回剪映微调，本产品定位"剪辑前的预处理器"不是终点站。③ **技术打包：本地桌面 App（Tauri/Electron 壳 + 打包 ffmpeg/whisper 二进制 + 复用现有 Python 当 sidecar）> 云 SaaS**——零服务器成本契合 Kevin 单兵+"商业化是意外之喜不能背成本"，隐私好卖（技术人在意），绕开"普通创作者不会装 Docker"（用户装的是 .dmg/.exe，不知道 Docker/Python 存在）。云 SaaS 的大视频上传+GPU 成本+值班对单兵不划算。④ **护城河诚实评估**：forced alignment 技术不难复制、巨头随时能加"导入文字稿"——但巨头不会做（目标用户是剪映用户 <1% 的窄场景，边际收益太低），**这正是 indie 的生存缝隙：做大厂看不上的窄场景**。薄护城河撑不起创业 All-in，但撑得起 levelsio 式小产品（窄人群+真痛点+$39 买断+攒 GitHub star+品牌拼图）——按 business-plan 的"意外之喜"定位刚好合格。⑤ **落地路径必须前置零成本验证，别闷头做半年**：Phase 0 落地页+30s 对比视频测水温（一周 ≥30 邮箱才继续）→ Phase 1 极简 GUI 自己跑通+5 个种子内测（验证愿不愿付）→ Phase 2 才做 Tauri MVP 上 Gumroad。每步带止损判据。
**下次怎么做**：遇到"把 X 自用工具/客户副产物产品化"的需求，先做三件事——(a) 功能逐条过"独占护城河"筛子，找出唯一钩子；(b) MVP 砍到只剩钩子+导出，能砍的配菜全砍（尤其别做"全能编辑器"）；(c) 落地页先于代码验证需求。技术形态默认本地 App 复用现有算法当 sidecar，别上云背成本（除非 research 证明必须云）。海外卖断（Gumroad）+ 国内 GitHub 开源引流，避开 business-plan 的国内合规曝光边界（国内推广不展示海外卖站）。详见 `kevin-hub/ideas/2026-06-07-script-first-video-editor.md`。
**适用场景**：所有"把自用工具/客户项目副产物打包成可卖产品"的微产品矩阵决策；尤其判断 MVP 边界 + 本地 App vs 云 SaaS + 薄护城河 indie 产品该不该做

## 2026-06-07 — ffmpeg lavfi `color=c@0.0` 透明源经编码后 alpha 必丢变不透明黑；透明帧统一用 Pillow RGBA PNG
**情境**：观点浮层单层透明叠加层里，卡片段用真实 PNG、空隙/前导/片尾的"填充透明段"图省事用了 lavfi 源 `color=c=black@0.0:s=WxH`（声称 `@0.0` = 全透明黑）+ `format=rgba` + qtrle。结果成片**片头前 5s（第一张卡之前）、片尾后 ~3.5s（最后一张卡之后）整屏黑屏、但有声音**——填充段是实心不透明黑盖住了主画面。卡片段透明正确（它从 viewpoint-cards.py 同款 `Image.new("RGBA",...,(0,0,0,0))` 出发）。
**经验**：① **lavfi `color=c=black@0.0` 产出的并不是真透明帧**——`@0.0` 的 alpha 经编码链（甚至直接写 PNG）后会丢，alpha→255 变不透明黑。实测探针：旧 `viewpoints-layer.mov` t=2s 全帧 RGBA=(0,0,0,**255**)，卡片段空白区 alpha=0。**只有 Pillow `Image.new("RGBA",(W,H),(0,0,0,0))` 才真正 alpha=0**。修法=填充段也走卡片段那条"真实 RGBA PNG"路径（`-loop 1 -t dur -i blank.png`），弃用 lavfi color 源，所有段逐字同构。② **透明/alpha 类 bug 的验证必须"实渲读像素 + 覆盖纯填充段时间区间"**：抽透明层 + 成片在片头(第一张卡之前)、片尾(最后一张卡之后)、卡间空隙的帧，读 alpha / maxCh（全黑 maxCh≈0、正常=255）。**上一轮抽帧只验了卡片段(≥5.8s)，漏了 5s 前的纯填充段，黑屏才溜过去**——和 OOM 那条同属"短样本/局部验证假绿"家族：验证的采样点必须覆盖每一类区段，不能只验"主要内容区"。
**下次怎么做**：ffmpeg 要造透明帧/透明垫片，别用 lavfi `color@0.0`（alpha 会丢），用 Pillow 渲真 RGBA PNG 再 `-loop 1 -i`。改透明叠加/抠像/alpha 合成后，验证清单显式列出"每一类时间区段各抽一帧读 alpha"——尤其首/尾/空隙这些"非主要内容但仍要透出底图"的填充区。
**适用场景**：media pipeline 透明浮层/垫片；任何 ffmpeg alpha 合成/抠像/透明叠加；以及"验证采样只覆盖主内容区、漏掉边界/填充区"导致的假绿（同 OOM 短 smoke 那条）
