/*
* Copyright (c) 2025 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import { AbilityConstant, ConfigurationConstant, UIAbility, Want, common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { distributedDataObject } from '@kit.ArkData';
import { window } from '@kit.ArkUI';
import { JSON } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { MailInfoManager } from '../utils/MailInfoManager';
import { MailTemplate } from '../model/MailTemplate';
import { QuickReply } from '../model/QuickReply';
import { TemplateManager } from '../utils/TemplateManager';
import { QuickReplyManager } from '../utils/QuickReplyManager';
import { DistributedSyncService, SyncDataObject } from '../utils/DistributedSyncService';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private distributedObject: distributedDataObject.DataObject | undefined = undefined;
  private templateDistributedObject: distributedDataObject.DataObject | undefined = undefined;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
      hilog.info(DOMAIN, 'EntryAbility', '%{public}s', 'Ability onCreate');

      // Initialize managers
      this.initManagers();

      this.restoreDistributedObject(want, launchParam);
    } catch (error) {
      hilog.error(0x0000, 'EntryAbility', `getApplicationContext error. Code:${error.code},message: ${error.message}`);
      return error.code;
    }
  }

  /**
   * Initialize TemplateManager, QuickReplyManager, and DistributedSyncService.
   */
  private async initManagers(): Promise<void> {
    const context = this.context as common.UIAbilityContext;
    const syncService: DistributedSyncService = DistributedSyncService.getInstance();
    syncService.init(context);

    const templateManager: TemplateManager = TemplateManager.getInstance();
    await templateManager.init(context);

    const quickReplyManager: QuickReplyManager = QuickReplyManager.getInstance();
    await quickReplyManager.init(context);

    // Register data restored callback
    syncService.onDataRestored((templateData: string, quickReplyData: string) => {
      hilog.info(DOMAIN, 'EntryAbility', 'Sync data restored callback triggered');
      if (templateData && templateData.length > 0) {
        templateManager.handleSyncData(templateData);
      }
      if (quickReplyData && quickReplyData.length > 0) {
        quickReplyManager.handleSyncData(quickReplyData);
      }
    });

    hilog.info(DOMAIN, 'EntryAbility', 'Managers initialized');
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'EntryAbility', `Ability onNewWant`);
    this.restoreDistributedObject(want, launchParam);
  }

  /**
   * The peer device receives data.
   * @param want
   * @param launchParam
   * @returns
   */
  async restoreDistributedObject(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    this.context.setMissionContinueState(AbilityConstant.ContinueState.INACTIVE, (result) => {
      hilog.info(0x0000, 'EntryAbility', `setMissionContinueState: ${JSON.stringify(result)}`);
    });
    if (launchParam.launchReason !== AbilityConstant.LaunchReason.CONTINUATION) {
      return;
    }
    // Obtain the session ID of a distributed data object.
    let mailInfoManager: MailInfoManager = new MailInfoManager(undefined, undefined, undefined, undefined);
    this.distributedObject = distributedDataObject.create(this.context, mailInfoManager);
    // Add a data restored listener.
    try {
      this.distributedObject.on('status',
        (sessionId: string, networkId: string, status: 'online' | 'offline' | 'restored') => {
          hilog.info(0x0000, 'EntryAbility', 'status changed ' + sessionId + ' ' + status + ' ' + networkId);
          if (status === 'restored') {
            if (!this.distributedObject) {
              return;
            }
            AppStorage.setOrCreate('recipient', this.distributedObject['recipient']);
            AppStorage.setOrCreate('sender', this.distributedObject['sender']);
            AppStorage.setOrCreate('subject', this.distributedObject['subject']);
            AppStorage.setOrCreate('emailContent', this.distributedObject['emailContent']);
          }
        });
      let sessionId: string = want.parameters?.distributedSessionId as string;
      hilog.info(0x0000, 'EntryAbility', 'sessionId' + sessionId);
      this.distributedObject.setSessionId(sessionId).catch((err: BusinessError) => {
        hilog.error(0x0000, 'EntryAbility', `setSessionId error .Code:${err.code},message: ${err.message}`);
      });

      // Restore template and quick reply data
      this.restoreTemplateSyncData(want, sessionId);

      this.context.restoreWindowStage(new LocalStorage());
    } catch (error) {
      hilog.error(0x0000, 'EntryAbility', `have error. Code:${error.code}, message: ${error.message}`);
    }
  }

  /**
   * Restore template and quick reply sync data from peer device.
   */
  private restoreTemplateSyncData(want: Want, sessionId: string): void {
    try {
      const templateManager: TemplateManager = TemplateManager.getInstance();
      const quickReplyManager: QuickReplyManager = QuickReplyManager.getInstance();

      // Create sync data object for template/quick reply
      const syncData: SyncDataObject = new SyncDataObject('', '', 0, '');
      this.templateDistributedObject = distributedDataObject.create(this.context, syncData);
      this.templateDistributedObject.on('status',
        (sid: string, networkId: string, status: 'online' | 'offline' | 'restored') => {
          hilog.info(0x0000, 'EntryAbility', `Template sync status: ${sid} ${status} ${networkId}`);
          if (status === 'restored') {
            if (!this.templateDistributedObject) {
              return;
            }
            const templateData: string = this.templateDistributedObject['templateData'] as string;
            const quickReplyData: string = this.templateDistributedObject['quickReplyData'] as string;

            if (templateData && templateData.length > 0) {
              templateManager.handleSyncData(templateData);
            }
            if (quickReplyData && quickReplyData.length > 0) {
              quickReplyManager.handleSyncData(quickReplyData);
            }
            hilog.info(0x0000, 'EntryAbility', 'Template and quick reply data restored from peer');
          }
        });

      // Use the same session ID to join the distributed network
      this.templateDistributedObject.setSessionId(sessionId).catch((err: BusinessError) => {
        hilog.error(0x0000, 'EntryAbility', `Template setSessionId error. Code:${err.code}, message:${err.message}`);
      });
    } catch (err) {
      hilog.error(0x0000, 'EntryAbility', `restoreTemplateSyncData error. Code:${(err as BusinessError).code}, message:${(err as BusinessError).message}`);
    }
  }

  onWindowStageRestore(windowStage: window.WindowStage): void {
    hilog.info(0x0000, 'EntryAbility', 'Ability onWindowStageRestore');

    windowStage.loadContent('pages/MailHomePage', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'EntryAbility', `ailed to load the content, Code:${err.code},message: ${err.message}`);
        return;
      }
      hilog.info(0x0000, 'EntryAbility', 'Succeeded in loading the content, ', `Data: ${data}`);
    });
  }

  async onContinue(wantParam: Record<string, Object | undefined>): Promise<AbilityConstant.OnContinueResult> {
    try {
      // Generate the session ID of the distributed data object.
      let sessionId: string = distributedDataObject.genSessionId();
      wantParam.distributedSessionId = sessionId;

      // Sync mail data (original logic)
      let mailInfoManager: MailInfoManager = new MailInfoManager(AppStorage.get('recipient'), AppStorage.get('sender'),
        AppStorage.get('subject'), AppStorage.get('emailContent'));
      this.distributedObject = distributedDataObject.create(this.context, mailInfoManager);
      this.distributedObject.setSessionId(sessionId).catch((err: BusinessError) => {
        hilog.error(0x0000, 'EntryAbility', `setSessionId error. Code:${err.code},message: ${err.message}`);
      });
      await this.distributedObject.save(wantParam.targetDevice as string).then(() => {
        hilog.info(0x0000, 'EntryAbility', 'onContinue distributedObject save success');
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'EntryAbility', `Failed to save. Code:${err.code}, message:${err.message}`);
      });

      // Sync template and quick reply data
      this.syncTemplateAndQuickReplyData(sessionId, wantParam);

    } catch (err) {
      hilog.error(0x0000, 'EntryAbility', `distributedDataObject failed, Code:${err.code}, message:${err.message}`);
    }
    return AbilityConstant.OnContinueResult.AGREE;
  }

  /**
   * Sync template and quick reply data to target device during onContinue.
   */
  private async syncTemplateAndQuickReplyData(sessionId: string,
    wantParam: Record<string, Object | undefined>): Promise<void> {
    try {
      const templateManager: TemplateManager = TemplateManager.getInstance();
      const quickReplyManager: QuickReplyManager = QuickReplyManager.getInstance();

      const templates: MailTemplate[] = templateManager.loadTemplates();
      const quickReplies: QuickReply[] = quickReplyManager.loadQuickReplies();

      const syncData: SyncDataObject = new SyncDataObject(
        MailTemplate.toListJson(templates),
        QuickReply.toListJson(quickReplies),
        Date.now(),
        'active'
      );

      this.templateDistributedObject = distributedDataObject.create(this.context, syncData);
      this.templateDistributedObject.setSessionId(sessionId).catch((err: BusinessError) => {
        hilog.error(0x0000, 'EntryAbility', `Template setSessionId error. Code:${err.code}, message:${err.message}`);
      });

      if (wantParam.targetDevice) {
        await this.templateDistributedObject.save(wantParam.targetDevice as string).then(() => {
          hilog.info(0x0000, 'EntryAbility', 'Template and quick reply data save success');
        }).catch((err: BusinessError) => {
          hilog.error(0x0000, 'EntryAbility', `Template save failed. Code:${err.code}, message:${err.message}`);
        });
      }
    } catch (err) {
      hilog.error(0x0000, 'EntryAbility', `syncTemplateAndQuickReplyData error. Code:${(err as BusinessError).code}, message:${(err as BusinessError).message}`);
    }
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability.
    hilog.info(0x0000, 'EntryAbility', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/MailHomePage', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'EntryAbility', `Failed to load the content, Code: ${err.code}  message:${err.message}`);
        return;
      }
      hilog.info(0x0000, 'EntryAbility', 'Succeeded in loading the content, ', `Data: ${data}`);
    });
  }

  onWindowStageDestroy() {
    hilog.info(DOMAIN, 'EntryAbility', 'Ability onWindowStageDestroy');
  }

  onForeground() {
    hilog.info(DOMAIN, 'EntryAbility', 'Ability onForeground');
  }

  onBackground() {
    hilog.info(DOMAIN, 'EntryAbility', 'Ability onBackground');
  }

  onDestroy() {
    hilog.info(DOMAIN, 'EntryAbility', 'Ability onDestroy');
  }
}
