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

import { AbilityConstant, common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { router } from '@kit.ArkUI';
import { MailTemplate, TemplateType } from '../model/MailTemplate';
import { QuickReply } from '../model/QuickReply';
import { TemplateManager } from '../utils/TemplateManager';
import { QuickReplyManager } from '../utils/QuickReplyManager';

@Entry
@Component
struct MailHomePage {
  @StorageLink('recipient') recipient: string = '';
  @StorageLink('sender') sender: string = '';
  @StorageLink('subject') subject: string = '';
  @StorageLink('emailContent') emailContent: string = '';
  @StorageLink('templateList') templateList: MailTemplate[] = [];
  @StorageLink('quickReplyList') quickReplyList: QuickReply[] = [];
  @State showTemplatePanel: boolean = false;
  @State selectedTemplateType: number = 0;
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  private templateTypes: TemplateType[] = [TemplateType.WORK_REPORT, TemplateType.LEAVE,
    TemplateType.QUOTATION, TemplateType.CUSTOM];
  private typeLabels: string[] = ['工作汇报', '请假', '报价', '自定义'];

  onPageShow(): void {
    this.context.setMissionContinueState(AbilityConstant.ContinueState.ACTIVE, (result) => {
      hilog.info(0x0000, 'MailHomePage', 'setMissionContinueState ACTIVE result: ', JSON.stringify(result));
    });
    this.loadData();
  }

  onBackPress(): void {
    this.context.setMissionContinueState(AbilityConstant.ContinueState.INACTIVE, (result) => {
      hilog.info(0x0000, 'MailHomePage', 'setMissionContinueState INACTIVE result: ', JSON.stringify(result));
    });
  }

  private loadData(): void {
    const templateManager: TemplateManager = TemplateManager.getInstance();
    const quickReplyManager: QuickReplyManager = QuickReplyManager.getInstance();
    this.templateList = templateManager.loadTemplates();
    this.quickReplyList = quickReplyManager.loadQuickReplies();
  }

  private getFilteredTemplates(): MailTemplate[] {
    const targetType: TemplateType = this.templateTypes[this.selectedTemplateType];
    return this.templateList.filter(t => t.templateType === targetType);
  }

  private applyTemplate(template: MailTemplate): void {
    if (template.subjectTemplate && template.subjectTemplate.length > 0) {
      this.subject = template.subjectTemplate;
      AppStorage.set('subject', template.subjectTemplate);
    }
    if (template.bodyTemplate && template.bodyTemplate.length > 0) {
      this.emailContent = template.bodyTemplate;
      AppStorage.set('emailContent', template.bodyTemplate);
    }
    this.showTemplatePanel = false;
    hilog.info(0x0000, 'MailHomePage', `Template applied: ${template.templateName}`);
  }

  private applyQuickReply(reply: QuickReply): void {
    this.emailContent = reply.replyContent;
    AppStorage.set('emailContent', reply.replyContent);
    hilog.info(0x0000, 'MailHomePage', `Quick reply applied: ${reply.replyContent}`);
  }

  build() {
    Column() {
      this.NavigationTitle();
      this.EmailContent();
      this.QuickReplyBar();
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFF1F3F5')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .bindSheet(this.showTemplatePanel, this.TemplatePanel(), {
      height: '60%',
      dragBar: true,
      showClose: true,
      onDisappear: () => {
        this.showTemplatePanel = false;
      }
    })
  }

  @Builder
  NavigationTitle() {
    Flex({ alignItems: ItemAlign.Center }) {
      Text($r('app.string.new_email_text'))
        .fontSize(20)
        .fontWeight(700)
        .lineHeight(27)
        .fontColor('rgba(0, 0, 0, 0.9)')
        .flexGrow(1)

      Row() {
        Row() {
          SymbolGlyph($r('sys.symbol.doc_text'))
            .fontSize(20)
            .fontWeight(400)
        }
        .width(36)
        .height(36)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('rgba(0, 0, 0, 0.05)')
        .borderRadius(18)
        .margin({ right: 8 })
        .onClick(() => {
          this.showTemplatePanel = true;
        })

        Row() {
          SymbolGlyph($r('sys.symbol.list_bullet'))
            .fontSize(20)
            .fontWeight(400)
        }
        .width(36)
        .height(36)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('rgba(0, 0, 0, 0.05)')
        .borderRadius(18)
        .margin({ right: 8 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/QuickReplyManagePage' });
        })

        Row() {
          SymbolGlyph($r('sys.symbol.paperplane'))
            .fontSize(24)
            .fontWeight(400)
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width(40)
        .height(40)
        .backgroundColor('rgba(0, 0, 0, 0.05)')
        .borderRadius(40)
        .margin({ right: 8 })
      }
    }
    .height(56)
  }

  @Builder
  EmailContent() {
    Column() {
      Row() {
        Text($r('app.string.recipient_text'))
          .fontColor($r('app.color.content_text_color'))
          .fontSize($r('app.float.text_font_size'))
          .focusable(true)
        TextInput({ text: this.recipient })
          .type(InputType.Email)
          .width('100%')
          .backgroundColor($r('app.color.input_textarea_background'))
          .caretColor($r('app.color.text_cursor_color'))
          .onChange((recipientName: string) => {
            this.recipient = recipientName;
            AppStorage.set('recipient', recipientName);
          })
      }
      .width('100%')
      .height(56)
      .border({ width: { bottom: 1 }, color: 'rgba(0, 0, 0, 0.2)' })

      Row() {
        Text($r('app.string.sender_text'))
          .fontColor($r('app.color.content_text_color'))
          .fontSize($r('app.float.text_font_size'))
        TextInput({ text: this.sender })
          .type(InputType.Email)
          .width('100%')
          .backgroundColor($r('app.color.input_textarea_background'))
          .caretColor($r('app.color.text_cursor_color'))
          .onChange((senderName: string) => {
            this.sender = senderName;
            AppStorage.set('sender', senderName);
          })
      }
      .width('100%')
      .height(56)
      .border({ width: { bottom: 1 }, color: 'rgba(0, 0, 0, 0.2)' })

      Row() {
        Text($r('app.string.subject_text'))
          .fontColor($r('app.color.content_text_color'))
          .fontSize($r('app.float.text_font_size'))
        TextInput({ text: this.subject })
          .width('100%')
          .backgroundColor($r('app.color.input_textarea_background'))
          .caretColor($r('app.color.text_cursor_color'))
          .onChange((subjectInfo: string) => {
            this.subject = subjectInfo;
            AppStorage.set('subject', subjectInfo);
          })
      }
      .width('100%')
      .height(56)
      .border({ width: { bottom: 1 }, color: 'rgba(0, 0, 0, 0.2)' })

      Row() {
        TextArea({ text: this.emailContent })
          .height('100%')
          .padding(0)
          .backgroundColor($r('app.color.input_textarea_background'))
          .borderRadius(0)
          .caretColor($r('app.color.text_cursor_color'))
          .onChange((emailContent: string) => {
            this.emailContent = emailContent;
            AppStorage.set('emailContent', emailContent);
          })
      }
      .layoutWeight(1)
      .alignItems(VerticalAlign.Top)
      .width('100%')
      .margin({
        top: $r('app.float.text_image_margin'),
        bottom: $r('app.float.navigation_height')
      })
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 8, right: 8 })
  }

  @Builder
  QuickReplyBar() {
    if (this.quickReplyList.length > 0) {
      Column() {
        Row() {
          Text('快捷回复:')
            .fontSize(12)
            .fontColor('rgba(0, 0, 0, 0.4)')
            .margin({ right: 8 })
        }
        .width('100%')
        .margin({ bottom: 6 })

        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.quickReplyList, (reply: QuickReply) => {
              Text(reply.replyContent)
                .fontSize(13)
                .fontColor('#007DFF')
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor('rgba(0, 125, 255, 0.08)')
                .borderRadius(16)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .constraintSize({ maxWidth: 180 })
                .onClick(() => {
                  this.applyQuickReply(reply);
                })
            }, (reply: QuickReply) => reply.replyId)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
      }
      .width('100%')
      .padding({ left: 8, right: 8, top: 8, bottom: 8 })
      .backgroundColor(Color.White)
      .border({ width: { top: 1 }, color: 'rgba(0, 0, 0, 0.08)' })
    }
  }

  @Builder
  TemplatePanel() {
    Column() {
      Text('选择模板')
        .fontSize(18)
        .fontWeight(700)
        .fontColor('rgba(0, 0, 0, 0.9)')
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ top: 12, bottom: 12 })

      Tabs({ index: this.selectedTemplateType }) {
        ForEach(this.typeLabels, (label: string, index?: number) => {
          TabContent() {
            Column() {}
            .width('100%')
            .height('100%')
          }
          .tabBar(label)
        }, (label: string, index?: number) => `${index}`)
      }
      .barMode(BarMode.Fixed)
      .barHeight(40)
      .onChange((index: number) => {
        this.selectedTemplateType = index;
      })
      .width('100%')

      Column() {
        if (this.getFilteredTemplates().length === 0) {
          Column() {
            Text('当前类型暂无模板')
              .fontSize(14)
              .fontColor('rgba(0, 0, 0, 0.4)')
              .margin({ top: 40 })
          }
          .width('100%')
          .layoutWeight(1)
        } else {
          List({ space: 8 }) {
            ForEach(this.getFilteredTemplates(), (template: MailTemplate) => {
              ListItem() {
                Row() {
                  Column() {
                    Text(template.templateName)
                      .fontSize(15)
                      .fontWeight(500)
                      .fontColor('rgba(0, 0, 0, 0.9)')
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })

                    if (template.subjectTemplate && template.subjectTemplate.length > 0) {
                      Text(template.subjectTemplate)
                        .fontSize(12)
                        .fontColor('rgba(0, 0, 0, 0.4)')
                        .margin({ top: 4 })
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  SymbolGlyph($r('sys.symbol.chevron_right'))
                    .fontSize(14)
                    .fontColor([$r('app.color.content_text_color')])
                }
                .width('100%')
                .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                .backgroundColor(Color.White)
                .borderRadius(8)
                .onClick(() => {
                  this.applyTemplate(template);
                })
              }
            }, (template: MailTemplate) => template.templateId)
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: 16, right: 16, top: 8 })
        }
      }
      .width('100%')
      .layoutWeight(1)

      Row() {
        Text('管理模板')
          .fontSize(14)
          .fontColor('#007DFF')
          .fontWeight(500)
      }
      .width('100%')
      .height(48)
      .justifyContent(FlexAlign.Center)
      .border({ width: { top: 1 }, color: 'rgba(0, 0, 0, 0.08)' })
      .onClick(() => {
        this.showTemplatePanel = false;
        router.pushUrl({ url: 'pages/TemplateManagePage' });
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF1F3F5')
  }
}
