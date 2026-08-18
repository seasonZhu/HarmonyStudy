<template>
  <view class="container">
    <!-- 头部信息 -->
    <view class="header">
      <text class="title">🎉 原生组件测试（修复版）</text>
      <text class="platform">当前平台: {{ platform }}</text>
    </view>

    <!-- HarmonyOS: 显示原生组件 -->
    <view v-if="isHarmonyOS" class="harmonyos-content">
      <!-- 你的 Button 组件（正确示例）-->
      <view class="test-card">
        <text class="card-title">✅ 你的 Button 组件</text>
        <text class="card-desc">使用正确的 NativeEmbedBuilderOptions 模式</text>

        <view class="component-wrapper">
          <embed
            tag="button"
            :options="{
              label: '我的按钮',
              width: 200,
              height: 50
            }"
            @click="handleButtonClick"
          />
        </view>

        <text v-if="buttonResult" class="result-text">{{ buttonResult }}</text>
      </view>

      <!-- 原生按钮组件（已修复）-->
      <view class="test-card">
        <text class="card-title">原生按钮组件（已修复）</text>
        <text class="card-desc">支持多种类型和防抖</text>

        <view class="component-wrapper">
          <embed
            tag="native-button"
            :options="{
              text: '原生按钮',
              type: 'primary',
              width: 200,
              height: 50
            }"
            @click="handleNativeButtonClick"
          />
        </view>

        <text v-if="nativeButtonResult" class="result-text">{{ nativeButtonResult }}</text>
      </view>

      <!-- 最简单的组件 -->
      <view class="test-card">
        <text class="card-title">最简单的组件</text>
        <text class="card-desc">无参数、无回调</text>

        <view class="component-wrapper">
          <embed tag="simple-text" />
        </view>
      </view>

      <!-- 带消息的组件 -->
      <view class="test-card">
        <text class="card-title">带消息的组件</text>
        <text class="card-desc">传递自定义参数</text>

        <view class="component-wrapper">
          <embed
            tag="text-with-message"
            :options="{
              message: 'Hello from uni-app!',
              width: 300,
              height: 100
            }"
          />
        </view>
      </view>

      <!-- 可点击的组件 -->
      <view class="test-card">
        <text class="card-title">可点击的组件</text>
        <text class="card-desc">带点击回调</text>

        <view class="component-wrapper">
          <embed
            tag="clickable-text"
            :options="{
              text: '点击测试',
              width: 200,
              height: 50
            }"
            @click="handleClickableTextClick"
          />
        </view>

        <text v-if="clickableResult" class="result-text">{{ clickableResult }}</text>
      </view>
    </view>

    <!-- 非 HarmonyOS: 显示提示 -->
    <view v-else class="other-platform">
      <text class="hello">Hello World</text>
      <text class="info">当前平台: {{ platform }}</text>
      <text class="info">原生组件仅在 HarmonyOS 平台可用</text>
    </view>
  </view>
</template>

<script>
export default {
  name: 'FixedNativeComponentsTest',
  data() {
    return {
      platform: '',
      isHarmonyOS: false,
      buttonResult: '',
      nativeButtonResult: '',
      clickableResult: ''
    }
  },

  created() {
    // 获取系统信息
    const systemInfo = uni.getSystemInfoSync()
    this.platform = systemInfo.platform || 'unknown'
    this.isHarmonyOS = systemInfo.platform === 'harmonyos'

    console.log('=== 系统信息 ===')
    console.log('platform:', this.platform)
    console.log('isHarmonyOS:', this.isHarmonyOS)
  },

  methods: {
    handleButtonClick(e) {
      console.log('=== Button 组件点击 ===')
      console.log('event:', e)
      console.log('detail:', e.detail)

      // e.detail = { text: 'test' }
      this.buttonResult = `Button 点击: ${e.detail.text}`

      uni.showToast({
        title: 'Button 工作正常！',
        icon: 'success'
      })
    },

    handleNativeButtonClick(e) {
      console.log('=== 原生按钮点击 ===')
      console.log('detail:', e.detail)

      // e.detail = { type: 'primary', text: '原生按钮', timestamp: xxx }
      this.nativeButtonResult = `类型: ${e.detail.type}, 时间: ${new Date(e.detail.timestamp).toLocaleTimeString()}`

      uni.showToast({
        title: '原生按钮工作正常！',
        icon: 'success'
      })
    },

    handleClickableTextClick(e) {
      console.log('=== 可点击组件点击 ===')
      console.log('detail:', e.detail)

      // e.detail = { text: '点击测试', timestamp: xxx }
      this.clickableResult = `点击: ${e.detail.text}`

      uni.showToast({
        title: '可点击组件工作正常！',
        icon: 'success'
      })
    }
  }
}
</script>

<style scoped>
.container {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 40rpx;
}

.header {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 24rpx;
  padding: 40rpx;
  margin-bottom: 40rpx;
  text-align: center;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.1);
}

.title {
  display: block;
  font-size: 48rpx;
  font-weight: bold;
  color: #333333;
  margin-bottom: 16rpx;
}

.platform {
  display: block;
  font-size: 28rpx;
  color: #666666;
}

.harmonyos-content {
  display: flex;
  flex-direction: column;
  gap: 30rpx;
}

.test-card {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 24rpx;
  padding: 40rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.1);
}

.card-title {
  display: block;
  font-size: 36rpx;
  font-weight: bold;
  color: #333333;
  margin-bottom: 12rpx;
}

.card-desc {
  display: block;
  font-size: 26rpx;
  color: #999999;
  margin-bottom: 30rpx;
}

.component-wrapper {
  background: #f5f5f5;
  border-radius: 16rpx;
  padding: 30rpx;
  margin-bottom: 20rpx;
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100rpx;
}

.result-text {
  display: block;
  font-size: 26rpx;
  color: #2c86ef;
  text-align: center;
  padding: 20rpx;
  background: #e3f2fd;
  border-radius: 12rpx;
  line-height: 1.6;
}

.other-platform {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 24rpx;
  padding: 120rpx 60rpx;
  text-align: center;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.1);
}

.hello {
  display: block;
  font-size: 80rpx;
  font-weight: bold;
  color: #333333;
  margin-bottom: 40rpx;
}

.info {
  display: block;
  font-size: 32rpx;
  color: #999999;
  margin-bottom: 20rpx;
}

embed {
  display: block;
}
</style>
