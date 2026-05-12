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
 * 邮件模板编辑页面
 * 
 * 功能说明：
 * 1. 支持新建和编辑两种模式
 * 2. 新建模式：创建新的邮件模板
 * 3. 编辑模式：修改已有的邮件模板
 * 
 * 页面结构：
 * - 顶部导航栏：返回按钮、标题、保存按钮
 * - 编辑表单：模板名称、模板类型、主题模板、正文模板
 */

import { router, promptAction } from '@kit.ArkUI';
import { MailTemplate, TemplateType } from '../model/MailTemplate';
import { TemplateManager } from '../utils/TemplateManager';
import { hilog } from '@kit.PerformanceAnalysisKit';

// 日志相关常量
const DOMAIN = 0x0000;
const TAG = 'TemplateEditPage';

/**
 * 模板编辑页面组件
 * 
 * @Entry 页面入口装饰器
 * @Component 组件装饰器
 */
@Entry
@Component
struct TemplateEditPage {
  // 编辑模式：'create' 新建，'edit' 编辑
  @State mode: string = 'create';
  // 编辑模式下的模板ID
  @State editTemplateId: string = '';
  // 模板名称
  @State templateName: string = '';
  // 模板类型索引
  @State templateType: number = 0;
  // 主题模板内容
  @State subjectTemplate: string = '';
  // 正文模板内容
  @State bodyTemplate: string = '';
  // 错误信息
  @State errorMessage: string = '';
  // 创建时间（编辑模式使用）
  @State createdAt: number = 0;
  // 数据是否已加载
  @State isDataLoaded: boolean = false;

  // 模板类型数组
  private templateTypes: TemplateType[] = [TemplateType.WORK_REPORT, TemplateType.LEAVE,
    TemplateType.QUOTATION, TemplateType.CUSTOM];
  // 类型标签显示名称
  private typeLabels: string[] = ['工作汇报', '请假', '报价', '自定义'];

  /**
   * 页面即将显示时的生命周期回调
   */
  aboutToAppear(): void {
    hilog.info(DOMAIN, TAG, 'aboutToAppear');
    this.loadParams();
  }

  /**
   * 页面显示时的生命周期回调
   * 确保数据加载
   */
  onPageShow(): void {
    hilog.info(DOMAIN, TAG, 'onPageShow');
    if (!this.isDataLoaded) {
      this.loadParams();
    }
  }

  /**
   * 加载路由参数
   * 根据参数判断是新建还是编辑模式
   */
  private loadParams(): void {
    try {
      const params: Record<string, Object> = router.getParams() as Record<string, Object>;
      hilog.info(DOMAIN, TAG, `params: ${JSON.stringify(params)}`);
      
      if (params && Object.keys(params).length > 0) {
        // 获取模式参数
        this.mode = (params['mode'] as string) || 'create';
        hilog.info(DOMAIN, TAG, `mode: ${this.mode}`);
        
        if (this.mode === 'edit') {
          // 编辑模式：加载已有模板数据
          const templateId: string = params['templateId'] as string;
          hilog.info(DOMAIN, TAG, `edit templateId: ${templateId}`);
          this.loadTemplateData(templateId);
        } else {
          // 新建模式：设置默认模板类型
          const templateTypeStr: string = (params['templateType'] as string) || TemplateType.WORK_REPORT;
          this.templateType = this.templateTypes.indexOf(templateTypeStr as TemplateType);
          if (this.templateType < 0) {
            this.templateType = 0;
          }
          this.isDataLoaded = true;
          hilog.info(DOMAIN, TAG, `create templateType: ${this.templateType}`);
        }
      } else {
        hilog.warn(DOMAIN, TAG, 'params is empty');
      }
    } catch (err) {
      hilog.error(DOMAIN, TAG, `loadParams error: ${(err as Error).message}`);
    }
  }

  /**
   * 加载模板数据
   * 编辑模式下从管理器获取模板数据
   * @param templateId 模板ID
   */
  private loadTemplateData(templateId: string): void {
    hilog.info(DOMAIN, TAG, `loadTemplateData start: ${templateId}`);
    const manager: TemplateManager = TemplateManager.getInstance();
    const template: MailTemplate | null = manager.getTemplateById(templateId);
    hilog.info(DOMAIN, TAG, `loadTemplateData: ${templateId}, found: ${template !== null}`);
    
    if (template) {
      // 填充表单数据
      this.editTemplateId = template.templateId;
      this.templateName = template.templateName;
      this.templateType = this.templateTypes.indexOf(template.templateType);
      if (this.templateType < 0) {
        this.templateType = 0;
      }
      this.subjectTemplate = template.subjectTemplate;
      this.bodyTemplate = template.bodyTemplate;
      this.createdAt = template.createdAt;
      this.isDataLoaded = true;
      hilog.info(DOMAIN, TAG, `loaded template: ${this.templateName}, body length: ${this.bodyTemplate.length}`);
    } else {
      hilog.error(DOMAIN, TAG, `template not found: ${templateId}`);
      promptAction.showToast({ message: '模板不存在' });
    }
  }

