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
 * 快捷回复数据模型
 * 
 * 功能说明：
 * 1. 定义快捷回复的数据结构
 * 2. 提供序列化/反序列化方法，用于数据存储和分布式同步
 * 3. 支持排序功能，按用户自定义顺序显示
 */

import { util } from '@kit.ArkTS';

/**
 * 快捷回复类
 * 
 * 表示一个预定义的快捷回复内容，用于一键快速回复邮件。
 * 用户可以创建常用的回复内容，提高回复效率。
 * 
 * 属性说明：
 * - replyId: 快捷回复唯一标识符（UUID）
 * - replyContent: 回复内容文本
 * - sortOrder: 排序顺序（数值越小越靠前）
 * - createdAt: 创建时间戳
 * - updatedAt: 最后更新时间戳
 */
export class QuickReply {
  // 快捷回复唯一标识符
  replyId: string;
  // 回复内容文本
  replyContent: string;
  // 排序顺序（数值越小越靠前）
  sortOrder: number;
  // 创建时间戳（毫秒）
  createdAt: number;
  // 最后更新时间戳（毫秒）
  updatedAt: number;

  /**
   * 构造函数
   * @param replyId 快捷回复ID
   * @param replyContent 回复内容
   * @param sortOrder 排序顺序
   * @param createdAt 创建时间
   * @param updatedAt 更新时间
   */
  constructor(replyId: string, replyContent: string, sortOrder: number,
    createdAt: number, updatedAt: number) {
    this.replyId = replyId;
    this.replyContent = replyContent;
    this.sortOrder = sortOrder;
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
   * 将快捷回复对象转换为可JSON序列化的普通对象
   * @returns 包含所有属性的普通对象
   */
  toPlainObject(): Record<string, Object> {
    return {
      'replyId': this.replyId,
      'replyContent': this.replyContent,
      'sortOrder': this.sortOrder,
      'createdAt': this.createdAt,
      'updatedAt': this.updatedAt
    };
  }

  /**
   * 从普通对象创建快捷回复实例
   * 用于从JSON解析后的数据创建快捷回复对象
   * @param obj 普通对象
   * @returns QuickReply实例
   */
  static fromPlainObject(obj: Record<string, Object>): QuickReply {
    return new QuickReply(
      obj['replyId'] as string,
      obj['replyContent'] as string,
      obj['sortOrder'] as number,
      obj['createdAt'] as number,
      obj['updatedAt'] as number
    );
  }

  /**
   * 序列化快捷回复列表为JSON字符串
   * 用于数据存储和分布式同步
   * @param list 快捷回复列表
   * @returns JSON字符串
   */
  static toListJson(list: QuickReply[]): string {
    const plainList: Record<string, Object>[] = [];
    for (const item of list) {
      plainList.push(item.toPlainObject());
    }
    return JSON.stringify(plainList);
  }

  /**
   * 从JSON字符串反序列化快捷回复列表
   * 用于从存储或分布式数据恢复快捷回复列表
   * @param jsonStr JSON字符串
   * @returns 快捷回复列表
   */
  static fromListJson(jsonStr: string): QuickReply[] {
    if (!jsonStr || jsonStr.length === 0) {
      return [];
    }
    try {
      const plainList: Record<string, Object>[] = JSON.parse(jsonStr) as Record<string, Object>[];
      const result: QuickReply[] = [];
      for (const obj of plainList) {
        result.push(QuickReply.fromPlainObject(obj));
      }
      return result;
    } catch (e) {
      // 解析失败返回空列表
      return [];
    }
  }
}
