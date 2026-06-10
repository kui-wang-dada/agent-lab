---
name: coder-mp-entity-cache-test
description: MyBatis-Plus ServiceImpl 单测涉及 LambdaWrapper.set/eq 时，无 Spring 上下文路径下 TableInfoHelper 抛 "can not find lambda cache" 的修法。BeforeAll 用 MapperBuilderAssistant + TableInfoHelper.initTableInfo 预热 entity cache。
metadata:
  type: skill
  stack: ruoyi-vue-plus (MyBatis-Plus)
  domain: coder
---

> ⚠️ **ruoyi-specific（MyBatis-Plus），非 generic。** 本 skill 是 RuoYi-Vue-Plus 栈插件的一部分（dongjiaoshan 抽出），**放栈插件 `stacks/skills/`，不放通用模板**。换栈（非 MyBatis-Plus）不适用。这是该栈"前置验收测试"机制的一个具体落地坑；generic 模板里对应的抽象是「机器可验收 checkbox / 前置测试 gate」。无项目专属业务值需占位——纯框架机制；下例 entity 类名用占位 `<Entity>`。

# coder-mp-entity-cache-test

> 适用场景：任何 ServiceImpl 单测涉及 `LambdaUpdateWrapper.set(field, val)` / `LambdaQueryWrapper.eq(field, val)` 等 lambda 调用。

## 触发场景

ServiceImpl 实现里用了 MyBatis-Plus lambda wrapper：

```java
new LambdaUpdateWrapper<EntityA>().eq(EntityA::getId, id).set(EntityA::getSomeField, val);
new LambdaQueryWrapper<EntityB>().eq(EntityB::getTenantId, "1001");
```

单测用 `@ExtendWith(MockitoExtension.class)` 无 Spring 上下文 + mock baseMapper → 跑到 lambda 行时抛：

```
MybatisPlusException: can not find lambda cache for this entity [EntityA]
```

## 根因

`LambdaUpdateWrapper.set(field, val)` 内部调 `TableInfoHelper.getTableInfo(Entity.class)` 解析 lambda 字段对应的列名。该 cache 默认在 `MybatisSqlSessionFactoryBean.afterPropertiesSet()` 时由 Spring 扫包注册；单测无 Spring → 缓存空 → 抛错。

## 修法

`@BeforeAll` 用 `MybatisConfiguration` + `MapperBuilderAssistant` + `TableInfoHelper.initTableInfo(assistant, Entity.class)` 手动预热每个 entity（**所有 service 内部用过 lambda 的 entity 都要列**，含间接调用的）。

## 完整代码样例

```java
import com.baomidou.mybatisplus.core.MybatisConfiguration;
import com.baomidou.mybatisplus.core.metadata.TableInfoHelper;
import org.apache.ibatis.builder.MapperBuilderAssistant;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.junit.jupiter.MockitoExtension;
// ...

@ExtendWith(MockitoExtension.class)
class SomeServiceImplTest {

    /**
     * MyBatis-Plus 单测 entity cache 预热：service 内 LambdaQueryWrapper / LambdaUpdateWrapper
     * 在 mock 路径下也会触发 TableInfoHelper.getTableInfo() 解析 lambda 列名，必须先注册 entity。
     */
    @BeforeAll
    static void initMpEntityCache() {
        MybatisConfiguration cfg = new MybatisConfiguration();
        MapperBuilderAssistant assistant = new MapperBuilderAssistant(cfg, "");
        assistant.setCurrentNamespace("test");
        TableInfoHelper.initTableInfo(assistant, EntityA.class);
        TableInfoHelper.initTableInfo(assistant, EntityB.class);
        TableInfoHelper.initTableInfo(assistant, EntityC.class);
        // 列出所有 service.xxx() 内部 LambdaWrapper 涉及的 entity（含 update 副作用 entity）
    }

    @BeforeEach
    void setUp() { /* 注入 mock mapper / 准备 stub */ }

    // @Test ...
}
```

## 必查清单（写 ServiceImpl 单测时）

1. service 实现里 grep `LambdaUpdateWrapper\|LambdaQueryWrapper\|Wrappers.lambdaUpdate\|Wrappers.lambdaQuery` — 列出所有命中的 entity 类
2. 单测 `@BeforeAll` 把这些 entity 全部 `initTableInfo` 预热
3. 跑测试看 `MybatisPlusException` 是否消失；如还有 → grep 漏了哪个 entity
4. 单测 class 头加 `@ExtendWith(MockitoExtension.class)` + `@MockitoSettings(strictness = Strictness.LENIENT)`（避免 stub 严格性 false positive）

## 反模式

- ❌ 不要在测试里把 lambda 改写成 `eq("col_name", val)` 硬编码列名 — 失去 lambda 类型安全
- ❌ 不要 `@SpringBootTest` 起整个 Spring 上下文 — 慢 + 与其他单测污染
- ❌ 不要 mock `TableInfoHelper.getTableInfo()` — 静态方法 mock 复杂且不可移植

## 关联

- 相关 skill：`coder-djs-cross-layer-contract`（跨层契约）
- 同栈建表 / 软删机制：`stacks/ruoyi-notes.md §1 §4`
- prompt 模板可加：后端 ticket prompt § 产出要求加一条"涉 LambdaWrapper 的 service 单测必须预热 entity cache"
