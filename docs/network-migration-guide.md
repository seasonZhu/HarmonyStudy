# Network 模块迁移指南

## 迁移背景

将 HarmonyStudy 项目从混合架构（httpRequest + network）演进为清晰的 MVVM + Repository 架构，统一网络层到 network 模块。

## 架构演进

### 迁移前
```
Page → ViewModel → httpRequest/Provider → Axios
                    ↘ network/HttpClient → Axios
```

### 迁移后
```
Page → ViewModel → Repository → network/HttpClient → Axios
```

## 迁移模式

### 1. Repository 层

**职责**：
- 封装网络请求细节
- 转换 API 响应为业务模型
- 处理错误码检查
- 提供统一的数据访问接口

**模板**：
```typescript
import { BaseRepository } from './base/BaseRepository'
import { ApiConstants } from '../../network/src/main/ets/constants/ApiConstants'
import { LogUtil } from '@pura/harmony-utils'

export class XxxRepository extends BaseRepository {
  async getXxxData(): Promise<XxxModel[]> {
    try {
      const response = await this.httpClient.get<XxxModel[]>(
        ApiConstants.XXX_URL
      )
      
      // 检查错误码
      if (response.errorCode !== 0) {
        LogUtil.error(`XxxRepository: API 错误，errorCode=${response.errorCode}`)
        throw new Error(response.errorMsg || '请求失败')
      }
      
      LogUtil.debug(`XxxRepository: 获取数据成功，数量=${response.data.length}`)
      return response.data
    } catch (error) {
      this.handleError(error as ApiError)
      throw error as Error
    }
  }
}
```

### 2. ViewModel 层

**职责**：
- 处理页面业务逻辑
- 调用 Repository 获取数据
- 返回业务模型给 Page

**模板**：
```typescript
import { XxxRepository } from '../repository/XxxRepository'
import { XxxModel } from '../model/XxxModel'
import { LogUtil } from '@pura/harmony-utils'

export class XxxViewModel {
  private xxxRepo = new XxxRepository()
  
  getXxxData = async (): Promise<XxxModel[]> => {
    LogUtil.debug('XxxViewModel: 获取数据')
    return this.xxxRepo.getXxxData()
  }
}
```

### 3. Page 层

**职责**：
- UI 渲染
- 调用 ViewModel
- 处理加载状态

**模板**：
```typescript
@Entry({routeName: RouterName.Xxx})
@ComponentV2
struct XxxPage {
  @Local dataSource: BaseListDataSource<XxxModel> = new BaseListDataSource<XxxModel>()
  @Local status: ViewStatus = ViewStatus.loading
  viewModel = new XxxViewModel()

  async aboutToAppear(): Promise<void> {
    await this.reloadData()
  }

  private async reloadData(): Promise<void> {
    try {
      const data: XxxModel[] = await this.viewModel.getXxxData()
      this.dataSource.refreshData(data)
      
      if (data.length === 0) {
        this.status = ViewStatus.empty
      } else {
        this.status = ViewStatus.success
      }
    } catch (error) {
      LogUtil.error("XxxPage load error: " + JSON.stringify(error))
      this.status = ViewStatus.error
    }
  }
}
```

## 关键技术点

### 1. 错误处理

**Repository 层**：
- 检查 `response.errorCode`
- 如果 `!== 0`，抛出错误
- 使用 `this.handleError()` 统一处理

**ViewModel 层**：
- 不处理错误，直接抛出
- 让 Page 层统一处理

**Page 层**：
- 使用 try-catch 捕获错误
- 设置 `status = ViewStatus.error`

### 2. 登录态处理

**CookieInterceptor**：
```typescript
export class CookieInterceptor implements Interceptor {
  intercept(config: InternalAxiosRequestConfig): InternalAxiosRequestConfig {
    const accountManager = globalThis.accountManager
    if (accountManager?.isLogin()) {
      const cookie = accountManager.getLoginCookie()
      if (cookie) {
        config.headers.Cookie = cookie
      }
    }
    return config
  }
}
```

**使用方式**：
- 在 `BaseRepository` 中注册拦截器
- 自动为所有请求添加登录 Cookie

### 3. 分页数据

**BaseListDataSource 增强**：
```typescript
class BaseListDataSource<T> {
  // 刷新数据（清空旧数据）
  refreshData(newData: T[]): void {
    this.originData = []
    newData.forEach(item => this.addData(item))
    this.notifyDataReload()
  }
  
  // 加载更多（追加数据）
  loadMoreData(newData: T[]): void {
    newData.forEach(item => this.addData(item))
    this.notifyDataAdd(this.originData.length - newData.length)
  }
}
```

