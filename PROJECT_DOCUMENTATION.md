# 鸿蒙打靶训练游戏 - 项目文档

## 项目概述

本项目是一个基于鸿蒙(HarmonyOS)开发的打靶训练游戏，类似于Steam平台上的Aim Lab。游戏旨在帮助用户提升瞄准能力和反应速度，具有计分系统、历史最高分记录以及大小屏适配功能。

## 项目结构

```
target/
├── entry/                          # 主模块目录
│   ├── src/                        # 源代码目录
│   │   └── main/                   # 主源码目录
│   │       ├── ets/                # ArkTS代码目录
│   │       │   ├── entryability/   # 应用能力目录
│   │       │   │   └── EntryAbility.ets    # 应用入口能力
│   │       │   └── pages/          # 页面目录
│   │       │       ├── Index.ets           # 首页
│   │       │       ├── GamePage.ets        # 游戏主页面
│   │       │       └── RecordPage.ets      # 历史记录页面
│   │       └── resources/          # 资源文件目录
│   │           └── base/           # 基础资源目录
│   │               ├── element/    # 元素资源目录
│   │               │   ├── string.json     # 字符串资源
│   │               │   └── color.json      # 颜色资源
│   │               └── profile/    # 配置文件目录
│   │                   └── main_pages.json # 页面路由配置
│   ├── build-profile.json5         # 模块构建配置
│   ├── hvigorfile.ts               # Hvigor构建脚本
│   ├── module.json5                # 模块配置文件
│   └── oh-package.json5            # 模块包配置
├── build-profile.json5             # 应用构建配置
├── hvigorfile.ts                   # 应用构建脚本
├── oh-package.json5                # 应用包配置
└── PROJECT_DOCUMENTATION.md        # 项目说明文档(本文件)
```

## 文件详细说明

### 1. 应用级配置文件

#### build-profile.json5
- **位置**: `target/build-profile.json5`
- **作用**: 应用级别的构建配置文件
- **功能**: 
  - 定义应用的编译SDK版本
  - 配置签名信息
  - 定义产品构建配置
  - 管理模块构建关系

#### hvigorfile.ts
- **位置**: `target/hvigorfile.ts`
- **作用**: 应用级别的Hvigor构建脚本
- **功能**: 
  - 导出应用构建任务
  - 配置应用级构建流程

#### oh-package.json5
- **位置**: `target/oh-package.json5`
- **作用**: 应用包配置文件
- **功能**: 
  - 定义应用名称、版本信息
  - 管理应用级依赖

### 2. 模块级配置文件

#### entry/module.json5
- **位置**: `target/entry/src/main/module.json5`
- **作用**: 模块配置文件，定义模块的基本信息和能力
- **功能**: 
  - 定义模块名称、类型(entry)
  - 配置支持的设备类型(phone, tablet)
  - 定义应用入口能力(EntryAbility)
  - 配置应用图标、标签等基本信息
  - 定义启动窗口样式

#### entry/build-profile.json5
- **位置**: `target/entry/build-profile.json5`
- **作用**: 模块构建配置
- **功能**: 
  - 定义API类型(stageMode)
  - 配置构建选项
  - 定义构建目标

#### entry/hvigorfile.ts
- **位置**: `target/entry/hvigorfile.ts`
- **作用**: 模块级Hvigor构建脚本
- **功能**: 
  - 导出HAP构建任务
  - 配置模块构建流程

#### entry/oh-package.json5
- **位置**: `target/entry/oh-package.json5`
- **作用**: 模块包配置
- **功能**: 
  - 定义模块名称、版本
  - 管理模块依赖

### 3. 页面路由配置

#### main_pages.json
- **位置**: `target/entry/src/main/resources/base/profile/main_pages.json`
- **作用**: 页面路由配置文件
- **功能**: 
  - 定义应用包含的所有页面
  - 配置页面加载顺序
  - 页面包括: Index(首页)、GamePage(游戏页)、RecordPage(记录页)

### 4. 资源文件

#### string.json
- **位置**: `target/entry/src/main/resources/base/element/string.json`
- **作用**: 字符串资源文件
- **功能**: 
  - 定义应用名称、描述等文本资源
  - 支持多语言扩展

#### color.json
- **位置**: `target/entry/src/main/resources/base/element/color.json`
- **作用**: 颜色资源文件
- **功能**: 
  - 定义应用使用的颜色值
  - 包括启动窗口背景色等

### 5. 应用能力文件

#### EntryAbility.ets
- **位置**: `target/entry/src/main/ets/entryability/EntryAbility.ets`
- **作用**: 应用入口能力，应用生命周期管理
- **功能**: 
  - 处理应用创建(onCreate)和销毁(onDestroy)
  - 管理窗口阶段创建(onWindowStageCreate)
  - 加载主页面(Index)
  - 处理前后台切换(onForeground/onBackground)

