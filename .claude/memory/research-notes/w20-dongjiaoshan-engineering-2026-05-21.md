# W20 素材：dongjiaoshan AI 工程实践（1.5 天观察）

**整理日期**：2026-05-21
**项目**：freelance/projects/dongjiaoshan（东角山有机生态农场 SaaS）
**观察窗口**：D01（5-20 周三）+ D02（5-21 周四，进行中）

---

## 一句话概括（视频核心论点支撑）

**"AI 写代码"只是基础设施；真正能让一个人扛大型 B 端项目的，是把每一天的开工、派单、自检、收尾全部"流程化"成 AI 看得懂、人能 review 的文档结构——`daily/D<N>/` + CR + OQ + `_inflight` + settings.json 五件套。**

---

## 项目快照

| 项 | 内容 |
|---|---|
| 业务领域 | 自营农业全产业链 SaaS：自己种 + 自己养 + 仓储加工 + 自营门店 + 顾客追溯 |
| 规模 | **5 个业务域 / 66 ticket / 69 张业务表 / 38 类字典 / 13 角色 / 15 工作日计划** |
| 当前进度（5-21 D2 中午）| **D1 5/5 ticket merge + D2 5/5 ticket 完成**（66 中 10 个 = 15.2%），69 张表全建，10+ 角色登录可见对应菜单 |
| 后端 | RuoYi-Vue-Plus 5.5.x（Java 17 + Spring Boot 3 + MyBatis-Plus + Sa-Token），5 个新模块 `ruoyi-djs-{common,breed,plant,warehouse,store}` |
| Admin 前端 | plus-ui（Vue3 + Element Plus + Pinia） |
| 小程序 | uni-app + wot-design-uni（D3 起步） |
| DB | MySQL 8（5-18 单独调研定案，否决了 PG）|
| 关键决策 | V1 单农场 / V2 多农场（拦截器写好但 disable）；多租户 `tenant_id VARCHAR(20) DEFAULT '1001'`；OSS V1 PRESIGNED_PUT / V2 STS（ADR-0002） |
| 团队 | Kevin 派单 + 业务对齐（4-5h/天）+ 3 全栈 review/测试（不写业务代码）+ AI subagent（写代码，并行 3-5） |

---

## 工程实践四块（与视频四个落点对齐）

### 1. 如何用 AI 拆解需求

**真实路径**：墨刀原型 116 画布 → AI 跑全量页面解析（`原型页面全量清单.md` 213 页）→ Kevin 5/16 重新核对发现"两份原型"实际是"PC + 小程序"两端而非两版业务 → AI 跨域写 16 个业务疑点 P0/P1/P2 + "按 1.5h 视频会议节奏分 4 组"的客户澄清问题清单 → 5/17 饭局拿到 P0 答案 → `02-需求拆解-v1.2.md` 锁 v1.2 + 拆出 66 ticket。

**AI 强的地方**：
- 把客户给的 3 个 xlsx（55 sheet / 2641 行）+ 一份 116 画布墨刀，**逆向出 5 域 + 66 ticket + 数据流图**——人工至少 1 周，AI + Kevin 协作 **3 天**做完
- 跨页面交叉验证业务实体（例：从养殖原型 + 仓库原型 + 门店原型推出"产品 vs 商品"概念边界，列为 P0 问题）

**AI 拆错被纠正的**：
- 客户 xlsx 里 `育种信息表` 末尾追加 2 sheet（5-19 追加），AI 第一版按"4 表独立建模"，Kevin 看出来客户实际是"2 表合表 + breed_strain 字段区分"。**走 CR-20260519-06 重写 schema**（养殖域表数 23→25）
- v1.1 残留字段 `pig_status`（11 字母枚举）与 v1.2 新字段 `current_status`（9 状态枚举）共存，AI 高概率两个都建出来 → Layer 2 评审 catch → **CR-20260519-05 显式删除** + 验收 SQL `grep -ri "pig_status\b"` 必须为空

**证据文件**：
- `freelance/projects/dongjiaoshan/doc/02-需求拆解-v1.2.md`（66 ticket 全索引）
- `freelance/projects/dongjiaoshan/doc/02-changes.md`（v1.2 之后所有 CR）
- `agent-lab/.claude/memory/kevin-dev/learnings.md` 2026-05-18 条目"xlsx 必须先 cleanup pass"

### 2. 如何确定架构

**核心打法**：**先写 ADR、再写 prompt**——拍板的决策落 `doc/_adr/` 单独文件，prompt 只引用 ADR 编号不重复决策内容。

**真实决策路径**（1.5 天内拍 5 个重大决策）：

