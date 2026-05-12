/*
 *  Copyright (c) 2025 Huawei Device Co., Ltd.
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

/**
 * 快捷回复管理页面
 * 
 * 功能说明：
 * 1. 展示所有快捷回复列表
 * 2. 支持新建、编辑、删除快捷回复
 * 3. 支持排序显示
 * 
 * 页面结构：
 * - 顶部导航栏：返回按钮、标题、新建按钮
 * - 快捷回复列表：每个项包含序号、内容、编辑按钮、删除按钮
 * - 编辑面板：弹出式面板，用于新建和编辑快捷回复
 */

import { router, promptAction } from '@kit.ArkUI';
import { QuickReply } from '../model/QuickReply';
import { QuickReplyManager } from '../utils/QuickReplyManager';
import { hilog } from '@kit.PerformanceAnalysisKit';

// 日志相关常量
const DOMAIN = 0x0000;
const TAG = 'QuickReplyManagePage';

/**
 * 快捷回复管理页面组件
 * 
 * @Entry 页面入口装饰器
 * @Component 组件装饰器
 */
@Entry
@Component
struct QuickReplyManagePage {
  // 快捷回复列表
  @State quickReplyList: QuickReply[] = [];
  // 是否显示编辑面板
  @State showEditPanel: boolean = false;
  // 当前编辑的快捷回复ID（空表示新建）
  @State editReplyId: string = '';
  // 当前编辑的内容
  @State editContent: string = '';
  // 是否为新建模式
  @State isNew: boolean = false;

  /**
   * 页面即将显示时的生命周期回调
   */
  aboutToAppear(): void {
    hilog.info(DOMAIN, TAG, 'aboutToAppear');
    this.loadQuickReplyData();
  }

  /**
   * 页面显示时的生命周期回调
   * 每次返回此页面时重新加载数据
   */
  onPageShow(): void {
    hilog.info(DOMAIN, TAG, 'onPageShow');
    this.loadQuickReplyData();
  }

  /**
   * 加载快捷回复数据
   * 从QuickReplyManager获取所有快捷回复
   */
  private loadQuickReplyData(): void {
    const manager: QuickReplyManager = QuickReplyManager.getInstance();
    const list: QuickReply[] = manager.loadQuickReplies();
    hilog.info(DOMAIN, TAG, `loadQuickReplyData count: ${list.length}`);
    this.quickReplyList = list;
  }

  /**
   * 打开新建面板
   * 初始化编辑状态为新建模式
   */
  private openCreatePanel(): void {
    hilog.info(DOMAIN, TAG, 'openCreatePanel');
    this.editReplyId = '';
    this.editContent = '';
    this.isNew = true;
    this.showEditPanel = true;
    hilog.info(DOMAIN, TAG, `openCreatePanel done, showEditPanel: ${this.showEditPanel}`);
  }

  /**
   * 打开编辑面板
   * @param reply 要编辑的快捷回复对象
   */
  private openEditPanel(reply: QuickReply): void {
    hilog.info(DOMAIN, TAG, `openEditPanel: ${reply.replyId}, content: ${reply.replyContent}`);
    this.editReplyId = reply.replyId;
    this.editContent = reply.replyContent;
    this.isNew = false;
    this.showEditPanel = true;
    hilog.info(DOMAIN, TAG, `openEditPanel done, editContent: ${this.editContent}`);
  }

  /**
   * 保存快捷回复
   * 验证并保存当前编辑的内容
   */
  private saveQuickReply(): void {
    hilog.info(DOMAIN, TAG, `saveQuickReply: ${this.editReplyId}, content: ${this.editContent}`);
    
    // 验证内容不为空
    if (!this.editContent || this.editContent.trim().length === 0) {
      promptAction.showToast({ message: '回复内容不能为空' });
      return;
    }

    const now: number = Date.now();
    let sortOrder: number = this.quickReplyList.length;
    let createdAt: number = now;
    
    // 如果是编辑模式，保留原有的排序和创建时间
    if (this.editReplyId.length > 0) {
      for (let i = 0; i < this.quickReplyList.length; i++) {
        if (this.quickReplyList[i].replyId === this.editReplyId) {
          sortOrder = this.quickReplyList[i].sortOrder;
          createdAt = this.quickReplyList[i].createdAt;
          break;
        }
      }
    }

    // 创建快捷回复对象
    const reply: QuickReply = new QuickReply(
      this.editReplyId.length > 0 ? this.editReplyId : QuickReply.generateId(),
      this.editContent,
      sortOrder,
      createdAt,
      now
    );

    // 验证快捷回复
    const manager: QuickReplyManager = QuickReplyManager.getInstance();
    const error: string | null = manager.validateQuickReply(reply);
    if (error !== null) {
      hilog.error(DOMAIN, TAG, `validate error: ${error}`);
      promptAction.showToast({ message: error });
      return;
    }

    // 保存快捷回复
    const success: boolean = manager.saveQuickReply(reply);
    hilog.info(DOMAIN, TAG, `saveQuickReply result: ${success}`);
    if (success) {
      this.showEditPanel = false;
      this.loadQuickReplyData();
      promptAction.showToast({ message: '保存成功' });
    } else {
      promptAction.showToast({ message: '保存失败，请重试' });
    }
  }

