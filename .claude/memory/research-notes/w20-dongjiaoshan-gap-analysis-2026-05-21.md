# W20 dongjiaoshan × 业界最佳实践 Gap Analysis

**整理日期**：2026-05-21
**输入**：`w20-ai-large-project-survey-2026-05-21.md` + `w20-dongjiaoshan-engineering-2026-05-21.md`
**视角**：业界已经走通的 5+1 防偏离机制 + SDD 四阶段 + Context Engineering 三块 vs dongjiaoshan D02 实际工程实践

---

## 一句话结论

dongjiaoshan 已经命中业界 9/10 核心实践，**唯一硬缺口是 TDD + Verification Gap 防御**（业界第 2、3 条机制），其余要么已经有、要么不适合 1.5 人小团队。还有 3 条 dongjiaoshan 走得比业界主流更聪明（§0 自检 / OQ / _inflight），不能被业界文章带偏放弃。

---

## Step 1：Gap Analysis（逐条对比）

### 业界 5+1 防偏离机制

### Plan Mode 强制先想后做
**业界做法**：Shift+Tab 进 read-only → 列计划 → 人 review → 才允许写代码
**dongjiaoshan 现状**：部分有。每个 ticket 一份完整 prompt md = 静态 Plan，但单 spawn 内部不强制 read-only 探索
**差距**：没有"AI 主动列计划等人 review"这一步，prompt 已写死
**该不该补**：❌ 不适合 dongjiaoshan
**理由**：dongjiaoshan 的 prompt md 本身就是 plan 的产物，Kevin 已经在 prompt 阶段把计划拍定，再加 Plan Mode 是重复工序

### TDD 红绿循环（不允许改 test）
**业界做法**：先写 test → commit failing → AI 实现到 green → 严禁改 test
**dongjiaoshan 现状**：没有。testing-ai.md 是"事后跑 curl + mysql count"，不是事前 failing test
**差距**：AI 实现完才验证，AI 完全可以无意识修改"验收口径"
**该不该补**：✅ 立即补（但轻量）
**理由**：D02 已经踩过"pig_status vs current_status 双字段"坑，本质就是缺前置验收契约

### Verification Gap 防御（evidence before claims）
**业界做法**：AI 宣称"完成"前必须**真的跑** test 并贴 output，禁止口头声明
**dongjiaoshan 现状**：部分有。reports/<TICKET>.md 要求贴 git diff --stat + 自测段落，但**没强制要求贴命令 raw output**
**差距**：AI 可以写"已通过编译"而不贴 mvn 输出，下游无法 audit
**该不该补**：✅ 立即补
**理由**：业界点名"multi-session agent 最常见失败模式"，dongjiaoshan 并发 3-5 AI 必踩

### Git Worktree 并行隔离
**业界做法**：`claude --worktree feat-xxx` 物理隔离目录，agent 互不感知
**dongjiaoshan 现状**：没有。同 repo 同分支靠 _inflight.md 文件 zone 表协调
**差距**：物理隔离 vs 文档约定
**该不该补**：❌ 不适合 dongjiaoshan
**理由**：5 个 AI 经常跨域引同一 ruoyi-djs-common 工具类，worktree 会让 common 改动同步成本爆炸；_inflight.md 在小团队里更轻

### AGENTS.md / CLAUDE.md 作"宪法"
**业界做法**：架构 + 命名 + 错误处理集中一个 md，所有 agent 自动加载
**dongjiaoshan 现状**：已有。`.claude/CLAUDE.md` 6 步循环图 + §6 菜单 id 段硬编码 + settings.json deny 边界
**差距**：无
**该不该补**：不用补

