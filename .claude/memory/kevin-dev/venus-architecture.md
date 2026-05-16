# Venus 架构 reference

> 提炼自 `~/Project/work/upwork/2025/4-6-rn-ai/`（Venus Skin Labs，韩国 AI 美妆 App，开发 1 年+）
> **用途**：新项目搭脚手架时，作为 Kevin 默认选型 + 模式范本
> **置信度标注**：✅ 高（Kevin 主动这么写）/ ⚠️ 中（项目里这么写但可能历史包袱）/ ❓ 低（来源不明，可能 contractor 留的）

---

## 仓库布局

Venus 是**多 repo + 子树式 monorepo 混合**，根目录 `~/Project/work/upwork/2025/4-6-rn-ai/` 下：

```
4-6-rn-ai/
├── main/                          # ← 服务端 + RN 主端（4 个 service）
│   ├── venus-react-native-app/    # Expo RN App（用户端）
│   ├── fastapi-backend/           # 主 REST API（8000）
│   ├── ai-skin-analysis/          # 人脸分析微服务（8002）
│   └── task-service/              # cron + one-off 任务调度（9200）
├── main-web/                      # ← 三个 Web 前端
│   ├── venus-backend/             # 旧后端遗留，迁移到 main/fastapi-backend
│   ├── venus-skin-review/         # Next.js 15 医生评审门户
│   ├── venus-skincare-box/        # Next.js 15 内部 admin（订单/包/库存）
│   └── venus-internal-admin/      # Vite + React 18 任务端 admin
├── clinic-main/                   # 旧 clinic 项目
├── venus-app/                     # 旧 RN 项目（已废）
├── venus-box-web/                 # 旧 box-web（已废）
└── not-main/                      # 试验性代码归档
```

**关键决策**：每个 service / web 项目独立 `package.json` / `requirements.txt`，**没有 monorepo 工具**（不用 nx / turborepo / yarn workspaces）。共享代码靠**手动复制**或后端 API 隔离。

✅ Kevin 的实际做法：**前端跨项目代码不共享**，宁愿复制 UI 组件也不引 monorepo 工具——降低构建复杂度。

---

## RN 端（`main/venus-react-native-app/`）

### 技术栈核心

```jsonc
// package.json 关键依赖
{
  "expo": "^53.0.0",             // SDK 53
  "react": "19.0.0",
  "react-native": "0.79.5",
  "zustand": "^5.0.3",
  "axios": "^1.8.4",
  "@react-navigation/native": "^7.1.5",
  "@react-navigation/native-stack": "^7.3.9",
  "@react-navigation/bottom-tabs": "^7.3.9",
  "@lingui/macro": "^5.3.0",
  "react-native-vision-camera": "^4.7.3",
  "react-native-purchases": "^9.1.0",   // RevenueCat
  "@stripe/stripe-react-native": "0.62.0",  // 锁定！
  "@sentry/react-native": "^6.20.0",
  "customerio-reactnative": "^5.3.0",
  "react-native-reanimated": "~3.17.4",
  "@shopify/react-native-skia": "^2.5.1",
  "lottie-react-native": "7.2.2"
}
```

**新架构关闭**（`app.config.js:newArchEnabled: false`）。理由：第三方库（vision-camera / customerio / stripe）兼容性 > 性能收益。

### 状态管理（zustand + slice 模式）

**模式**：所有 store 合并成一个 `useRootStore`，按业务域切 slice。

**实例**：[main/venus-react-native-app/src/store/root.ts:37-115](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main/venus-react-native-app/src/store/root.ts)

```typescript
export const useRootStore = create<RootStore>()(
  persist(
    subscribeWithSelector(
      devtools((...args) => ({
        ...createUserSlice(...args),
        ...createCommonSlice(...args),
        ...createScanSlice(...args),
        ...createRoutineSlice(...args),
        // ... 共 12 个 slice
        resetAllStores: () => { /* 全局重置 */ },
      }))
    ),
    {
      name: 'venus-auth-storage',
      storage: createJSONStorage(() => AsyncStorage),
      partialize: (state) => ({
        token: state.token,
        userInfo: state.userInfo,
        firstAiChat: state.firstAiChat,
        // 只白名单持久化必要字段
      }),
    }
  )
);
```

**Slice 文件结构**：`src/store/{domain}Store.ts`，每个 export `createXxxSlice` 函数 + `XxxType` 类型。
**实例**：[main/venus-react-native-app/src/store/userStore.ts:112-735](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main/venus-react-native-app/src/store/userStore.ts)

