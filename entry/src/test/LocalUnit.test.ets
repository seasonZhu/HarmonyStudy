import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';

export default function localUnitTest() {
  describe('localUnitTest', () => {
    // 定义测试套件
    beforeAll(() => {
      console.log('========== LocalUnit Test Start ==========');
    });

    beforeEach(() => {
      // 每个测试用例前执行
    });

    afterEach(() => {
      // 每个测试用例后执行
    });

    afterAll(() => {
      console.log('========== LocalUnit Test End ==========');
    });

    it('assertContain', () => {
      // 定义测试用例 - 字符串包含测试
      let a = 'abc';
      let b = 'b';
      // 使用新版 API (Jasmine 风格)
      expect(a).toContain(b);
      expect(a).toEqual(a);
    });

    it('number operations', () => {
      // 数字运算测试
      let x = 10;
      let y = 5;
      expect(x + y).toBe(15);
      expect(x - y).toBe(5);
      expect(x * y).toBe(50);
      expect(x / y).toBe(2);
    });

    it('boolean operations', () => {
      // 布尔运算测试
      let flag = true;
      expect(flag).toBe(true);
      expect(!flag).toBe(false);
    });

    it('array operations', () => {
      // 数组操作测试
      let arr = [1, 2, 3, 4, 5];
      expect(arr.length).toBe(5);
      expect(arr).toContain(3);
    });
  });
}
