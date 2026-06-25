/**
 * 布局参数常量类
 * 集中管理所有可适配的UI布局参数
 * 每个参数提供 small（小屏）和 large（大屏）两个取值
 */

// 数值类型布局参数
export interface SizeValue {
  small: number;
  large: number;
}

// 字符串类型布局参数（如百分比高度）
export interface StringValue {
  small: string;
  large: string;
}

/**
 * 首页布局参数
 */
export namespace IndexPage {
  // 标题
  export const titleFontSize: SizeValue = { small: 32, large: 48 };
  export const titleMarginTop: SizeValue = { small: 60, large: 100 };

  // 图标
  export const iconSize: SizeValue = { small: 120, large: 180 };
  export const iconMarginTop: SizeValue = { small: 40, large: 60 };

  // 按钮
  export const buttonWidth: SizeValue = { small: 200, large: 280 };
  export const buttonHeight: SizeValue = { small: 50, large: 70 };
  export const buttonFontSize: SizeValue = { small: 20, large: 28 };
  export const buttonMarginTop: SizeValue = { small: 60, large: 80 };
}

/**
 * 游戏页布局参数
 */
export namespace GamePage {
  // 准备阶段标题
  export const titleFontSize: SizeValue = { small: 28, large: 40 };

  // 标签文字（靶子数量/大小/时长）
  export const labelFontSize: SizeValue = { small: 16, large: 20 };

  // 靶子数量选择按钮
  export const countButtonSize: SizeValue = { small: 36, large: 48 };
  export const countButtonFontSize: SizeValue = { small: 16, large: 20 };
  export const countButtonBorderRadius: SizeValue = { small: 18, large: 24 };

  // 靶子大小选择按钮
  export const sizeButtonWidth: SizeValue = { small: 50, large: 64 };
  export const sizeButtonHeight: SizeValue = { small: 36, large: 48 };
  export const sizeButtonFontSize: SizeValue = { small: 16, large: 20 };
  export const sizeButtonBorderRadius: SizeValue = { small: 18, large: 24 };

  // 游戏时长选择按钮
  export const durationButtonWidth: SizeValue = { small: 60, large: 80 };
  export const durationButtonHeight: SizeValue = { small: 36, large: 48 };
  export const durationButtonFontSize: SizeValue = { small: 14, large: 18 };
  export const durationButtonBorderRadius: SizeValue = { small: 18, large: 24 };

  // 开始游戏按钮
  export const startButtonWidth: SizeValue = { small: 200, large: 280 };
  export const startButtonHeight: SizeValue = { small: 50, large: 70 };
  export const startButtonFontSize: SizeValue = { small: 20, large: 28 };

  // 得分/时间信息栏
  export const scoreFontSize: SizeValue = { small: 20, large: 28 };
  export const scorePadding: SizeValue = { small: 10, large: 20 };
  export const scoreMarginTop: SizeValue = { small: 10, large: 20 };

  // 游戏区域
  export const gameAreaHeight: StringValue = { small: '55%', large: '65%' };
  export const gameAreaMarginTop: SizeValue = { small: 10, large: 20 };

  // 靶子半径
  export const targetRadiusSmall: SizeValue = { small: 20, large: 35 };
  export const targetRadiusMedium: SizeValue = { small: 30, large: 55 };
  export const targetRadiusLarge: SizeValue = { small: 40, large: 75 };

  // 基础分数
  export const baseScore: SizeValue = { small: 30, large: 50 };

  // 默认游戏区域尺寸（onAreaChange未触发时的降级值）
  export const defaultAreaWidth: SizeValue = { small: 300, large: 500 };
  export const defaultAreaHeight: SizeValue = { small: 400, large: 600 };

  // 游戏结束面板
  export const gameOverTitleFontSize: SizeValue = { small: 28, large: 36 };
  export const gameOverScoreFontSize: SizeValue = { small: 24, large: 32 };
  export const gameOverButtonWidth: SizeValue = { small: 200, large: 260 };
  export const gameOverButtonHeight: SizeValue = { small: 44, large: 56 };
  export const gameOverButtonFontSize: SizeValue = { small: 18, large: 22 };
  export const gameOverPanelWidth: StringValue = { small: '70%', large: '60%' };
  export const gameOverPanelPadding: SizeValue = { small: 30, large: 40 };
}

/**
 * 记录页布局参数
 */
export namespace RecordPage {
  // 标题
  export const titleFontSize: SizeValue = { small: 28, large: 36 };
  export const titleMarginTop: SizeValue = { small: 40, large: 60 };

  // 最高分区域
  export const highScoreFontSize: SizeValue = { small: 18, large: 24 };
  export const scoreFontSize: SizeValue = { small: 36, large: 48 };
  export const highScorePadding: SizeValue = { small: 20, large: 30 };
  export const highScoreMarginTop: SizeValue = { small: 20, large: 30 };

  // 记录列表项
  export const rankFontSize: SizeValue = { small: 16, large: 20 };
  export const rankWidth: SizeValue = { small: 60, large: 80 };
  export const scoreValueFontSize: SizeValue = { small: 18, large: 24 };
  export const scoreValueWidth: SizeValue = { small: 80, large: 100 };
  export const dateFontSize: SizeValue = { small: 12, large: 16 };
  export const listItemPadding: SizeValue = { small: 12, large: 16 };

  // 列表区域
  export const listHeight: StringValue = { small: '35%', large: '45%' };
  export const listMarginTop: SizeValue = { small: 20, large: 30 };

  // 空状态
  export const emptyTextFontSize: SizeValue = { small: 20, large: 24 };
  export const emptyTextMarginTop: SizeValue = { small: 60, large: 100 };

  // 按钮
  export const buttonWidth: SizeValue = { small: 140, large: 180 };
  export const buttonHeight: SizeValue = { small: 45, large: 55 };
  export const buttonFontSize: SizeValue = { small: 18, large: 22 };
  export const buttonMarginTop: SizeValue = { small: 30, large: 40 };
}

/**
 * 投送功能布局参数
 */
export namespace CastUI {
  // 投送按钮
  export const castButtonWidth: SizeValue = { small: 200, large: 280 };
  export const castButtonHeight: SizeValue = { small: 50, large: 70 };
  export const castButtonFontSize: SizeValue = { small: 20, large: 28 };

  // 设备选择面板
  export const panelWidth: StringValue = { small: '90%', large: '70%' };
  export const panelTitleFontSize: SizeValue = { small: 22, large: 28 };
  export const deviceItemHeight: SizeValue = { small: 60, large: 80 };
  export const deviceNameFontSize: SizeValue = { small: 16, large: 20 };
  export const connectButtonWidth: SizeValue = { small: 80, large: 100 };
  export const connectButtonHeight: SizeValue = { small: 36, large: 44 };
  export const connectButtonFontSize: SizeValue = { small: 14, large: 16 };

  // 状态栏
  export const statusBarHeight: SizeValue = { small: 40, large: 50 };
  export const statusBarFontSize: SizeValue = { small: 14, large: 16 };
}

/**
 * 辅助函数：根据 isSmallScreen 获取 SizeValue 的对应值
 */
export function getSizeValue(value: SizeValue, isSmall: boolean): number {
  return isSmall ? value.small : value.large;
}

/**
 * 辅助函数：根据 isSmallScreen 获取 StringValue 的对应值
 */
export function getStringValue(value: StringValue, isSmall: boolean): string {
  return isSmall ? value.small : value.large;
}