```typescript
export const createUserSlice: StateCreator<
  RootStore,
  [['zustand/subscribeWithSelector', never], ['zustand/devtools', never]],
  [],
  UserType
> = (set, get) => ({
  token: '',
  userInfo: undefined,
  setUserInfo: (userInfo) => { /* ... */ },
  getUserInfo: async () => { /* 调 axios + sync Sentry user */ },
  // 业务方法直接挂在 slice 上（不分 action / selector）
});
```

**Kevin 的偏好**（✅ 高确信）：
- 业务异步逻辑（API 调用）直接挂在 slice 的方法上，**不写中间层**（不要 redux-toolkit 那种 createAsyncThunk）
- 选 N 个值用 `useShallow(state => [s.a, s.b, s.c])`
- 全局重置走 `resetAllStores`（logout 时调用）
- persist 只白名单关键字段，不要把整个 store 都存

### 网络层（axios + interceptor）

**实例**：
- 单例创建：[main/venus-react-native-app/src/store/api/api.ts:8-21](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main/venus-react-native-app/src/store/api/api.ts)
- 拦截器：[main/venus-react-native-app/src/store/api/intercept.ts:13-105](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main/venus-react-native-app/src/store/api/intercept.ts)

```typescript
// $api 是一个 callable + 带 get/post/put/delete/patch 方法
const $api = async (config) => axiosInstance(config);
$api.get = (url, params, config) => $api({ method: 'GET', url, params, ...config });
// ...
```

**Request 拦截器**：从 zustand 读 token，注入 `Authorization: Bearer ...`

**Response 拦截器关键模式**（✅ Kevin 自创无感 token 刷新）：
```typescript
const newToken = response.headers?.['x-new-token'];
const tokenRefreshed = response.headers?.['x-token-refreshed'];
if (newToken && tokenRefreshed === 'true') {
  useRootStore.getState().setToken(newToken);
}
```
配合后端 `TokenRefreshMiddleware`（见后端章节），实现"快过期时下次请求自动续期"——**无需 refresh token endpoint**。

**401 处理**：interceptor 直接调 `useRootStore.getState().logout()`，整个 app 自动跳登录。

⚠️ 注意：当前 `config.ts` hardcode 了 prod URL（[config.ts:101](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main/venus-react-native-app/src/store/api/config.ts)），动态 ENV 选择函数（`getApiUrl`）写好了但未启用 —— 历史调试遗留。

### 导航（React Navigation v7）

**模式**：按业务域拆 module navigator，根 navigator 汇总。

```
src/navigation/
├── AppNavigator.tsx          # 根（含 Login / Onboarding / MainTabs 切换）
├── MainTabNavigator.tsx       # 底部 tab（Home / Routine / Scan / Explore / Profile）
├── 1HomeModule.tsx           # 每个 tab 内部一个 stack navigator
├── 2RoutineModule.tsx
├── 3StudioModule.tsx          # （即 Scan tab，重命名了）
├── 4ExploreModule.tsx
├── 5UserModule.tsx
├── LibraryModule.tsx
├── OnboardingStackNavigator.tsx
└── types.ts                  # RootStackParamList + routerOptions
```

**实例**：[main/venus-react-native-app/src/navigation/AppNavigator.tsx:53-79](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main/venus-react-native-app/src/navigation/AppNavigator.tsx)

```typescript
useEffect(() => {
  const initRoute = token
    ? (userInfo?.has_onboarded ? 'MainTabs' : 'OnboardingStack')
    : 'Login';
  setInitialRouteName(initRoute);
}, [token, userInfo]);
```

**Kevin 的偏好**（✅）：模块文件名用数字前缀（`1HomeModule`/`2RoutineModule`...）反映 tab 顺序。

### 相机 / 人脸扫描（vision-camera + 自封装 hook）

**实例**：[main/venus-react-native-app/src/hooks/useVisionCamera.ts:44-195](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main/venus-react-native-app/src/hooks/useVisionCamera.ts)

封装的关键问题：
1. **Android CameraX 黑屏自动恢复**：onError → 设 `isRecovering=true` → 等 300ms → bump `cameraKey` 触发组件 remount → 重置 `isRecovering`。最多 3 次重试。
2. **Android 首次安装 device list 为 null 的 polling fallback**：直接读 `NativeModules.CameraDevices.getConstants()` 绕过 JS 缓存
3. **isActive 计算**：`isFocused && isForeground && hasPermission && device != null && !isRecovering`
4. **takePhoto**：返回标准化 `file://` URI

