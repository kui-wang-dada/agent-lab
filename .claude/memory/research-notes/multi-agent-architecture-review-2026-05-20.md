# Multi-Agent Architecture Review — agent-lab vs 2026 业界

**调研时间**：2026-05-20
**调研对象**：Kevin 个人 agent-lab 当前 10 agent 架构
**时间窗**：2025 年下半年 — 2026 年 5 月
**整体可信度**：B+（Anthropic 官方 + 多篇技术博客 + arxiv，互相印证；indie hacker 实测样本偏少）

---

## TL;DR（5 条）

1. **Kevin 当前架构在多数维度上已对齐 2026 业界主流**，特别是"按 domain/语言切分 + 共享 memory + curator 周巡"——这些是 Anthropic 官方 blog 明确推荐的做法。
2. **10 个 agent 在业界标准下偏多**——主流建议 3-5 个，但 Kevin 的 10 个里有 5 个是"客户域专属"（upwork/domestic/media/research），属于"清晰可分的业务域"，不是"role-based 拆分"，**不构成 anti-pattern**。
3. **唯一可能真值得动的地方**：`kevin-router` (sonnet) 是否多余——Anthropic 官方明确说"路由本身应该是主线程的轻量职责，不需要专门 agent"。可考虑合并到主线程。
4. **学习闭环（SubagentStop hook + curator 周巡）走在前面**——业界 2026 才开始讨论"如何让 agent 自我演化"，Kevin 的实现已经接近 Hermes Agent v0.10 的 GEPA 机制（虽然简化版）。
5. **不要做的事**：不要引入 LangGraph/CrewAI 类编排框架，不要拆分 dev 层（"3 个夹心心智模式"是对的），不要把 memory 改成向量库（async write + multi-signal retrieval 在 Kevin 量级下是过度设计）。

---

## 外部对标表

| 维度 | 业界 2026 主流做法 | Kevin 当前 | 评估 |
|---|---|---|---|
| **主 agent 数量** | 3-5 个（productivity 拐点在 4 个） | 10 个 | 看下文分析（不一定是问题） |
| **拆分原则** | context-centric > role-based（Anthropic 官方）| 客户域 + 心智模式（context-centric） | ✅ 已对齐 |
| **dev 层拆分** | 反对 plan→code→test 流水线拆分，赞成"一个 agent 拥有完整 feature 的 context" | coder 一体（fe+be+架构合并）| 🟢 我们做得更好（很多人还在拆 fe/be）|
| **memory 三层** | episodic / semantic / procedural（mem0 2026）| facts(semantic) + learnings(procedural) + session(episodic 走 ccd_session) | ✅ 已对齐 |
| **memory 共享** | 业界没有共识，多数 agent 独占 | dev 类共享 kevin-dev/，其他独占 | 🟢 我们做得更好（dev 共享 + 业务域独占是合理 trade-off） |
| **学习闭环** | Hermes v0.10 GEPA、AutoSkill、MemSkill (arxiv 2026)，业界刚刚起步 | SubagentStop hook → _review-queue → curator 周巡 | ✅ 已对齐，简化但能跑 |
| **CLAUDE.md 长度** | <200 行，Boris Cherny 自己 ~100 行 | 当前约 180 行 | ✅ 刚好压线 |
| **router 是否独立 agent** | Anthropic 说 routing 是 orchestrator 主线程的职责，不该是单独 agent | kevin-router (sonnet) 独立 | ⚠️ 值得考虑 |
| **Skills vs Subagents 边界** | skills = 短任务/继承父 context；subagents = 长任务/隔离 context | 当前体系混用（hook 触发 skill；agent 有自己的 skills 目录）| ✅ 已对齐 |
| **是否引入编排框架** | LangGraph 给"production 级状态机"，个人/solo 用 Claude Code 原生 | Claude Code 原生 | ✅ 已对齐（不要引入 LangGraph）|
| **agent 间通信** | Anthropic 警告"agents 中途不能通信"是限制 | 不依赖中途通信，结果通过 markdown 沉淀 | ✅ 已对齐 |
| **MCP 集成** | 2026 标准做法 | 已用 ccd_session_mgmt | ✅ 已对齐 |
| **测试 agent 单独** | 多数推荐独立 | qa 独立（sonnet） | ✅ 已对齐 |
| **designer 独立** | 业界少见，多数把 UI 拆到 frontend | 独立 kevin-designer | 🟢 我们做得更好（设计 → 编码前的视觉拍板层很关键）|

---

## 具体优化建议（按优先级）

### P0 — 真值得改的（仅 1 条）

