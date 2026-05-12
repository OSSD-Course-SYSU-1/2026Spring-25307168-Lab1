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
 * 分布式同步服务
 * 
 * 功能说明：
 * 1. 封装分布式数据对象的创建、监听和同步
 * 2. 实现跨设备数据同步
 * 3. 处理数据恢复和冲突解决
 * 4. 提供同步状态监听
 * 
 * 设计模式：单例模式，确保应用内只有一个同步通道
 */

import { distributedDataObject } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { MailTemplate } from '../model/MailTemplate';
import { QuickReply } from '../model/QuickReply';

// 日志相关常量
const DOMAIN = 0x0000;
const TAG = 'MailTemplate';

/**
 * 分布式同步数据对象结构
 * 
 * 作为跨设备数据同步的载体，包含：
 * - templateData: 模板数据JSON字符串
 * - quickReplyData: 快捷回复数据JSON字符串
 * - syncTimestamp: 同步时间戳
 * - status: 同步状态
 */
export class SyncDataObject {
  // 模板数据（JSON字符串）
  templateData: string;
  // 快捷回复数据（JSON字符串）
  quickReplyData: string;
  // 同步时间戳
  syncTimestamp: number;
  // 同步状态
  status: string;

  /**
   * 构造函数
   * @param templateData 模板数据
   * @param quickReplyData 快捷回复数据
   * @param syncTimestamp 同步时间戳
   * @param status 状态
   */
  constructor(templateData: string, quickReplyData: string, syncTimestamp: number, status: string) {
    this.templateData = templateData;
    this.quickReplyData = quickReplyData;
    this.syncTimestamp = syncTimestamp;
    this.status = status;
  }
}

/**
 * 数据恢复回调类型
 * 当从对端设备恢复数据时调用
 */
type DataRestoredCallback = (templateData: string, quickReplyData: string) => void;

/**
 * 分布式同步服务类
 * 
 * 使用单例模式确保全局只有一个实例。
 * 负责管理分布式数据对象，实现跨设备数据同步。
 */
export class DistributedSyncService {
  // 单例实例
  private static instance: DistributedSyncService | undefined = undefined;
  // 分布式数据对象
  private distributedObject: distributedDataObject.DataObject | undefined = undefined;
  // 应用上下文
  private context: common.UIAbilityContext | undefined = undefined;
  // 数据恢复回调
  private dataRestoredCallback: DataRestoredCallback | undefined = undefined;

  /**
   * 私有构造函数（单例模式）
   */
  private constructor() {
  }

  /**
   * 获取单例实例
   * @returns DistributedSyncService实例
   */
  static getInstance(): DistributedSyncService {
    if (!DistributedSyncService.instance) {
      DistributedSyncService.instance = new DistributedSyncService();
    }
    return DistributedSyncService.instance;
  }

  /**
   * 初始化同步服务
   * @param context 应用上下文
   */
  init(context: common.UIAbilityContext): void {
    this.context = context;
    hilog.info(DOMAIN, TAG, 'DistributedSyncService init');
  }

  /**
   * 创建分布式数据对象并注册状态监听
   * @param data 初始数据
   * @param sessionId 会话ID
   */
  createDistributedObject(data: SyncDataObject, sessionId: string): void {
    if (!this.context) {
      hilog.error(DOMAIN, TAG, 'DistributedSyncService context is not initialized');
      return;
    }
    try {
      // 创建分布式数据对象
      this.distributedObject = distributedDataObject.create(this.context, data);
      
      // 注册状态变化监听
      this.distributedObject.on('status',
        (sid: string, networkId: string, status: 'online' | 'offline' | 'restored') => {
          hilog.info(DOMAIN, TAG, `Sync status changed: sessionId=${sid}, status=${status}, networkId=${networkId}`);
          // 数据恢复时触发处理
          if (status === 'restored') {
            this.handleDataRestored();
          }
        });
      
      // 设置会话ID，加入分布式网络
      this.distributedObject.setSessionId(sessionId).catch((err: BusinessError) => {
        hilog.error(DOMAIN, TAG, `setSessionId error. Code:${err.code}, message:${err.message}`);
      });
      hilog.info(DOMAIN, TAG, 'DistributedSyncService createDistributedObject success');
    } catch (err) {
      hilog.error(DOMAIN, TAG, `createDistributedObject error. Code:${(err as BusinessError).code}, message:${(err as BusinessError).message}`);
    }
  }