✅ Kevin 经验：vision-camera 的 Android CameraX 错误必须 JS 层兜底，原生层 3 次重试失败后才到 JS。

### 多语言（Lingui v5）

- macro 模式：组件内 `t\`Hello\`` / `<Trans>Hello</Trans>`
- 4 种 locale：`en`, `ko`, `es`, `ja`
- `npm run lingui` = extract + compile，**husky pre-commit hook 自动跑**
- Provider：[main/venus-react-native-app/src/contexts/I18nProvider.tsx](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main/venus-react-native-app/src/contexts/I18nProvider.tsx)

### IAP / 订阅（RevenueCat 主，Stripe 辅）

**RevenueCat 是 source of truth**，所有"是否 Pro 用户"判断走 entitlements：

**实例**：[main/venus-react-native-app/src/store/userStore.ts:287-347](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main/venus-react-native-app/src/store/userStore.ts)

```typescript
const customerInfo = await revenueCatService.getCustomerInfo(true);
const activeEntitlements = customerInfo.entitlements.active || {};
const hasActiveEntitlement = Object.keys(activeEntitlements).length > 0;
// isReturningUser = 曾经有 entitlement 但现在没了（trial 结束 / 订阅过期）
const isReturningUser = !hasActiveEntitlement && Object.keys(allEntitlements).length > 0;
```

⚠️ **`@stripe/stripe-react-native` 锁定 0.62.0**（package.json:46）—— 更高版本 Xcode 26.4 崩，更低版本 Android toolchain 需要升级。**碰这个依赖前必查 CLAUDE.md**。

### Contexts（React Context）

业务异步状态都在 zustand，Context 只用于：
- `GlobalContext` / `ModalContext` / `NotificationContext` / `RatingContext` / `ThemeContext` / `I18nProvider` / `FullscreenVideoContext`

✅ Kevin 偏好：Context = UI 层 ephemeral state（modal / theme / video player）；Zustand = 持久 / 跨页面业务状态。

### 路径别名

`tsconfig.json` 设 `@/* → ./src/*`，babel 用 `babel-plugin-module-resolver` 同步。**所有内部 import 必须用 `@/`，不能用相对路径 `../../`**。

### 构建 / OTA

- EAS Build（`build:preview` / `build:prod`）
- EAS Update（`update:preview` / `update:prod`），runtime version 2.1.2
- 分支映射：`dev` → development / `staging` → preview / `master` → production
- 不能直接 push `main`（husky 拦截）

---

## Web 端（`main-web/`）

### 三种栈共存

| 项目 | 栈 | 路径 |
|---|---|---|
| venus-skin-review | Next.js 15 + Context | `main-web/venus-skin-review/` |
| venus-skincare-box | Next.js 15 + Context | `main-web/venus-skincare-box/` |
| venus-internal-admin | Vite + React 18 + Zustand + react-router 6 | `main-web/venus-internal-admin/` |

**共享**：
- shadcn/ui（Radix + Tailwind）
- react-hook-form + zod
- date-fns / luxon
- lucide-react
- sonner（toast）

### Next.js 项目模式（venus-skin-review / venus-skincare-box）

**目录结构**（venus-skin-review）：
```
app/
├── admin/
│   ├── (auth)/          # 路由分组（无 layout）
│   │   ├── login/
│   │   └── create-account/
│   └── (dashboard)/     # 含 sidebar layout
│       ├── tasks/
│       ├── tasks/[id]/  # 主审核页
│       ├── users/
│       └── settings/
└── api/
    ├── proxy/doctor/    # HTTPS → HTTP 后端代理
    ├── proxy/general/
    ├── products/        # 自有 SQL 查询
    ├── ingredients/
    └── translate/

components/
├── auth-provider.tsx    # Context-based auth
├── task-detail/         # 业务组件目录
└── ui/                  # shadcn/ui 拷贝出来的组件

lib/
├── api.ts               # 高层 API helper
├── services/
│   ├── auth-service.ts
│   └── doctor-api.ts
├── db.ts                # pg.Pool singleton
├── types.ts             # 全局 TS 类型
└── utils/api-config.ts  # HTTP vs HTTPS 路由切换
```

**HTTPS Proxy 模式**（✅ 重要 production 经验）：

后端是 HTTP（`http://3.149.41.153:8000`），网页是 HTTPS。浏览器会 block mixed content。
**解决**：production 走 `/api/proxy/doctor` Next.js route handler 中转，dev 直连。

**实例**：[main-web/venus-skin-review/lib/utils/api-config.ts](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main-web/venus-skin-review/lib/utils/api-config.ts)