| 决策 | 路径 | 落点 |
|---|---|---|
| DB 选 MySQL 不切 PG | 5-18 单独调研报告（4000 字 + 决策矩阵：项目命中度 / 团队栈 / 甲方维护 / 价格 4 维度） | `dongjiaoshan-db-selection-2026-05-18.md` |
| 多农场 V1 disable / V2 enable | ADR-0001，拦截器代码全写好但 `@ConditionalOnProperty(djs.multi-farm.enabled=false)` | `_adr/0001-multi-farm-deferred.md` |
| OSS V1 PRESIGNED_PUT / V2 STS | ADR-0002，minio 不支持 STS 是技术原因 | `_adr/0002-oss-sts-v2-blueprint.md` |
| `tenant_id VARCHAR(20)` 不 BIGINT | D01 现场拍板，对齐 ruoyi `TenantEntity.tenantId` String | `D01/summary.md` "重大决策" |
| 软删 `del_unique` 应用层 fill 不用 MySQL GENERATED 列 | D01 现场拍板，MySQL 8 GENERATED 不能引用 AUTO_INCREMENT | 同上 |

**"卡 ADR 还是直接试"的取舍**：影响 3+ 文件 + 影响下游 ticket 的决策必落 ADR；纯实现细节直接 commit message 写 why 就够（CLAUDE.md §11 "不记录中间态" 原则）。

**证据文件**：
- `freelance/projects/dongjiaoshan/doc/05-架构文档-ruoyi.md`（技术总图）
- `freelance/projects/dongjiaoshan/doc/_adr/0001-multi-farm-deferred.md`
- `freelance/projects/dongjiaoshan/doc/_adr/0002-oss-sts-v2-blueprint.md`

### 3. 如何拆分每天的工作

**三层颗粒度**（一周 → 一天 → 一次 spawn）：

**周计划**（`doc/daily/README.md`）：W1-W3 各 5 天 = 15 工作日，每天平均 4.4 ticket，按 5 个业务域横向并发不按"3 个全栈各包 1 域"纵向切。

**日计划**（`doc/daily/D<N>/`）每天一个子文件夹，**7 类文件**：

```
D02/
├── README.md          ← 今日目标 + 5 ticket 清单 + DoD + 谁做什么 + 风险表
├── prompts/           ← 5 个 .md，每个是完整可独立 spawn 的 prompt
│   ├── SYS-INFRA-001.md   （含 §0 自检 + §N 完工总结模板）
│   ├── SYS-INFRA-004.md
│   ├── SYS-INFRA-005.md
│   ├── SYS-INFRA-006.md
│   └── SYS-MD-001.md
├── testing-ai.md      ← AI 跑的机械验证（编译/单测/curl/mysql count/docker）
├── testing-human.md   ← 3 全栈跑的感官验证（浏览器 UI / DB 浏览 / 代码 review）
├── progress.md        ← 表格状态跟踪（AI 实现 / be review / fe review / merge）
├── _inflight.md       ← 并发 AI 跟踪：派单前写一行 ticket + 改动文件 zone，下游 §0 自检读它发现冲突 STOP
├── _open-issues.md    ← 非阻塞 raise 集中收集（D02 当前 12 条）
├── reports/           ← AI 每完成一个 ticket 写一个独立 md，避免并发写冲突
└── summary.md         ← 全栈 A 17:30 cat reports/*.md 整理
```

**一次 spawn 的颗粒度**：每个 ticket 一个 prompt md，**强制三段式**：
1. **§0 状态自检**（30s-2min）：git 状态 / 上游 ticket merge 检查 / 关键类/表/API 硬探 / 编译健康 / 扫 02-changes + _oq-tracking → 不通过 STOP
2. **主任务**：实现代码
3. **§N 完工总结**：写 `reports/<TICKET-ID>.md`（git diff --stat + 新产物 + 自测 + 已知 issue + 对下游 ticket 提示）

**工具组合**：Kevin 早上 9:00 `cd D<N>/` → 复制 `prompts/<TICKET>.md` 全文 → 另一个 Claude Code 窗口 spawn subagent → 3-5 个 ticket 并行跑 → 中午回流。**没用 git worktree**（同 repo 不同文件，靠 _inflight.md 文件 zone 表协调而非分支隔离）。

**证据文件**：
- `freelance/projects/dongjiaoshan/doc/daily/README.md`（W1-W3 总览）
- `freelance/projects/dongjiaoshan/doc/daily/D01/` 完整一日
- `freelance/projects/dongjiaoshan/doc/daily/D02/summary.md`（5 ticket 100% 完成）
- `freelance/projects/dongjiaoshan/doc/daily/D01/prompts/SYS-INIT-001.md`（祖宗 ticket 完整 prompt 样例）

### 4. 如何确保不偏离

**每天开 / 关机制**：

