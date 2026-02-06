<template>
  <view class="page">
    <!-- 只在 HarmonyOS 平台显示原生组件 -->
    <view v-if="isHarmonyOS">
      <text class="title">原生组件测试</text>

      <!-- 👇 这就是调用原生组件的方式 -->
      <embed tag="simple-text" />

      <text class="tip">如果上面显示了 "Hello from Native"，说明成功了！</text>
    </view>

    <!-- 其他平台显示这个 -->
    <view v-else>
      <text class="title">Hello World</text>
      <text class="tip">原生组件只在 HarmonyOS 平台可用</text>
      <text class="info">当前平台: {{ platform }}</text>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      platform: '',
      isHarmonyOS: false
    }
  },

  created() {
    // 获取系统信息
    const systemInfo = uni.getSystemInfoSync()
    this.platform = systemInfo.platform

    // 判断是否是 HarmonyOS
    this.isHarmonyOS = systemInfo.platform === 'harmonyos'
  }
}
</script>

<style scoped>
.page {
  min-height: 100vh;
  padding: 40rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.title {
  font-size: 48rpx;
  font-weight: bold;
  color: #ffffff;
  margin-bottom: 60rpx;
  text-align: center;
}

.tip {
  font-size: 28rpx;
  color: #ffffff;
  text-align: center;
  padding: 20rpx;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 12rpx;
  margin-top: 40rpx;
}

.info {
  font-size: 24rpx;
  color: rgba(255, 255, 255, 0.8);
  margin-top: 20rpx;
}

embed {
  display: block;
  margin: 40rpx auto;
}
</style>