```typescript
export const getDoctorAPIBaseURL = () => {
  if (isProductionHTTPS()) return '/api/proxy/doctor';
  return getExternalAPIBaseURL();
};
```

**API 调用**：手写 fetch wrapper（[doctor-api.ts](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main-web/venus-skin-review/lib/services/doctor-api.ts)），不用 axios，不用 SWR / TanStack Query。

```typescript
const handleAPIResponse = async (response: Response) => {
  if (!response.ok) {
    const error = await response.json().catch(() => ({ detail: 'Unknown error' }));
    throw new DoctorAPIError(error.detail || 'API request failed', response.status);
  }
  return response.json();
};
```

**Auth**：JWT 存 `localStorage.access_token`，`AuthProvider` Context 暴露 `useAuth()`。
Admin 权限是**邮箱白名单 hardcode**（`ADMIN_EMAILS`）—— ⚠️ 不够好，但客户接受。

**DB 访问**：`pg.Pool` 直接 SQL（不用 ORM），只用于内部 `/api/products/` 等查询。主数据走 FastAPI。

### Vite Admin 模式（venus-internal-admin）

为什么用 Vite 而不是 Next.js：✅ Kevin 经验——纯后台 admin 不需要 SSR / SEO，Vite dev server 更快，路由用 react-router 更直观。

**目录结构**：
```
src/
├── main.tsx
├── App.tsx
├── router/
│   ├── index.tsx        # createBrowserRouter（含 lazy + Suspense）
│   ├── AuthGuard.tsx
│   ├── RoleGuard.tsx
│   └── permissions.ts   # 角色 → 默认页面映射
├── layouts/
│   ├── AuthLayout.tsx
│   └── DashboardLayout.tsx
├── pages/               # 路由级页面
│   ├── auth/
│   ├── doctor-review/
│   ├── color-consult/
│   ├── users/
│   ├── reporting/
│   └── settings/
├── components/
├── store/               # zustand root + slices（同 RN 端模式）
│   ├── root.ts
│   ├── commonStore.ts
│   ├── doctorReviewStore.ts
│   └── api/
└── lib/
    ├── services/        # API 调用
    ├── types.ts
    └── utils/
```

**实例**：[main-web/venus-internal-admin/src/router/index.tsx:44-80](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main-web/venus-internal-admin/src/router/index.tsx)

```typescript
const ReviewListPage = lazy(() => import("@/pages/doctor-review/ReviewListPage").then(m => ({ default: m.ReviewListPage })));

export const router = createBrowserRouter([
  {
    path: "/admin",
    children: [
      {
        element: <AuthLayout />,
        children: [
          { path: "login", element: <LoginPage /> },
        ],
      },
      {
        element: <DashboardLayout />,
        children: [
          { path: "doctor-review", element: withSuspense(ReviewListPage) },
          { path: "users", element: <RoleGuard pageId="users">...</RoleGuard> },
        ],
      },
    ],
  },
]);
```

**Zustand store 模式**：与 RN 端一样的 root + slice + persist + useShallow 模式：

**实例**：[main-web/venus-internal-admin/src/store/root.ts:9-28](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main-web/venus-internal-admin/src/store/root.ts)

```typescript
export const useRootStore = create<RootState>()(
  persist(
    devtools((...args) => ({
      ...createCommonSlice(...args),
      ...createDoctorReviewSlice(...args),
      ...createColorConsultSlice(...args),
    })),
    {
      name: 'venus-internal-admin',
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({ token, user, locale, role, isAdmin }),
    },
  ),
);
```

**Convenience hooks**（✅ Kevin 模式）：
```typescript
export function useAuth() {
  return useRootStore(useShallow(s => [s.user, s.isAdmin, s.role, s.checkAuth, s.logout] as const));
}
```
不让组件直接选字段，统一暴露 hook。

✅ **可复用脚手架要点**：Vite + react-router + Zustand + shadcn/ui 是 Kevin 写"客户后台"的稳定栈。

---

## 后端（`main/fastapi-backend/` + 3 个微服务）

### 整体架构

4 个独立 FastAPI 进程，共享 PostgreSQL，docker network `venus-internal` 通信：

```
fastapi-backend       :8000   # 主业务（24+ route 文件）
ai-skin-analysis      :8002   # 人脸分析（Roboflow + MediaPipe + PyTorch）
task-service          :9200   # cron + one-off（APScheduler + 自封装 registry）
venus-backend (旧)             # main-web 下，被 main/ 取代
```

### 目录结构（fastapi-backend）

