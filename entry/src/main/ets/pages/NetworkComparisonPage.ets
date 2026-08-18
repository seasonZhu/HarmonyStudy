import provider from '../httpRequest/Provider'
import { getHttpClient, HttpClient, ApiResponse } from 'network'
import { AxiosResponse } from '@ohos/axios'
import { BaseResponse } from '../model/BaseResponse'
import { PageModel } from '../model/PageModel'
import { Article } from '../model/Article'
import { RankModel } from '../model/RankModel'
import { ApiConstants } from '../constants/ApiConstants'
import { LogUtil } from '@pura/harmony-utils'
import { RouterName } from '../router/RouterName'

interface TestResult {
  testName: string
  httpRequestTime?: number
  networkTime?: number
  httpRequestSuccess?: boolean
  networkSuccess?: boolean
  httpRequestData?: string
  networkData?: string
  error?: string
}

@Entry({ routeName: RouterName.NetworkComparison })
@Component
struct NetworkComparisonPage {
  @State testResults: TestResult[] = []
  @State isRunning: boolean = false
  @State currentTest: string = ''

  private httpClient: HttpClient = getHttpClient()

  build() {
    NavDestination() {
      Column() {
        Text('网络层对比测试')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20, bottom: 20 })

        Text('对比 httpRequest 和 network 模块的功能和性能')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .margin({ bottom: 20 })

        Button('开始所有测试')
          .width('80%')
          .height(50)
          .fontSize(16)
          .enabled(!this.isRunning)
          .onClick(() => {
            this.runAllTests()
          })
          .margin({ bottom: 20 })

        if (this.isRunning) {
          Row() {
            LoadingProgress()
              .width(20)
              .height(20)
            Text(`正在执行: ${this.currentTest}`)
              .fontSize(14)
              .margin({ left: 10 })
          }
          .margin({ bottom: 20 })
        }

        List({ space: 10 }) {
          ForEach(this.testResults, (result: TestResult, index: number) => {
            ListItem() {
              this.TestResultCard(result)
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .title('网络层对比测试')
  }

  @Builder
  TestResultCard(result: TestResult) {
    Column() {
      Row() {
        Text(result.testName)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
        Blank()
        if (result.error) {
          Text('异常')
            .fontSize(12)
            .fontColor(Color.Red)
            .backgroundColor('#FFEBEE')
            .borderRadius(4)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
        } else if (result.httpRequestSuccess && result.networkSuccess) {
          Text('通过')
            .fontSize(12)
            .fontColor(Color.Green)
            .backgroundColor('#E8F5E9')
            .borderRadius(4)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
        }
      }
      .width('100%')
      .margin({ bottom: 10 })

      if (result.error) {
        Text(`错误: ${result.error}`)
          .fontSize(12)
          .fontColor(Color.Red)
          .width('100%')
      } else {
        Row() {
          Column() {
            Text('httpRequest')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
            Text(`耗时: ${result.httpRequestTime?.toFixed(2) ?? '-'} ms`)
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
            Text(`状态: ${result.httpRequestSuccess ? '成功' : '失败'}`)
              .fontSize(12)
              .fontColor(result.httpRequestSuccess ? Color.Green : Color.Red)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Divider()
            .vertical(true)
            .height(60)

          Column() {
            Text('network')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
            Text(`耗时: ${result.networkTime?.toFixed(2) ?? '-'} ms`)
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
            Text(`状态: ${result.networkSuccess ? '成功' : '失败'}`)
              .fontSize(12)
              .fontColor(result.networkSuccess ? Color.Green : Color.Red)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')

        if (result.httpRequestTime && result.networkTime) {
          Row() {
            Text(`性能对比: network 比 httpRequest ${result.networkTime < result.httpRequestTime ? '快' : '慢'} ${Math.abs(result.networkTime - result.httpRequestTime).toFixed(2)} ms`)
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
          }
          .width('100%')
          .margin({ top: 8 })
        }
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.white'))
    .borderRadius(8)
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  private async runAllTests(): Promise<void> {
    this.isRunning = true
    this.testResults = []

    try {
      await this.testArticleList()
      await this.testRankList()
      await this.testBannerList()
      await this.testHotKeyList()
      await this.testErrorScenario()
    } catch (error) {
      LogUtil.error('测试执行失败: ' + JSON.stringify(error))
    } finally {
      this.isRunning = false
    }
  }

  private async testArticleList(): Promise<void> {
    this.currentTest = '文章列表接口测试'
    const result: TestResult = { testName: '文章列表接口 (GET, 分页)' }

    try {
      const page = 0

      const httpRequestStart = Date.now()
      const httpResponse: AxiosResponse<BaseResponse<PageModel<Article>>> = await provider.get(
        ApiConstants.articleList(page)
      )
      const httpRequestTime = Date.now() - httpRequestStart

      const networkStart = Date.now()
      const networkResponse: ApiResponse<PageModel<Article>> = await this.httpClient.get(
        ApiConstants.articleList(page)
      )
      const networkTime = Date.now() - networkStart

      result.httpRequestTime = httpRequestTime
      result.networkTime = networkTime
      result.httpRequestSuccess = httpResponse.data.errorCode === 0
      result.networkSuccess = networkResponse.errorCode === 0
      result.httpRequestData = `文章数: ${httpResponse.data.data?.datas?.length ?? 0}`
      result.networkData = `文章数: ${networkResponse.data?.datas?.length ?? 0}`

      LogUtil.info(`文章列表测试完成: httpRequest=${httpRequestTime}ms, network=${networkTime}ms`)
    } catch (error) {
      result.error = JSON.stringify(error)
      LogUtil.error('文章列表测试失败: ' + JSON.stringify(error))
    }

    this.testResults.push(result)
  }

  private async testRankList(): Promise<void> {
    this.currentTest = '排行榜接口测试'
    const result: TestResult = { testName: '排行榜接口 (GET, 分页)' }

    try {
      const page = 1

      const httpRequestStart = Date.now()
      const httpResponse: AxiosResponse<BaseResponse<PageModel<RankModel>>> = await provider.get(
        ApiConstants.coinRank(page)
      )
      const httpRequestTime = Date.now() - httpRequestStart

      const networkStart = Date.now()
      const networkResponse: ApiResponse<PageModel<RankModel>> = await this.httpClient.get(
        ApiConstants.coinRank(page)
      )
      const networkTime = Date.now() - networkStart

      result.httpRequestTime = httpRequestTime
      result.networkTime = networkTime
      result.httpRequestSuccess = httpResponse.data.errorCode === 0
      result.networkSuccess = networkResponse.errorCode === 0
      result.httpRequestData = `排名数: ${httpResponse.data.data?.datas?.length ?? 0}`
      result.networkData = `排名数: ${networkResponse.data?.datas?.length ?? 0}`

      LogUtil.info(`排行榜测试完成: httpRequest=${httpRequestTime}ms, network=${networkTime}ms`)
    } catch (error) {
      result.error = JSON.stringify(error)
      LogUtil.error('排行榜测试失败: ' + JSON.stringify(error))
    }

    this.testResults.push(result)
  }

  private async testBannerList(): Promise<void> {
    this.currentTest = '轮播图接口测试'
    const result: TestResult = { testName: '轮播图接口 (GET)' }

    try {
      const httpRequestStart = Date.now()
      const httpResponse: AxiosResponse<BaseResponse<Article[]>> = await provider.get(
        ApiConstants.BANNER
      )
      const httpRequestTime = Date.now() - httpRequestStart

      const networkStart = Date.now()
      const networkResponse: ApiResponse<Article[]> = await this.httpClient.get(
        ApiConstants.BANNER
      )
      const networkTime = Date.now() - networkStart

      result.httpRequestTime = httpRequestTime
      result.networkTime = networkTime
      result.httpRequestSuccess = httpResponse.data.errorCode === 0
      result.networkSuccess = networkResponse.errorCode === 0
      result.httpRequestData = `轮播数: ${httpResponse.data.data?.length ?? 0}`
      result.networkData = `轮播数: ${networkResponse.data?.length ?? 0}`

      LogUtil.info(`轮播图测试完成: httpRequest=${httpRequestTime}ms, network=${networkTime}ms`)
    } catch (error) {
      result.error = JSON.stringify(error)
      LogUtil.error('轮播图测试失败: ' + JSON.stringify(error))
    }

    this.testResults.push(result)
  }

  private async testHotKeyList(): Promise<void> {
    this.currentTest = '热门关键词接口测试'
    const result: TestResult = { testName: '热门关键词接口 (GET)' }

    try {
      const httpRequestStart = Date.now()
      const httpResponse: AxiosResponse<BaseResponse<Article[]>> = await provider.get(
        ApiConstants.HOTKEY
      )
      const httpRequestTime = Date.now() - httpRequestStart

      const networkStart = Date.now()
      const networkResponse: ApiResponse<Article[]> = await this.httpClient.get(
        ApiConstants.HOTKEY
      )
      const networkTime = Date.now() - networkStart

      result.httpRequestTime = httpRequestTime
      result.networkTime = networkTime
      result.httpRequestSuccess = httpResponse.data.errorCode === 0
      result.networkSuccess = networkResponse.errorCode === 0
      result.httpRequestData = `关键词数: ${httpResponse.data.data?.length ?? 0}`
      result.networkData = `关键词数: ${networkResponse.data?.length ?? 0}`

      LogUtil.info(`热门关键词测试完成: httpRequest=${httpRequestTime}ms, network=${networkTime}ms`)
    } catch (error) {
      result.error = JSON.stringify(error)
      LogUtil.error('热门关键词测试失败: ' + JSON.stringify(error))
    }

    this.testResults.push(result)
  }

  private async testErrorScenario(): Promise<void> {
    this.currentTest = '错误场景测试'
    const result: TestResult = { testName: '错误场景测试 (无效URL)' }

    try {
      const invalidUrl = '/invalid/url/that/does/not/exist'

      const httpRequestStart = Date.now()
      try {
        await provider.get(invalidUrl)
        result.httpRequestSuccess = false
      } catch (error) {
        result.httpRequestSuccess = false
      }
      const httpRequestTime = Date.now() - httpRequestStart

      const networkStart = Date.now()
      try {
        await this.httpClient.get<Object>(invalidUrl)
        result.networkSuccess = false
      } catch (error) {
        result.networkSuccess = false
      }
      const networkTime = Date.now() - networkStart

      result.httpRequestTime = httpRequestTime
      result.networkTime = networkTime
      result.httpRequestData = '正确抛出错误'
      result.networkData = '正确抛出错误'

      LogUtil.info(`错误场景测试完成: httpRequest=${httpRequestTime}ms, network=${networkTime}ms`)
    } catch (error) {
      result.error = JSON.stringify(error)
      LogUtil.error('错误场景测试失败: ' + JSON.stringify(error))
    }

    this.testResults.push(result)
  }
}

@Builder
export function NetworkComparisonPageBuilder() {
  NetworkComparisonPage()
}