- **开工**（Kevin 9:00）：`cd D<N>/`，读 `README.md` 1 分钟知道今天 5 个 ticket 是什么。AI 每个 ticket §0 自检读 02-changes + _oq-tracking 看有没有需求变更影响本 ticket。
- **测试触发顺序硬约束**：AI testing-ai.md（机械）全 ✅ → 才走人力 testing-human.md（感官）。前者 ❌ → AI 自己 fix 重跑，**不进人力阶段**。
- **收工**（18:00）：日终 closing 集中改文档（_open-issues.md 每条逐一 a/b/c 决策 + 该 ADR 的写 ADR）→ 日终工程自检（A-H 维度 grep 一致性扫描）→ 全 ✅ merge dev。

**AI 跑偏的 3 种发现机制**：

1. **§0 自检挡住上游漏 merge**：D02 第一件事就靠自检发现 D01 SYS-INIT-001 实际只建 66 张表（漏建 3 张：`t_md_biz_code_rule` / `t_md_biz_code_sequence` / `t_md_person`，影响当天 3 个 ticket），当场补 `V202605210800__D02-PATCH-D01-missing-tables.sql` 灌入后业务表 = 69 ✅。**没有自检这一关，D02 5 ticket 全部跑废**。
2. **CR 单文件**（`02-changes.md`）：客户 5-19 追加 2 sheet → 立即写 CR-20260519-06 → AI prompt §0 自检读 CR → 按新 schema 实现。**6 张 CR 在 1.5 天里全部 sign-off**。
3. **_inflight.md 防撞车**：5 个 AI 并行时 Kevin 派单前在 _inflight 写一行 ticket + 改动文件 zone，下游 AI §0 自检读到冲突立即 STOP。

**settings.json 的 allow/deny 真实片段**（脱敏后核心）：

```json
{
  "permissions": {
    "defaultMode": "acceptEdits",
    "allow": [
      "Bash(mvn:*)", "Bash(pnpm:*)", "Bash(mysql:*)", "Bash(curl:*)",
      "Edit(code/main/RuoYi-Vue-Plus/ruoyi-djs-*/**)",
      "Edit(code/main/plus-ui/src/views/**)",
      "Write(script/sql/djs/**)"
    ],
    "deny": [
      "Bash(rm -rf:*)", "Bash(git push --force:*)", "Bash(git reset --hard:*)",
      "Edit(code/main/RuoYi-Vue-Plus/ruoyi-common/**)",
      "Edit(code/main/RuoYi-Vue-Plus/ruoyi-modules/ruoyi-system/**)",
      "Write(code/main/RuoYi-Vue-Plus/ruoyi-admin/**)"
    ]
  }
}
```

效果：AI 写业务模块飞快零打断；想动 ruoyi 源码 deny 拦死。

**证据文件**：
- `freelance/projects/dongjiaoshan/.claude/CLAUDE.md`（项目级 6 步循环图）
- `freelance/projects/dongjiaoshan/.claude/settings.json`（完整 allow/deny）
- `freelance/projects/dongjiaoshan/doc/daily/D02/summary.md` "🛠 D02 开工前 D1 漏建追补" 段（自检救场的真实记录）
- `freelance/projects/dongjiaoshan/doc/daily/D02/_open-issues.md`（12 条 raise 真实样本）

---

## 可视化候选（给 PPT/演示用）

### PPT 适合的 3 张图

1. **项目模块图**：5 域并行（养殖/种植/仓库/门店/通用）+ 66 ticket 在 daily/D01-D15 的分布 ← 用 `doc/daily/README.md §2` 的表格直接生成 Mermaid
2. **6 步日循环图**：开工 → AI 跑 → 测试 → standup → closing → 工程自检 ← 直接用 `dongjiaoshan/.claude/CLAUDE.md §2` 已画好的 ASCII 图重绘
3. **防漂移三件套图**：CR（需求漂移）+ OQ（客户待答 Fallback）+ _inflight（并发冲突）三个文件如何在 AI §0 自检里被读取

### 屏幕录制候选（30-60s 片段）

| 片段 | 内容 | 文件定位 |
|---|---|---|
| A | 打开 `D02/README.md` → 复制 `prompts/SYS-MD-001.md` 全文 → spawn → 30s 后 §0 自检报 ✅ → 主任务开跑 | `doc/daily/D02/prompts/SYS-MD-001.md` |
| B | §0 自检在 D02 发现 D1 漏建 3 张表，当场打 patch SQL `V202605210800__D02-PATCH-*.sql` | `script/sql/djs/V202605210800__D02-PATCH-D01-missing-tables.sql` + `D02/summary.md` 抓屏 |
| C | settings.json 的 deny 真实拦截一次（演示 AI 想 Edit ruoyi-system 被拒） | `.claude/settings.json` line 60-83 |
| D | `02-changes.md` 6 张 CR 倒序展示（客户改需求 → CR 落地 → AI 自动按新 schema） | `doc/02-changes.md` |

