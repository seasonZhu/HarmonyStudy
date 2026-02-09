/**
 * 测试套件入口文件
 *
 * @description
 * 组织和执行所有单元测试
 */

import localUnitTest from './LocalUnit.test';
import statusWeightTest from './StatusWeight.test';
import toastUtilTest from './ToastUtil.test';
import routerTest from './Router.test';

export default function testsuite() {
  // 执行本地单元测试
  localUnitTest();

  // 执行组件测试
  statusWeightTest();

  // 执行工具类测试
  toastUtilTest();

  // 执行路由测试
  routerTest();
}
