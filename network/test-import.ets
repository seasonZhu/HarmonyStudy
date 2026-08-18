/**
 * Network模块导入测试
 * 用于验证network模块的所有导出是否正常工作
 */

// 测试所有导出
import {
  // Models
  ApiResponse,
  createSuccessResponse,
  ApiError,
  ApiErrorType,
  HttpConfig,
  RequestMethod,

  // Core
  HttpClient,
  InterceptorManager,
  ErrorHandler,

  // Interceptors
  createRetryInterceptor,
  createTokenInterceptor,
  createLoggingInterceptor,
  LogLevel,

  // Services
  EnvironmentService,
  Environment,
  LoadingService,
  environmentService,
  loadingService,

  // Default exports
  getHttpClient,
  createDefaultHttpClient,
  resetHttpClient
} from './Index.ets'

// 测试函数
export function testNetworkImports(): boolean {
  try {
    // 测试HttpClient
    const client = getHttpClient()
    console.log('✅ HttpClient imported successfully')

    // 测试EnvironmentService
    const currentEnv = environmentService.getCurrentEnvironment()
    console.log('✅ EnvironmentService imported successfully, current env:', currentEnv)

    // 测试LoadingService
    const isLoading = loadingService.isLoading()
    console.log('✅ LoadingService imported successfully, isLoading:', isLoading)

    // 测试工厂函数
    const retryInterceptor = createRetryInterceptor()
    console.log('✅ RetryInterceptor created successfully')

    const tokenInterceptor = createTokenInterceptor()
    console.log('✅ TokenInterceptor created successfully')

    const loggingInterceptor = createLoggingInterceptor()
    console.log('✅ LoggingInterceptor created successfully')

    console.log('✅ All network module imports successful!')
    return true
  } catch (error) {
    console.error('❌ Network module import test failed:', error)
    return false
  }
}
