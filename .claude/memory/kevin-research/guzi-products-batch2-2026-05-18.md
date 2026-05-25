# 谷子宇宙真实商品资料 — 第二批（更多 IP）— 2026-05-18

> 第一批是 CHIIKAWA × 三丽鸥 14 张（见 `guzi-products-2026-05-18.md`），本批是其他二次元 IP 40 张。
> 整体可信度：B（Amazon JP 商品页 hero shot，版权各归商品制造商）

---

## TL;DR

- **40 张新图**，覆盖 mockup 点名的 4 个 IP + 加分的 4 个国内主流 IP
- **唯一成功源：Amazon Japan**（AliExpress / Bing / 百度 / DuckDuckGo / Hpoi / Shopify 全被反爬封）
- 命名：`<slug>/<slug>-NN.jpg`
- 路径：`agent-lab/.claude/memory/kevin-research/assets/guzi-products/<ip>/`

---

## 1. 各 IP 抓取结果汇总

| IP | 张数 | 体积 | 图源 | 版权归属 | mockup 优先级 |
|---|---|---|---|---|---|
| 咒术回战 jjk | 5 | 620KB | Amazon.co.jp | 集英社/MAPPA/授权方 | 第一 |
| 魔法少女小圆 madoka | 3 | 376KB | Amazon.co.jp | Magica Quartet/Aniplex/Shaft | 第一 |
| 蜡笔小新 crayon-shinchan | 5 | 416KB | Amazon.co.jp | 双叶社/新创华 | 第一 |
| 原神 genshin | 5 | 752KB | Amazon.co.jp | miHoYo/HoYoverse | 加分 |
| 鬼灭之刃 demon-slayer | 5 | 480KB | Amazon.co.jp | 集英社/Aniplex/ufotable | 加分 |
| 间谍过家家 spyfamily | 5 | 520KB | Amazon.co.jp | 集英社/WIT×CloverWorks | 第一 |
| 蓝色监狱 bluelock | 5 | 1128KB | Amazon.co.jp | 讲谈社/8bit | 加分 |
| 日漫经典 classic | 7 | 980KB | Amazon.co.jp | ONE PIECE / 哆啦A梦 / NARUTO 各方 | 第一（笼统标签） |

> classic/ 混抓 ONE PIECE × 3、哆啦 A 梦 × 2、NARUTO × 2，对应 mockup 里"日漫经典"标签

---

## 2. 商品清单（每 IP 关键文件）

### jjk/（咒术回战）
- `-01` アクリル五条悟系列 / `-02` 立体周边 / `-03` フィギュア / `-04` 缶バッジセット / `-05` ぬいぐるみ

### madoka/（魔法少女小圆）
- `-01` アクリルスタンド / `-02` 主角立牌 / `-03` 系列周边

### crayon-shinchan/（蜡笔小新）
- `-01` 经典ぬいぐるみ ★主推 / `-02-03` 立体/小毛绒 / `-04-05` 亚克力挂件

### genshin/（原神）
- `-01-02` アクリル立牌 / `-03` 角色周边套 / `-04` ぬいぐるみ大图 / `-05` 缶バッジ

### demon-slayer/（鬼灭之刃）
- `-01-02` アクリル单角 / `-03` 立体大图 / `-04-05` 毛绒/挂件

### spyfamily/（间谍过家家）
- `-01-02` アーニャ亚克力立牌 / `-03` 周边套 / `-04` ぬいぐるみ / `-05` 缶バッジ

### bluelock/（蓝色监狱）
- `-01` アクリル主角 / `-02-03` 徽章/毛绒 / `-04-05` **凪/潔系列高清 396-399KB ★大图**

### classic/（日漫经典）
- `-01-02` **ONE PIECE ルフィ 246-256KB ★最高清** / `-03` ONE PIECE 周边 / `-04-05` ドラえもん / `-06-07` NARUTO

---

## 3. 给 designer 的优先替换位