  /**
   * 保存模板
   * 验证并保存当前编辑的模板
   */
  private saveTemplate(): void {
    hilog.info(DOMAIN, TAG, `saveTemplate: name=${this.templateName}, type=${this.templateType}, body length=${this.bodyTemplate.length}`);
    
    // 验证模板名称
    if (!this.templateName || this.templateName.trim().length === 0) {
      this.errorMessage = '模板名称不能为空';
      promptAction.showToast({ message: '模板名称不能为空' });
      return;
    }
    // 验证正文模板
    if (!this.bodyTemplate || this.bodyTemplate.trim().length === 0) {
      this.errorMessage = '正文模板不能为空';
      promptAction.showToast({ message: '正文模板不能为空' });
      return;
    }

    const now: number = Date.now();
    // 创建模板对象
    const template: MailTemplate = new MailTemplate(
      this.mode === 'edit' ? this.editTemplateId : MailTemplate.generateId(),
      this.templateName,
      this.templateTypes[this.templateType],
      this.subjectTemplate,
      this.bodyTemplate,
      this.mode === 'edit' ? this.createdAt : now,
      now
    );

    // 验证模板
    const manager: TemplateManager = TemplateManager.getInstance();
    const error: string | null = manager.validateTemplate(template);
    if (error !== null) {
      hilog.error(DOMAIN, TAG, `validate error: ${error}`);
      this.errorMessage = error;
      promptAction.showToast({ message: error });
      return;
    }

    // 保存模板
    const success: boolean = manager.saveTemplate(template);
    hilog.info(DOMAIN, TAG, `saveTemplate result: ${success}`);
    if (success) {
      promptAction.showToast({ message: '保存成功' });
      router.back();
    } else {
      this.errorMessage = '保存失败，请重试';
      promptAction.showToast({ message: '保存失败，请重试' });
    }
  }

  /**
   * 页面构建方法
   * 定义页面UI结构
   */
  build() {
    Column() {
      this.NavigationBar();  // 顶部导航栏
      this.EditForm();       // 编辑表单
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF1F3F5')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  /**
   * 顶部导航栏
   * 包含返回按钮、标题、保存按钮
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

      // 标题（根据模式显示不同文字）
      Text(this.mode === 'create' ? '新建模板' : '编辑模板')
        .fontSize(20)
        .fontWeight(700)
        .fontColor('rgba(0, 0, 0, 0.9)')
        .flexGrow(1)
        .margin({ left: 4 })

      // 保存按钮
      Button('保存')
        .fontSize(14)
        .fontColor(Color.White)
        .backgroundColor('#007DFF')
        .borderRadius(18)
        .height(32)
        .padding({ left: 16, right: 16 })
        .margin({ right: 16 })
        .onClick(() => {
          this.saveTemplate();
        })
    }
    .height(56)
    .padding({ left: 4 })
  }

  /**
   * 编辑表单
   * 包含模板名称、类型、主题、正文等输入项
   */
  @Builder
  EditForm() {
    Scroll() {
      Column() {
        // ========== 模板名称输入 ==========
        Column() {
          Text('模板名称 *')
            .fontSize(14)
            .fontColor('rgba(0, 0, 0, 0.6)')
            .width('100%')
            .margin({ bottom: 8 })
          TextInput({ text: this.templateName, placeholder: '请输入模板名称' })
            .width('100%')
            .height(44)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .padding({ left: 12, right: 12 })
            .maxLength(50)  // 最大50字符
            .onChange((value: string) => {
              this.templateName = value;
              this.errorMessage = '';
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 20 })

        // ========== 模板类型选择 ==========
        Column() {
          Text('模板类型')
            .fontSize(14)
            .fontColor('rgba(0, 0, 0, 0.6)')
            .width('100%')
            .margin({ bottom: 8 })
          Row() {
            ForEach(this.typeLabels, (label: string, index?: number) => {
              Column() {
                Row() {
                  // 单选按钮
                  Radio({ value: `${index}`, group: 'templateType' })
                    .checked(this.templateType === index)
                    .onChange((isChecked: boolean) => {
                      if (isChecked && index !== undefined) {
                        this.templateType = index;
                      }
                    })
                    .width(18)
                    .height(18)
                  // 类型标签
                  Text(label)
                    .fontSize(14)
                    .fontColor('rgba(0, 0, 0, 0.9)')
                    .margin({ left: 6 })
                }
              }
              .layoutWeight(1)
            }, (label: string, index?: number) => `${index}`)
          }
          .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 20 })

        // ========== 主题模板输入 ==========
        Column() {
          Text('主题模板')
            .fontSize(14)
            .fontColor('rgba(0, 0, 0, 0.6)')
            .width('100%')
            .margin({ bottom: 8 })
          TextInput({ text: this.subjectTemplate, placeholder: '请输入主题模板' })
            .width('100%')
            .height(44)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .padding({ left: 12, right: 12 })
            .maxLength(200)  // 最大200字符
            .onChange((value: string) => {
              this.subjectTemplate = value;
              this.errorMessage = '';
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 20 })

        // ========== 正文模板输入 ==========
        Column() {
          Text('正文模板 *')
            .fontSize(14)
            .fontColor('rgba(0, 0, 0, 0.6)')
            .width('100%')
            .margin({ bottom: 8 })
          TextArea({ text: this.bodyTemplate, placeholder: '请输入正文模板' })
            .width('100%')
            .height(200)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .padding(12)
            .maxLength(5000)  // 最大5000字符
            .onChange((value: string) => {
              this.bodyTemplate = value;
              this.errorMessage = '';
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 20 })

        // ========== 错误信息显示 ==========
        if (this.errorMessage.length > 0) {
          Text(this.errorMessage)
            .fontSize(13)
            .fontColor('#E84026')
            .width('100%')
            .margin({ bottom: 12 })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16 })
    }
    .width('100%')
    .layoutWeight(1)
  }
}
