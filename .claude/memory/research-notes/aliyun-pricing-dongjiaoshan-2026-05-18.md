# 阿里云采购报价（东角山项目）— Research Brief

**调研日期**：2026-05-18
**时间窗**：当前实时（2026 年）
**深度**：完整采购清单（已落地为项目文档 04-阿里云采购清单.md）
**整体可信度**：B —— ECS/RDS/SMS/OSS/域名/SSL 多源印证（A），Redis 详细价格单源待验（C）

## TL;DR

- ECS 经济型 e 2C2G 99 元/年特惠 + RDS MySQL 倚天 1C2G 88 元/年 + Redis 标准版高可用 256M 72 元/年 = 测试环境年成本约 ¥400-700。
- 生产环境：c9i 4C8G ¥3147-3459/年 + RDS HA 2C4G ¥3888/年 + Redis 双副本 1G + OSS 500G 资源包 ¥118.99/年 = 首年约 ¥7400-7700。
- 关键风险：ICP 备案 20 工作日，**生产上线前 4 周必须启动**，且必须用甲方主体。

## 关键事实

| 事实 | 数值 | 来源 | 可信度 |
|---|---|---|---|
| ECS 经济型 e 2C2G 3M 40G | ¥99/年 续费同价 | aliyun.com/product/ecs 首屏 | A |
| ECS 经济型 e 4C16G | ¥860/年 | developer.aliyun 1712513 | A |
| ECS 通用算力 u1 2C4G 5M 80G（企业） | ¥199/年 续费同价 | aliyun.com/product/ecs 首屏 | A |
| ECS c9i 4C8G | ¥3147.56-3459/年 活动价 | developer.aliyun 1704169 | B |
| RDS MySQL 基础倚天 1C2G 50G | ¥88/年 续费同价 | developer.aliyun 1708069 | A |
| RDS MySQL 高可用版 2C4G 50G | ¥3888/年 | aliyunbaike.com/database/9337 + WebSearch 印证 | B |
| RDS MySQL 集群版 2C4G 100G | ¥4003.2/年 | developer.aliyun 1690100 | B |
| Redis 标准版高可用 256MB | ¥72/年（2026-03-31 活动延续） | aliyun.com/product/tair 首屏 | A |
| Redis 经济版 2GB 倚天 | 首年 2.66 折 | developer.aliyun 1708069 | A |
| OSS 标准存储本地冗余 | ¥0.12/GB/月 | help.aliyun.com OSS 计费 | A |
| OSS 资源包 500GB/年 | ¥118.99 | 新浪转载 OSS 文档 | B |
| SMS 国内验证码 ≤10w/月 | ¥0.045/条（2026-05-20 新价） | help.aliyun SMS 公告 2604 | A |
| 域名 .com 首年+续费 | ¥85 | wanwang.aliyun.com/domain | A |
| 域名 .cn | ¥38 | 同上 | A |
| ICP 备案 | 免费，23-24 工作日 | beian.aliyun.com | A |
| SSL 免费 DV 单域名 | 0 元，每年 20 张额度，3 月有效自动续 | developer.aliyun 1713842 | A |
| SSL 付费 DV 通配符 | ¥1500/年（DigiCert） | 同上 | A |

## 趋势 / 解读（推断）

- 阿里云对新用户的"99 元 / 88 元 / 72 元"档常年开放，是获客款，**不抢也能买到**——这是稳定的可规划成本。
- 生产档 RDS 高可用版 ¥3888 才是真实生产基线（不是 ¥88 那种新用户首年特惠）。**别被新用户特惠误导生产预算**。
- 2026-05-20 起 SMS 加价（之前传 0.035-0.04），但 0.045 元/条仍处国内市场中位水平。

## 矛盾 / 待验证

- Redis 1G/2G 双副本精确年付价：官网首屏不展示，**必须到控制台询价**。文档中给的 ¥80-100/月是行业经验估算，不是官网拿到的数字。
- ECS c9i 4C8G 价格区间 ¥3147-3459 来自不同来源（c9i 实测文 vs 早期定价），下单时以实际控制台为准。

## 给 Kevin 的建议（非决策）

1. **今天就让甲方主体注册阿里云账号 + 实名 + 启动 ICP 备案**——这是关键路径，不动会拖死生产上线。
2. **测试环境一次性下单 99+88+72+域名共 ¥400 内**，省去后期反复审批。
3. **生产 ECS 不要省，c9i 4C8G 比经济型 e 贵 4 倍但工作流引擎 + 50 人不会卡**。
4. **Redis 测试用 256M 特惠，生产先 1G 包月跑 1-2 月看用量再切年付**——这是最稳的"先试再锁"路径。
5. **签名审核用甲方主体**，不要 Kevin 个人——生产切换签名要重审。

## 沉淀给后续调研的方法

- 阿里云产品介绍页（aliyun.com/product/xxx）会 302 到 cn.aliyun.com，**优先用 cn.aliyun.com 直接访问**节省一次往返。
- 详细价格在 aliyun 帮助文档 / developer 社区 文章里反而比官网产品页更全（产品页只展示首屏特价，深度规格价格藏在控制台）。
- Redis / RDS 这类"配置组合多"的产品，下单前必须用控制台**配置询价**——首屏价格永远只是引流款。

## 来源全列表

- [aliyun.com/product/ecs](https://cn.aliyun.com/product/ecs?from_alibabacloud=) — 抓取 2026-05-18 — A
- [aliyun.com/product/tair](https://cn.aliyun.com/product/tair?from_alibabacloud=) — A
- [wanwang.aliyun.com/domain](https://wanwang.aliyun.com/domain/) — A
- [beian.aliyun.com](https://beian.aliyun.com/) — A
- [help.aliyun.com SMS 调价公告 2604](https://help.aliyun.com/zh/sms/product-overview/notice-on-price-adjustment-for-domestic-sms-services-2604) — A
- [developer.aliyun.com 1712513 ECS 年付](https://developer.aliyun.com/article/1712513) — A
- [developer.aliyun.com 1708069 数据库特惠](https://developer.aliyun.com/article/1708069) — A
- [developer.aliyun.com 1713842 SSL 价格](https://developer.aliyun.com/article/1713842) — A
- [developer.aliyun.com 1690100 RDS 价格](https://developer.aliyun.com/article/1690100) — B
- [developer.aliyun.com 1704169 c9i 实测](https://developer.aliyun.com/article/1704169) — B
- [aliyunbaike.com/database/9337](https://www.aliyunbaike.com/database/9337/) — B
- [aliyunfuwuqi.com/jiagebiao](https://aliyunfuwuqi.com/jiagebiao/) — B
- [新浪转载 OSS 价格](https://cj.sina.com.cn/articles/view/7879848900/1d5acf3c401902tgmg) — B

## 产出文件

主清单：`~/Project/profile/project/freelance/projects/dongjiaoshan/doc/04-阿里云采购清单.md`