### Code Review Skill 强制 APPROVED
**业界做法**：`/dhh-review` slash command，必须返回 APPROVED 才允许 commit
**dongjiaoshan 现状**：部分有。人力 review（3 全栈 testing-human.md）+ 日终工程自检 A-H 维度 grep
**差距**：没有一个"AI 自审 → 必须输出 APPROVED verdict"的强制 gate
**该不该补**：⚠️ 等 D15 后再说
**理由**：dongjiaoshan 有 3 全栈做真人 review，AI 自审属于锦上添花；当前阶段引入会让单 ticket 流程变重

### SDD 四阶段（specify → plan → tasks → implement）

### specify（PRD → spec）
**业界做法**：人写一句话 PRD，AI 反问 + 列 edge case，spec 由人拍板
**dongjiaoshan 现状**：已有。墨刀原型 + 3 xlsx → AI 跨域 16 业务疑点 P0/P1/P2 → 客户饭局答 → 02-需求拆解-v1.2.md
**差距**：无
**该不该补**：不用补

### plan（架构 / ADR）
**业界做法**：AI 列选项 + trade-off，人拍板，决策自动写 ADR
**dongjiaoshan 现状**：已有。5 个重大决策 1.5 天内拍完 + ADR-0001/0002 + 05-架构文档
**差距**：无
**该不该补**：不用补

### tasks（拆 ticket）
**业界做法**：50 个 Linear ticket + 每 commit 引用 architecture section
**dongjiaoshan 现状**：已有。66 ticket 跨 5 域 / 15 工作日 + daily/D<N>/ 三层颗粒度
**差距**：commit message 没强制引用 ADR 编号
**该不该补**：⚠️ 等 D15 后再说，价值低

### implement（写代码）
**业界做法**：AI 写、人 review、TDD/Verification 防偏
**dongjiaoshan 现状**：已有但缺 TDD/Verification（见前文）
**差距**：见前文
**该不该补**：见前文

### Context Engineering 三块

### 共享"宪法"context
**业界做法**：AGENTS.md / CLAUDE.md 自动加载
**dongjiaoshan 现状**：已有
**差距**：无

### 决策历史 context（ADR 自动加载）
**业界做法**：`~/.claude/adr/` 自动加载（Anthropic issue #13853 在做）
**dongjiaoshan 现状**：已有 `doc/_adr/`，但**没强制 prompt §0 自检读 ADR**
**差距**：ADR 写了不一定被读
**该不该补**：✅ 立即补
**理由**：30 秒改 prompt 模板，避免 D15 后回头返工

### 变更 context（CR + OQ）
**业界做法**：业界**没普及**这个机制
**dongjiaoshan 现状**：已有 `02-changes.md`（6 CR / 1.5 天）+ `_oq-tracking`
**差距**：无（dongjiaoshan 反超）
**该不该补**：不用补

---

## Step 2：可执行优化清单（带优先级）

**P0（不补会翻车）**：

1. **[P0] 在 prompt §0 自检里增加"必须贴 raw output"硬约束**
   - 在 `freelance/projects/dongjiaoshan/.claude/CLAUDE.md` §6 加一句："reports/<TICKET>.md 的自测段落必须贴 mvn / mysql / curl 的**完整命令 + 完整 stdout 后 5 行**，不允许写'已通过'三个字了事"
   - 耗时：15 分钟（改 CLAUDE.md + 一个 D03 ticket prompt 验证）
   - 验证：D03 第一个 ticket 收尾的 reports md 必含 raw output 块

2. **[P0] 关键业务实体加 SQL 验收契约（轻量 TDD）**
   - 在 `doc/daily/D<N>/testing-ai.md` 顶部加固定段："**前置验收 SQL**"，每个 ticket 在 AI 实现前先写出 `SELECT count(*) FROM ... WHERE ...` 期望值
   - AI 实现完先跑这段，failing 就不进下一步
   - 耗时：20 分钟（改模板 + D03 三个 ticket 试用）
   - 验证：D03 收尾时这些验收 SQL 全 ✅ 才算 done