---

## 反直觉发现 / 失败教训

**1.5 天里被 AI 坑过的瞬间**：
- **D02 §0 自检发现 D01 漏建 3 张表**——AI 写 D01 时口径不一致（summary 写"69 张"实际 66 张）。**学到**：summary 数字必须跟 SQL grep count 对账，不能 AI 自己写多少算多少。
- **`pig_status` vs `current_status` 双字段**（CR-20260519-05）——AI 看到 xlsx + v1.2 两版 schema 高概率两个字段都建。**学到**：废弃字段必须显式写 `grep -ri "pig_status\b"` 必须为空作为验收 SQL。
- **客户 xlsx 末尾追加 2 sheet 没人看到**（CR-20260519-06）——客户 5-19 加的 2 sheet AI 没主动 diff，Kevin 自己核对 origin 才发现。**学到**：客户给的源材料要写 `md5sum` snapshot 进 `origin/_analysis/`，下次 diff 一目了然。
- **MIN-INFRA-001/2/3 估时 8-12h vs 06-实现描述子任务 10-13 人日**——AI 在不同文档里给的估时差一个数量级。**学到**：估时只在一份权威文档（CLAUDE.md 选 daily/README.md），其他文档别再独立估。

**AI 比想象更行的地方**：
- **跨域命名一致性**：69 张表跨 5 域全部按 `t_<domain>_<entity>_<sub>` 命名 + 全部含 `tenant_id VARCHAR(20)` + `del_unique` + 审计字段 6 件套——AI 一次性 SQL 写完，0 人工返工。
- **prompt 模板自更新**：D2 完工 raise 写"字典复用优先"准则，建议进 prompt 模板。下游 D3+ ticket 立刻继承，不重复踩字典重建坑。

**你以为 AI 行其实不行的地方**：
- **业务术语对账**："产品 vs 商品"在养殖/仓库/门店三个域语义略不同，AI 写出来字段都对但语义混了——必须 Kevin 业务 review 5 分钟当场 catch。
- **菜单 id 段分配**：5 个域 + 系统底座 6 段，AI 不会自动协调，必须 CLAUDE.md §6 第 6 条硬编码 `5000-5999 系统 / 7000-7999 养殖 / 8000-8999 种植 / 9000-9999 仓库 / 10000-10999 门店追溯DSH`。

---

## 给 kevin-media 的 talking points（30s 口播 hook 候选）

1. **"我以前不敢一个人接 1.5 个月的大单。这次接了，开干 1.5 天，66 个 ticket 已经做掉 10 个——不是 AI 写得快，是我把'每天怎么干'拆成了 AI 能照着跑的文档。"**

2. **"AI 写代码这事 2024 年就有了。但单人扛大项目卡在哪？卡在'5 个 AI 并行写代码会撞车''客户改需求 AI 不知道''今天写的代码明天 AI 接不上'。我用 5 个文档解决了这三件事——CR、OQ、_inflight、daily README、settings.json。"**

3. **"今天 D02 开工第一件事，AI §0 自检 30 秒发现昨天 D01 漏建 3 张表。如果没这一关，今天 5 个 ticket 全部跑废，我得倒退一天。这就是为什么我宁可让每个 prompt 多花 1 分钟自检。"**

4. **"以前我对'国内 B 端项目'的恐惧是：客户必然改需求。这次我提前写了 `02-changes.md`——客户每改一次，我追加一条 CR，AI 写代码前必读。1.5 天客户改了 6 次需求，0 个 ticket 返工。"**

5. **"重点不是 AI 写代码有多牛，是你能不能让 AI 写的代码'第二天还能接着改'。这考验的不是 AI，是你的工程纪律——文档单一权威源 / 不留中间态 / 每天 closing 必须 merge dev。"**

---

## 合规 / 事实风险

**无显著矛盾**。1.5 天数据真实，下面 3 处需 kevin-media 注意：

1. **"1.5 天 10/66"是真进度但不是"AI 一个人扛"**——团队是 Kevin + 3 全栈，视频口播必须说"派单 + review 是我做，全栈做测试 + 联调"，**不能塑造"我一个人 + AI 干完"的人设**（甲方/朋友圈/同行会反感）。
2. **甲方是国内朋友介绍**，不要在视频里展示甲方真实名字 / 行业 / 地点 / 合同金额。"养殖业 SaaS"是行业类型可说，"东角山"代号也可（已是内部代号非品牌）。
3. **dongjiaoshan 项目仍在进行中**，**M5 全量交付未到**，"成功一个人扛下大项目"目前只能说"开局顺利"，不能说"已经验证可行"。视频结尾留口子：等 D15 跑完再发"完整结案"那期。
