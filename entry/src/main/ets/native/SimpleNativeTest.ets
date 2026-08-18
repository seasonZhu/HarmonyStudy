/**
 * 原生嵌入组件 - 修复版
 * 遵循 uni-app runtime 的正确模式
 */

import { NativeEmbedBuilderOptions, defineNativeEmbed } from "@dcloudio/uni-app-runtime"

// ==================== 1. 最简单的组件 ====================

@Component
export struct SimpleTextComponent {
  build() {
    Text('Hello from Native')
      .fontSize(20)
      .fontColor('#333333')
      .padding(20)
  }
}

@Builder
function SimpleTextBuilder(options: NativeEmbedBuilderOptions) {
  SimpleTextComponent()
}

// ==================== 2. 带消息的组件 ====================

interface TextWithMessageOptions extends NativeEmbedBuilderOptions {
  message: string
}

@Component
export struct TextWithMessageComponent {
  @Prop message: string = 'Default Message'

  build() {
    Column() {
      Text(this.message)
        .fontSize(18)
        .fontColor('#2C86EF')
        .padding(16)

      Text('Native Component Works!')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 8 })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#F5F5F5')
    .borderRadius(8)
  }
}

@Builder
function TextWithMessageBuilder(options: TextWithMessageOptions) {
  TextWithMessageComponent({
    message: options.message
  })
}

// ==================== 3. 可点击的组件 ====================

interface ClickableTextOptions extends NativeEmbedBuilderOptions {
  text: string
}

interface ClickEventDetail {
  text: string
  timestamp: number
}

@Component
export struct ClickableTextComponent {
  @Prop text: string = 'Click Me'
  onClickCallback?: Function

  build() {
    Button(this.text)
      .fontSize(16)
      .backgroundColor('#4CAF50')
      .onClick(() => {
        if (this.onClickCallback) {
          const detail = {
            text: this.text,
            timestamp: Date.now()
          } as ClickEventDetail
          this.onClickCallback({
            detail
          })
        }
      })
  }
}

@Builder
function ClickableTextBuilder(options: ClickableTextOptions) {
  ClickableTextComponent({
    text: options.text,
    onClickCallback: options?.on?.get('click')
  })
}

// ==================== 4. 完整按钮组件 ====================

interface TestButtonOptions extends NativeEmbedBuilderOptions {
  text: string
  type?: string
}

interface TestButtonClickDetail {
  text: string
  type: string
  timestamp: number
}

@Component
export struct TestButtonComponent {
  @Prop text: string = 'Button'
  @Prop type: string = 'primary'
  onClickCallback?: Function

  build() {
    Column() {
      Button(this.text)
        .fontSize(16)
        .width('100%')
        .height('100%')
        .backgroundColor(this.type === 'primary' ? '#2C86EF' : '#4CAF50')
        .onClick(() => {
          if (this.onClickCallback) {
            const detail = {
              text: this.text,
              type: this.type,
              timestamp: Date.now()
            } as TestButtonClickDetail
            this.onClickCallback({
              detail
            })
          }
        })
    }
    .width(200)
    .height(50)
  }
}

@Builder
function TestButtonBuilder(options: TestButtonOptions) {
  TestButtonComponent({
    text: options.text,
    type: options.type ?? 'primary',
    onClickCallback: options?.on?.get('click')
  })
}

// ==================== 5. 你的 Button 组件（保持不变）====================

interface ButtonBuilderOptions extends NativeEmbedBuilderOptions {
  label: string
}

interface ButtonClickEventDetail {
  text: string
}

@Component
struct ButtonComponent {
  @Prop label: string
  onButtonClick?: Function

  build() {
    Button(this.label)
      .width('100%')
      .height('100%')
      .onClick(() => {
        if (this.onButtonClick) {
          const detail = {
            text: 'test'
          } as ButtonClickEventDetail
          this.onButtonClick({
            detail
          })
        }
      })
  }
}

@Builder
function ButtonBuilder(options: ButtonBuilderOptions) {
  ButtonComponent({
    label: options.label,
    onButtonClick: options?.on?.get('click')
  })
  .width(options.width)
  .height(options.height)
}

// ==================== 注册所有组件 ====================

export function registerSimpleTestComponents(): void {
  // 测试1: 最简单的组件
  defineNativeEmbed('simple-text', {
    builder: SimpleTextBuilder
  })

  // 测试2: 带消息的组件
  defineNativeEmbed('text-with-message', {
    builder: TextWithMessageBuilder
  })

  // 测试3: 可点击的组件
  defineNativeEmbed('clickable-text', {
    builder: ClickableTextBuilder
  })

  // 测试4: 完整的按钮组件
  defineNativeEmbed('test-button', {
    builder: TestButtonBuilder
  })

  // 你的 Button 组件
  defineNativeEmbed('button', {
    builder: ButtonBuilder
  })
}