mockup 里出现 IP 的文件：home / gacha-list / gacha-spark-shop / gacha-detail / news-list / news-detail / me-collection / order-list / order-confirm / preorder-list / pay-result / admin-dashboard / admin-orders / admin-products

| Mockup 位置 | 用图建议 |
|---|---|
| 首页主推位 | 各 IP 的 **-01.jpg**（最具代表性） |
| 抽盲盒列表/详情 | jjk-01/02、madoka-02、spyfamily-01（看着像盲盒的 acrylic 类） |
| 商品详情主图 | classic-01（ONE PIECE 256KB 最大最清，适合压头） |
| 列表小图/订单缩略图 | 各 IP **-04/-05**（小尺寸够用） |
| 公告/Banner | classic-01（ONE PIECE 立绘）、bluelock-04（凪/潔高清） |
| me-collection 用户已购 | 杂用各 IP 小图模拟多样性 |

**替换规则**：
1. 同一商品在不同流程页**复用同一张图**——让客户能识别"这是同一商品的订单/详情/支付"
2. 首页/抽盲盒/详情 → 用 -01（高清代表）
3. 列表/订单缩略 → 用 -04/-05（小尺寸）
4. 真实商品图右下角加 "Mockup Only" 半透明角标（沿用第一批 designer 已做的样式）

**当前 mockup 兜底色块位置（优先替换）**：
- `home.html`：商品瀑布流 2、3 位
- `preorder-list.html`：商品 2 / 5 / 6 位（兜底色块：JJK / SPY / 魔法少女）

---

## 4. 抓不到的源 + 兜底方案

| 平台 | 状态 | 原因 |
|---|---|---|
| Hpoi 手办维基 | HTML 拿到但商品图 JS 渲染 | CSR |
| AliExpress | 第一次 614KB，之后 IP 风控 → 2KB 验证页 | 速率风控 |
| Bing/百度/DDG 图片 | 反爬黑名单 / JS 渲染 | 设计反爬 |
| kawaiianime / 多个 Shopify | Cloudflare 5s 等待 / 域名失效 | 反爬+变迁 |
| Goodsmile | 1.8MB SSR shell 无图 | SPA |
| eBay /sch | 403 Access Denied | 边缘节点封锁 |
| eBay /b/<id> | 可用，但需查每个 IP 的 category ID | 实施成本高 |
| 国内淘宝/京东直连 | 国内域名国外 IP 不可达 / 强反爬 | 设备限制 |

**最终兜底**：
1. **客户实拍**——上线必须方案
2. p-bandai.com（万代官方）SSR 可抓，但只覆盖万代 IP，需 30s 间隔
3. AI 生图占位，加"AI 示意"水印

---

## 5. 给 Kevin 的关键注意

1. mockup 内部 OK，**正式上线必须替换为客户实拍**——已抓的图都是 Amazon 卖家商品页 hero shot，版权各归制造商
2. mockup 建议加 "示意图 / Mockup Only" 水印（designer 第一批已做）
3. bluelock 最少（5 张），ONE PIECE 最清晰（classic-01/02 256/246KB）
4. chiikawa-sanrio 14 张（第一批）原目录未动

---

## 6. 学到的（反爬现状 2026-05）

**反爬现状**：
- **Amazon JP/US**：SSR 含商品图 + 友好 UA 即通 — 当前最稳的电商图源
- **国内电商系**：全部要客户端验证，纯 curl 不可行
- **国际 Shopify 系**：80% 已被 Cloudflare/Shopify 反爬覆盖（chiikawamarket.jp 是少数例外）
- **图搜引擎**：Bing/Baidu/Google/DDG 全部识别 curl UA 拦截

**Amazon 图 URL pattern**（值得抽 skill）：
```
https://m.media-amazon.com/images/I/<ID>._AC_UL<size>_QL<q>_.jpg
```
- ID 是商品图唯一标识；size 改成 320/480/1500 调分辨率；UL1500 通常是最大变体
- 搜索路径：`https://www.amazon.co.jp/s?k=<urlencoded-jp-keyword>` + UA Chrome 120 + Accept-Language ja
