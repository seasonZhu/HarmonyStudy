# AI 移动端开发工具链分析

> 分析日期：2026-05-13
> 数据来源：skills.sh 生态搜索

---

## 一、主流平台 AI 辅助开发成熟度

| 平台 | AI 工具链成熟度 | 官方/社区 Skills | 核心工具 |
|------|----------------|-----------------|----------|
| **Flutter** | ⭐⭐⭐⭐⭐ | 官方 flutter/skills (10K+ 安装) | Flutter SDK, Dart, GetX |
| **iOS** | ⭐⭐⭐⭐ | rshanklas/apple-skills (366 安装) | Xcode, Swift |
| **Android** | ⭐⭐⭐⭐ | mindrally/skills (333 安装) | Android Studio, Kotlin |
| **HarmonyOS** | ⭐⭐⭐ | majiayu000/claude-arsenal (309 安装) | ArkTS, DevEco Studio |

---

## 二、Skills 生态推荐

### 2.1 Flutter（最成熟）

```bash
# 安装命令
npx skills add flutter/skills@flutter-building-layouts        # 10.6K 安装
npx skills add flutter/skills@flutter-architecting-apps      # 10.4K 安装
npx skills add flutter/skills@flutter-managing-state        # 9.6K 安装
npx skills add flutter/skills@flutter-implementing-navigation-and-routing  # 9.3K 安装
npx skills add flutter/skills@flutter-animating-apps         # 9.6K 安装
npx skills add flutter/skills@flutter-theming-apps            # 9.5K 安装
```

**说明**：Flutter 官方 Skills，覆盖布局、架构、状态管理、路由、动画、主题，是最完整的移动端 AI 开发生态。

### 2.2 HarmonyOS

```bash
# 安装命令
npx skills add majiayu000/claude-arsenal@harmonyos-app       # 309 安装
npx skills add fadinglight9291117/arkts_skills@harmonyos-build-deploy  # 120 安装
npx skills add web-infra-dev/midscene-skills@harmonyos-device-automation # 1K 安装
npx skills add coreylyn/harmonyos-skills@harmonyos-dev        # 74 安装
npx skills add openharmonyinsight/openharmony-skills@android-to-harmonyos-migration-workflow  # 50 安装
```

**说明**：
- `harmonyos-app`：HarmonyOS 应用开发综合指南
- `harmonyos-build-deploy`：ArkTS 编译部署
- `harmonyos-device-automation`：设备自动化测试（1K 安装，最热门）
- `android-to-harmonyos-migration-workflow`：Android 迁移工作流

### 2.3 iOS / macOS

```bash
# 安装命令
npx skills add rshankras/claude-code-apple-skills@ios-development     # 366 安装
npx skills add rshankras/claude-code-apple-skills@macos-development   # 653 安装
npx skills add rshankras/claude-code-apple-skills@product-development  # 208 安装
```

**说明**：苹果官方 Skills，覆盖 iOS/macOS 开发、产品开发。

### 2.4 Android

```bash
# 安装命令
npx skills add mindrally/skills@android-development                   # 333 安装
```

**说明**：Android 开发综合指南。

### 2.5 跨平台移动开发

```bash
# 安装命令
npx skills add sickn33/antigravity-awesome-skills@mobile-developer              # 438 安装
npx skills add sickn33/antigravity-awesome-skills@frontend-mobile-development  # 374 安装
npx skills add capawesome-team/skills@capacitor-app-development                # 178 安装
npx skills add capawesome-team/skills@ionic-app-development                    # 143 安装
```

**说明**：
- `mobile-developer`：移动端开发者综合技能
- `mobile-development-component-scaffold`：组件脚手架
- `capacitor-app-development`：Capacitor 跨平台开发
- `ionic-app-development`：Ionic 跨平台开发

### 2.6 跨平台框架对比

| 框架 | AI 工具链成熟度 | 安装量 | 适用场景 |
|------|---------------|--------|----------|
| Flutter | ⭐⭐⭐⭐⭐ | 10K+ | 跨 iOS/Android/Web |
| React Native | ⭐⭐⭐ | 中等 | 跨 iOS/Android |
| Capacitor | ⭐⭐⭐ | 178 | Web 技术栈跨平台 |
| Ionic | ⭐⭐⭐ | 143 | Web 技术栈跨平台 |
| HarmonyOS | ⭐⭐⭐ | 309 | 华为设备专用 |

---

## 三、已有 Skills 盘点

你当前已安装的移动端相关 Skills：

| Skill | 用途 |
|-------|------|
| `flutter-getx` | Flutter GetX 状态管理与路由开发指南 |
| `cross-platform-architecture` | 跨平台移动开发架构总览 |
| `common-tools` | 跨平台通用工具封装（存储、事件总线、日志） |

---

## 四、工具链组合建议

### 4.1 Flutter + AI

```
AI Coding → Claude Code / Cursor / Windsurf
   ↓
Flutter SDK (Dart)
   ↓
状态管理: GetX / Riverpod / BLoC
   ↓
Skills: flutter/skills (官方)
```

**推荐安装**：
```bash
npx skills add flutter/skills@flutter-managing-state
npx skills add flutter/skills@flutter-implementing-navigation-and-routing
```

### 4.2 HarmonyOS + AI

```
AI Coding → Claude Code
   ↓
HarmonyOS SDK (ArkTS/ArkUI)
   ↓
路由: NavPathStack
   ↓
Skills: majiayu000/claude-arsenal@harmonyos-app
```

**推荐安装**：
```bash
npx skills add majiayu000/claude-arsenal@harmonyos-app
npx skills add web-infra-dev/midscene-skills@harmonyos-device-automation
```

### 4.3 iOS + AI

```
AI Coding → Claude Code / Xcode Copilot
   ↓
Swift / SwiftUI
   ↓
架构: MVVM / TCA
   ↓
Skills: rshankras/claude-code-apple-skills
```

**推荐安装**：
```bash
npx skills add rshankras/claude-code-apple-skills@ios-development
```

---

## 五、快速安装命令汇总

如需一次性安装推荐的 Skills，执行以下命令：

### HarmonyOS 推荐
```bash
npx skills add majiayu000/claude-arsenal@harmonyos-app -g -y
npx skills add web-infra-dev/midscene-skills@harmonyos-device-automation -g -y
```

### Flutter 推荐
```bash
npx skills add flutter/skills@flutter-managing-state -g -y
npx skills add flutter/skills@flutter-implementing-navigation-and-routing -g -y
```

### iOS 推荐
```bash
npx skills add rshankras/claude-code-apple-skills@ios-development -g -y
```

### 跨平台推荐
```bash
npx skills add sickn33/antigravity-awesome-skills@mobile-developer -g -y
```

---

## 六、结论

1. **Flutter 最成熟**：官方 Skills 支持 Layouts、State、Navigation、Theming、Animations，覆盖完整开发周期
2. **HarmonyOS 起步中**：社区有 `majiayu000/claude-arsenal`，1K 安装的 `midscene` 自动化测试是亮点
3. **跨平台方案**：Capacitor/Ionic 有官方 Skills 支持，适合 Web 技术栈团队
4. **你的项目**：HarmonyOS + iOS 可用 `flutter-getx` 的思路（状态管理 + 路由），配合 `common-tools` 封装日志、存储

---

> 如需安装，直接告诉我"安装 HarmonyOS Skills"或"安装 Flutter Skills"，我会帮你执行安装命令。