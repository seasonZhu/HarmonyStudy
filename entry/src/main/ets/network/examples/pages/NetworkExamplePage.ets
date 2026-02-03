/**
 * NetworkExamplePage - 网络请求示例页面
 * @description 展示如何使用 network 模块进行各种网络请求
 * 所有接口都使用真实的 WanAndroid API
 */

import { NetworkProvider } from '../../../httpRequest/NetworkProvider'
import { Environment } from 'network'
import { NetworkExampleViewModel, ViewState } from '../viewModel/NetworkExampleViewModel'
import { Article, Banner, HotKey } from '../api/WanAndroidModels'
import { promptAction } from '@kit.ArkUI'

@Entry
@Component
struct NetworkExamplePage {
  @State viewModel: NetworkExampleViewModel = new NetworkExampleViewModel()
  @State username: string = ''
  @State password: string = ''
  @State searchKeyword: string = ''

  aboutToAppear(): void {
    // 初始化 NetworkProvider
    NetworkProvider.init(getContext(this))
  }

  build() {
    Navigation() {
      Scroll() {
        Column() {
          // 页面标题
          this.HeaderSection()

          // 初始化 NetworkProvider 说明
          this.InitSection()

          // 示例1: 首页数据
          this.HomeDataSection()

          // 示例2: 登录注册
          this.LoginSection()

          // 示例3: 积分排行榜
          this.CoinRankSection()

          // 示例4: 搜索功能
          this.SearchSection()

          // 环境切换
          this.EnvironmentSection()

          // 说明区域
          this.InfoSection()
        }
        .width('100%')
        .backgroundColor('#F5F5F5')
      }
      .width('100%')
      .height('100%')
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
    }
    .title('网络请求示例')
    .mode(NavigationMode.Auto)
    .titleMode(NavigationTitleMode.Mini)
  }

  /**
   * 页面标题
   */
  @Builder
  HeaderSection() {
    Column() {
      Text('Network 模块示例')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 8 })

