# 鸿蒙打靶游戏项目构建指南

## 项目已创建完成

所有源代码和配置文件已成功创建，包括：
- ✅ 3个页面文件（Index.ets、GamePage.ets、RecordPage.ets）
- ✅ 应用入口能力（EntryAbility.ets）
- ✅ 完整的项目配置文件
- ✅ 项目说明文档（PROJECT_DOCUMENTATION.md）

## 构建错误解决方案

当前遇到的错误：
```
The project structure and configuration need to be upgraded before use.
```

### 解决方法（按顺序尝试）：

#### 方法1：使用DevEco Studio迁移工具（推荐）
1. 在DevEco Studio中打开项目
2. 查看顶部菜单栏，点击 **Tools** 菜单
3. 选择 **Migrate Project to HarmonyOS** 或类似选项
4. 按照向导提示完成迁移
5. 迁移完成后，点击 **Build > Make Project** 构建项目

#### 方法2：手动触发项目同步
1. 在DevEco Studio中，点击 **File > Invalidate Caches / Restart**
2. 选择 **Invalidate and Restart**
3. 重启后，点击 **File > Sync Project with Build Files**
4. 如果弹出迁移提示，点击确认进行迁移

#### 方法3：创建新项目并复制代码
如果上述方法都不行，可以：
1. 在DevEco Studio中创建一个新的HarmonyOS项目
   - File > New > Create Project
   - 选择 Empty Ability 模板
   - 配置项目名称和包名
2. 将本项目的源代码复制到新项目中：
   - 复制 `entry/src/main/ets/pages/` 下的3个页面文件
   - 复制 `entry/src/main/ets/entryability/EntryAbility.ets`
   - 复制 `entry/src/main/resources/` 下的资源文件
3. 更新 `main_pages.json` 配置页面路由
4. 构建新项目

## 项目功能说明

### 游戏功能
- 30秒限时打靶挑战
- 随机生成不同大小的靶标
- 动态计分系统（靶标越小分数越高）
- 靶标2秒后自动消失

### 历史记录
- 自动保存前10名最高分
- 使用Preferences API持久化存储
- 支持清除记录功能

### 大小屏适配
- 自动检测设备屏幕密度
- 动态调整UI元素尺寸
- 支持手机、平板、2in1设备

## 文件结构

```
target/
├── entry/
│   ├── src/main/
│   │   ├── ets/
│   │   │   ├── entryability/
│   │   │   │   └── EntryAbility.ets    # 应用入口
│   │   │   └── pages/
│   │   │       ├── Index.ets           # 首页
│   │   │       ├── GamePage.ets        # 游戏页面
│   │   │       └── RecordPage.ets      # 历史记录页面
│   │   └── resources/                  # 资源文件
│   └── module.json5                    # 模块配置
├── build-profile.json5                 # 构建配置
├── app.json5                           # 应用配置
└── PROJECT_DOCUMENTATION.md            # 项目说明文档
```

## 技术栈

- **开发语言**: ArkTS (TypeScript扩展)
- **UI框架**: ArkUI声明式开发
- **数据存储**: Preferences API
- **路由管理**: Router
- **构建工具**: Hvigor

## 注意事项

1. 确保DevEco Studio版本支持HarmonyOS 5.0.0(12)
2. 项目配置已设置为最新格式，需要IDE支持
3. 如果IDE版本较旧，建议使用方法3创建新项目

## 联系支持

如果遇到其他问题，可以：
1. 查看DevEco Studio官方文档
2. 访问HarmonyOS开发者社区
3. 检查IDE的Build Output获取详细错误信息