  /**
   * 处理从对端设备恢复的数据
   * 当收到'restored'状态时调用
   */
  private handleDataRestored(): void {
    if (!this.distributedObject) {
      return;
    }
    // 从分布式对象中读取恢复的数据
    const templateData: string = this.distributedObject['templateData'] as string;
    const quickReplyData: string = this.distributedObject['quickReplyData'] as string;
    hilog.info(DOMAIN, TAG, 'Data restored from peer device');

    // 调用回调处理恢复的数据
    if (this.dataRestoredCallback) {
      this.dataRestoredCallback(templateData, quickReplyData);
    }
  }

  /**
   * 同步模板数据到对端设备
   * @param templates 模板列表
   */
  syncTemplateData(templates: MailTemplate[]): void {
    if (!this.distributedObject) {
      hilog.warn(DOMAIN, TAG, 'syncTemplateData: distributedObject not available');
      return;
    }
    try {
      // 序列化模板数据
      const templateJson: string = MailTemplate.toListJson(templates);
      // 更新分布式对象
      this.distributedObject['templateData'] = templateJson;
      this.distributedObject['syncTimestamp'] = Date.now();
      hilog.info(DOMAIN, TAG, `syncTemplateData success, data length: ${templateJson.length}`);
    } catch (err) {
      hilog.error(DOMAIN, TAG, `syncTemplateData error: ${(err as BusinessError).message}`);
    }
  }

  /**
   * 同步快捷回复数据到对端设备
   * @param replies 快捷回复列表
   */
  syncQuickReplyData(replies: QuickReply[]): void {
    if (!this.distributedObject) {
      hilog.warn(DOMAIN, TAG, 'syncQuickReplyData: distributedObject not available');
      return;
    }
    try {
      // 序列化快捷回复数据
      const replyJson: string = QuickReply.toListJson(replies);
      // 更新分布式对象
      this.distributedObject['quickReplyData'] = replyJson;
      this.distributedObject['syncTimestamp'] = Date.now();
      hilog.info(DOMAIN, TAG, `syncQuickReplyData success, data length: ${replyJson.length}`);
    } catch (err) {
      hilog.error(DOMAIN, TAG, `syncQuickReplyData error: ${(err as BusinessError).message}`);
    }
  }

  /**
   * 注册数据恢复回调
   * 当从对端设备恢复数据时调用
   * @param callback 回调函数
   */
  onDataRestored(callback: DataRestoredCallback): void {
    this.dataRestoredCallback = callback;
    hilog.info(DOMAIN, TAG, 'Data restored callback registered');
  }

  /**
   * 生成新的会话ID
   * 用于创建分布式数据对象时使用
   * @returns 会话ID字符串
   */
  getSessionId(): string {
    return distributedDataObject.genSessionId();
  }

  /**
   * 获取当前分布式数据对象
   * 用于onContinue保存操作
   * @returns 分布式数据对象
   */
  getDistributedObject(): distributedDataObject.DataObject | undefined {
    return this.distributedObject;
  }

  /**
   * 保存分布式数据到目标设备
   * 在onContinue中调用
   * @param targetDevice 目标设备ID
   */
  async saveToTargetDevice(targetDevice: string): Promise<void> {
    if (!this.distributedObject) {
      hilog.warn(DOMAIN, TAG, 'saveToTargetDevice: distributedObject not available');
      return;
    }
    await this.distributedObject.save(targetDevice).then(() => {
      hilog.info(DOMAIN, TAG, 'saveToTargetDevice success');
    }).catch((err: BusinessError) => {
      hilog.error(DOMAIN, TAG, `saveToTargetDevice failed. Code:${err.code}, message:${err.message}`);
    });
  }
}