3. **[P0] §0 自检强制读 doc/_adr/ 索引**
   - 在 `.claude/CLAUDE.md` §0 自检列表里加一行："扫 `doc/_adr/*.md` 文件名，凡是 ADR 编号被本 ticket 改动文件 import/extends/implements 的，必读全文"
   - 耗时：10 分钟
   - 验证：D03 任一 ticket spawn 后 §0 输出含 "已读 ADR-0001/0002"

**P1（省 1+ ticket review 时间）**：

1. **[P1] 客户源材料 md5sum snapshot**
   - `origin/_analysis/_snapshot.md` 每周一一行：`<file>  <md5>  <date>`
   - 客户改 xlsx → md5 不一致 → CR 必触发
   - 耗时：10 分钟（写一个 `script/snapshot.sh`）
   - 验证：W2 周一 Kevin 跑一次，diff 出 5-19 客户加的 2 sheet

2. **[P1] 估时单一权威源**
   - CLAUDE.md 加一条："**估时仅在 `doc/daily/README.md` 维护**，其他文档（02-需求拆解 / 06-实现描述 / ticket prompt）禁止独立估时，引用 daily README 的数字"
   - 耗时：5 分钟 + 顺手清掉 06-实现描述里的"人日"列
   - 验证：D03 当 Kevin 问 AI"这个 ticket 多久"，AI 必引用 daily README

3. **[P1] reports/<TICKET>.md 强制"对下游 ticket 的提示"段**
   - 现已有但非强制，改成"§N 完工总结必须含'对下游 X-ticket-id 的提示：...'，否则 ticket 不 close"
   - 耗时：5 分钟（改 prompt 模板）
   - 验证：D03 5 个 ticket reports 全部带这一段

**P2（长期参考，短期不痛）**：

1. **[P2] D15 全量交付后引入 `/dhh-review` 类的 AI 自审 slash command**
   - 当前有 3 全栈做 review，AI 自审是冗余；M5 之后如果团队缩到 1+1 可考虑
   - 耗时：D15 后再评估

---

## Step 3：dongjiaoshan 已经比业界做得更好的实践

1. **§0 状态自检强制读 02-changes + _oq-tracking + 上游 ticket merge 状态**
   - 业界普遍做法：AGENTS.md / CLAUDE.md 自动加载作为静态 context
   - dongjiaoshan 实际做法：每个 prompt §0 主动读 6 个动态文件（git 状态 / 上游 ticket / 02-changes / _oq-tracking / _inflight / 关键表 schema），30s-2min 不通过 STOP
   - 为什么这条更适合 1.5 人 + AI 小团队：业界 AGENTS.md 是"开盘 context"，dongjiaoshan §0 是"开工前一刻的现场快检"——D02 就靠这关救场 D01 漏建 3 表，业界目前没普及这种"运行时自检"

2. **CR / OQ 双轨变更追踪**
   - 业界普遍做法：没有专门机制，需求变更靠重写 spec 文档版本号
   - dongjiaoshan 实际做法：`02-changes.md` 时间轴记 CR + `_oq-tracking` 收"客户未答需求"作 fallback default，AI prompt §0 必读两文件
   - 为什么更适合：国内 B 端项目"客户必改需求"是确定性事件，业界 SDD spec-first 假设需求稳定不现实；dongjiaoshan 用 CR/OQ 显式承接"需求漂移"，1.5 天 6 CR 0 返工就是证据

3. **_inflight.md 文件 zone 协调（替代 git worktree）**
   - 业界普遍做法：`claude --worktree feat-xxx` 物理隔离
   - dongjiaoshan 实际做法：同 repo 同分支，派单前写 ticket + 改动文件 zone，下游 §0 自检读到冲突 STOP
   - 为什么更适合：worktree 适合"agent 互不感知"的 horizontal 任务；dongjiaoshan 跨域共享 ruoyi-djs-common，worktree 会让 common 改动同步爆炸，文件 zone 表是更轻的方案
