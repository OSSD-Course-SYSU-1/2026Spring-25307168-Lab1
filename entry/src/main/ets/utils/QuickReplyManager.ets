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
 * 快捷回复管理器
 * 
 * 功能说明：
 * 1. 处理快捷回复的增删改查（CRUD）操作
 * 2. 支持排序功能
 * 3. 数据持久化存储（使用Preferences）
 * 4. 快捷回复数据验证
 * 5. 分布式数据同步触发
 * 6. 冲突解决（使用"最后修改时间优先"策略）
 * 
 * 设计模式：单例模式
 */

import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { QuickReply } from '../model/QuickReply';
import { DistributedSyncService } from './DistributedSyncService';

// 日志相关常量
const DOMAIN = 0x0000;
const TAG = 'MailTemplate';
// Preferences存储名称
const PREFERENCES_NAME = 'quick_reply_prefs';
// 快捷回复列表存储键
const QUICK_REPLY_KEY = 'quick_reply_list';

/**
 * 快捷回复管理器类
 * 
 * 使用单例模式确保全局只有一个实例。
 * 负责快捷回复数据的存储、读取、验证、排序和同步。
 */
export class QuickReplyManager {
  // 单例实例
  private static instance: QuickReplyManager | undefined = undefined;
  // Preferences存储对象
  private preferencesStore: preferences.Preferences | undefined = undefined;
  // 分布式同步服务
  private syncService: DistributedSyncService = DistributedSyncService.getInstance();
  // 是否已初始化
  private isInitialized: boolean = false;

  /**
   * 私有构造函数（单例模式）
   */
  private constructor() {
  }

  /**
   * 获取单例实例
   * @returns QuickReplyManager实例
   */
  static getInstance(): QuickReplyManager {
    if (!QuickReplyManager.instance) {
      QuickReplyManager.instance = new QuickReplyManager();
    }
    return QuickReplyManager.instance;
  }

  /**
   * 初始化管理器
   * 必须在使用其他方法前调用
   * @param context 应用上下文
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.isInitialized) {
      return;
    }
    try {
      // 初始化Preferences存储
      this.preferencesStore = await preferences.getPreferences(context, PREFERENCES_NAME);
      this.isInitialized = true;
      hilog.info(DOMAIN, TAG, 'QuickReplyManager init success');

      // 首次使用时初始化默认快捷回复
      this.initDefaultQuickReplies();
    } catch (err) {
      hilog.error(DOMAIN, TAG, `QuickReplyManager init error: ${(err as Error).message}`);
    }
  }

  /**
   * 加载所有快捷回复
   * 从Preferences读取数据并按sortOrder排序
   * @returns 排序后的快捷回复列表
   */
  loadQuickReplies(): QuickReply[] {
    if (!this.preferencesStore) {
      hilog.warn(DOMAIN, TAG, 'loadQuickReplies: preferencesStore not initialized');
      return [];
    }
    try {
      const jsonStr: string = this.preferencesStore.getSync(QUICK_REPLY_KEY, '') as string;
      const replies: QuickReply[] = QuickReply.fromListJson(jsonStr);
      // 按sortOrder排序
      replies.sort((a, b) => a.sortOrder - b.sortOrder);
      hilog.info(DOMAIN, TAG, `loadQuickReplies success, count: ${replies.length}`);
      return replies;
    } catch (err) {
      hilog.error(DOMAIN, TAG, `loadQuickReplies error: ${(err as Error).message}`);
      return [];
    }
  }

