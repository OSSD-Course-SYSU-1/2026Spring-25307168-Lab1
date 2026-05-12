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
 * 邮件模板数据模型
 * 
 * 功能说明：
 * 1. 定义邮件模板的数据结构
 * 2. 提供模板类型的枚举定义
 * 3. 提供序列化/反序列化方法，用于数据存储和分布式同步
 */

import { util } from '@kit.ArkTS';

/**
 * 模板类型枚举
 * 
 * 支持四种模板类型：
 * - WORK_REPORT: 工作汇报模板
 * - LEAVE: 请假申请模板
 * - QUOTATION: 报价单模板
 * - CUSTOM: 自定义模板
 */
export enum TemplateType {
  WORK_REPORT = 'WORK_REPORT',  // 工作汇报
  LEAVE = 'LEAVE',              // 请假申请
  QUOTATION = 'QUOTATION',      // 报价单
  CUSTOM = 'CUSTOM'             // 自定义
}

/**
 * 邮件模板类
 * 
 * 表示一个预定义的邮件模板，包含主题和正文内容。
 * 用于快速创建常用类型的邮件，提高工作效率。
 * 
 * 属性说明：
 * - templateId: 模板唯一标识符（UUID）
 * - templateName: 模板名称（用户可见）
 * - templateType: 模板类型（工作汇报/请假/报价/自定义）
 * - subjectTemplate: 主题模板内容
 * - bodyTemplate: 正文模板内容
 * - createdAt: 创建时间戳
 * - updatedAt: 最后更新时间戳
 */
export class MailTemplate {
  // 模板唯一标识符
  templateId: string;
  // 模板名称
  templateName: string;
  // 模板类型
  templateType: TemplateType;
  // 主题模板内容
  subjectTemplate: string;
  // 正文模板内容
  bodyTemplate: string;
  // 创建时间戳（毫秒）
  createdAt: number;
  // 最后更新时间戳（毫秒）
  updatedAt: number;

  /**
   * 构造函数
   * @param templateId 模板ID
   * @param templateName 模板名称
   * @param templateType 模板类型
   * @param subjectTemplate 主题模板
   * @param bodyTemplate 正文模板
   * @param createdAt 创建时间
   * @param updatedAt 更新时间
   */
  constructor(templateId: string, templateName: string, templateType: TemplateType,
    subjectTemplate: string, bodyTemplate: string, createdAt: number, updatedAt: number) {
    this.templateId = templateId;
    this.templateName = templateName;
    this.templateType = templateType;
    this.subjectTemplate = subjectTemplate;
    this.bodyTemplate = bodyTemplate;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
  }

  /**
   * 生成唯一ID
   * 使用UUID算法生成唯一标识符
   * @returns UUID字符串
   */
  static generateId(): string {
    return util.generateRandomUUID(true);
  }

  /**
   * 序列化为普通对象
   * 将模板对象转换为可JSON序列化的普通对象
   * @returns 包含所有属性的普通对象
   */
  toPlainObject(): Record<string, Object> {
    return {
      'templateId': this.templateId,
      'templateName': this.templateName,
      'templateType': this.templateType,
      'subjectTemplate': this.subjectTemplate,
      'bodyTemplate': this.bodyTemplate,
      'createdAt': this.createdAt,
      'updatedAt': this.updatedAt
    };
  }

  /**
   * 从普通对象创建模板实例
   * 用于从JSON解析后的数据创建模板对象
   * @param obj 普通对象
   * @returns MailTemplate实例
   */
  static fromPlainObject(obj: Record<string, Object>): MailTemplate {
    return new MailTemplate(
      obj['templateId'] as string,
      obj['templateName'] as string,
      obj['templateType'] as TemplateType,
      obj['subjectTemplate'] as string,
      obj['bodyTemplate'] as string,
      obj['createdAt'] as number,
      obj['updatedAt'] as number
    );
  }

  /**
   * 序列化模板列表为JSON字符串
   * 用于数据存储和分布式同步
   * @param list 模板列表
   * @returns JSON字符串
   */
  static toListJson(list: MailTemplate[]): string {
    const plainList: Record<string, Object>[] = [];
    for (const item of list) {
      plainList.push(item.toPlainObject());
    }
    return JSON.stringify(plainList);
  }

  /**
   * 从JSON字符串反序列化模板列表
   * 用于从存储或分布式数据恢复模板列表
   * @param jsonStr JSON字符串
   * @returns 模板列表
   */
  static fromListJson(jsonStr: string): MailTemplate[] {
    if (!jsonStr || jsonStr.length === 0) {
      return [];
    }
    try {
      const plainList: Record<string, Object>[] = JSON.parse(jsonStr) as Record<string, Object>[];
      const result: MailTemplate[] = [];
      for (const obj of plainList) {
        result.push(MailTemplate.fromPlainObject(obj));
      }
      return result;
    } catch (e) {
      // 解析失败返回空列表
      return [];
    }
  }
}