```
app/
├── main.py
├── api/
│   ├── deps.py              # 共享 dependencies
│   ├── account.py           # 独立 router
│   ├── v1/
│   │   ├── router.py        # importlib 自动扫描 routes/
│   │   └── routes/          # 24 个路由文件
│   │       ├── analysis.py
│   │       ├── chat.py
│   │       ├── ...
│   └── v2/                  # disabled
├── core/
│   ├── config.py            # pydantic-settings Settings
│   └── logging_config.py
├── db/session.py            # SQLAlchemy engine + SessionLocal
├── middleware/
│   └── token_refresh.py     # 自研无感刷新
├── models/                  # SQLAlchemy ORM（18+ 表）
├── schemas/                 # Pydantic v2 schemas
├── services/                # 业务逻辑（30+ 文件）
├── utils/                   # auth / openai / s3 / customerio / face_alignment
└── tasks/                   # APScheduler 旧位置（已迁到 task-service）
```

### 路由自动发现

**实例**：[main/fastapi-backend/app/api/v1/router.py](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main/fastapi-backend/app/api/v1/router.py)

```python
import importlib, os
api_router = APIRouter()
routes_dir = os.path.dirname(__file__) + "/routes"
for filename in os.listdir(routes_dir):
    if filename.endswith(".py") and filename != "__init__.py":
        module = importlib.import_module(f"app.api.v1.routes.{filename[:-3]}")
        if hasattr(module, "router"):
            api_router.include_router(module.router)
```

✅ **Kevin 偏好**：route 文件加进去就自动 mount，**新增不要碰中央注册表**。每个文件内部自己定义 `prefix` / `tags`（在 APIRouter 里）。

### Route Handler 模板

每个 route 三段式错误处理（**全项目一致**）：

**实例**：[main/fastapi-backend/app/api/v1/routes/analysis.py:34-52](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main/fastapi-backend/app/api/v1/routes/analysis.py)

```python
@router.get("/users/{user_id}/analysis", response_model=List[AnalysisRow])
def get_analysis_history(
    user_id: int,
    page: int = 1,
    limit: int = 365,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    try:
        analyses = AnalysisService.get_user_analysis_history(db, user_id, page, limit)
        return analyses
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        logger.error(f"Error getting analysis history: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail="Internal server error")
```

模式：`HTTPException` 直接 re-raise（不写 except）/ `ValueError` → 404 / 其他 → 500 + log。

### 服务层（Service classes）

**实例**：[main/fastapi-backend/app/services/analysis_service.py:24-60](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main/fastapi-backend/app/services/analysis_service.py)

```python
class AnalysisService:
    """Analysis service layer containing all business logic"""

    @staticmethod
    def get_user_analysis_history(db: Session, user_id: int, page: int = 1, limit: int = 365):
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            raise ValueError("User not found")
        # ...
```

⚠️ **大量 @staticmethod**，与 Kevin 主张"函数 > 类"有冲突——这是历史习惯 / 客户接手时已成型。

✅ Kevin 的偏好：新项目用 **module-level 函数**（不要 service class），但维护 Venus 时跟随既有风格。

### 数据库

**实例**：[main/fastapi-backend/app/db/session.py](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main/fastapi-backend/app/db/session.py)

```python
engine = create_engine(
    settings.effective_database_url,
    pool_pre_ping=True,
    future=True,
    pool_size=10 if not is_sqlite else 5,
    max_overflow=20 if not is_sqlite else 10,
    pool_timeout=30,
    pool_recycle=3600,
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

⚠️ **同步 Session**（非 async）—— Venus 历史选择。tianda-web 走 async。

✅ Schema 管理特殊规则：
- `fastapi-backend` / `ai-skin-analysis`：**手写 SQL** 直接 apply，不用 Alembic（main/CLAUDE.md:276 明确）
- `task-service`：独立 Alembic chain（shared + staging + production 三套 version 目录）

### 认证（多类型 JWT）

**实例**：[main/fastapi-backend/app/utils/auth.py:43-70](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main/fastapi-backend/app/utils/auth.py)

3 种 JWT，用 `type` 字段区分：

```python
def create_jwt_token(user_id, email):
    # type = None (普通用户)
    return jwt.encode({"sub": user_id, "email": email, "exp": expire}, SECRET, HS256)

def create_doctor_jwt_token(doctor_id, email):
    return jwt.encode({"sub": str(doctor_id), "email": email, "exp": expire, "type": "doctor"}, ...)

def create_skinbox_jwt_token(staff_id, email):
    return jwt.encode({"sub": str(staff_id), "email": email, "exp": expire, "type": "skinbox"}, ...)