  /**
   * 保存快捷回复（创建或更新）
   * 如果replyId已存在则更新，否则创建新快捷回复
   * @param reply 要保存的快捷回复
   * @returns 是否保存成功
   */
  saveQuickReply(reply: QuickReply): boolean {
    if (!this.preferencesStore) {
      hilog.warn(DOMAIN, TAG, 'saveQuickReply: preferencesStore not initialized');
      return false;
    }
    try {
      const replies: QuickReply[] = this.loadQuickReplies();
      const existingIndex: number = replies.findIndex(r => r.replyId === reply.replyId);

      if (existingIndex >= 0) {
        // 更新已有快捷回复
        replies[existingIndex] = reply;
        hilog.info(DOMAIN, TAG, `QuickReply updated: ${reply.replyId}`);
      } else {
        // 添加新快捷回复
        if (reply.sortOrder === 0) {
          reply.sortOrder = replies.length;
        }
        replies.push(reply);
        hilog.info(DOMAIN, TAG, `QuickReply created: ${reply.replyId}`);
      }

      // 保存到Preferences
      const jsonStr: string = QuickReply.toListJson(replies);
      this.preferencesStore.putSync(QUICK_REPLY_KEY, jsonStr);
      this.preferencesStore.flush();

      // 更新AppStorage（用于UI响应式更新）
      AppStorage.setOrCreate('quickReplyList', replies);

      // 触发分布式同步
      this.syncService.syncQuickReplyData(replies);

      return true;
    } catch (err) {
      hilog.error(DOMAIN, TAG, `saveQuickReply error: ${(err as Error).message}`);
      return false;
    }
  }

  /**
   * 删除快捷回复
   * @param replyId 要删除的快捷回复ID
   * @returns 是否删除成功
   */
  deleteQuickReply(replyId: string): boolean {
    if (!this.preferencesStore) {
      hilog.warn(DOMAIN, TAG, 'deleteQuickReply: preferencesStore not initialized');
      return false;
    }
    try {
      const replies: QuickReply[] = this.loadQuickReplies();
      const filteredReplies: QuickReply[] = replies.filter(r => r.replyId !== replyId);

      if (filteredReplies.length === replies.length) {
        hilog.warn(DOMAIN, TAG, `QuickReply not found: ${replyId}`);
        return false;
      }

      // 重新索引排序顺序
      for (let i = 0; i < filteredReplies.length; i++) {
        filteredReplies[i].sortOrder = i;
      }

      // 保存到Preferences
      const jsonStr: string = QuickReply.toListJson(filteredReplies);
      this.preferencesStore.putSync(QUICK_REPLY_KEY, jsonStr);
      this.preferencesStore.flush();

      // 更新AppStorage
      AppStorage.setOrCreate('quickReplyList', filteredReplies);

      // 触发分布式同步
      this.syncService.syncQuickReplyData(filteredReplies);

      hilog.info(DOMAIN, TAG, `QuickReply deleted: ${replyId}`);
      return true;
    } catch (err) {
      hilog.error(DOMAIN, TAG, `deleteQuickReply error: ${(err as Error).message}`);
      return false;
    }
  }

  /**
   * 更新排序顺序
   * 用于拖拽排序后保存新的顺序
   * @param replyList 重新排序后的快捷回复列表
   * @returns 是否更新成功
   */
  updateSortOrder(replyList: QuickReply[]): boolean {
    if (!this.preferencesStore) {
      hilog.warn(DOMAIN, TAG, 'updateSortOrder: preferencesStore not initialized');
      return false;
    }
    try {
      // 重新索引排序顺序
      for (let i = 0; i < replyList.length; i++) {
        replyList[i].sortOrder = i;
      }

      // 保存到Preferences
      const jsonStr: string = QuickReply.toListJson(replyList);
      this.preferencesStore.putSync(QUICK_REPLY_KEY, jsonStr);
      this.preferencesStore.flush();

      // 更新AppStorage
      AppStorage.setOrCreate('quickReplyList', replyList);

      // 触发分布式同步
      this.syncService.syncQuickReplyData(replyList);

      hilog.info(DOMAIN, TAG, 'QuickReply sort order updated');
      return true;
    } catch (err) {
      hilog.error(DOMAIN, TAG, `updateSortOrder error: ${(err as Error).message}`);
      return false;
    }
  }

  /**
   * 验证快捷回复
   * 检查数据是否符合要求
   * @param reply 要验证的快捷回复
   * @returns 错误信息，验证通过返回null
   */
  validateQuickReply(reply: QuickReply): string | null {
    // 检查内容不为空
    if (!reply.replyContent || reply.replyContent.trim().length === 0) {
      return '回复内容不能为空';
    }
    // 检查内容长度
    if (reply.replyContent.length > 200) {
      return '回复内容不能超过200个字符';
    }
    // 检查内容唯一性
    const replies: QuickReply[] = this.loadQuickReplies();
    const duplicate: QuickReply | undefined = replies.find(r =>
      r.replyContent === reply.replyContent &&
      r.replyId !== reply.replyId
    );
    if (duplicate !== undefined) {
      return '已存在相同内容的快捷回复';
    }
    return null;
  }

