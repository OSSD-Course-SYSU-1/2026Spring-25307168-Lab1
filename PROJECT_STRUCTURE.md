# DistributedMail 项目文件说明

## 项目概述

这是一个基于 HarmonyOS 的分布式邮件应用，使用应用接续和分布式数据对象实现跨设备的数据传输和功能迁移。

## 根目录文件

| 文件/文件夹 | 作用说明 |
|------------|---------|
| `README.md` | 项目主文档，包含项目简介、功能说明、使用说明、实现步骤等 |
| `README.en.md` | 英文版本的项目说明文档 |
| `LICENSE` | 项目许可证文件 |
| `build-profile.json5` | 应用构建配置文件，定义SDK版本、构建模式等 |
| `code-linter.json5` | 代码规范配置文件，用于代码风格检查 |
| `oh-package.json5` | 项目依赖管理配置文件 |
| `hvigorfile.ts` | Hvigor 构建脚本配置，导出应用构建任务 |
| `AppScope/` | 应用全局配置目录 |
| `entry/` | 应用主模块目录 |
| `hvigor/` | Hvigor 构建工具相关文件目录 |
| `screenshots/` | 项目截图目录 |
| `.hvigor/` | Hvigor 构建缓存目录（不建议上传） |
| `.idea/` | IDE 配置目录（不建议上传） |

## AppScope/ 目录

| 文件/文件夹 | 作用说明 |
|------------|---------|
| `app.json5` | 应用全局配置文件 |
| `resources/` | 应用全局资源文件目录 |

## entry/ 目录（主模块）

| 文件/文件夹 | 作用说明 |
|------------|---------|
| `build-profile.json5` | 模块构建配置文件 |
| `hvigorfile.ts` | 模块构建脚本 |
| `oh-package.json5` | 模级依赖管理配置 |
| `src/` | 源代码目录 |

## entry/src/main/ 目录

| 文件/文件夹 | 作用说明 |
|------------|---------|
| `module.json5` | 模块配置文件，定义应用能力、权限等 |
| `resources/` | 模块资源文件目录 |
| `ets/` | ArkTS 源代码目录 |

## entry/src/main/ets/ 目录（源代码）

| 文件/文件夹 | 作用说明 |
|------------|---------|
| `entryability/EntryAbility.ets` | 应用入口文件，管理应用生命周期和接续逻辑 |
| `pages/MailHomePage.ets` | 邮件首页UI界面 |
| `pages/TemplateManagePage.ets` | 邮件模板管理页面 |
| `pages/TemplateEditPage.ets` | 邮件模板编辑页面 |
| `pages/QuickReplyManagePage.ets` | 快捷回复管理页面 |
| `model/MailTemplate.ets` | 邮件模板数据模型 |
| `model/QuickReply.ets` | 快捷回复数据模型 |
| `utils/MailInfoManager.ets` | 邮件信息管理类，处理分布式数据对象 |
| `utils/TemplateManager.ets` | 模板管理类，处理模板的增删改查和分布式同步 |
| `utils/QuickReplyManager.ets` | 快捷回复管理类，处理快捷回复的增删改查和分布式同步 |
| `utils/DistributedSyncService.ets` | 分布式同步服务，处理跨设备数据同步 |

---

## 新增功能说明

### 1. 邮件模板功能

#### 功能概述
支持用户创建和管理自定义邮件模板，包括工作汇报、请假申请、报价单等多种类型，实现跨设备同步。

#### 功能特性
- **模板类型**：支持四种模板类型
  - 工作汇报（WORK_REPORT）
  - 请假（LEAVE）
  - 报价（QUOTATION）
  - 自定义（CUSTOM）

- **模板管理**：
  - 新建模板：创建新的邮件模板
  - 编辑模板：修改已有模板内容
  - 删除模板：删除不需要的模板
  - 模板分类：按类型筛选显示模板