      Text('基于真实的 WanAndroid API')
        .fontSize(14)
        .fontColor('#999999')
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ top: 20, left: 16, right: 16 })
  }

  /**
   * 初始化说明
   */
  @Builder
  InitSection() {
    Column() {
      Row() {
        Column() {
          Text('NetworkProvider 初始化')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')

          Text('在 aboutToAppear 中初始化')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#F8F8F8')
      .borderRadius(8)

      Text('NetworkProvider.init(context)')
        .fontSize(12)
        .fontColor('#666666')
        .fontFamily('monospace')
        .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 16 })
  }

  /**
   * 首页数据示例
   */
  @Builder
  HomeDataSection() {
    Column() {
      Row() {
        Column() {
          Text('首页数据（并发请求）')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')

          Text('轮播图 + 置顶文章 + 文章列表')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text('首页')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#2C86EF')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(4)
      }
      .width('100%')
      .height(80)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .borderRadius(12)

      Button('加载首页数据')
        .width('100%')
        .height(44)
        .fontSize(16)
        .backgroundColor('#2C86EF')
        .borderRadius(8)
        .margin({ top: 12 })
        .onClick(() => {
          this.viewModel.loadHomeData()
          promptAction.showToast({ message: '正在加载首页数据...' })
        })

      // 显示文章数量
      if (this.viewModel.getArticleList().length > 0) {
        Text(`成功加载 ${this.viewModel.getArticleList().length} 篇文章`)
          .fontSize(14)
          .fontColor('#52C41A')
          .margin({ top: 12 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#F8F8F8')
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 16 })
  }

  /**
   * 登录注册示例
   */
  @Builder
  LoginSection() {
    Column() {
      Row() {
        Column() {
          Text('用户登录')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')

          Text('测试账号随意输入即可')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text('登录')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#52C41A')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(4)
      }
      .width('100%')
      .height(80)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .borderRadius(12)

      // 用户名输入
      TextInput({ placeholder: '用户名', text: this.username })
        .width('100%')
        .height(44)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .margin({ top: 12 })
        .onChange((value: string) => {
          this.username = value
        })

      // 密码输入
      TextInput({ placeholder: '密码', text: this.password })
        .width('100%')
        .height(44)
        .type(InputType.Password)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .margin({ top: 8 })
        .onChange((value: string) => {
          this.password = value
        })

      // 登录按钮
      Button('登录')
        .width('100%')
        .height(44)
        .fontSize(16)
        .backgroundColor('#52C41A')
        .borderRadius(8)
        .margin({ top: 12 })
        .onClick(() => {
          if (!this.username || !this.password) {
            promptAction.showToast({ message: '请输入用户名和密码' })
            return
          }
          this.viewModel.login(this.username, this.password)
            .then(() => {
              promptAction.showToast({ message: '登录成功！积分: ' + this.viewModel.getUserCoin() })
            })
            .catch(() => {
              promptAction.showToast({ message: '登录失败' })
            })
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#F8F8F8')
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 16 })
  }

  /**
   * 积分排行榜示例
   */
  @Builder
  CoinRankSection() {
    Column() {
      Row() {
        Column() {
          Text('积分排行榜')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')

          Text('查看用户积分排名')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text('排行')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#FA8C16')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(4)
      }
      .width('100%')
      .height(80)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .borderRadius(12)

      Button('获取积分排行榜')
        .width('100%')
        .height(44)
        .fontSize(16)
        .backgroundColor('#FA8C16')
        .borderRadius(8)
        .margin({ top: 12 })
        .onClick(() => {
          this.viewModel.loadCoinRank()
          promptAction.showToast({ message: '正在加载排行榜...' })
        })

      // 显示排行榜数量
      if (this.viewModel.getCoinRankList().length > 0) {
        Text(`成功加载 ${this.viewModel.getCoinRankList().length} 条排行榜数据`)
          .fontSize(14)
          .fontColor('#52C41A')
          .margin({ top: 12 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#F8F8F8')
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 16 })
  }

  /**
   * 搜索功能示例
   */
  @Builder
  SearchSection() {
    Column() {
      Row() {
        Column() {
          Text('搜索功能')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')

          Text('支持关键词搜索文章')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text('搜索')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#9C27B0')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(4)
      }
      .width('100%')
      .height(80)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .borderRadius(12)

      // 搜索输入框
      Row() {
        TextInput({ placeholder: '搜索关键词', text: this.searchKeyword })
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#FFFFFF')
          .borderRadius({ topLeft: 8, bottomLeft: 8 })
          .onChange((value: string) => {
            this.searchKeyword = value
          })

        Button('搜索')
          .height(44)
          .backgroundColor('#9C27B0')
          .borderRadius({ topRight: 8, bottomRight: 8 })
          .onClick(() => {
            if (!this.searchKeyword) {
              promptAction.showToast({ message: '请输入搜索关键词' })
              return
            }
            this.viewModel.searchArticles(this.searchKeyword)
              .then(() => {
                const count = this.viewModel.getSearchResults().length
                promptAction.showToast({ message: '找到 ' + count + ' 篇文章' })
              })
          })
      }
      .width('100%')
      .margin({ top: 12 })

      // 搜索热词按钮
      Button('获取搜索热词')
        .width('100%')
        .height(44)
        .fontSize(16)
        .backgroundColor('#9C27B0')
        .borderRadius(8)
        .margin({ top: 8 })
        .onClick(() => {
          this.viewModel.loadHotKeys()
          promptAction.showToast({ message: '正在加载搜索热词...' })
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#F8F8F8')
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 16 })
  }

  /**
   * 环境切换示例
   */
  @Builder
  EnvironmentSection() {
    Column() {
      Row() {
        Column() {
          Text('环境切换')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')

          Text('支持多环境配置管理')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text('环境')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#1890FF')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(4)
      }
      .width('100%')
      .height(80)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .borderRadius(12)

      // 环境切换按钮
      Row() {
        Button('开发环境')
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .backgroundColor('#52C41A')
          .borderRadius(8)
          .margin({ right: 8 })
          .onClick(() => {
            NetworkProvider.switchEnvironment(Environment.DEV)
            promptAction.showToast({ message: '已切换到开发环境' })
          })

        Button('生产环境')
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .backgroundColor('#FA541C')
          .borderRadius(8)
          .onClick(() => {
            NetworkProvider.switchEnvironment(Environment.PROD)
            promptAction.showToast({ message: '已切换到生产环境' })
          })
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#F8F8F8')
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 16 })
  }

  /**
   * 说明区域
   */
  @Builder
  InfoSection() {
    Column() {
      Text('功能说明')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ bottom: 8 })

      Text('• 所有接口均使用真实的 WanAndroid API')
        .fontSize(12)
        .fontColor('#666666')

      Text('• 支持 GET、POST 等多种请求方式')
        .fontSize(12)
        .fontColor('#666666')
        .margin({ top: 4 })

      Text('• 支持并发请求、分页加载')
        .fontSize(12)
        .fontColor('#666666')
        .margin({ top: 4 })

      Text('• 支持环境切换、Token 管理')
        .fontSize(12)
        .fontColor('#666666')
        .margin({ top: 4 })

      Text('• 完整的错误处理和日志记录')
        .fontSize(12)
        .fontColor('#666666')
        .margin({ top: 4 })

      Text('• BaseURL: https://www.wanandroid.com/')
        .fontSize(12)
        .fontColor('#2C86EF')
        .margin({ top: 4 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFF8E1')
    .borderRadius(12)
    .margin({ left: 16, right: 16, bottom: 20 })
  }
}

export { NetworkExamplePage }
