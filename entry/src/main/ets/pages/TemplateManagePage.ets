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
 * 邮件模板管理页面
 * 
 * 功能说明：
 * 1. 展示所有邮件模板，按类型分类（工作汇报、请假、报价、自定义）
 * 2. 支持新建、编辑、删除模板
 * 3. 通过标签页切换不同类型的模板
 * 
 * 页面结构：
 * - 顶部导航栏：返回按钮、标题、新建按钮
 * - 类型标签页：工作汇报、请假、报价、自定义
 * - 模板列表：每个模板项包含名称、编辑按钮、删除按钮
 * - 删除确认弹窗：确认删除操作
 */

import { router, promptAction } from '@kit.ArkUI';
import { MailTemplate, TemplateType } from '../model/MailTemplate';
import { TemplateManager } from '../utils/TemplateManager';
import { hilog } from '@kit.PerformanceAnalysisKit';

// 日志相关常量
const DOMAIN = 0x0000;
const TAG = 'TemplateManagePage';

/**
 * 模板管理页面组件
 * 
 * @Entry 页面入口装饰器
 * @Component 组件装饰器
 */
@Entry
@Component
struct TemplateManagePage {
  // 所有模板列表
  @State allTemplates: MailTemplate[] = [];
  // 当前选中的类型索引
  @State currentType: number = 0;
  // 是否显示删除确认弹窗
  @State showDeleteConfirm: boolean = false;
  // 待删除的模板ID
  @State deleteTargetId: string = '';
  // 待删除的模板名称（用于弹窗显示）
  @State deleteTargetName: string = '';

  // 模板类型数组
  private templateTypes: TemplateType[] = [TemplateType.WORK_REPORT, TemplateType.LEAVE,
    TemplateType.QUOTATION, TemplateType.CUSTOM];
  // 类型标签显示名称
  private typeLabels: string[] = ['工作汇报', '请假', '报价', '自定义'];

  /**
   * 页面即将显示时的生命周期回调
   * 在此加载模板数据
   */
  aboutToAppear(): void {
    hilog.info(DOMAIN, TAG, 'aboutToAppear');
    this.loadTemplateData();
  }

  /**
   * 页面显示时的生命周期回调
   * 每次返回此页面时重新加载数据
   */
  onPageShow(): void {
    hilog.info(DOMAIN, TAG, 'onPageShow');
    this.loadTemplateData();
  }

  /**
   * 加载模板数据
   * 从TemplateManager获取所有模板
   */
  private loadTemplateData(): void {
    const manager: TemplateManager = TemplateManager.getInstance();
    const list: MailTemplate[] = manager.loadTemplates();
    hilog.info(DOMAIN, TAG, `loadTemplateData count: ${list.length}`);
    this.allTemplates = list;
  }

  /**
   * 获取当前类型的模板列表
   * @returns 过滤后的模板数组
   */
  private getFilteredTemplates(): MailTemplate[] {
    const targetType: TemplateType = this.templateTypes[this.currentType];
    return this.allTemplates.filter(t => t.templateType === targetType);
  }

  /**
   * 确认删除模板
   * 执行删除操作并刷新列表
   */
  private confirmDelete(): void {
    hilog.info(DOMAIN, TAG, `confirmDelete: ${this.deleteTargetId}`);
    const manager: TemplateManager = TemplateManager.getInstance();
    const success: boolean = manager.deleteTemplate(this.deleteTargetId);
    if (success) {
      this.loadTemplateData();
      promptAction.showToast({ message: '删除成功' });
    } else {
      promptAction.showToast({ message: '删除失败' });
    }
    this.showDeleteConfirm = false;
  }

