<template>
  <view class="container">
    <view class="header">
      <text class="title">🔍 原生组件调试页面</text>
      <text class="subtitle">用最小排除法定位问题</text>
    </view>

    <!-- 测试1: 最简单的组件 -->
    <view class="test-section">
      <view class="test-header">
        <text class="test-title">测试1: 最简单的组件</text>
        <text class="test-desc">无参数、无回调、只显示文本</text>
      </view>
      <view class="test-content">
        <embed tag="simple-text" />
      </view>
    </view>

    <!-- 测试2: 带消息的组件 -->
    <view class="test-section">
      <view class="test-header">
        <text class="test-title">测试2: 带消息参数</text>
        <text class="test-desc">一个字符串参数，无回调</text>
      </view>
      <view class="test-content">
        <embed
          tag="text-with-message"
          :options="{ message: 'Hello from uni-app!' }"
        />
      </view>
    </view>

    <!-- 测试3: 可点击的组件 -->
    <view class="test-section">
      <view class="test-header">
        <text class="test-title">测试3: 带点击回调</text>
        <text class="test-desc">一个参数 + 一个回调函数</text>
      </view>
      <view class="test-content">
        <embed
          tag="clickable-text"
          :options="{ text: '点击测试按钮' }"
          :onClick="handleClickableTextClick"
        />
        <text v-if="clickableTextResult" class="result">{{ clickableTextResult }}</text>
      </view>
    </view>

    <!-- 测试4: 完整按钮组件 -->
    <view class="test-section">
      <view class="test-header">
        <text class="test-title">测试4: 完整按钮组件</text>
        <text class="test-desc">类似原生按钮的完整结构</text>
      </view>
      <view class="test-content">
        <embed
          tag="test-button"
          :options="{
            text: '完整测试按钮',
            type: 'primary'
          }"
          :onClick="handleTestButtonClick"
        />
        <text v-if="testButtonResult" class="result">{{ testButtonResult }}</text>
      </view>
    </view>

    <!-- 测试5: 无事件绑定 -->
    <view class="test-section">
      <view class="test-header">
        <text class="test-title">测试5: 无事件绑定</text>
        <text class="test-desc">测试不绑定事件是否会报错</text>
      </view>
      <view class="test-content">
        <embed
          tag="test-button"
          :options="{ text: '无事件按钮', type: 'primary' }"
        />
      </view>
    </view>

    <!-- 系统信息 -->
    <view class="system-info">
      <text class="info-title">系统信息</text>
      <text class="info-item">平台: {{ platform }}</text>
      <text class="info-item">系统: {{ system }}</text>
      <text class="info-item">uni-app 版本: {{ uniVersion }}</text>
    </view>
  </view>
</template>

<script>
export default {
  name: 'DebugNativeComponents',
  data() {
    return {
      platform: '',
      system: '',
      uniVersion: '',
      clickableTextResult: '',
      testButtonResult: ''
    }
  },

  created() {
    // 获取系统信息
    const systemInfo = uni.getSystemInfoSync()
    this.platform = systemInfo.platform || 'unknown'
    this.system = systemInfo.system || 'unknown'
    this.uniVersion = systemInfo.uniVersion || 'unknown'

    console.log('=== 系统信息 ===')
    console.log('platform:', this.platform)
    console.log('system:', this.system)
    console.log('完整信息:', JSON.stringify(systemInfo, null, 2))
  },

  methods: {
    handleClickableTextClick() {
      console.log('=== 可点击文本按钮被点击 ===')
      this.clickableTextResult = '点击时间: ' + new Date().toLocaleTimeString()

      uni.showToast({
        title: '可点击组件工作正常！',
        icon: 'success'
      })
    },

    handleTestButtonClick() {
      console.log('=== 完整测试按钮被点击 ===')
      this.testButtonResult = '完整按钮点击成功: ' + new Date().toLocaleTimeString()

      uni.showToast({
        title: '完整按钮工作正常！',
        icon: 'success'
      })
    }
  }
}
</script>

<style scoped>
.container {
  min-height: 100vh;
  background-color: #f5f5f5;
  padding: 40rpx;
}

.header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 24rpx;
  padding: 60rpx 40rpx;
  margin-bottom: 40rpx;
  text-align: center;
}

.title {
  display: block;
  font-size: 48rpx;
  font-weight: bold;
  color: #ffffff;
  margin-bottom: 16rpx;
}

.subtitle {
  display: block;
  font-size: 28rpx;
  color: rgba(255, 255, 255, 0.8);
}

.test-section {
  background-color: #ffffff;
  border-radius: 24rpx;
  padding: 40rpx;
  margin-bottom: 30rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.08);
}

.test-header {
  margin-bottom: 30rpx;
  border-bottom: 2rpx solid #f0f0f0;
  padding-bottom: 20rpx;
}

.test-title {
  display: block;
  font-size: 36rpx;
  font-weight: bold;
  color: #333333;
  margin-bottom: 12rpx;
}

.test-desc {
  display: block;
  font-size: 26rpx;
  color: #999999;
}

.test-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20rpx 0;
}

.result {
  margin-top: 30rpx;
  padding: 24rpx;
  background-color: #e8f5e9;
  border-radius: 12rpx;
  font-size: 28rpx;
  color: #4caf50;
  text-align: center;
  display: block;
  width: 100%;
}

.system-info {
  background-color: #ffffff;
  border-radius: 24rpx;
  padding: 40rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.08);
}

.info-title {
  display: block;
  font-size: 32rpx;
  font-weight: bold;
  color: #333333;
  margin-bottom: 24rpx;
}

.info-item {
  display: block;
  font-size: 28rpx;
  color: #666666;
  margin-bottom: 12rpx;
  line-height: 1.6;
}

embed {
  display: block;
  margin: 20rpx auto;
}
</style>
