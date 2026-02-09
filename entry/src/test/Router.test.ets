/**
 * Router 单元测试
 *
 * @description
 * 测试路由管理器的功能
 */

import { describe, it, expect, beforeAll } from '@ohos/hypium';
import { Router } from '../../main/ets/router/Router';
import { RouterName } from '../../main/ets/router/RouterName';

export default function RouterTest() {
  describe('Router', () => {
    beforeAll(() => {
      console.log('========== Router Test Start ==========');
    });

    it('should exist and be defined', () => {
      expect(Router).not.toBeNull();
      expect(Router).toBeDefined();
    });

    it('should have all required methods', () => {
      expect(Router.push).toBeDefined();
      expect(Router.replace).toBeDefined();
      expect(Router.back).toBeDefined();
      expect(Router.clear).toBeDefined();
      expect(Router.backWithParams).toBeDefined();
    });

    it('should have all router names defined', () => {
      // 验证所有路由名称都有对应的定义
      const requiredRoutes = [
        'Splash',
        'Index',
        'Login',
        'Register',
        'MyCoin',
        'Rank',
        'SearchResult',
        'MyCollect',
        'Web',
        'Hotkey',
        'TreeDetail',
        'EnvironmentSwitch',
        'Setting',
        'WebExample',
        'WebComponent',
        'ObservedV2TestPage',
        'NetworkExample',
        'NativeComponentsDemo',
      ];

      requiredRoutes.forEach((route) => {
        expect(RouterName[route]).toBeDefined();
        expect(typeof RouterName[route]).toBe('string');
      });
    });

    it('should have correct enum values', () => {
      expect(RouterName.Splash).toBe('Splash');
      expect(RouterName.Index).toBe('Index');
      expect(RouterName.Login).toBe('Login');
      expect(RouterName.Setting).toBe('Setting');
      expect(RouterName.NativeComponentsDemo).toBe('NativeComponentsDemo');
    });

    it('should have consistent route names', () => {
      // 验证路由名称的一致性
      expect(RouterName.Splash).toEqual('Splash');
      expect(RouterName.Index).toEqual('Index');
      expect(RouterName.Login).toEqual('Login');
    });
  });

  describe('RouterName', () => {
    it('should be a valid enum object', () => {
      expect(RouterName).toBeDefined();
      expect(typeof RouterName).toBe('object');
    });

    it('should have multiple routes defined', () => {
      const routeCount = Object.keys(RouterName).length;
      expect(routeCount).toBeGreaterThan(10);
    });

    it('should have all core routes', () => {
      // 验证核心路由存在
      expect(RouterName.Splash).toBeDefined();
      expect(RouterName.Index).toBeDefined();
      expect(RouterName.Login).toBeDefined();
      expect(RouterName.Setting).toBeDefined();
    });
  });
}
