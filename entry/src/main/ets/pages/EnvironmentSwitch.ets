import { Environment } from '../httpRequest/Environment'
import { environmentManager } from '../httpRequest/EnvironmentManager'
import { common } from '@kit.AbilityKit'
import { LogUtil } from '@pura/harmony-utils';
import { RouterName } from '../router/RouterName'
import { ErrorHandler } from '../utils/ErrorHandler'

@Entry({routeName: RouterName.EnvironmentSwitch})
@ComponentV2
struct EnvironmentSwitch {
  @Local currentEnvironment: Environment = Environment.PROD

  private environments: Environment[] = [
    Environment.DEV,
    Environment.TEST,
    Environment.PROD
  ]

  async aboutToAppear(): Promise<void> {
    // 获取当前环境
    this.currentEnvironment = await environmentManager.getCurrentEnvironment()
    LogUtil.debug('当前环境: ' + this.currentEnvironment)
  }

  /**
   * 选择环境
   */
  async onSelectEnvironment(env: Environment): Promise<void> {
    if (env === this.currentEnvironment) {
      // 已经是当前环境，提示用户
      try {
        this.getUIContext().getPromptAction().showToast({
          message: '当前已是该环境',
          duration: 2000
        })
      } catch (error) {
        ErrorHandler.handle(error, '提示显示失败', false)
      }
      return
    }

    // 显示确认提示
    this.showConfirmDialog(env)
  }

  /**
   * 显示确认对话框并切换环境
   */
  async showConfirmDialog(env: Environment): Promise<void> {
    try {
      // 保存新环境
      await environmentManager.setCurrentEnvironment(env)

      LogUtil.debug('环境已切换为: ' + env)

      // 显示成功提示
      this.getUIContext().getPromptAction().showToast({
        message: `已切换至${environmentManager.getEnvironmentDisplayName(env)}，应用即将退出`,
        duration: 2000
      })

      // 延迟退出，让用户看到提示
      setTimeout(() => {
        this.exitApp()
      }, 2000)
    } catch (error) {
      LogUtil.debug('切换环境失败: ' + JSON.stringify(error))
      this.getUIContext().getPromptAction().showToast({
        message: '切换失败，请重试',
        duration: 2000
      })
    }
  }

  /**
   * 退出应用
   */
  exitApp(): void {
    const context = getContext(this) as common.UIAbilityContext
    context.terminateSelf().catch((error: Error) => {
      ErrorHandler.handle(error, '应用退出失败', false)
    })
  }

  build() {
    NavDestination() {
      Column() {
        // 当前环境卡片
        Column() {
          Text('当前环境')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 20, bottom: 10 })

          Text(environmentManager.getEnvironmentDisplayName(this.currentEnvironment))
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Text(environmentManager.getEnvironmentDescription(this.currentEnvironment))
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 8 })
        }
        .width('100%')
        .padding(20)
        .backgroundColor('#F5F5F5')
        .borderRadius(12)
        .margin({ top: 20, left: 16, right: 16 })

        // 环境列表
        Text('选择环境')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .width('100%')
          .padding({ left: 16, right: 16, top: 30, bottom: 12 })

        List({ space: 0 }) {
          ForEach(this.environments, (env: Environment) => {
            ListItem() {
              Row() {
                Column() {
                  Text(environmentManager.getEnvironmentDisplayName(env))
                    .fontSize(16)
                    .fontColor('#333333')
                    .fontWeight(FontWeight.Medium)

                  Text(environmentManager.getEnvironmentDescription(env))
                    .fontSize(12)
                    .fontColor('#999999')
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                // 当前环境标识
                if (env === this.currentEnvironment) {
                  Text('当前')
                    .fontSize(12)
                    .fontColor('#FFFFFF')
                    .backgroundColor('#2C86EF')
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .borderRadius(4)
                } else {
                  Text('切换')
                    .fontSize(12)
                    .fontColor('#FFFFFF')
                    .backgroundColor('#CCCCCC')
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .borderRadius(4)
                }
              }
              .width('100%')
              .height(80)
              .padding({ left: 16, right: 16 })
              .onClick(() => {
                this.onSelectEnvironment(env)
              })
            }
            .width('100%')
          })
        }
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .margin({ left: 16, right: 16 })
        .divider({
          strokeWidth: 0.5,
          color: '#EEEEEE',
          startMargin: 16,
          endMargin: 16
        })

        Blank()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F8F8F8')
    }
    .title('环境切换')
  }
}

@Builder
export function EnvironmentSwitchBuilder() {
  EnvironmentSwitch()
}
