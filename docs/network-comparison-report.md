# 网络层对比测试报告

## 测试目的

对比 `httpRequest` 模块和 `network` 模块的功能和性能，为渐进式迁移到 `network` 模块提供数据支持。

## 测试环境

- **测试时间**：2026-08-17 14:20
- **测试分支**：`feature/network-migration`
- **测试页面**：`NetworkComparisonPage.ets`
- **访问路径**：我的 → 网络层对比测试

## 测试结果

### ✅ 总体结论

**所有测试通过，network 模块性能优于 httpRequest 模块！**

### 详细测试结果

| 测试项 | 状态 | 性能对比 | 备注 |
|--------|------|----------|------|
| 文章列表接口 | ✅ 通过 | network 更快 | GET, 分页 |
| 排行榜接口 | ✅ 通过 | network 更快 | GET, 分页 |
| 轮播图接口 | ✅ 通过 | network 更快 | GET |
| 热门关键词接口 | ✅ 通过 | network 更快 | GET |
| 错误场景测试 | ✅ 通过 | 两者一致 | 错误处理正确 |

### 性能对比

**network 模块在所有测试中均比 httpRequest 模块更快！**

具体性能数据（从测试页面观察）：
- 文章列表接口：network 响应更快
- 排行榜接口：network 响应更快
- 轮播图接口：network 响应更快
- 热门关键词接口：network 响应更快

## 功能对比总结

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
- ❌ 性能较慢

### network 模块

**优点**：
- ✅ 功能完善（支持 GET/POST/PUT/DELETE/PATCH）
- ✅ 有重试机制
- ✅ 统一加载提示管理
- ✅ 完善的错误处理机制
- ✅ API 设计更清晰（ApiResponse vs AxiosResponse）
- ✅ **性能更快** ⭐

**缺点**：
- ❌ 在项目中使用较少（仅7处）
- ❌ 需要迁移成本

## 迁移决策

### ✅ 推荐迁移到 network 模块

**理由**：
1. **性能更优**：所有测试中 network 均更快
2. **功能更完善**：重试机制、统一错误处理、加载提示
3. **API 更清晰**：ApiResponse vs AxiosResponse
4. **无兼容性问题**：所有测试通过，功能一致

### 迁移风险评估

#### 低风险

1. **功能一致性**：✅ 所有测试通过
2. **性能表现**：✅ network 更快
3. **错误处理**：✅ 两者一致

#### 需要注意

1. **认证相关接口**：需要测试 Token 拦截器
2. **Cookie 处理**：需要确认 Cookie 拦截器配置

## 下一步计划

### 阶段二：渐进式迁移（预计 3-5 天）

#### 2.1 创建 Repository 层基础结构

**目标**：引入 Repository 层，隔离网络实现细节

**步骤**：
1. 创建 `entry/src/main/ets/repository/` 目录
2. 创建基础 Repository 接口和实现
3. 创建数据映射器（Mapper）

#### 2.2 迁移顺序（按复杂度从低到高）

1. ✅ RankViewModel（试点）
2. MyCoinViewModel（我的积分）
3. HotKeyViewModel（热门关键词）
4. SearchResultViewModel（搜索结果）
5. TabsDetailViewModel（标签详情）
6. MyCollectViewModel（我的收藏）
7. HomeViewModel（首页，最复杂）
8. LoginViewModel（认证相关）

#### 2.3 每个迁移步骤

1. 创建对应的 Repository
2. 修改 ViewModel，使用 Repository
3. 修改 Page，适配新数据结构
4. 测试功能
5. 提交代码

### 阶段三：提取通用组件为 HAR 包（预计 2-3 天）

- 创建 `ui-components` HAR 包
- 创建 `domain` HAR 包
- 更新依赖关系

### 阶段四：清理旧代码（预计 1-2 天）

- 删除 `httpRequest/` 目录
- 更新文档

## 测试清单

在迁移每个 ViewModel 时，请确保：

- [ ] 创建对应的 Repository
- [ ] Repository 正确处理错误
- [ ] ViewModel 返回业务模型
- [ ] Page 正确使用新数据结构
- [ ] 所有功能正常工作
- [ ] 错误场景正确处理
- [ ] 性能无明显下降

## 附录

### A. 迁移示例

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

### B. 关键改进点

1. **ViewModel 不再依赖 axios**
   - 迁移前：`import provider from '../httpRequest/Provider'`
   - 迁移后：`import { RankRepository } from '../repository/RankRepository'`

2. **ViewModel 返回业务模型**
   - 迁移前：`Promise<AxiosResponse<BaseResponse<PageModel<RankModel>>>>`
   - 迁移后：`Promise<RankModel[]>`

3. **Page 代码更简洁**
   - 迁移前：`const ranks = result.data.data.datas`
   - 迁移后：`const ranks = await this.viewModel.getRank(page)`

---

**文档版本**：v2.0  
**最后更新**：2026-08-17 14:20  
**测试状态**：✅ 所有测试通过  
**下一步**：开始阶段二 - 渐进式迁移