### 4. 数据转换

**网络响应 → 业务模型**：
```typescript
// network 模块返回 ApiResponse<T>
interface ApiResponse<T> {
  data: T
  errorCode: number
  errorMsg: string
}

// Repository 转换为业务模型
async getData(): Promise<XxxModel[]> {
  const response = await this.httpClient.get<XxxModel[]>(url)
  if (response.errorCode !== 0) {
    throw new Error(response.errorMsg)
  }
  return response.data  // 直接返回 data
}
```

## 迁移步骤

### 单个 ViewModel 迁移流程

1. **创建 Repository**
   - 继承 `BaseRepository`
   - 实现数据获取方法
   - 添加错误码检查

2. **修改 ViewModel**
   - 删除 `httpRequest/Provider` 导入
   - 导入对应的 Repository
   - 修改方法返回类型（去掉 `AxiosResponse` 包装）
   - 调用 Repository 方法

3. **修改 Page**
   - 删除 `AxiosResponse`、`BaseResponse` 导入
   - 修改数据处理逻辑（直接使用业务模型）
   - 使用 `dataSource.refreshData()` 或 `dataSource.loadMoreData()`

4. **测试验证**
   - 构建项目：`build_project`
   - 运行应用：`start_app`
   - 测试功能是否正常

5. **提交代码**
   ```bash
   git add .
   git commit -m "feat: 完成 XxxViewModel 迁移到 network 模块"
   ```

## 已完成迁移

| ViewModel | Repository | Page | 状态 | 备注 |
|-----------|-----------|------|------|------|
| RankViewModel | RankRepository | Rank.ets | ✅ | 积分排名 |
| MyCoinViewModel | MyCoinRepository | MyCoin.ets | ✅ | 我的积分，需要登录 |
| HotKeyViewModel | HotKeyRepository | HotKey.ets | ✅ | 热门关键词 |

## 待迁移列表

| ViewModel | 复杂度 | 优先级 | 备注 |
|-----------|--------|--------|------|
| SearchResultViewModel | 中 | 高 | 搜索结果，分页列表 |
| TabsDetailViewModel | 中 | 高 | 标签详情，分页列表 |
| MyCollectViewModel | 中 | 中 | 我的收藏，分页列表，需要登录 |
| HomeViewModel | 高 | 低 | 首页，多个数据源，最复杂 |
| LoginViewModel | 高 | 低 | 认证相关，特殊处理 |

## 注意事项

### 1. ArkTS 限制

- ❌ 不支持 `any`、`unknown` 类型
- ❌ 不支持 `as` 类型断言（除 `throw error as Error`）
- ❌ 不支持 spread 操作符 `{...obj}`
- ❌ 不支持动态属性访问 `obj[key]`
- ✅ 必须使用显式类型
- ✅ 必须使用显式继承

### 2. 路由系统

- 页面文件名（去掉.ets）必须等于 `RouterName` 枚举值
- 使用 `Router.push()` 或 `navPathStack.pushPath()` 进行跳转

### 3. 网络请求

- network 模块返回 `ApiResponse<T>`
- httpRequest 模块返回 `AxiosResponse<BaseResponse<T>>`
- 注意数据结构差异

### 4. Git 分支管理

- 使用 `feature/network-migration` 分支
- 每个 ViewModel 迁移完成后提交
- 所有迁移完成后合并到主分支

## 测试验证

### 功能测试清单

- [ ] 数据加载正常
- [ ] 错误处理正确
- [ ] 空数据显示正常
- [ ] 分页加载正常（如适用）
- [ ] 登录态处理正确（如需要）
- [ ] 页面跳转正常

### 性能对比

参考 `docs/network-comparison-report.md`：
- network 模块性能优于 httpRequest 模块
- 平均响应时间更快
- 内存占用更低

## 后续工作

### 阶段三：提取通用组件为 HAR 包

- 识别可复用的 UI 组件
- 创建 HAR 包项目
- 迁移组件到 HAR 包
- 更新依赖关系

### 阶段四：清理旧代码

- 删除 `entry/src/main/ets/httpRequest/` 目录
- 删除 `entry/src/main/ets/network/` 目录（已迁移到 network 模块）
- 更新导入路径
- 运行全量测试

## 参考资料

- [ArkTS 语法规范](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-getting-started-V5)
- [ArkUI 组件开发](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkui-overview-V5)
- [网络请求开发](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/http-overview-V5)