  /**
   * 页面构建方法
   * 定义页面UI结构
   */
  build() {
    Column() {
      // ========== 顶部导航栏 ==========
      Row() {
        // 返回按钮 - 点击返回上一页
        Button('返回')
          .onClick(() => {
            router.back();
          })

        // 页面标题
        Text('邮件模板')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 新建按钮 - 跳转到模板编辑页面（新建模式）
        Button('新建')
          .onClick(() => {
            router.pushUrl({
              url: 'pages/TemplateEditPage',
              params: { mode: 'create', templateType: this.templateTypes[this.currentType] }
            });
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })

      // ========== 类型选择标签页 ==========
      Tabs({ index: this.currentType }) {
        ForEach(this.typeLabels, (label: string, index?: number) => {
          TabContent() {
            Column() {}
          }
          .tabBar(label)
        }, (label: string, index?: number) => `${index}`)
      }
      .barMode(BarMode.Fixed)
      .barHeight(48)
      .onChange((index: number) => {
        // 切换标签页时更新当前类型
        this.currentType = index;
      })
      .width('100%')

      // ========== 模板列表区域 ==========
      if (this.getFilteredTemplates().length === 0) {
        // 空状态提示
        Column() {
          Text('暂无模板，点击右上角新建')
            .fontSize(16)
            .fontColor('#999999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        // 模板列表
        List({ space: 10 }) {
          ForEach(this.getFilteredTemplates(), (template: MailTemplate) => {
            ListItem() {
              // 单个模板项
              Column() {
                // 模板名称显示
                Text(template.templateName)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 12, bottom: 12 })

                // 操作按钮行
                Row() {
                  // 编辑按钮 - 跳转到模板编辑页面（编辑模式）
                  Button('编辑')
                    .fontSize(14)
                    .backgroundColor('#007DFF')  // 蓝色背景
                    .fontColor(Color.White)
                    .layoutWeight(1)
                    .onClick(() => {
                      router.pushUrl({
                        url: 'pages/TemplateEditPage',
                        params: { mode: 'edit', templateId: template.templateId }
                      });
                    })

                  // 按钮间距
                  Blank().width(10)

                  // 删除按钮 - 显示删除确认弹窗
                  Button('删除')
                    .fontSize(14)
                    .backgroundColor('#E84026')  // 红色背景
                    .fontColor(Color.White)
                    .layoutWeight(1)
                    .onClick(() => {
                      this.deleteTargetId = template.templateId;
                      this.deleteTargetName = template.templateName;
                      this.showDeleteConfirm = true;
                    })
                }
                .width('100%')
                .padding({ left: 16, right: 16, bottom: 12 })
              }
              .width('100%')
              .backgroundColor(Color.White)
              .borderRadius(8)
            }
          }, (template: MailTemplate) => template.templateId)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 10 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    // 绑定删除确认弹窗
    .bindContentCover(this.showDeleteConfirm, this.DeleteDialog(), {
      modalTransition: ModalTransition.NONE
    })
  }

  /**
   * 删除确认弹窗
   * 使用@Builder装饰器构建弹窗UI
   */
  @Builder
  DeleteDialog() {
    Column() {
      Column() {
        // 弹窗标题
        Text('确认删除')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 16 })

        // 删除提示信息
        Text('确定要删除"' + this.deleteTargetName + '"吗？')
          .fontSize(14)
          .margin({ bottom: 24 })

        // 操作按钮
        Row() {
          // 取消按钮
          Button('取消')
            .layoutWeight(1)
            .onClick(() => {
              this.showDeleteConfirm = false;
            })

          Blank().width(16)

          // 确认删除按钮
          Button('删除')
            .layoutWeight(1)
            .backgroundColor('#E84026')
            .onClick(() => {
              this.confirmDelete();
            })
        }
        .width('100%')
      }
      .padding(24)
      .backgroundColor(Color.White)
      .borderRadius(16)
      .width('80%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0,0,0,0.5)')  // 半透明遮罩
    .justifyContent(FlexAlign.Center)
    // 点击遮罩关闭弹窗
    .onClick(() => {
      this.showDeleteConfirm = false;
    })
  }
}
