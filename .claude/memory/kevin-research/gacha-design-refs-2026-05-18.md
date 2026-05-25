# 扭蛋设计参考 — 2026-05-18

> 给 sensenran-guzi mockup 提升扭蛋机游戏性 / 趣味性用。
> 调研人：kevin-research（asynchronous）

---

## TL;DR

**当前 mockup 缺的最大三件事**：
1. 没有"投币 → 转把手"的触发仪式（用户只点按钮，缺物理参与感）
2. 胶囊是悬空旋转，不是从机器吐出滚落（缺真实扭蛋机出蛋物理感）
3. 缺"快出 SSR"的预告动效（保底 80%+ 应有震动/微光暗示）

**最高 ROI 两条改动**（详见第 4 节）：
1. `gacha-detail.html` 顶部加"扭蛋机本体"组件（黄黑配色 + 透明球桶 + 投币口 + 把手 + 出蛋口） + 0.6s 投币摇把手前置仪式
2. `gacha-list.html` 所有机器卡片加保底进度环（`距 SSR 必出 还有 X 抽`）

**Top 3 最高质量参考**：
- [CodePen — Gacha Machine with GSAP](https://codepen.io/wheatup/pen/BawKVYe) — 最接近完整实现
- [GameRes — 抽卡体验设计完全分析](https://www.gameres.com/902668.html) — 仪式感与上瘾机制
- [Josh Comeau — Squash and Stretch](https://www.joshwcomeau.com/animation/squash-and-stretch/) — 胶囊弹跳物理感原理

---

## 1. 真实扭蛋机视觉参考

| 链接 | 借鉴点 |
|---|---|
| [Bandai Namco 旗舰店](https://bandainamco-am.co.jp/en/others/capsule-toy-store/) | 橙黄主色 + 黑金属框架 + 透明球桶矩阵；mockup 黄色权重可加重 |
| [Bandai 官方店机器墙](https://bandainamco-am.co.jp/en/others/gashapon-bandai-officialshop/) | 高密度阵列；`gacha-list.html` 大厅可用 2 列网格 + 卡片间距 5-8px 模拟扭蛋墙 |
| [Tokyo Weekender — Gachapon](https://www.tokyoweekender.com/art_and_culture/gachapon-japanese-capsule-toys/) | 街头扭蛋机的玻璃反光质感；SSR 揭晓背景可加霓虹反光层 (`mix-blend-mode:overlay`) |
| [The Travel Pockets — Ikebukuro](https://www.thetravelpockets.com/new-blog/a-complete-guide-to-the-gashapon-store-in-ikebukuro-japan) | 高饱和色块顶部 banner |
| [Japan Pop Now — Gachapon Guide](https://www.japan-pop-now.com/articles/gachapon-guide-japan) | 圆形透明出蛋窗 + 黑色塑料把手；扭蛋机卡片底部加半透明圆形舱门装饰 |
| [Studio Brillantine — Blind Box](https://www.studiobrillantine.com/blog/surprise-blind-box-collecting-guide/) | Sonny Angel 极简白机身 + 高彩度产品的反差；机器背景调成 #F0F4F2 让胶囊金/紫色更跳 |

---

## 2. 可落地动效模式（按 ROI 排序）

### 模式 1：投币 + 摇把手前置仪式（★ 必加）

- 触发：点"开扭"后 → Frame 1 之前插入 600-800ms
- 实现：
```css
@keyframes coin-drop {
  0%   { transform: translate(-40px, -60px) rotate(0deg); opacity: 0; }
  20%  { opacity: 1; }
  60%  { transform: translate(-10px, -20px) rotate(180deg); }
  100% { transform: translate(0, 0) rotate(360deg) scale(.6); opacity: 0; }
}
.handle { animation: handle-turn .5s cubic-bezier(.4, 0, .2, 1); }
@keyframes handle-turn { 0%{transform:rotate(0)} 100%{transform:rotate(180deg)} }
.machine.shake { animation: shake 0.2s ease-in-out 2; }
```

### 模式 2：胶囊从机器底部弹出（squash & stretch）

```css
@keyframes capsule-eject {
  0%   { transform: translateY(-30px) scale(.6); opacity: 0; }
  40%  { transform: translateY(20px) scale(1.1, .9); opacity: 1; }
  60%  { transform: translateY(0)    scale(.95, 1.05); }
  100% { transform: translateY(0)    scale(1); }
}
```

### 模式 3：SSR 预告金光扫光（关键差异化）

- 触发：Frame 2 裂开**之前** 0.3-0.5s（预判式预告）
- 心理学：用户在揭晓前就知道"要出大的了"，这一秒延迟是上瘾的关键

```css
@keyframes ssr-foreshadow {
  0%   { box-shadow: 0 0 0 rgba(255,215,0,0); }
  50%  { box-shadow: 0 0 60px 20px rgba(255,215,0,.6); transform: scale(1.04); }
  100% { box-shadow: 0 0 0 rgba(255,215,0,0); transform: scale(1); }
}
```

### 模式 4：保底进度环（运营+视觉双赢）

- 位置：大厅扭蛋机卡片右上角 + 详情页顶部
- 文案：`距 SSR 必出 还有 X 抽`；>80% 时卡片加金光呼吸；≥95% 加"🔥 准爆"角标

```html
<svg class="pity-ring" viewBox="0 0 36 36">
  <circle cx="18" cy="18" r="16" fill="none" stroke="#FFEFC4" stroke-width="3"/>
  <circle cx="18" cy="18" r="16" fill="none" stroke="#F2A900" stroke-width="3"
          stroke-dasharray="100" stroke-dashoffset="35"
          transform="rotate(-90 18 18)"/>
  <text x="18" y="22" text-anchor="middle" font-size="10" font-weight="900">65%</text>
</svg>
```

### 模式 5：10 连扇形撒开 + 逐张翻面（SSR 留到最后翻）

```css
.card { transform: rotateY(180deg) translateX(calc(var(--i) * 30px)); }
.card.reveal {
  animation: flip .4s ease-out;
  animation-delay: calc(var(--i) * 80ms);
}
.card.is-ssr { animation-delay: 1.5s !important; }
```

### 模式 6：粒子追尾（Frame 3 揭晓后）

```css
.particle {
  position: absolute; width: 4px; height: 4px;
  border-radius: 50%; background: gold;
  animation: particle-float 1.8s ease-out infinite;
}
@keyframes particle-float {
  0%   { transform: translate(0, 0) scale(0); opacity: 1; }
  100% { transform: translate(var(--dx), var(--dy)) scale(1); opacity: 0; }
}
```

### 模式 7：N/R 的"小高兴"反馈（避免挫败）

- N/R 揭晓时：+1 集卡积分浮空弹幕 + 微弱蓝/灰光晕（区别于 SSR 金光但仍有反馈）

---

## 3. 玩法增强（运营层）

### 3.1 保底进度可视化（★ 必做，第一版）
- 案例：原神 / 鸣潮 / 世界之外
- 数据：玩家公认"看着进度条停不下来"，抽卡留存第一杠杆

### 3.2 集卡 → 兑换徽章/实物/优先权（★ 必做）
- 案例：世界之外（限定卡 → 徽章/摆件/卡套）、明日方舟（300 寻访点换任意限定六星）
- 落地：当前 mockup 已埋好"集齐解锁特典徽章"伏笔 → 第一版上；加"扭蛋火花"商店（每抽 1 点，300 点换任意 SSR）

### 3.3 摇盒提示（差异化付费点 · 需合规审查）
- 案例：泡泡玛特"摇盒提示"
- 落地：单抽 ¥39 + ¥3 解锁本机已排除的 3 款
- ⚠️ 必须标注"概率性提示，不保证结果"

### 3.4 限时活动池 / 复刻池
- 案例：原神每 3 周轮换 UP 池 / 明日方舟 6 个月复刻
- 落地：每周一台"周限定机"（库存 500 颗）；3 个月做"经典复刻周"

### 3.5 集体抽卡 / 战绩广场
- 案例：阴阳师召唤大厅 / 世界之外晒卡广场
- 落地：大厅顶部滚屏"刚刚 杭州小红 在 CHIIKAWA 第三弾抽到金牌"
- ⚠️ 必须真实数据，不能机器人刷屏

---

## 4. 给 designer 的优先级建议

### 必做（最高 ROI · 第一版）
- **改动 1**：扭蛋机本体 + 投币摇把手前置仪式 + 胶囊弹出（模式 1+2，约 1 天）
- **改动 2**：SSR 预告金光 + 保底进度环（模式 3 + 3.1，约 1 天）

### 可做（中等 ROI · 第二版）
- **改动 3**：10 连扇形 + 逐张翻面 + 粒子追尾（模式 5+6，约 1.5 天）
- **改动 4**：集卡兑换"扭蛋火花"商店 + 系列徽章（3.2，前端 ~2 天 + 后端 ~3 天）

### 缓做（成本高 / 法务 / 场景不匹配）
- **改动 5**：摇盒提示付费点 — 需后端真实库存逻辑 + 合规审查
- **改动 6**：实时战绩广场 — DAU < 1000 时滚屏显假；替代静态"本机最近 10 位幸运儿"
- **改动 7**：3D 透视 + blend mode — 小程序对 WebGL 弱；2D + 多层 box-shadow 已能达 80% 效果

---

## 5. 关键参考链接索引

### 国内对标（直接抄作业）
- [泡泡玛特抽盒机小程序拆解](https://blog.csdn.net/shaonianrumeng/article/details/149065693)
- [泡泡玛特商业拆解（92% 会员贡献）](https://www.xinlingshou.com/learn/48249)
- [一番赏融合解析](https://blog.csdn.net/wangzhencici/article/details/154642725)
- [GameRes — 抽卡体验设计](https://www.gameres.com/902668.html)
- [GameRes — 表现设计 仪式感](https://www.gameres.com/900128.html)
- [知乎 — 关于盲盒抽卡开箱](https://zhuanlan.zhihu.com/p/695913395)
- [世界之外 280 抽全拿策略](https://cg.163.com/static/content/6784b1add6b287ad30937c0e)
- [鸣潮 角色与武器保底](https://cg.163.com/static/content/6752d7defebcfe860158b644)

### 海外动效灵感（仅参考，不展示）
- [CodePen — Gacha Machine with GSAP](https://codepen.io/wheatup/pen/BawKVYe) — 最接近完整实现
- [CodePen — Gachapon](https://codepen.io/ThomasYoungDev/pen/RzrvqM)
- [CodePen — 3D CSS Minecraft Gacha](https://codepen.io/chernyakkho/pen/zYqjRKz)
- [CodePen — Gachapon Machine](https://codepen.io/tianaxu976/pen/ExWqJao)
- [Dribbble — Lootbox Animation 合集](https://dribbble.com/hellandhome/collections/6489011-Lootbox-Animation)
- [Josh Comeau — Squash and Stretch](https://www.joshwcomeau.com/animation/squash-and-stretch/)
- [CSS-Tricks — Shake Keyframe](https://css-tricks.com/snippets/css/shake-css-keyframe-animation/)
- [CSShake 库](https://elrumordelaluz.github.io/csshake/)
