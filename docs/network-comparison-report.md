# 网络层对比测试报告

## 测试目的

对比 `httpRequest` 模块和 `network` 模块的功能和性能，为渐进式迁移到 `network` 模块提供数据支持。

## 测试环境

- **测试时间**：待执行
- **测试分支**：`feature/network-migration`
- **测试页面**：`NetworkComparisonPage.ets`
- **访问路径**：我的 → 网络层对比测试

## 测试内容

### 1. 文章列表接口测试

**接口**：`GET /article/list/{page}/json`

**测试点**：
- ✅ 响应时间对比
- ✅ 响应数据一致性
- ✅ 分页功能
- ✅ 错误处理

**预期结果**：
- 两个模块返回相同的数据
- 响应时间差异在合理范围内（±50ms）
- 错误处理机制一致

### 2. 排行榜接口测试

**接口**：`GET /coin/rank/{page}/json`

**测试点**：
- ✅ 响应时间对比
- ✅ 响应数据一致性
- ✅ 分页功能

### 3. 轮播图接口测试

**接口**：`GET /banner/json`

**测试点**：
- ✅ 响应时间对比
- ✅ 响应数据一致性

### 4. 热门关键词接口测试

**接口**：`GET /hotkey/json`

**测试点**：
- ✅ 响应时间对比
- ✅ 响应数据一致性

### 5. 错误场景测试

**测试点**：
- ✅ 无效URL错误处理
- ✅ 网络超时处理
- ✅ 401错误处理

## 测试结果

### 待执行测试

请按照以下步骤执行测试：

1. **启动应用**
   ```bash
   # 在 DevEco Studio 中运行应用
   ```

2. **访问测试页面**
   - 进入"我的"页面
   - 点击"网络层对比测试"

3. **执行测试**
   - 点击"开始所有测试"按钮
   - 等待所有测试完成
   - 查看测试结果

4. **记录结果**
   - 将测试结果截图保存
   - 记录响应时间数据
   - 记录任何异常情况

### 测试结果记录模板

| 测试项 | httpRequest 耗时 | network 耗时 | 差异 | 状态 | 备注 |
|--------|------------------|--------------|------|------|------|
| 文章列表 | - ms | - ms | - ms | 待测试 | - |
| 排行榜 | - ms | - ms | - ms | 待测试 | - |
| 轮播图 | - ms | - ms | - ms | 待测试 | - |
| 热门关键词 | - ms | - ms | - ms | 待测试 | - |
| 错误场景 | - ms | - ms | - ms | 待测试 | - |

## 功能对比

### httpRequest 模块

**优点**：
- ✅ 已在项目中广泛使用（43处）
- ✅ 稳定可靠
- ✅ 开发团队熟悉

**缺点**：
- ❌ 功能较少（仅支持 GET/POST）
- ❌ 无重试机制
- ❌ 无统一加载提示
- ❌ 错误处理较简单

### network 模块

**优点**：
- ✅ 功能完善（支持 GET/POST/PUT/DELETE/PATCH）
- ✅ 有重试机制
- ✅ 统一加载提示管理
- ✅ 完善的错误处理机制
- ✅ API 设计更清晰（ApiResponse vs AxiosResponse）

**缺点**：
- ❌ 在项目中使用较少（仅7处）
- ❌ 需要迁移成本

## 迁移风险评估

### 高风险项

1. **认证相关接口**
   - 登录、注册、Token 管理
   - 需要特别测试 Cookie 和 Token 拦截器

2. **收藏相关接口**
   - 需要登录态
   - 需要测试 Token 自动添加

### 中风险项

1. **分页接口**
   - 需要测试分页逻辑一致性
   - 需要测试上拉加载更多

2. **错误处理**
   - 需要确保错误提示一致
   - 需要测试网络断开场景

### 低风险项

1. **只读接口**
   - 文章列表、排行榜等
   - 无副作用，易于回滚

## 下一步计划

### 阶段一：完善测试（当前阶段）

- [x] 创建对比测试页面
- [ ] 执行测试并记录结果
- [ ] 分析差异和风险
- [ ] 完善network模块配置（如有必要）

### 阶段二：试点迁移

- [ ] 选择 RankViewModel 作为试点
- [ ] 创建 RankRepository
- [ ] 迁移 RankViewModel 使用 Repository
- [ ] 测试功能完整性
- [ ] 总结迁移经验

### 阶段三：批量迁移

- [ ] 迁移 MyCoinViewModel
- [ ] 迁移 HotKeyViewModel
- [ ] 迁移 SearchResultViewModel
- [ ] 迁移 TabsDetailViewModel
- [ ] 迁移 MyCollectViewModel
- [ ] 迁移 HomeViewModel
- [ ] 迁移 LoginViewModel

### 阶段四：清理旧代码

- [ ] 确认所有功能正常
- [ ] 删除 httpRequest/ 目录
- [ ] 更新文档

## 注意事项

1. **渐进式迁移**
   - 每次只迁移一个 ViewModel
   - 每次迁移后进行完整测试
   - 保留旧代码，直到所有迁移完成

2. **Git 分支管理**
   - 在 `feature/network-migration` 分支上开发
   - 每个阶段完成后创建 tag
   - 随时可以回滚到上一个稳定版本

3. **团队沟通**
   - 及时同步迁移进度
   - 记录遇到的问题和解决方案
   - 定期review代码

## 附录

### A. 两个模块的 API 对比

#### httpRequest 模块

```typescript
// 使用方式
import provider from '../httpRequest/Provider'

const response = await provider.get<BaseResponse<PageModel<Article>>>(
  ApiConstants.articleList(page)
)

// 返回类型
Promise<AxiosResponse<BaseResponse<T>>>

// 访问数据
const articles = response.data.data.datas
```

#### network 模块

```typescript
// 使用方式
import { getHttpClient } from 'network'

const httpClient = getHttpClient()
const response = await httpClient.get<PageModel<Article>>(
  ApiConstants.articleList(page)
)

// 返回类型
Promise<ApiResponse<T>>

// 访问数据
const articles = response.data.datas
```

### B. 迁移示例

**迁移前**：

```typescript
// RankViewModel.ets
import provider from '../httpRequest/Provider'

export class RankViewModel {
  async getRank(page: number): Promise<AxiosResponse<BaseResponse<PageModel<RankModel>>>> {
    return provider.get(ApiConstants.coinRank(page))
  }
}

// Rank.ets
const result = await this.viewModel.getRank(page)
const ranks = result.data.data.datas
```

**迁移后**：

```typescript
// repository/RankRepository.ets
export class RankRepository extends BaseRepository {
  async getRankList(page: number): Promise<RankModel[]> {
    const response = await this.httpClient.get<PageModel<RankModel>>(
      ApiConstants.coinRank(page)
    )
    return response.data.datas
  }
}

// RankViewModel.ets
export class RankViewModel {
  private rankRepo = new RankRepository()
  
  async getRank(page: number): Promise<RankModel[]> {
    return this.rankRepo.getRankList(page)
  }
}

// Rank.ets
const ranks = await this.viewModel.getRank(page)
```

---

**文档版本**：v1.0  
**最后更新**：2026-08-17  
**负责人**：开发团队