```

3 个 dependency 函数：`get_current_user` / `get_current_doctor` / `get_current_skinbox_user`。

⚠️ JWT 直接长 expire（user `129600` 分钟 ≈ 90 天）—— 不分 access/refresh，靠 middleware 自动续期。

### Token 自动刷新 Middleware（✅ Kevin 自创亮点）

**实例**：[main/fastapi-backend/app/middleware/token_refresh.py](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main/fastapi-backend/app/middleware/token_refresh.py)

**模式**：
1. 用户请求带旧 token
2. middleware 检查剩余时间 < 阈值（user 3000 分钟，doctor 6000 分钟）
3. 生成新 token 注入 response header：
   ```
   X-New-Token: <new_jwt>
   X-Token-Refreshed: true
   X-Token-Type: user
   ```
4. 前端 axios response interceptor 检测 header → 更新 store

**性能优化**：
- 跳过 `/docs` `/health` `/static/` 等公开路径
- 只处理含 Authorization header 的请求
- 只处理 200 响应（404/401 不刷）

✅ **vs 传统 refresh token**：少一个 endpoint，少一次往返，对单页应用 / 移动 app 都适用。**新项目可直接复用此模式**。

### Pydantic Schemas

**实例**：[main/fastapi-backend/app/schemas/analysis.py:42-80](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main/fastapi-backend/app/schemas/analysis.py)

```python
class AnalysisRow(BaseModel):
    id: int
    user_id: Optional[int]
    dryness_level: Optional[float]
    # ...
    model_config = ConfigDict(from_attributes=True)  # Pydantic v2 ORM mode
```

✅ 字段保持 snake_case，**不做 camelCase 转换**——前端直接收 snake_case。

### 配置（pydantic-settings）

**实例**：[main/fastapi-backend/app/core/config.py:18-60](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main/fastapi-backend/app/core/config.py)

```python
class Settings(BaseSettings):
    app_env: str = Field(default="development", alias="APP_ENV")
    jwt_secret_key: str = Field(default="change-me", alias="JWT_SECRET_KEY")
    postgres_connection_url: Optional[str] = Field(default=None, alias="POSTGRES_CONNECTION_URL")
    # ...
    model_config = SettingsConfigDict(env_file=None, case_sensitive=False, extra="ignore")
```

env 文件按 `APP_ENV` 选：`config/environments/{development,production,test}.env`，由 `python-dotenv` 在 config.py 顶部 load。

启动时打印**全部环境变量**到 stdout：[main.py:38-41](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main/fastapi-backend/app/main.py) → `print_all_env_vars()`。✅ 方便调试，但**不要在生产打印密钥**——Venus 现在还在打。

### AI / Chat 集成（OpenAI + LangChain + Pinecone）

⚠️ Venus 用 OpenAI（客户锁定），不是 Kevin 偏好的 Anthropic。

- 主 AI client：[main/fastapi-backend/app/utils/openai_chat.py](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main/fastapi-backend/app/utils/openai_chat.py)
- RAG：`langchain` + `langchain-pinecone` + `sentence-transformers`
- Chat tools：[main/fastapi-backend/app/services/chat_tools_manager_pinecone.py](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main/fastapi-backend/app/services/chat_tools_manager_pinecone.py)
- 人脸分析：独立 service `ai-skin-analysis`，Roboflow + MediaPipe + 自研 PigmentationService

✅ Kevin 新项目首选 **Anthropic SDK + prompt caching**，Venus 是历史包袱。

---

## task-service（cron 单一入口）

### 设计理念

✅ **所有定时任务 / 一次性脚本必须注册到这里**，不准在 `fastapi-backend` 或仓库根目录写 standalone script。这是 main/CLAUDE.md 明确的规则。

### Registry 模式

**实例**：[main/task-service/task_service/jobs/registry.py](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main/task-service/task_service/jobs/registry.py)

```python
@dataclass
class RecurringJobSpec:
    module: str
    func: Callable
    job_id: str
    name: str
    cron_kwargs: Dict[str, Any]

@dataclass
class OneOffJobSpec:
    module: str
    func: Callable
    job_id: str
    name: str
    idempotency_key: str

