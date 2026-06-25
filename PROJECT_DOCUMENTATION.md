# 鸿蒙打靶训练游戏 - 项目文档

## 项目概述

本项目是一个基于鸿蒙(HarmonyOS)开发的打靶训练游戏，类似于Steam平台上的Aim Lab。游戏旨在帮助用户提升瞄准能力和反应速度，具有计分系统、历史最高分记录、大小屏适配以及跨设备投送功能。

## 项目结构

```
target/
├── entry/                          # 主模块目录
│   ├── src/                        # 源代码目录
│   │   └── main/                   # 主源码目录
│   │       ├── ets/                # ArkTS代码目录
│   │       │   ├── entryability/   # 应用能力目录
│   │       │   │   └── EntryAbility.ets    # 应用入口能力
│   │       │   ├── pages/          # 页面目录
│   │       │   │   ├── Index.ets           # 首页
│   │       │   │   ├── GamePage.ets        # 游戏主页面
│   │       │   │   └── RecordPage.ets      # 历史记录页面
│   │       │   ├── utils/          # 工具类目录
│   │       │   │   └── ScreenAdapter.ets   # 屏幕适配工具类
│   │       │   ├── constants/      # 常量类目录
│   │       │   │   └── LayoutConstants.ets # 布局参数常量类
│   │       │   └── cast/           # 跨设备投送目录
│   │       │       ├── DeviceCastManager.ets    # 投送管理器
│   │       │       ├── DistributedGameData.ets  # 分布式数据同步
│   │       │       ├── DeviceSelectPanel.ets    # 设备选择面板
│   │       │       └── CastStatusBar.ets        # 投送状态栏
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
  - 配置支持的设备类型(phone, tablet, 2in1)
  - 定义应用入口能力(EntryAbility)
  - 配置应用图标、标签等基本信息
  - 定义启动窗口样式
  - 声明分布式数据同步权限(ohos.permission.DISTRIBUTED_DATASYNC)

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
  - 定义分布式权限说明文本
  - 定义跨设备投送相关UI文本
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

### 6. 工具类文件

#### ScreenAdapter.ets
- **位置**: `target/entry/src/main/ets/utils/ScreenAdapter.ets`
- **作用**: 屏幕适配工具类
- **功能**: 
  - 使用HarmonyOS MediaQuery API检测屏幕宽度
  - 断点值600vp：宽度<600vp为小屏，>=600vp为大屏
  - 提供initScreenDetection()初始化屏幕检测
  - 提供registerListener()注册断点监听器，动态响应窗口尺寸变化
  - 提供unregisterListener()注销监听器，避免内存泄漏
  - 异常降级：API调用失败时默认使用大屏布局

#### LayoutConstants.ets
- **位置**: `target/entry/src/main/ets/constants/LayoutConstants.ets`
- **作用**: 布局参数常量类
- **功能**: 
  - 定义SizeValue和StringValue接口（small/large双值）
  - 按页面分组管理所有可适配的布局参数
  - IndexPage命名空间：首页布局参数（标题、图标、按钮等）
  - GamePage命名空间：游戏页布局参数（准备区、游戏区、结束面板等）
  - RecordPage命名空间：记录页布局参数（标题、列表、按钮等）
  - CastUI命名空间：投送功能布局参数
  - 提供getSizeValue()和getStringValue()辅助函数

### 7. 跨设备投送文件

#### DeviceCastManager.ets
- **位置**: `target/entry/src/main/ets/cast/DeviceCastManager.ets`
- **作用**: 跨设备投送核心管理器（单例模式）
- **功能**: 
  - 使用@ohos.distributedDeviceManager进行设备发现和管理
  - 启动/停止设备发现(startDeviceDiscovery/stopDeviceDiscovery)
  - 连接/断开设备(connectDevice/disconnectDevice)
  - 检测分布式能力支持(isDistributedSupported)
  - 设备发现超时处理(默认10秒)
  - 连接失败自动重试(最多3次)
  - 不支持分布式能力时安全降级

#### DistributedGameData.ets
- **位置**: `target/entry/src/main/ets/cast/DistributedGameData.ets`
- **作用**: 跨设备游戏数据同步模块
- **功能**: 
  - 使用@ohos.data.distributedDataObject创建分布式数据对象
  - 同步游戏状态(分数、时间、靶子位置等)到远端设备
  - 接收远端控制事件(击中靶子等操作)
  - 监听远端数据变更
  - 靶子列表通过JSON序列化同步(分布式对象不支持数组直接同步)

#### DeviceSelectPanel.ets
- **位置**: `target/entry/src/main/ets/cast/DeviceSelectPanel.ets`
- **作用**: 设备选择UI面板(@CustomDialog)
- **功能**: 
  - 显示"选择投送设备"标题
  - 搜索状态指示器(加载动画)
  - 设备列表(设备图标+名称+连接按钮)
  - 空状态提示+重试按钮
  - 关闭按钮
  - 适配大小屏布局

#### CastStatusBar.ets
- **位置**: `target/entry/src/main/ets/cast/CastStatusBar.ets`
- **作用**: 投送状态栏组件(@Component)
- **功能**: 
  - 投送图标+连接状态文本+断开按钮
  - 仅在连接状态为CONNECTED时显示
  - 适配大小屏布局

### 8. 页面文件

#### Index.ets
- **位置**: `target/entry/src/main/ets/pages/Index.ets`
- **作用**: 应用首页，游戏入口界面
- **功能**: 
  - 显示游戏标题和图标
  - 提供"开始游戏"按钮，跳转到游戏页面
  - 提供"历史记录"按钮，跳转到记录页面
  - 使用ScreenAdapter实现大小屏动态适配
  - 使用LayoutConstants获取布局参数
  - 支持分布式能力时显示投送功能提示
  - 使用渐变背景美化界面

#### GamePage.ets
- **位置**: `target/entry/src/main/ets/pages/GamePage.ets`
- **作用**: 游戏主页面，核心游戏逻辑
- **功能**: 
  - **游戏机制**:
    - 可配置游戏时长(15s/30s/60s)
    - 可配置靶子数量(1-5个同时存在)
    - 可配置靶子大小(小/中/大)
    - 随机位置生成靶标，位置验证防止重叠
    - 点击靶标获得分数，靶标越小分数越高
  
  - **计分系统**:
    - 根据靶标大小动态计算得分
    - 实时显示当前得分和剩余时间
    - 游戏结束时保存分数
  
  - **大小屏适配**:
    - 使用ScreenAdapter检测屏幕类型
    - 使用LayoutConstants获取所有布局参数
    - 支持窗口尺寸动态变化(2in1设备拖拽窗口)
    - 靶子半径、基础分数等游戏参数也根据屏幕适配
  
  - **跨设备投送**:
    - 准备阶段显示"跨设备投送"按钮(仅支持分布式能力的设备)
    - 点击按钮打开设备选择面板
    - 连接成功后显示CastStatusBar状态栏
    - 游戏状态变化时自动同步到远端设备
    - 接收远端控制事件(击中靶子)
    - 断开连接时自动清理状态
  
  - **游戏结束处理**:
    - 显示最终得分
    - 提供"再来一局"和"返回首页"选项

#### RecordPage.ets
- **位置**: `target/entry/src/main/ets/pages/RecordPage.ets`
- **作用**: 历史记录页面，展示游戏成绩
- **功能**: 
  - 从全局变量加载历史记录
  - 显示最高分(第一名)突出展示
  - 列表形式展示前10名记录
  - 每条记录显示排名、分数、日期
  - 提供"清除记录"功能
  - 提供"返回首页"功能
  - 使用ScreenAdapter和LayoutConstants实现大小屏动态适配

## 核心功能实现

### 1. 计分系统
- **实现位置**: `GamePage.ets` 中的 `hitTarget()` 方法
- **计分规则**: 
  - 基础分数根据屏幕大小设定(小屏30，大屏50)，从LayoutConstants.GamePage.baseScore获取
  - 实际得分 = 10 × (基础分数 / 靶标半径)
  - 靶标越小，得分越高，鼓励精准射击

### 2. 历史最高分记录
- **实现位置**: `GamePage.ets` 中的 `saveScore()` 方法
- **存储方式**: 使用全局变量gameRecords存储（内存存储）
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
  - ScreenAdapter工具类使用 `@ohos.mediaQuery` 的 `matchMediaSync` API
  - 断点值600vp：窗口宽度<600vp为小屏，>=600vp为大屏
  - 页面aboutToAppear中初始化检测并注册监听器
  - 页面aboutToDisappear中注销监听器
  - LayoutConstants集中管理所有布局参数的small/large双值
  - 使用getSizeValue()/getStringValue()辅助函数根据isSmallScreen取值
- **适配范围**:
  - 字体大小（标题、标签、按钮文字等）
  - 组件尺寸（按钮宽高、图标大小等）
  - 间距和边距
  - 游戏区域高度占比
  - 靶子半径（小/中/大三种尺寸）
  - 基础分数
  - 游戏结束面板宽度和内边距
- **动态响应**:
  - 支持窗口尺寸变化时自动切换布局
  - 适用于2in1设备自由拖拽窗口场景
  - 支持phone、tablet、2in1三种设备类型

### 4. 跨设备投送
- **实现方式**:
  - DeviceCastManager单例管理器使用 `@ohos.distributedDeviceManager`
  - DistributedGameData使用 `@ohos.data.distributedDataObject`
  - DeviceSelectPanel自定义弹窗提供设备选择UI
  - CastStatusBar组件显示投送连接状态
- **功能流程**:
  1. 用户在游戏准备页点击"跨设备投送"按钮
  2. 启动设备发现，搜索同一华为账号下的可用设备
  3. 用户在设备选择面板中选择目标设备
  4. 建立投送连接，创建分布式数据对象
  5. 游戏进行中，本地游戏状态实时同步到远端
  6. 远端设备的触控操作通过控制事件传递到本地
  7. 用户可随时断开投送连接
- **安全机制**:
  - 仅发现和连接同一华为账号下的可信设备
  - 声明ohos.permission.DISTRIBUTED_DATASYNC权限
  - 数据传输使用HarmonyOS安全通道
- **降级策略**:
  - 不支持分布式能力的设备隐藏投送入口
  - 设备发现失败显示空状态和重试按钮
  - 连接失败自动重试(最多3次)
  - 连接断开自动通知用户

### 5. 游戏机制
- **靶标生成**: 
  - 游戏开始时根据targetCount生成对应数量的靶标
  - 随机位置生成，位置验证防止重叠和超出边界
  - 最多尝试100次，超过则放弃生成
  - 击中后立即补充新靶标，保持屏幕上始终有targetCount个
  
- **交互方式**: 
  - 点击靶标命中得分
  - 实时更新分数显示
  
- **游戏流程**: 
  1. 进入游戏页面显示准备阶段
  2. 配置靶子数量、大小、游戏时长
  3. 点击"开始游戏"开始倒计时
  4. 时间结束显示结果面板
  5. 可选择再来一局或返回首页

## 技术栈

- **开发语言**: ArkTS (TypeScript扩展)
- **UI框架**: ArkUI声明式开发范式
- **运行平台**: HarmonyOS
- **屏幕适配**: @ohos.mediaQuery (MediaQuery API)
- **分布式能力**: @ohos.distributedDeviceManager (设备发现与连接)
- **数据同步**: @ohos.data.distributedDataObject (分布式数据对象)
- **路由管理**: @ohos.router (页面路由)
- **日志**: @ohos.hilog (日志输出)
- **构建工具**: Hvigor

## 设备支持

- **手机(phone)**: 完整支持，小屏优化布局，支持投送和被投送
- **平板(tablet)**: 完整支持，大屏优化布局，支持投送和被投送
- **2in1设备**: 完整支持，大屏优化布局，支持窗口自由拖拽时动态切换布局，支持投送和被投送

## 权限说明

| 权限名称 | 用途 | 使用场景 |
|---------|------|---------|
| ohos.permission.DISTRIBUTED_DATASYNC | 跨设备数据同步，用于发现和连接附近设备进行游戏投送 | 用户主动使用投送功能时(inuse) |

## 如何运行

1. 使用DevEco Studio打开项目
2. 连接鸿蒙设备或启动模拟器
3. 点击运行按钮安装应用
4. 应用启动后点击"开始游戏"即可游玩
5. 如需使用跨设备投送，确保两台设备登录同一华为账号并在同一网络下

## 未来扩展建议

1. 添加不同游戏模式(限时模式、无限模式等)
2. 增加靶标类型(移动靶、缩小靶等)
3. 添加音效和震动反馈
4. 实现在线排行榜
5. 添加成就系统
6. 使用Preferences API实现数据持久化存储
7. 支持多设备同时投送(一对多)
8. 添加投送过程中的语音通话功能

## 版本信息

- **版本**: 2.0.0
- **兼容SDK版本**: 5.0.0(12)
- **目标SDK版本**: 6.0.2(22)
- **运行OS**: HarmonyOS