### 6. 页面文件

#### Index.ets
- **位置**: `target/entry/src/main/ets/pages/Index.ets`
- **作用**: 应用首页，游戏入口界面
- **功能**: 
  - 显示游戏标题和图标
  - 提供"开始游戏"按钮，跳转到游戏页面
  - 提供"历史记录"按钮，跳转到记录页面
  - 实现大小屏适配，根据设备屏幕密度调整UI尺寸
  - 使用渐变背景美化界面

#### GamePage.ets
- **位置**: `target/entry/src/main/ets/pages/GamePage.ets`
- **作用**: 游戏主页面，核心游戏逻辑
- **功能**: 
  - **游戏机制**:
    - 30秒倒计时游戏时长
    - 自动生成随机位置和大小的靶标
    - 靶标会在2秒后自动消失
    - 点击靶标获得分数，靶标越小分数越高
  
  - **计分系统**:
    - 根据靶标大小动态计算得分
    - 实时显示当前得分和剩余时间
    - 游戏结束时保存分数到本地存储
  
  - **数据持久化**:
    - 使用Preferences API保存游戏记录
    - 记录包含分数和时间戳
    - 自动保留前10名最高分
  
  - **大小屏适配**:
    - 检测设备屏幕密度
    - 动态调整靶标大小、UI元素尺寸
    - 适配不同分辨率的设备
  
  - **游戏结束处理**:
    - 显示最终得分
    - 提供"再来一局"和"返回首页"选项

#### RecordPage.ets
- **位置**: `target/entry/src/main/ets/pages/RecordPage.ets`
- **作用**: 历史记录页面，展示游戏成绩
- **功能**: 
  - 从本地存储加载历史记录
  - 显示最高分(第一名)突出展示
  - 列表形式展示前10名记录
  - 每条记录显示排名、分数、日期
  - 提供"清除记录"功能
  - 提供"返回首页"功能
  - 实现大小屏适配

## 核心功能实现

### 1. 计分系统
- **实现位置**: `GamePage.ets` 中的 `hitTarget()` 方法
- **计分规则**: 
  - 基础分数根据屏幕大小设定(小屏30，大屏50)
  - 实际得分 = 10 × (基础分数 / 靶标半径)
  - 靶标越小，得分越高，鼓励精准射击

### 2. 历史最高分记录
- **实现位置**: `GamePage.ets` 中的 `saveScore()` 方法
- **存储方式**: 使用鸿蒙Preferences API
- **存储键名**: 'game_records'
- **数据结构**: 
  ```typescript
  {
    score: number,    // 分数
    date: string      // 游戏时间
  }
  ```
- **记录管理**: 
  - 按分数降序排序
  - 保留前10条记录
  - 支持清除所有记录

### 3. 大小屏适配
- **实现方式**: 
  - 通过 `resourceManager.getDeviceCapability()` 获取设备能力
  - 判断屏幕密度(screenDensity < 2 为小屏)
  - 根据屏幕类型动态调整:
    - 字体大小
    - 按钮尺寸
    - 靶标大小和生成范围
    - 间距和边距

### 4. 游戏机制
- **靶标生成**: 
  - 每800毫秒生成一个新靶标
  - 随机位置和大小
  - 2秒后自动消失
  
- **交互方式**: 
  - 点击靶标命中得分
  - 实时更新分数显示
  
- **游戏流程**: 
  1. 进入游戏页面自动开始
  2. 30秒倒计时
  3. 时间结束显示结果
  4. 可选择再来一局或返回

## 技术栈

- **开发语言**: ArkTS (TypeScript扩展)
- **UI框架**: ArkUI声明式开发范式
- **数据存储**: Preferences轻量级数据存储
- **路由管理**: Router页面路由
- **构建工具**: Hvigor

## 设备支持

- **手机**: 完整支持，优化小屏体验
- **平板**: 完整支持，优化大屏体验

## 如何运行

1. 使用DevEco Studio打开项目
2. 连接鸿蒙设备或启动模拟器
3. 点击运行按钮安装应用
4. 应用启动后点击"开始游戏"即可游玩

## 未来扩展建议

1. 添加不同游戏模式(限时模式、无限模式等)
2. 增加靶标类型(移动靶、缩小靶等)
3. 添加音效和震动反馈
4. 实现在线排行榜
5. 添加成就系统
6. 支持自定义游戏时长和难度

## 版本信息

- **版本**: 1.0.0
- **最低SDK版本**: 9
- **目标SDK版本**: 9
