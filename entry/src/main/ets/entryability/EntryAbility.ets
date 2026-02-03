import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AppUtil } from '@pura/harmony-utils';
import { init } from '@dcloudio/uni-app-runtime'
import { environmentManager } from '../httpRequest/EnvironmentManager'
import { Provider } from '../httpRequest/Provider'
import { NetworkProvider } from '../network/examples/NetworkProvider'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    // 初始化 NetworkProvider
    NetworkProvider.init(this.context)

    // 初始化环境管理器
    environmentManager.init(this.context).then(() => {
      hilog.info(0x0000, 'testTag', '环境管理器初始化成功')

      // 初始化Provider环境配置
      return Provider.initEnvironment()
    }).then(() => {
      hilog.info(0x0000, 'testTag', 'Provider环境配置初始化成功')
      const currentEnv = Provider.getCurrentEnvironment()
      const baseUrl = Provider.getBaseUrl()
      hilog.info(0x0000, 'testTag', `当前环境: ${currentEnv}, BaseURL: ${baseUrl}`)
    }).catch((error: Error) => {
      hilog.error(0x0000, 'testTag', '环境初始化失败: %{public}s', JSON.stringify(error))
    })
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    init(this, windowStage, { debug: true })

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });

    AppUtil.init(this.context)
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
