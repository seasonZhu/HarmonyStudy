module.exports = {
  root: true,
  env: {
    node: true,
    ohos: true,
    es6: true
  },
  extends: ['plugin:@ohos/recommended'],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 2020,
    sourceType: 'module'
  },
  plugins: ['@typescript-eslint'],
  rules: {
    // 禁止 console
    'no-console': 'warn',

    // 禁止 any 类型（warn 而不是 error，为了渐进式迁移）
    '@typescript-eslint/no-explicit-any': 'warn',
    '@typescript-eslint/no-unsafe-call': 'warn',
    '@typescript-eslint/no-unsafe-member-access': 'warn',

    // 禁止未使用的变量
    '@typescript-eslint/no-unused-vars': ['warn', {
      argsIgnorePattern: '^_',
      varsIgnorePattern: '^_'
    }],

    // 禁止空的接口
    '@typescript-eslint/no-empty-interface': 'warn',

    // 允许使用 any 作为类型（用于兼容性）
    '@typescript-eslint/no-explicit-any': 'off',

    // 建议使用 const 断言
    '@typescript-eslint/prefer-const': 'warn',

    // 建议使用可选链
    '@typescript-eslint/prefer-optional-chain': 'warn'
  },
  globals: {
    // HarmonyOS 全局变量
    'AbilityConstant': 'readonly',
    'UIAbility': 'readonly',
    'Want': 'readonly',
    'window': 'readonly',
    'display': 'readonly',
    'deviceInfo': 'readonly'
  }
};