RECURRING_JOBS: List[RecurringJobSpec] = []
ONE_OFF_JOBS: List[OneOffJobSpec] = []
```

**任务文件**：`jobs/recurring/<name>.py`，每个 export 一个函数。
**注册**：在 `jobs/recurring/__init__.py` 集中 append 到 `RECURRING_JOBS`。

**实例**：[main/task-service/task_service/jobs/recurring/__init__.py:41-160](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main/task-service/task_service/jobs/recurring/__init__.py)

```python
RECURRING_JOBS.extend([
    RecurringJobSpec(
        module=__name__,
        func=generate_weekly_user_recommendations_v2,
        job_id="generate_weekly_user_recommendations_v2",
        name="generate_weekly_user_recommendations_v2",
        cron_kwargs={"day_of_week": "mon", "hour": "6", "minute": "30"},
    ),
    # ...
])
```

### CLI（Typer）

**实例**：[main/task-service/task_service/cli.py](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main/task-service/task_service/cli.py)

```bash
python -m task_service.cli serve --host 0.0.0.0 --port 9200  # HTTP + scheduler
python -m task_service.cli start-scheduler                    # scheduler only
python -m task_service.cli list-jobs                          # 列出所有注册任务
python -m task_service.cli run <task_name>                    # 手动跑一次
python -m task_service.cli migrate upgrade --env staging
```

### Session 模式（task 内部）

每个 task 函数自己开 SessionLocal，**不共享 session**：

```python
def daily_streak_check():
    db_generator = get_db()
    db = next(db_generator)
    try:
        # 业务
        db.commit()
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()
```

### 重试装饰器（tenacity）

**实例**：[main/task-service/task_service/services/core/retry_service.py](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main/task-service/task_service/services/core/retry_service.py)

```python
@with_retry(attempts=5, retry_on=(httpx.HTTPError, ConnectionError))
def flaky_task():
    pass

# 或组合 retry + timeout
@resilient_task(attempts=5, timeout_seconds=600)
async def long_task():
    pass
```

✅ **新项目可直接复用** `with_retry` 装饰器（基于 tenacity，wait_exponential）。

### Alembic 多环境

task-service 有 3 套 alembic config：`alembic.ini`（shared）/ `alembic.staging.ini` / `alembic.production.ini`。
Migration 文件分目录：`alembic/versions/` / `alembic/versions_staging/` / `alembic/versions_production/`。

✅ 设计意图：staging 上能测试新 migration，不污染 shared 主线，待稳定后合并。

---

## ai-skin-analysis（人脸分析微服务）

**实例**：[main/ai-skin-analysis/app/main.py](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main/ai-skin-analysis/app/main.py)

✅ **关键模式**：startup 时**强制初始化 ML 模型**，失败则 app 启动失败（不允许 broken 模型）：

```python
@app.on_event("startup")
async def startup_event():
    try:
        face_analysis.initialize_models()
        if not face_analysis.models_initialized:
            raise RuntimeError("Models initialization completed but flag is False")
        face_analysis.get_pigmentation_service()  # singleton
    except Exception as e:
        logger.error(f"Failed to initialize models: {e}")
        raise RuntimeError(f"Model initialization failed: {str(e)}") from e
```

`/health` endpoint 返回 `models_initialized` 状态，给 load balancer 用。

**Pipeline**：upload → RGB → 并行 Roboflow 模型推理（acne / wrinkles / redness / eye bags）+ MediaPipe ROI → pore 检测（LoG/DoG/Adaptive Threshold）→ PyTorch pigmentation segmentation → score 聚合。

✅ **新 AI 项目可借鉴**：模型初始化失败 → app 起不来，让 k8s/docker 重启策略接管。

---

## 部署 / DevOps

### Docker Compose

**fastapi-backend**：[main/fastapi-backend/docker-compose.yml](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main/fastapi-backend/docker-compose.yml)

```yaml
services:
  venus-backend:
    build: .
    ports: ["8000:80"]
    networks:
      venus-network:
      venus-internal:    # 跨 compose 共享网络
        aliases:
          - venus-backend
networks:
  venus-internal:
    external: true       # 主机上一次性创建：docker network create venus-internal
