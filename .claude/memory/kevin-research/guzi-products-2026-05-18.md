# 谷子宇宙真实商品资料 — 2026-05-18

> 给 sensenran-guzi 项目 mockup 替换 emoji 占位图用。
> 调研人：kevin-research（asynchronous）

---

## 1. 客户自家账号定位结果

| 平台 | 状态 |
|---|---|
| 小红书 | 通过搜索引擎未找到（SPA 不被 Google 索引，不等于不存在） |
| 抖音 | 同上 |
| 微信小程序 | 未上线（本项目就是要做的） |
| 西安小寨银泰入驻 | 已通过赢商网印证（2025-03） |
| 成都门店 | 公开媒体未印证 |

**强建议 Kevin 做 10 分钟动作**：微信问森森老师要小红书/抖音 URL +「我授权你用我们门店和商品照片做设计稿」一句话存档。

模板：
> "森森老师，想把设计稿做得跟你家店里实际感觉一致。麻烦发我你们小红书/抖音主页链接，我截几张店里现场和热销商品图放设计稿。"

---

## 2. 兜底素材（14 张，CHIIKAWA × 三丽鸥官方授权）

- **图源**：[Chiikawa Market 中文官方站](https://chiikawamarket.jp/zh-hans/)（Shopify 系统）
- **抓取方式**：Shopify 公开 `products.json` API
- **本地路径**：`agent-lab/.claude/memory/kevin-research/assets/guzi-products/chiikawa-sanrio/`

| 文件名 | 商品名 | IP | 类型 | 售价 |
|---|---|---|---|---|
| `keychain-melody.jpg` | 成对钥匙扣 古本屋 × 美乐蒂 | CHIIKAWA × 三丽鸥 | 钥匙扣 | ¥1408 |
| `keychain-kuromi.jpg` | 成对钥匙扣 飞鼠 × 酷洛米 | CHIIKAWA × 三丽鸥 | 钥匙扣 | ¥1408 |
| `keychain-pudding.jpg` | 成对钥匙扣 乌萨奇 × 布丁狗 | CHIIKAWA × 三丽鸥 | 钥匙扣 | ¥1408 |
| `keychain-kitty.jpg` | 成对钥匙扣 哈奇喵 × 凯蒂猫 | CHIIKAWA × 三丽鸥 | 钥匙扣 | ¥1408 |
| `keychain-cinnamoroll.jpg` | 成对钥匙扣 吉伊卡哇 × 大耳狗 | CHIIKAWA × 三丽鸥 | 钥匙扣 | ¥1408 |
| `penholder-yellow.jpg` | 旋转笔筒 黄色 | CHIIKAWA × 三丽鸥 | 文具 | ¥1980 |
| `box-yellow.jpg` | 收纳盒 黄色 | CHIIKAWA × 三丽鸥 | 文具 | ¥2178 |
| `charger-melody.jpg` | Type-C 充电宝 古本屋 & 美乐蒂 | CHIIKAWA × 三丽鸥 | 数码周边 | ¥5478 |
| `badge-cookie-set.jpg` | 刺绣徽章饼干食玩 2（13种盲盒） | CHIIKAWA | 徽章/盲盒 | ¥4620 |
| `badge-frame-set.jpg` | 吉伊卡哇乐园 画框徽章套装 | CHIIKAWA | 徽章 | ¥5000 |
| `badge-baby-set.jpg` | Chiikawa Baby 玩偶脸型徽章套装 | CHIIKAWA | 徽章 | ¥2640 |
| `badge-horse-set.jpg` | 变身马玩偶徽章套装 | CHIIKAWA | 徽章 | ¥2640 |
| `plush-bat.jpg` | 大家一起变装挂件 蝙蝠古本屋 | CHIIKAWA | 毛绒 | ¥1980 |
| `plush-shisa.jpg` | 大家一起变装挂件 巴风特狮萨 | CHIIKAWA | 毛绒 | ¥1980 |

**API 自助补图**（无需鉴权）：
```bash
curl -sL "https://chiikawamarket.jp/zh-hans/collections/sanriocharacters/products.json?limit=50"
curl -sL "https://chiikawamarket.jp/zh-hans/collections/badge/products.json?limit=50"
curl -sL "https://chiikawamarket.jp/zh-hans/collections/nuigurumi/products.json?limit=50"
```

---

## 3. 版权判断

| 场景 | 风险 | 建议 |
|---|---|---|
| mockup 给客户提案看 | 极低 | 加 "Mockup Only" 水印即可 |
| mockup 在 Kevin 简历/案例集公开展示 | 中 | 全部模糊或替换 |
| 上线真实小程序 | 低（前提：客户提供） | 必须客户自家实拍图，Kevin 不承担选图责任 |

**客户小红书/抖音照片能用吗**：能。先在微信里让客户明确说"我授权你用我们门店和商品照片做设计稿"（截图存档）；优先用"商品摆在他们家货架上拍的"照片，避免用 IP 方官方素材。

---

## 4. 给 designer 的替换建议（按页面权重）

### home.html（首屏，最重要）
- 主 Banner 右侧叠加 `keychain-melody.jpg` 或 `badge-cookie-set.jpg` 半透明
- "扭蛋"入口小图 → `badge-frame-set.jpg`
- "预购"入口小图 → `plush-bat.jpg`
- 商品瀑布流 4 个：`keychain-kuromi.jpg` / `badge-baby-set.jpg` / `box-yellow.jpg` / `keychain-cinnamoroll.jpg`

### gacha-list.html / gacha-detail.html
- 扭蛋机大图 → `penholder-yellow.jpg`（旋转笔筒造型最接近扭蛋机）
- 奖品池 6 格 SSR/SR/R → 6 张钥匙扣 + `badge-horse-set.jpg`

### preorder-list.html
- 3 个预购大卡片 → `plush-shisa.jpg` / `plush-bat.jpg` / `charger-melody.jpg`（恰好都是预售标的，语境匹配）

### me-collection.html / admin 后台
- **不动**。现有纯色块/表格设计已经够精致

### 兜底色块（咒术/魔法少女/蜡笔小新等没拿到 API 的 IP）
- 圆角方块 + 主色调（紫=咒术、黄=蜡笔小新、粉=魔法少女）+ IP 缩写 + 简单 SVG 剪影
- 比 emoji 精致且 100% 无版权风险

---

## 5. 沉淀（未来调研复用）

1. **国内 UGC 平台 site: 语法无效**：小红书/抖音/B 站内容全在 JS 渲染后，Google/Bing 不索引。**不要在搜索引擎上耗时间**，让用户/客户直接给账号 URL
2. **Shopify 万能后门**：任何 Shopify 商城都有 `/collections/<handle>/products.json` 公开端点，能直接拿结构化商品数据。判断方式：看页面 HTML 有没有 `cdn.shopify.com` 引用