  /**
   * 处理来自对端设备的同步数据
   * 使用"最后修改时间优先"策略解决冲突
   * @param quickReplyDataJson 快捷回复数据JSON字符串
   */
  handleSyncData(quickReplyDataJson: string): void {
    if (!this.preferencesStore) {
      hilog.warn(DOMAIN, TAG, 'handleSyncData: preferencesStore not initialized');
      return;
    }
    try {
      const remoteReplies: QuickReply[] = QuickReply.fromListJson(quickReplyDataJson);
      if (remoteReplies.length === 0) {
        hilog.info(DOMAIN, TAG, 'handleSyncData: no remote quick reply data');
        return;
      }

      const localReplies: QuickReply[] = this.loadQuickReplies();
      // 合并本地和远程数据
      const mergedReplies: QuickReply[] = this.mergeQuickReplies(localReplies, remoteReplies);

      // 保存合并后的数据
      const jsonStr: string = QuickReply.toListJson(mergedReplies);
      this.preferencesStore.putSync(QUICK_REPLY_KEY, jsonStr);
      this.preferencesStore.flush();

      // 更新AppStorage
      AppStorage.setOrCreate('quickReplyList', mergedReplies);

      hilog.info(DOMAIN, TAG, `handleSyncData success, merged count: ${mergedReplies.length}`);
    } catch (err) {
      hilog.error(DOMAIN, TAG, `handleSyncData error: ${(err as Error).message}`);
    }
  }

  /**
   * 合并本地和远程快捷回复
   * 使用"最后修改时间优先"策略
   * @param local 本地快捷回复列表
   * @param remote 远程快捷回复列表
   * @returns 合并后的快捷回复列表
   */
  private mergeQuickReplies(local: QuickReply[], remote: QuickReply[]): QuickReply[] {
    const mergedMap: Map<string, QuickReply> = new Map();

    // 添加所有本地快捷回复
    for (const r of local) {
      mergedMap.set(r.replyId, r);
    }

    // 合并远程快捷回复
    for (const remoteR of remote) {
      const localR: QuickReply | undefined = mergedMap.get(remoteR.replyId);
      if (localR === undefined) {
        // 远程新增的快捷回复
        mergedMap.set(remoteR.replyId, remoteR);
      } else {
        // 冲突：保留更新时间较晚的
        if (remoteR.updatedAt > localR.updatedAt) {
          mergedMap.set(remoteR.replyId, remoteR);
        }
      }
    }

    // 转换为数组并排序
    const result: QuickReply[] = Array.from(mergedMap.values());
    result.sort((a, b) => a.sortOrder - b.sortOrder);
    return result;
  }

  /**
   * 初始化默认快捷回复
   * 首次使用时创建预设快捷回复
   */
  private initDefaultQuickReplies(): void {
    if (!this.preferencesStore) {
      return;
    }
    // 检查是否已有快捷回复数据
    const existing: string = this.preferencesStore.getSync(QUICK_REPLY_KEY, '') as string;
    if (existing && existing.length > 0) {
      hilog.info(DOMAIN, TAG, 'Quick replies already exist, skip default initialization');
      return;
    }

    const now: number = Date.now();
    // 预设快捷回复列表
    const defaultReplies: QuickReply[] = [
      new QuickReply(QuickReply.generateId(), '已收到，谢谢！', 0, now, now),
      new QuickReply(QuickReply.generateId(), '稍后回复您。', 1, now, now),
      new QuickReply(QuickReply.generateId(), '好的，确认。', 2, now, now),
      new QuickReply(QuickReply.generateId(), '已处理完毕。', 3, now, now),
      new QuickReply(QuickReply.generateId(), '请查看附件。', 4, now, now)
    ];

    // 保存默认快捷回复
    const jsonStr: string = QuickReply.toListJson(defaultReplies);
    this.preferencesStore.putSync(QUICK_REPLY_KEY, jsonStr);
    this.preferencesStore.flush();
    AppStorage.setOrCreate('quickReplyList', defaultReplies);
    hilog.info(DOMAIN, TAG, `Default quick replies initialized, count: ${defaultReplies.length}`);
  }
}
