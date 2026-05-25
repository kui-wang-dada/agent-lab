# 东角山数据库选型调研 — 索引

**调研日期**：2026-05-18
**类型**：技术选型决策
**项目**：freelance/projects/dongjiaoshan
**整体可信度**：A（多源印证）

## 一句话结论

**保持 MySQL 8，不切 PG**。若依对 PG 是平等支持但东角山 V1 所有 PG 加分场景都不命中，团队栈匹配 + 甲方未来自维护强 lock-in MySQL。

## 完整报告位置

`~/Project/profile/project/freelance/projects/dongjiaoshan/code/main/docs/数据库选型调研.md`（4000+ 字，7 大段 + 决策矩阵）

## 关键事实速查

| 事实 | 数值 / 描述 | 来源 |
|---|---|---|
| 若依 4 方言 SQL 同步更新 | 同一 commit `2026-01-12 09:17:39`（含 MySQL/PG/Oracle/SQLServer）| 项目 git log |
| 框架抽象层 | `DataBaseHelper.findInSet` 内置 4 方言 switch case | DataBaseHelper.java |
| PG 配置切换成本 | application-dev.yml + pom.xml 各取消一段注释 | 项目源码 |
| 阿里云 RDS 价差（同规格 2C4G）| MySQL ¥3888/年 vs PG ¥4176/年（+7.4%） | aliyun |
| 国内 MySQL:PG 装机比 | 10:1 到 5:1 | vonng.com / 阿里云 RDS 负责人披露 |
| MySQL 8 JSON vs PG JSONB 性能差 | PG 快 3-4x（但项目内 JSON 用量小绝对值无感） | tech-insider.org |
| MySQL 8 GIS | InnoDB 原生支持 R 树索引 + ST_Distance 等 | mysql.taobao.org |
| 若依多租户实现 | **应用层** MyBatis 拦截器，跟 DB 选型无关 | 项目代码 + iocoder.cn 文档 |

## 给 Kevin 的 3 个动作项

1. **本周**：在 `00-brief.md §4` 加一行决策记录 + 通知兼职用 MySQL
2. **5/17 饭局**：不主动提 DB 选型，被问时统一口径"用 MySQL 8，未来换 PG / 国产化代码层基本不用动"
3. **Phase 1 后**：在技术方案里加"DB 演进策略"段，沉淀决策

## 沉淀给其他 agent 的 takeaway

- 若依框架对 PG 是 first-class 支持，遇到 RuoYi-Vue-Plus 项目时不要默认"只能 MySQL"
- 但反过来"切 PG 享 PG 优势"在大多数若依小项目里**不成立**——业务场景命中度低 + 团队栈成本
- 类似选型问题应该按"V1 真实业务命中度 vs 切换成本 + 团队栈 + 甲方维护"四个维度评分，**不能用"PG 功能强大"这种口号决策**

## 沉淀给后续调研的方法

- 框架对某 DB 的支持度 = 看 4 个层面：SQL 脚本同步度 / 框架抽象层封装 / 代码生成器模板 / pom+yml 切换便利
- 业务场景命中判断要**逐项**对照需求拆解，不能泛泛而谈"以后可能用到"
- 价格 / 招聘 / 维护团队这三个"软"维度往往是决策的隐藏权重