  /**
   * 确认删除快捷回复
   * 显示删除确认对话框
   * @param reply 要删除的快捷回复对象
   */
  private confirmDelete(reply: QuickReply): void {
    promptAction.showDialog({
      title: '确认删除',
      message: `确定要删除快捷回复"${reply.replyContent}"吗？`,
      buttons: [
        { text: '取消', color: '#666666' },
        { text: '删除', color: '#E84026' }
      ]
    }).then((result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1) {
        const manager: QuickReplyManager = QuickReplyManager.getInstance();
        manager.deleteQuickReply(reply.replyId);
        this.loadQuickReplyData();
        promptAction.showToast({ message: '删除成功' });
      }
    });
  }

  /**
   * 页面构建方法
   * 定义页面UI结构
   */
  build() {
    Stack() {
      // 主内容区域
      Column() {
        this.NavigationBar();  // 顶部导航栏
        this.QuickReplyList(); // 快捷回复列表
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFF1F3F5')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

      // 编辑面板（条件显示）
      if (this.showEditPanel) {
        this.EditPanel()
      }
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 编辑面板
   * 用于新建和编辑快捷回复
   */
  @Builder
  EditPanel() {
    Column() {
      // ========== 顶部导航栏 ==========
      Row() {
        // 取消按钮
        Button('取消')
          .fontSize(14)
          .fontColor('#666666')
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.showEditPanel = false;
          })

        Blank().layoutWeight(1)

        // 标题（根据模式显示不同文字）
        Text(this.isNew ? '新建快捷回复' : '编辑快捷回复')
          .fontSize(17)
          .fontWeight(600)

        Blank().layoutWeight(1)

        // 保存按钮
        Button('保存')
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor('#007DFF')
          .borderRadius(18)
          .height(32)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            this.saveQuickReply();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })

      // ========== 内容区域 ==========
      Column() {
        Text('回复内容')
          .fontSize(14)
          .fontColor('rgba(0, 0, 0, 0.6)')
          .width('100%')
          .margin({ bottom: 8 })

        // 内容输入框
        TextArea({ text: this.editContent, placeholder: '请输入快捷回复内容' })
          .width('100%')
          .height(150)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .padding(12)
          .maxLength(200)  // 最大200字符
          .onChange((value: string) => {
            this.editContent = value;
            hilog.info(DOMAIN, TAG, `editContent changed: ${value}`);
          })
      }
      .width('100%')
      .padding(16)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF1F3F5')
  }

  /**
   * 顶部导航栏
   * 包含返回按钮、标题、新建按钮
   */
  @Builder
  NavigationBar() {
    Flex({ alignItems: ItemAlign.Center }) {
      // 返回按钮
      Button() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(20)
          .fontColor([$r('app.color.content_text_color')])
      }
      .width(40)
      .height(40)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        router.back();
      })

      // 页面标题
      Text('快捷回复')
        .fontSize(20)
        .fontWeight(700)
        .fontColor('rgba(0, 0, 0, 0.9)')
        .flexGrow(1)
        .margin({ left: 4 })

      // 新建按钮
      Button() {
        SymbolGlyph($r('sys.symbol.plus'))
          .fontSize(20)
          .fontColor([Color.White])
      }
      .width(36)
      .height(36)
      .backgroundColor('#007DFF')
      .borderRadius(18)
      .onClick(() => {
        this.openCreatePanel();
      })
    }
    .height(56)
    .padding({ left: 4, right: 16 })
  }

  /**
   * 快捷回复列表
   * 展示所有快捷回复
   */
  @Builder
  QuickReplyList() {
    Column() {
      if (this.quickReplyList.length === 0) {
        // 空状态提示
        Column() {
          Text('暂无快捷回复，点击右上角 + 新建')
            .fontSize(14)
            .fontColor('rgba(0, 0, 0, 0.4)')
            .margin({ top: 80 })
        }
        .width('100%')
        .layoutWeight(1)
      } else {
        // 快捷回复列表
        List({ space: 8 }) {
          ForEach(this.quickReplyList, (reply: QuickReply, index?: number) => {
            ListItem() {
              this.ReplyItem(reply, index ?? 0)
            }
          }, (reply: QuickReply) => reply.replyId)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 8 })
      }
    }
    .width('100%')
    .layoutWeight(1)
  }

  /**
   * 单个快捷回复项
   * @param reply 快捷回复对象
   * @param index 序号
   */
  @Builder
  ReplyItem(reply: QuickReply, index: number) {
    Row() {
      // 序号
      Text(`${index + 1}`)
        .fontSize(14)
        .fontColor('rgba(0, 0, 0, 0.4)')
        .width(24)
        .textAlign(TextAlign.Center)

      // 回复内容
      Text(reply.replyContent)
        .fontSize(15)
        .fontColor('rgba(0, 0, 0, 0.9)')
        .layoutWeight(1)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ left: 8 })

      // 编辑按钮
      Button() {
        SymbolGlyph($r('sys.symbol.square_and_pencil'))
          .fontSize(16)
          .fontColor([$r('app.color.primary')])
      }
      .width(36)
      .height(36)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.openEditPanel(reply);
      })

      // 删除按钮
      Button() {
        SymbolGlyph($r('sys.symbol.trash'))
          .fontSize(16)
          .fontColor([$r('app.color.error')])
      }
      .width(36)
      .height(36)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.confirmDelete(reply);
      })
    }
    .width('100%')
    .padding({ left: 12, right: 8, top: 10, bottom: 10 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(VerticalAlign.Center)
  }
}