- **模板内容**：
  - 模板名称：模板的显示名称
  - 主题模板：邮件主题的模板内容
  - 正文模板：邮件正文的模板内容
  - 创建/更新时间：记录模板的创建和最后修改时间

#### 相关文件
| 文件 | 说明 |
|-----|------|
| `model/MailTemplate.ets` | 模板数据模型，定义模板结构和序列化方法 |
| `utils/TemplateManager.ets` | 模板管理器，处理模板的CRUD操作和分布式同步 |
| `pages/TemplateManagePage.ets` | 模板管理页面，展示模板列表和操作按钮 |
| `pages/TemplateEditPage.ets` | 模板编辑页面，新建和编辑模板 |

#### 使用方式
1. 在邮件首页点击"模板"按钮
2. 在模板面板中点击"管理模板"
3. 在模板管理页面可以：
   - 点击右上角"+"新建模板
   - 点击模板项的"编辑"按钮修改模板
   - 点击模板项的"删除"按钮删除模板
4. 在模板面板中选择模板快速填充邮件内容

---

### 2. 快捷回复功能

#### 功能概述
支持用户创建和管理常用快捷回复内容，实现一键快速回复邮件，支持跨设备同步。

#### 功能特性
- **快捷回复管理**：
  - 新建快捷回复：创建新的快捷回复内容
  - 编辑快捷回复：修改已有快捷回复内容
  - 删除快捷回复：删除不需要的快捷回复
  - 排序功能：支持拖拽排序（预留接口）

- **快捷回复内容**：
  - 回复内容：快捷回复的文本内容
  - 排序顺序：用于显示排序
  - 创建/更新时间：记录创建和最后修改时间

#### 相关文件
| 文件 | 说明 |
|-----|------|
| `model/QuickReply.ets` | 快捷回复数据模型，定义数据结构和序列化方法 |
| `utils/QuickReplyManager.ets` | 快捷回复管理器，处理CRUD操作和分布式同步 |
| `pages/QuickReplyManagePage.ets` | 快捷回复管理页面，展示列表和操作按钮 |

#### 使用方式
1. 在邮件首页点击"快捷回复"按钮
2. 在快捷回复管理页面可以：
   - 点击右上角"+"新建快捷回复
   - 点击快捷回复项的"编辑"按钮修改内容
   - 点击快捷回复项的"删除"按钮删除
3. 在邮件编辑时选择快捷回复快速填充

---

### 3. 分布式同步功能

#### 功能概述
实现模板和快捷回复数据的跨设备自动同步，确保多设备间数据一致性。

#### 技术实现
- 使用 HarmonyOS 分布式数据对象（Distributed Data Object）API
- 数据变更自动同步到同一网络下的其他设备
- 支持增量同步，减少数据传输量

#### 相关文件
| 文件 | 说明 |
|-----|------|
| `utils/DistributedSyncService.ets` | 分布式同步服务，管理跨设备数据同步 |
| `utils/TemplateManager.ets` | 模板管理器，集成分布式同步 |
| `utils/QuickReplyManager.ets` | 快捷回复管理器，集成分布式同步 |

#### 同步数据类型
- 模板数据（templates）
- 快捷回复数据（quickReplies）

---

## 核心功能实现

1. **分布式数据传输**：通过 `distributedDataObject` API 实现跨设备数据传输
2. **应用接续**：通过系统 Dock 栏实现应用在不同设备间的接续
3. **数据同步**：使用分布式数据对象实现邮件数据的实时同步
4. **模板管理**：支持创建、编辑、删除邮件模板，跨设备同步
5. **快捷回复**：支持管理常用回复内容，一键快速回复

## 技术要求

- HarmonyOS 系统：5.0.5 Release 及以上
- DevEco Studio：6.0.2 Release 及以上
- HarmonyOS SDK：6.0.2 Release SDK 及以上
- 支持设备：华为手机

## 必要权限

- `ohos.permission.DISTRIBUTED_DATASYNC`：分布式数据同步权限