#### P0-1：评估 `kevin-router` 是否合并进主线程

**问题描述**：业界共识是 routing 属于 orchestrator/主线程的"轻量职责"——Anthropic 官方多次强调"避免为 routing 单独起 agent，会增加 token 开销和 3-5 秒启动延迟"。Kevin 现在的 router 用 sonnet 跑，每次路由要付出一次 subagent spawn 的成本。

**改动方案**（二选一）：
- **方案 A（推荐）**：删掉 kevin-router，把它的路由逻辑直接嵌入 CLAUDE.md 主线程"路由约定"段（其实已经有了——见 CLAUDE.md L57-82 路由表）。主线程读 @前缀就派单，没前缀的含糊消息直接派 `kevin-assistant`，由 assistant 自己识别要不要再转派。
- **方案 B**：保留 router 但只在"含糊消息 + 主线程不确定"时调用（罕见场景），不是默认入口。

**理由**：
- 路由决策的认知成本对 sonnet 是大材小用，主线程 opus 直接读路由表 30 token 内搞定
- 减少一次 subagent spawn 延迟（3-5s + 几百 token）
- 9 个 agent 是更接近业界推荐区间的数字
- 来源：Anthropic multi-agent blog 明确指出 "verification/routing subagents should be used sparingly"

**预估改动成本**：30 分钟

**风险**：低。如果发现主线程派单错误率上升，1 分钟可以加回来。

**状态**：2026-05-20 已采纳方案 A，落地中。

---

### P1 — 可以考虑的（不紧急）

#### P1-1：给 procedural memory（learnings.md）加"过期/衰减"机制

**问题描述**：mem0 2026 报告指出业界 #1 production gap 是"memory staleness"——高频检索的记忆会变成"confidently wrong"。Kevin 的 `learnings.md` 现在是 append-only，没有衰减/重审机制。

**改动方案**：
- curator 周巡时，对超过 90 天没被引用的 learnings 条目做一次重审，决定"保留 / 归档 / 删除"
- 每条 learning 加一个 `last_used: YYYY-MM-DD` 字段（agent 引用时自动更新——但这需要 hook 支持，可能太重）
- **轻量版**：curator 周巡只做"读一遍最老的 5 条，问 Kevin 还有效吗"

**理由**：
- 业务进展快，3 个月前的 learning 可能基于已经废弃的 Cowork 配置
- 不做的话，agent 会被旧经验带偏

**预估改动成本**：1 小时（curator 周巡 prompt 改）

---

#### P1-2：让 SubagentStop hook 更结构化地记录 metadata

**问题描述**：当前 `_review-queue/` 是"把 metadata 写入 queue"，curator 周巡时批量看。但根据 Hermes Agent v0.10 的 GEPA 机制，更好的做法是 hook 时就给每条记录打"可泛化分数"——curator 只看高分的。

**改动方案**：
- `subagent-stop.sh` 里加一个 LLM 调用（用 haiku，~$0.001/次），给每次 session 打一个 0-10 的"可泛化分"
- queue 文件名带分数，curator 只看 score >= 7 的

**理由**：周巡负担会越来越重，预筛能节省 curator 上下文

**预估改动成本**：2 小时

**反对方**：可能是"过早优化"。如果 _review-queue/ 当前一周不超过 20 条，curator 看得完，就别加这个。

---

### P2 — 写下来但建议不做

#### P2-1：拆分 `kevin-coder` 为前端/后端

**业界证据**：很多 2026 文章还在按 fe/be 拆

**为什么不做**：Anthropic 官方明确反对 phase-based decomposition（"planning → implementation → testing"是 anti-pattern），context-centric 才对。Kevin 的"全栈 + 自行 spawn 并行 subagent"已经是更先进的做法。**保持现状**。

---

#### P2-2：引入 LangGraph 做状态机编排

**业界证据**：LangGraph 2026 是 production-grade 编排首选

**为什么不做**：LangGraph 是给"团队规模化 + 需要严格状态机回放"的场景，Kevin 是 solo + Max 订阅 + Claude Code 原生工作流，引入只会增加心智负担。**保持现状**。

---

#### P2-3：把 memory 改成向量数据库

**业界证据**：mem0、Zep、Letta 等都用向量库做语义检索

**为什么不做**：
- Kevin 当前 memory 总量 < 100 个 markdown 文件，grep + filename convention 完全够用
- Claude Code 的 Read/Glob 本质上是更智能的"语义检索"（LLM 自己决定读哪个文件）
- 向量库带来部署/迁移负担，violates "默认极简" 原则
- **保持现状**

