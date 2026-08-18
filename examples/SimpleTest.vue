<template>
  <view class="container">
    <!-- 头部信息 -->
    <view class="header">
      <text class="title">🔍 原生组件测试</text>
      <text class="platform">当前平台: {{ platform }}</text>
    </view>

    <!-- HarmonyOS: 显示原生组件 -->
    <view v-if="isHarmonyOS" class="harmonyos-content">
      <view class="test-card">
        <text class="card-title">测试1: 最简单的组件</text>
        <text class="card-desc">无参数、无回调，只显示文本</text>

        <!-- 调用原生组件 -->
        <view class="component-wrapper">
          <embed tag="simple-text" />
        </view>

        <text class="success-text">✅ 如果上面显示 "Hello from Native"，说明组件工作正常！</text>
      </view>

      <!-- 更多测试 -->
      <view class="test-card">
        <text class="card-title">测试2: 带消息的组件</text>
        <text class="card-desc">传递自定义消息参数</text>

        <view class="component-wrapper">
          <embed
            tag="text-with-message"
            :options="{ message: 'Hello from uni-app 小程序！' }"
          />
        </view>
      </view>

      <view class="test-card">
        <text class="card-title">测试3: 可点击的组件</text>
        <text class="card-desc">点击下面的按钮测试</text>

        <view class="component-wrapper">
          <embed
            tag="clickable-text"
            :options="{ text: '点击我试试' }"
            :onClick="handleClick"
          />
        </view>

        <text v-if="clickResult" class="result-text">{{ clickResult }}</text>
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
  name: 'SimpleTest',
  data() {
    return {
      platform: '',
      isHarmonyOS: false,
      clickResult: ''
    }
  },

  created() {
    // 检测平台
    try {
      const systemInfo = uni.getSystemInfoSync()
      console.log('=== 系统信息 ===', systemInfo)

      this.platform = systemInfo.platform || 'unknown'

      // 判断是否是 HarmonyOS
      this.isHarmonyOS = systemInfo.platform === 'harmonyos' ||
                        (systemInfo.system && systemInfo.system.toLowerCase().includes('harmonyos'))

      console.log('平台:', this.platform)
      console.log('是否HarmonyOS:', this.isHarmonyOS)
    } catch (error) {
      console.error('获取系统信息失败:', error)
      this.platform = 'unknown'
      this.isHarmonyOS = false
    }
  },

  methods: {
    handleClick() {
      console.log('=== 原生组件按钮被点击 ===')
      this.clickResult = '点击成功！时间: ' + new Date().toLocaleTimeString()

      uni.showToast({
        title: '原生组件工作正常！🎉',
        icon: 'success',
        duration: 2000
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

.success-text {
  display: block;
  font-size: 26rpx;
  color: #4caf50;
  text-align: center;
  padding: 20rpx;
  background: #e8f5e9;
  border-radius: 12rpx;
}

.result-text {
  display: block;
  font-size: 28rpx;
  color: #2c86ef;
  text-align: center;
  padding: 24rpx;
  background: #e3f2fd;
  border-radius: 12rpx;
  margin-top: 20rpx;
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
  width: 100%;
}
</style>