```

✅ **跨 compose 通信模式**：`external: true` 网络 + 服务 alias。新项目要做"多 service 单 host 部署"时复用。

### 平台

- **VPS（宝塔面板）**：3 个后端服务 + 反代
- **Vercel**：venus-skincare-box（Next.js 自动部署）
- **EAS**：RN app（preview / production channel）

### CI/CD

- 分支：`dev` → development / `staging` → preview / `master` → production
- staging 分支自动 deploy 后端，master 手动
- husky pre-commit 阻止 push `main`

### 监控

- **Sentry**：RN 端深度集成（[App.tsx](file:///Users/wkui/Project/work/upwork/2025/4-6-rn-ai/main/venus-react-native-app/App.tsx) 初始化 `sentryNavigationIntegration`），用户身份在 setUserInfo 时同步
- **后端无 Sentry**：只有 logger 写日志文件（`logs/` 目录）
- **应用层日志**：startup 时 print 所有 env vars（debug 用）

---

## 测试

✅ Kevin 实际投入测试的优先级：**业务关键 pytest > RN E2E（maestro） > 单元测试 > web 测试（基本没有）**

- `fastapi-backend/tests/`：有 pytest 文件但覆盖薄
- `task-service/tests/`：少量
- `ai-skin-analysis/tests/`：少量
- `venus-react-native-app/maestro_e2e/`：E2E 配置文件
- 3 个 web 项目：**无测试框架**（package.json 里没 jest / vitest / playwright）

新项目如果时间紧，Venus 的优先级可以参考。

---

## 关键 file 速查（拷贝模板时用）

| 想抄什么 | 看哪个文件 |
|---|---|
| Zustand root + slice + persist | `main/venus-react-native-app/src/store/root.ts` |
| Zustand slice 写法 | `main/venus-react-native-app/src/store/userStore.ts` |
| axios + interceptor + 无感刷新 token | `main/venus-react-native-app/src/store/api/` 全部 |
| RN navigation 模块化 | `main/venus-react-native-app/src/navigation/AppNavigator.tsx` |
| vision-camera 黑屏恢复 hook | `main/venus-react-native-app/src/hooks/useVisionCamera.ts` |
| RN app.config.js（含 Sentry/Branch/IAP） | `main/venus-react-native-app/app.config.js` |
| FastAPI main + middleware | `main/fastapi-backend/app/main.py` |
| 路由自动发现 | `main/fastapi-backend/app/api/v1/router.py` |
| Route handler 三段式错误 | `main/fastapi-backend/app/api/v1/routes/analysis.py` |
| 多类型 JWT auth | `main/fastapi-backend/app/utils/auth.py` |
| Token 自动刷新 middleware | `main/fastapi-backend/app/middleware/token_refresh.py` |
| Pydantic v2 schema | `main/fastapi-backend/app/schemas/analysis.py` |
| pydantic-settings config | `main/fastapi-backend/app/core/config.py` |
| SQLAlchemy 同步 Session | `main/fastapi-backend/app/db/session.py` |
| APScheduler registry 模式 | `main/task-service/task_service/jobs/registry.py` |
| Tenacity retry 装饰器 | `main/task-service/task_service/services/core/retry_service.py` |
| Typer CLI 多命令 | `main/task-service/task_service/cli.py` |
| ML 模型 startup 初始化 | `main/ai-skin-analysis/app/main.py` |
| Next.js + Context auth | `main-web/venus-skin-review/components/auth-provider.tsx` |
| HTTPS proxy 模式 | `main-web/venus-skin-review/lib/utils/api-config.ts` |
| 手写 fetch API service | `main-web/venus-skin-review/lib/services/doctor-api.ts` |
| Vite + react-router + lazy | `main-web/venus-internal-admin/src/router/index.tsx` |
| Vite admin 的 Zustand | `main-web/venus-internal-admin/src/store/root.ts` |
| Docker compose 跨 compose 通信 | `main/fastapi-backend/docker-compose.yml` |

---

## 新项目快速决策表

| 场景 | 选什么 | 为什么 |
|---|---|---|
| 新 RN app | Expo 53 + zustand + axios + vision-camera | Venus 全套已稳定 |
| 新 web admin（重交互） | Vite + react-router 6 + zustand + shadcn/ui | Venus internal-admin 模板 |
| 新公开 web | Next.js 15 + Tailwind（不要 shadcn 那么重） | tianda-web 模式 |
| 新 FastAPI 后端（个人项目） | **async** SQLAlchemy + Alembic + Anthropic | tianda-web 模式（不抄 Venus） |
| 新 FastAPI 后端（客户项目，要兼容旧栈） | 同步 SQLAlchemy + 手写 SQL + OpenAI | Venus 模式 |
| cron 任务 | APScheduler + 自封装 registry（抄 task-service） | 优于 Celery（无 broker 依赖） |
| AI 推理服务 | 独立 FastAPI + startup 强制初始化模型 | 同 ai-skin-analysis |
| 跨服务通信 | docker network external + service alias | 同 venus-internal |
| Token 刷新 | 自创 middleware 注入 X-New-Token header | 优于 access+refresh 双 token |
| 多语言 RN | Lingui v5 + husky pre-commit | 同 Venus |
| 多语言 web | 自研 i18n（小而轻） / Lingui（重项目） | Venus 两种都用 |
