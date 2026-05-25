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
