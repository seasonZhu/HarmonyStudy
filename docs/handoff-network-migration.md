# HarmonyStudy Network Migration Handoff - 2026-08-17

## 当前状态

**分支**: `feature/network-migration`
**阶段**: 阶段二 - 迁移 ViewModel 到 network 模块
**进度**: 6/8 ViewModel 已完成，HomeViewModel 进行中

## 已完成工作

### 1. Repository 层创建 ✅
- `BaseRepository.ets` - 基类，统一 HTTP 客户端和错误处理，重新导出 ApiError
- `RankRepository.ets` - 积分排名数据仓库
- `MyCoinRepository.ets` - 我的积分数据仓库
- `HotKeyRepository.ets` - 热门关键词数据仓库
- `SearchResultRepository.ets` - 搜索结果数据仓库
- `TabsDetailRepository.ets` - 标签详情数据仓库
- `MyCollectRepository.ets` - 我的收藏数据仓库
- `HomeRepository.ets` - 首页数据仓库（Banner、置顶文章、普通文章）

### 2. ViewModel 迁移 ✅
- `RankViewModel` → 使用 RankRepository
- `MyCoinViewModel` → 使用 MyCoinRepository
- `HotKeyViewModel` → 使用 HotKeyRepository
- `SearchResultViewModel` → 使用 SearchResultRepository
- `TabsDetailViewModel` → 使用 TabsDetailRepository
- `MyCollectViewModel` → 使用 MyCollectRepository
- `HomeViewModel` → 使用 HomeRepository（进行中）

### 3. Page 层适配 ✅
- `Rank.ets` - 已适配新数据结构
- `MyCoin.ets` - 已适配新数据结构
- `HotKey.ets` - 已适配新数据结构
- `SearchResult.ets` - 已适配新数据结构
- `TabsDetail.ets` - 已适配新数据结构
- `MyCollect.ets` - 已适配新数据结构
- `Home.ets` - 待适配

### 4. 关键技术实现 ✅
- 创建 `CookieInterceptor.ets` - 自动添加登录 Cookie
- 在 Repository 层检查 `errorCode` 并抛出错误
- 增强 `BaseListDataSource` - 添加 refreshData() 和 loadMoreData() 方法
- 创建迁移文档 `docs/network-migration-guide.md`

## 待完成工作

### HomeViewModel 迁移（进行中）

**已完成**：
- ✅ 创建 HomeRepository
- ✅ 修改 HomeViewModel

**待完成**：
- ⏳ 修改 `Home.ets` 页面适配新数据结构
- ⏳ 测试验证

**Home.ets 页面位置**：
- `entry/src/main/ets/pages/Home.ets`

**关键点**：
- 首页包含三个数据源：Banner、置顶文章、普通文章
- 刷新时需要同时获取三个数据源
- 加载更多只获取普通文章
- 需要合并置顶文章和普通文章显示

### LoginViewModel 迁移（未开始）

**文件位置**：
- `entry/src/main/ets/viewModel/LoginViewModel.ets`

**特殊处理**：
- 登录操作涉及认证
- 需要保存登录信息到 AccountManager
- 可能需要特殊处理 Cookie

### 后续阶段

**阶段三**: 提取通用组件为 HAR 包
**阶段四**: 清理旧代码（删除 httpRequest/ 目录）

## 迁移模式（已验证）

```
1. 创建 Repository（继承 BaseRepository）
   - 导入：import { BaseRepository, ApiError } from './base/BaseRepository'
   - 导入：import { ApiConstants } from '../constants/ApiConstants'
   - 检查 errorCode：if (response.errorCode !== 0) { throw new Error(response.errorMsg) }
   - 抛出错误：throw error as Error

2. 修改 ViewModel（使用 Repository）
   - 删除 httpRequest/Provider 导入
   - 导入对应的 Repository
   - 修改方法返回类型（去掉 AxiosResponse 包装）
   - 调用 Repository 方法

3. 修改 Page（适配新数据结构）
   - 删除 AxiosResponse、BaseResponse 导入
   - 使用 dataSource.refreshData() 或 dataSource.loadMoreData()
   - 处理错误：throw error as Error

4. 构建测试
   - 运行 build_project

5. 提交代码
   - git add . && git commit -m "feat: 完成 XxxViewModel 迁移"
```

## 明天继续工作的步骤

### 1. 恢复工作环境
```bash
cd /Users/dy/Documents/HarmonyOS/HarmonyStudy
git checkout feature/network-migration
git pull
```

### 2. 完成 HomeViewModel 迁移
```bash
# 读取 Home.ets 页面
# 修改数据处理逻辑，适配新的 HomeRefreshResult 结构
# 构建测试：build_project
# 提交代码
```

### 3. 迁移 LoginViewModel
```bash
# 创建 LoginRepository
# 修改 LoginViewModel
# 修改 Login.ets 页面
# 构建测试
# 提交代码
```

### 4. 完成阶段二
```bash
# 更新迁移文档
# 运行全量测试
# 合并到主分支（可选）
```

## 技术要点提醒

### 1. 错误处理
```typescript
// Repository 层检查 errorCode
if (response.errorCode !== 0) {
  throw new Error(response.errorMsg || '请求失败')
}

// Page 层处理错误
catch (error) {
  LogUtil.error("Error: " + JSON.stringify(error))
  this.status = ViewStatus.error
  throw error as Error
}
```

### 2. 数据转换
```typescript
// network 返回 ApiResponse<T>
// Repository 返回 T（业务模型）
// ViewModel 返回 T
// Page 使用 T
```

### 3. 分页数据
```typescript
// 刷新数据
this.listDataSource.refreshData(pageData.datas)

// 加载更多
this.listDataSource.loadMoreData(pageData.datas)
```

### 4. 首页特殊处理
```typescript
// 刷新时获取三个数据源
const result: HomeRefreshResult = await this.viewModel.refreshRequest()
this.bannerDataSource.refreshData(result.banners)

// 合并置顶文章和普通文章
const allArticles = [...result.hotArticles, ...result.normalArticles.datas]
this.articleDataSource.refreshData(allArticles)
```

## 注意事项

- ✅ 每个 ViewModel 迁移前先读取原文件，理解数据流
- ✅ 注意分页数据的处理（page、pageSize）
- ✅ 注意登录态相关的 ViewModel（MyCollect、Login）
- ✅ 迁移完成后运行 `build_project` 验证
- ✅ 所有迁移完成后合并到主分支
- ⚠️ HomeViewModel 最复杂，需要仔细处理多数据源合并
- ⚠️ LoginViewModel 涉及认证，需要特殊处理

## 建议的 Skills

1. **harmony-next** - HarmonyOS 开发帮助
2. **arkts-error-fixes** - ArkTS 编译错误修复
3. **arkui-knowledge** - ArkUI 组件知识
