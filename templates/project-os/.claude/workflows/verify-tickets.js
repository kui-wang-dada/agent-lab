export const meta = {
  name: 'verify-tickets',
  description: '对某一天完工的 ticket 做对抗式验收验证：每个 ticket 派一个 fresh-context 审查者，逐条尝试 REFUTE 验收 checkbox，报告未通过项。SP2 验证骨干 #5（异构 fresh-context 预审）。硬边界：只验证、给报告，人仍然 commit——这是放大 review 带宽，不替代人签字。',
  phases: [
    { title: 'Discover', detail: '列出当天完工 ticket + 各自验收 checkbox' },
    { title: 'Verify', detail: '每 ticket fresh-context 逐条 refute（并发≤16）' },
  ],
}

// 用法：Workflow({ scriptPath: '.claude/workflows/verify-tickets.js', args: { day: 3 } })
// args 可传 {day:3} / 3 / "3"
const DAY = (args && args.day != null) ? args.day : args
if (DAY == null) throw new Error('需传入 day，例如 args: { day: 3 }')

const TICKET_SCHEMA = {
  type: 'object',
  properties: {
    tickets: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          ticket_id: { type: 'string' },
          files: { type: 'array', items: { type: 'string' }, description: '该 ticket 改动涉及的关键文件' },
          checkboxes: { type: 'array', items: { type: 'string' }, description: '该 ticket 在 acceptance-checkboxes.md 里的验收条目原文' },
        },
        required: ['ticket_id', 'files', 'checkboxes'],
        additionalProperties: false,
      },
    },
  },
  required: ['tickets'],
  additionalProperties: false,
}

const VERDICT_SCHEMA = {
  type: 'object',
  properties: {
    verdicts: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          checkbox: { type: 'string' },
          status: { type: 'string', enum: ['satisfied', 'refuted', 'unverifiable'] },
          evidence: { type: 'string', description: '支持该裁决的具体反证/证据（文件:行 / SQL结果 / 运行时现象）' },
        },
        required: ['checkbox', 'status', 'evidence'],
        additionalProperties: false,
      },
    },
  },
  required: ['verdicts'],
  additionalProperties: false,
}

phase('Discover')
const discovered = await agent(
  `读本项目 daily/D${DAY}/reports/ 下所有完工报告（每个 reports/<id>.md = 一个已完工 ticket）。对每个 ticket 列出：ticket_id、改动涉及的关键文件、以及该 ticket 在 doc/authority/acceptance-checkboxes.md 里对应的全部验收 checkbox（逐条原文，含验收 SQL）。只列真有 reports/<id>.md 的。`,
  { label: `discover:D${DAY}`, phase: 'Discover', schema: TICKET_SCHEMA }
)

const tickets = (discovered && discovered.tickets) ? discovered.tickets : []
log(`D${DAY} 完工 ${tickets.length} 个 ticket` + (tickets.length ? '，逐个对抗式验证' : '，无可验证项'))

phase('Verify')
const results = tickets.length
  ? await parallel(tickets.map((t) => () =>
      agent(
        `你是一个**全新上下文**的对抗式验收审查者，不带实现者偏见。目标：尝试 REFUTE ticket ${t.ticket_id} 的每一条验收 checkbox——逐条去代码 / DB / 运行时找反证（字段没真写、状态没真改、边界没覆盖、越权或租户串数据、只编译过但跑不起来、报告自我声明与实现不符）。\n\n` +
        `验收 checkbox：\n${t.checkboxes.map((c, i) => `${i + 1}. ${c}`).join('\n')}\n\n` +
        `涉及文件：${t.files.join(', ')}\n\n` +
        `逐条裁决：satisfied（有据可查确实满足）/ refuted（找到明确反证）/ unverifiable（查不到证据、存疑）。**默认对存疑取 unverifiable，不要轻信报告的自我声明**。evidence 写具体到 文件:行 / SQL 结果 / 运行时现象。`,
        { label: `verify:${t.ticket_id}`, phase: 'Verify', schema: VERDICT_SCHEMA }
      ).then((v) => ({ ticket_id: t.ticket_id, verdicts: (v && v.verdicts) ? v.verdicts : [] }))
    ))
  : []

const flat = results.filter(Boolean)
const problems = flat.flatMap((r) =>
  (r.verdicts || [])
    .filter((v) => v.status !== 'satisfied')
    .map((v) => ({ ticket: r.ticket_id, checkbox: v.checkbox, status: v.status, evidence: v.evidence }))
)

log(`验证完成：${flat.length} 个 ticket，${problems.length} 条 checkbox 未通过对抗式验证（refuted / unverifiable）。人据此决定是否 merge——workflow 不替你 commit。`)
return { day: DAY, tickets_checked: flat.length, problems }
