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
 * 邮件模板管理器
 * 
 * 功能说明：
 * 1. 处理模板的增删改查（CRUD）操作
 * 2. 数据持久化存储（使用Preferences）
 * 3. 模板数据验证
 * 4. 分布式数据同步触发
 * 5. 冲突解决（使用"最后修改时间优先"策略）
 * 
 * 设计模式：单例模式
 */

import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { MailTemplate, TemplateType } from '../model/MailTemplate';
import { DistributedSyncService } from './DistributedSyncService';

// 日志相关常量
const DOMAIN = 0x0000;
const TAG = 'MailTemplate';
// Preferences存储名称
const PREFERENCES_NAME = 'mail_template_prefs';
// 模板列表存储键
const TEMPLATE_KEY = 'mail_template_list';

/**
 * 模板管理器类
 * 
 * 使用单例模式确保全局只有一个实例。
 * 负责模板数据的存储、读取、验证和同步。
 */
export class TemplateManager {
  // 单例实例
  private static instance: TemplateManager | undefined = undefined;
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
   * @returns TemplateManager实例
   */
  static getInstance(): TemplateManager {
    if (!TemplateManager.instance) {
      TemplateManager.instance = new TemplateManager();
    }
    return TemplateManager.instance;
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
      hilog.info(DOMAIN, TAG, 'TemplateManager init success');

      // 首次使用时初始化默认模板
      this.initDefaultTemplates();
    } catch (err) {
      hilog.error(DOMAIN, TAG, `TemplateManager init error: ${(err as Error).message}`);
    }
  }

  /**
   * 加载所有模板
   * 从Preferences读取模板数据
   * @returns 模板列表
   */
  loadTemplates(): MailTemplate[] {
    if (!this.preferencesStore) {
      hilog.warn(DOMAIN, TAG, 'loadTemplates: preferencesStore not initialized');
      return [];
    }
    try {
      const jsonStr: string = this.preferencesStore.getSync(TEMPLATE_KEY, '') as string;
      const templates: MailTemplate[] = MailTemplate.fromListJson(jsonStr);
      hilog.info(DOMAIN, TAG, `loadTemplates success, count: ${templates.length}`);
      return templates;
    } catch (err) {
      hilog.error(DOMAIN, TAG, `loadTemplates error: ${(err as Error).message}`);
      return [];
    }
  }

  /**
   * 保存模板（创建或更新）
   * 如果templateId已存在则更新，否则创建新模板
   * @param template 要保存的模板
   * @returns 是否保存成功
   */
  saveTemplate(template: MailTemplate): boolean {
    if (!this.preferencesStore) {
      hilog.warn(DOMAIN, TAG, 'saveTemplate: preferencesStore not initialized');
      return false;
    }
    try {
      const templates: MailTemplate[] = this.loadTemplates();
      const existingIndex: number = templates.findIndex(t => t.templateId === template.templateId);

      if (existingIndex >= 0) {
        // 更新已有模板
        templates[existingIndex] = template;
        hilog.info(DOMAIN, TAG, `Template updated: ${template.templateId}`);
      } else {
        // 添加新模板
        templates.push(template);
        hilog.info(DOMAIN, TAG, `Template created: ${template.templateId}`);
      }

      // 保存到Preferences
      const jsonStr: string = MailTemplate.toListJson(templates);
      this.preferencesStore.putSync(TEMPLATE_KEY, jsonStr);
      this.preferencesStore.flush();

      // 更新AppStorage（用于UI响应式更新）
      AppStorage.setOrCreate('templateList', templates);

      // 触发分布式同步
      this.syncService.syncTemplateData(templates);

      return true;
    } catch (err) {
      hilog.error(DOMAIN, TAG, `saveTemplate error: ${(err as Error).message}`);
      return false;
    }
  }

  /**
   * 删除模板
   * @param templateId 要删除的模板ID
   * @returns 是否删除成功
   */
  deleteTemplate(templateId: string): boolean {
    if (!this.preferencesStore) {
      hilog.warn(DOMAIN, TAG, 'deleteTemplate: preferencesStore not initialized');
      return false;
    }
    try {
      const templates: MailTemplate[] = this.loadTemplates();
      const filteredTemplates: MailTemplate[] = templates.filter(t => t.templateId !== templateId);

      if (filteredTemplates.length === templates.length) {
        hilog.warn(DOMAIN, TAG, `Template not found: ${templateId}`);
        return false;
      }

      // 保存到Preferences
      const jsonStr: string = MailTemplate.toListJson(filteredTemplates);
      this.preferencesStore.putSync(TEMPLATE_KEY, jsonStr);
      this.preferencesStore.flush();

      // 更新AppStorage
      AppStorage.setOrCreate('templateList', filteredTemplates);

      // 触发分布式同步
      this.syncService.syncTemplateData(filteredTemplates);

      hilog.info(DOMAIN, TAG, `Template deleted: ${templateId}`);
      return true;
    } catch (err) {
      hilog.error(DOMAIN, TAG, `deleteTemplate error: ${(err as Error).message}`);
      return false;
    }
  }

  /**
   * 按类型获取模板
   * @param type 模板类型
   * @returns 过滤后的模板列表
   */
  getTemplatesByType(type: TemplateType): MailTemplate[] {
    const templates: MailTemplate[] = this.loadTemplates();
    return templates.filter(t => t.templateType === type);
  }

  /**
   * 按ID获取模板
   * @param templateId 模板ID
   * @returns 模板对象，不存在则返回null
   */
  getTemplateById(templateId: string): MailTemplate | null {
    const templates: MailTemplate[] = this.loadTemplates();
    const found: MailTemplate | undefined = templates.find(t => t.templateId === templateId);
    return found !== undefined ? found : null;
  }

  /**
   * 验证模板
   * 检查模板数据是否符合要求
   * @param template 要验证的模板
   * @returns 错误信息，验证通过返回null
   */
  validateTemplate(template: MailTemplate): string | null {
    // 检查名称不为空
    if (!template.templateName || template.templateName.trim().length === 0) {
      return '模板名称不能为空';
    }
    // 检查名称长度
    if (template.templateName.length > 50) {
      return '模板名称不能超过50个字符';
    }
    // 检查正文不为空
    if (!template.bodyTemplate || template.bodyTemplate.trim().length === 0) {
      return '正文模板不能为空';
    }
    // 检查正文长度
    if (template.bodyTemplate.length > 5000) {
      return '正文模板不能超过5000个字符';
    }
    // 检查主题长度
    if (template.subjectTemplate && template.subjectTemplate.length > 200) {
      return '主题模板不能超过200个字符';
    }
    // 检查同类型下名称唯一性
    const templates: MailTemplate[] = this.loadTemplates();
    const duplicate: MailTemplate | undefined = templates.find(t =>
      t.templateType === template.templateType &&
      t.templateName === template.templateName &&
      t.templateId !== template.templateId
    );
    if (duplicate !== undefined) {
      return '该类型下已存在同名模板';
    }
    return null;
  }

  /**
   * 处理来自对端设备的同步数据
   * 使用"最后修改时间优先"策略解决冲突
   * @param templateDataJson 模板数据JSON字符串
   */
  handleSyncData(templateDataJson: string): void {
    if (!this.preferencesStore) {
      hilog.warn(DOMAIN, TAG, 'handleSyncData: preferencesStore not initialized');
      return;
    }
    try {
      const remoteTemplates: MailTemplate[] = MailTemplate.fromListJson(templateDataJson);
      if (remoteTemplates.length === 0) {
        hilog.info(DOMAIN, TAG, 'handleSyncData: no remote template data');
        return;
      }

      const localTemplates: MailTemplate[] = this.loadTemplates();
      // 合并本地和远程数据
      const mergedTemplates: MailTemplate[] = this.mergeTemplates(localTemplates, remoteTemplates);

      // 保存合并后的数据
      const jsonStr: string = MailTemplate.toListJson(mergedTemplates);
      this.preferencesStore.putSync(TEMPLATE_KEY, jsonStr);
      this.preferencesStore.flush();

      // 更新AppStorage
      AppStorage.setOrCreate('templateList', mergedTemplates);

      hilog.info(DOMAIN, TAG, `handleSyncData success, merged count: ${mergedTemplates.length}`);
    } catch (err) {
      hilog.error(DOMAIN, TAG, `handleSyncData error: ${(err as Error).message}`);
    }
  }

  /**
   * 合并本地和远程模板
   * 使用"最后修改时间优先"策略
   * @param local 本地模板列表
   * @param remote 远程模板列表
   * @returns 合并后的模板列表
   */
  private mergeTemplates(local: MailTemplate[], remote: MailTemplate[]): MailTemplate[] {
    const mergedMap: Map<string, MailTemplate> = new Map();

    // 添加所有本地模板
    for (const t of local) {
      mergedMap.set(t.templateId, t);
    }

    // 合并远程模板
    for (const remoteT of remote) {
      const localT: MailTemplate | undefined = mergedMap.get(remoteT.templateId);
      if (localT === undefined) {
        // 远程新增的模板
        mergedMap.set(remoteT.templateId, remoteT);
      } else {
        // 冲突：保留更新时间较晚的
        if (remoteT.updatedAt > localT.updatedAt) {
          mergedMap.set(remoteT.templateId, remoteT);
        }
      }
    }

    return Array.from(mergedMap.values());
  }

  /**
   * 初始化默认模板
   * 首次使用时创建预设模板
   */
  private initDefaultTemplates(): void {
    if (!this.preferencesStore) {
      return;
    }
    // 检查是否已有模板数据
    const existing: string = this.preferencesStore.getSync(TEMPLATE_KEY, '') as string;
    if (existing && existing.length > 0) {
      hilog.info(DOMAIN, TAG, 'Templates already exist, skip default initialization');
      return;
    }

    const now: number = Date.now();
    // 预设模板列表
    const defaultTemplates: MailTemplate[] = [
      // 周报模板
      new MailTemplate(
        MailTemplate.generateId(), '周报', TemplateType.WORK_REPORT,
        '本周工作汇报',
        '各位领导、同事：\n\n以下是本周工作汇报：\n\n一、本周完成工作：\n1. \n2. \n3. \n\n二、下周工作计划：\n1. \n2. \n3. \n\n三、需要协调的事项：\n\n此致\n敬礼',
        now, now
      ),
      // 月报模板
      new MailTemplate(
        MailTemplate.generateId(), '月报', TemplateType.WORK_REPORT,
        '本月工作汇报',
        '各位领导、同事：\n\n以下是本月工作汇报：\n\n一、本月完成工作：\n1. \n2. \n3. \n\n二、下月工作计划：\n1. \n2. \n3. \n\n三、需要协调的事项：\n\n此致\n敬礼',
        now, now
      ),
      // 事假模板
      new MailTemplate(
        MailTemplate.generateId(), '事假', TemplateType.LEAVE,
        '请假申请',
        '尊敬的领导：\n\n因个人事务，特申请事假，具体如下：\n\n请假时间：\n请假事由：\n预计返岗时间：\n\n工作交接安排：\n\n恳请批准，谢谢！\n\n此致\n敬礼',
        now, now
      ),
      // 病假模板
      new MailTemplate(
        MailTemplate.generateId(), '病假', TemplateType.LEAVE,
        '病假申请',
        '尊敬的领导：\n\n因身体不适，特申请病假，具体如下：\n\n请假时间：\n病情说明：\n预计返岗时间：\n\n工作交接安排：\n\n恳请批准，谢谢！\n\n此致\n敬礼',
        now, now
      ),
      // 产品报价模板
      new MailTemplate(
        MailTemplate.generateId(), '产品报价', TemplateType.QUOTATION,
        '产品报价单',
        '尊敬的客户：\n\n感谢您的咨询，以下是产品报价信息：\n\n产品名称：\n规格型号：\n单价：\n数量：\n总价：\n\n报价有效期：\n交货周期：\n付款方式：\n\n如有任何疑问，请随时联系。\n\n此致\n敬礼',
        now, now
      )
    ];

    // 保存默认模板
    const jsonStr: string = MailTemplate.toListJson(defaultTemplates);
    this.preferencesStore.putSync(TEMPLATE_KEY, jsonStr);
    this.preferencesStore.flush();
    AppStorage.setOrCreate('templateList', defaultTemplates);
    hilog.info(DOMAIN, TAG, `Default templates initialized, count: ${defaultTemplates.length}`);
  }
}
