/**
 * ToastUtil 单元测试
 *
 * @description
 * 测试 ToastUtil 的各种方法
 */

import { describe, it, expect, beforeAll } from '@ohos/hypium';
import { ToastUtil } from '../../main/ets/utils/ToastUtil';

export default function ToastUtilTest() {
  describe('ToastUtil', () => {
    beforeAll(() => {
      console.log('========== ToastUtil Test Start ==========');
    });

    it('should exist and be defined', () => {
      expect(ToastUtil).not.toBeNull();
      expect(ToastUtil).toBeDefined();
    });

    it('should have all required static methods', () => {
      expect(ToastUtil.success).toBeDefined();
      expect(ToastUtil.error).toBeDefined();
      expect(ToastUtil.info).toBeDefined();
      expect(ToastUtil.warning).toBeDefined();
      expect(ToastUtil.show).toBeDefined();
      expect(ToastUtil.showAtBottom).toBeDefined();
    });

    it('should have correct method types', () => {
      expect(typeof ToastUtil.success).toBe('function');
      expect(typeof ToastUtil.error).toBe('function');
      expect(typeof ToastUtil.info).toBe('function');
      expect(typeof ToastUtil.warning).toBe('function');
      expect(typeof ToastUtil.show).toBe('function');
    });

    describe('success()', () => {
      it('should be callable without errors', () => {
        expect(() => {
          ToastUtil.success('测试成功');
        }).not.toThrow();
      });

      it('should accept custom duration', () => {
        expect(() => {
          ToastUtil.success('测试成功', 3000);
        }).not.toThrow();
      });
    });

    describe('error()', () => {
      it('should be callable without errors', () => {
        expect(() => {
          ToastUtil.error('测试错误');
        }).not.toThrow();
      });

      it('should accept custom duration', () => {
        expect(() => {
          ToastUtil.error('测试错误', 5000);
        }).not.toThrow();
      });
    });

    describe('info()', () => {
      it('should be callable without errors', () => {
        expect(() => {
          ToastUtil.info('测试信息');
        }).not.toThrow();
      });
    });

    describe('warning()', () => {
      it('should be callable without errors', () => {
        expect(() => {
          ToastUtil.warning('测试警告');
        }).not.toThrow();
      });
    });

    describe('show()', () => {
      it('should be callable with options', () => {
        expect(() => {
          ToastUtil.show({
            message: '自定义消息',
            duration: 3000,
          });
        }).not.toThrow();
      });

      it('should handle minimal options', () => {
        expect(() => {
          ToastUtil.show({
            message: '消息',
          });
        }).not.toThrow();
      });
    });

    describe('showAtBottom()', () => {
      it('should be callable without errors', () => {
        expect(() => {
          ToastUtil.showAtBottom('底部消息');
        }).not.toThrow();
      });
    });
  });
}
