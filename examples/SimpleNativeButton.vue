<template>
  <view class="container">
    <view class="header">
      <text class="title">{{ isHarmonyOS ? '🎉 HarmonyOS 环境' : '🌍 非 HarmonyOS 环境' }}</text>
    </view>

    <!-- HarmonyOS: 使用原生组件 -->
    <view v-if="isHarmonyOS" class="harmonyos-content">
      <text class="desc">点击下方按钮测试原生组件：</text>

      <!-- 原生按钮 -->
      <embed
        tag="native-button"
        :options="{
          text: '我是原生按钮',
          type: 'primary',
          width: 300,
          height: 50
        }"
        @click="handleClick"
      />

      <text v-if="result" class="result">{{ result }}</text>
    </view>

    <!-- 其他平台: Hello World -->
    <view v-else class="hello-world">
      <text class="hello">Hello World</text>
      <text class="info">当前平台: {{ platform }}</text>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      isHarmonyOS: false,
      platform: 'unknown',
      result: ''
    };
  },

  created() {
    // 判断平台
    const systemInfo = uni.getSystemInfoSync();
    this.platform = systemInfo.platform;
    // uni-app 中 HarmonyOS 的 platform 为 'harmonyos'
    this.isHarmonyOS = systemInfo.platform === 'harmonyos' ||
                      (systemInfo.system && systemInfo.system.toLowerCase().includes('harmonyos'));

    console.log('当前平台:', this.platform, '是否HarmonyOS:', this.isHarmonyOS);
  },

  methods: {
    handleClick(e) {
      console.log('原生按钮被点击:', e);
      const detail = e.detail || e;
      this.result = `点击时间: ${new Date(detail.timestamp).toLocaleTimeString()}`;
    }
  }
};
</script>

<style scoped>
.container {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 40rpx;
}

.header {
  text-align: center;
  margin-bottom: 60rpx;
}

.title {
  font-size: 48rpx;
  font-weight: bold;
  color: #ffffff;
}

.harmonyos-content {
  background: #ffffff;
  border-radius: 24rpx;
  padding: 60rpx 40rpx;
  align-items: center;
}

.desc {
  font-size: 32rpx;
  color: #666666;
  margin-bottom: 40rpx;
  display: block;
  text-align: center;
}

.result {
  margin-top: 40rpx;
  padding: 24rpx;
  background: #f0f9ff;
  border-radius: 12rpx;
  font-size: 28rpx;
  color: #2c86ef;
  text-align: center;
  display: block;
}

.hello-world {
  background: #ffffff;
  border-radius: 24rpx;
  padding: 120rpx 40rpx;
  align-items: center;
  justify-content: center;
}

.hello {
  font-size: 80rpx;
  font-weight: bold;
  color: #333333;
  margin-bottom: 20rpx;
  display: block;
  text-align: center;
}

.info {
  font-size: 32rpx;
  color: #999999;
  text-align: center;
  display: block;
}

embed {
  display: block;
  margin: 40rpx auto;
}
</style>