---

#### P2-4：合并 designer 到 coder

**业界证据**：多数小团队没有 designer 这层

**为什么不做**：Kevin 反复在 CLAUDE.md 强调"designer 是写代码前的视觉拍板层"，这是踩过坑的产物。海外客户对视觉敏感，留着是对的。**保持现状**。

---

## 不建议改的地方（明确"别动"清单）

| 看起来可优化的地方 | 为什么别动 |
|---|---|
| 10 个 agent 偏多 | 5 个是"业务域专属"（不是 role 拆分），符合 context-centric 原则 |
| 客户按"语言"切而非"平台" | 这是基于 Kevin 实战的设计，业界没人讨论过这个维度，但符合"context-centric"逻辑 |
| dev 共享 memory、其他独占 | 是经过思考的 trade-off，不是 bug |
| 主线程不直接执行 | Anthropic 官方推荐的"orchestrator-worker"模式，对 |
| facts / learnings / USER.md 三件套 | 对应 mem0 的 semantic/procedural/episodic 三类，已经对齐 |
| curator 周日 21:30 跑 | 时间无所谓，机制本身是对的 |
| Skills 在项目级 + 全局级两层 | Anthropic 官方推荐做法，对 |

---

## 总结建议

**真正要做的事**：只有 1 条 P0（评估删 kevin-router）。✅ 2026-05-20 已落地。

**可以观察一段时间再决定的**：2 条 P1（learnings 衰减 + SubagentStop 预筛），等遇到"agent 用错过期 learning"或"curator 周巡看不完"的痛点时再做。

**永远别做的**：拆 coder / 引入 LangGraph / 换向量库 / 合并 designer。

**核心结论**：Kevin 当前架构在 2026 业界标准下处于第一梯队——尤其是"context-centric 拆分"、"dev 全栈不拆 fe/be"、"hook + curator 学习闭环"这三点，很多博客文章里都还在"建议这样做"，Kevin 已经在做了。继续保持"默认极简"的判断力，不要被"业界又出新框架了"焦虑拉走。

---

## Sources

- [Anthropic — Building Multi-Agent Systems: When and How](https://claude.com/blog/building-multi-agent-systems-when-and-how-to-use-them)
- [Anthropic — Building a Multi-Agent Research System (ZenML)](https://www.zenml.io/llmops-database/building-a-multi-agent-research-system-for-complex-information-tasks)
- [Anthropic — Building Effective AI Agents](https://resources.anthropic.com/building-effective-ai-agents)
- [Nimbalyst — Claude Code Subagents Practical 2026 Guide](https://nimbalyst.com/blog/claude-code-subagents-guide/)
- [Developers Digest — Claude Code Agent Teams 2026 Playbook](https://www.developersdigest.tech/blog/claude-code-agent-teams-subagents-2026)
- [obviousworks — Designing CLAUDE.md correctly: 2026 architecture](https://www.obviousworks.ch/en/designing-claude-md-right-the-2026-architecture-that-finally-makes-claude-code-work/)
- [Hermes Agent 2026 — First Production-Ready Self-Improving Open-Source AI Agent (innobu)](https://www.innobu.com/en/articles/hermes-agent-self-improvement-open-source-2026.html)
- [Hermes Agent v0.10 Review (TokenMix)](https://tokenmix.ai/blog/hermes-agent-review-self-improving-open-source-2026)
- [mem0 — State of AI Agent Memory 2026](https://mem0.ai/blog/state-of-ai-agent-memory-2026)
- [Towards Data Science — Why Your Multi-Agent System is Failing](https://towardsdatascience.com/why-your-multi-agent-system-is-failing-escaping-the-17x-error-trap-of-the-bag-of-agents/)
- [The AI Architects — Subagents vs Skills](https://theaiarchitects.com/blog/claude-code-subagents-vs-skills)
- [DataCamp — CrewAI vs LangGraph vs AutoGen](https://www.datacamp.com/tutorial/crewai-vs-langgraph-vs-autogen)
- [Claude Code Docs — Sub-agents](https://code.claude.com/docs/en/sub-agents)
- [Claude Code Docs — Hooks reference](https://code.claude.com/docs/en/hooks)
- [arxiv — MemSkill: Learning and Evolving Memory Skills](https://arxiv.org/abs/2602.02474)
- [arxiv — AutoSkill: Experience-Driven Lifelong Learning](https://arxiv.org/html/2603.01145v2)
- [arxiv — Interpretable Context Methodology (folder-as-architecture)](https://arxiv.org/html/2603.16021v2)
