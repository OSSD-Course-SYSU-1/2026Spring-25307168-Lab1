import mediaQuery from "@ohos:mediaquery";
/**
 * 屏幕适配工具类
 * 负责检测设备屏幕尺寸并动态调整UI布局
 * 使用 HarmonyOS MediaQuery API 实现响应式断点监听
 */
export class ScreenAdapter {
    // 断点值：窗口宽度 >= 600vp 为大屏，< 600vp 为小屏
    private static readonly BREAKPOINT: number = 600;
    // 当前是否为小屏
    private static smallScreen: boolean = false;
    // MediaQuery 监听器引用
    private static listener: mediaQuery.MediaQueryListener | null = null;
    // 状态变化回调
    private static callback: ((isSmall: boolean) => void) | null = null;
    /**
     * 初始化屏幕检测
     * 使用 MediaQuery matchMediaSync 检测当前屏幕宽度是否小于断点值
     * @returns 当前是否为小屏
     */
    static initScreenDetection(): boolean {
        try {
            // 创建 MediaQuery 条件：屏幕宽度在 [0, 600vp) 范围内为小屏
            const mq = mediaQuery.matchMediaSync(`(width<${ScreenAdapter.BREAKPOINT}vp)`);
            // 获取当前匹配结果
            ScreenAdapter.smallScreen = mq.matches;
            return ScreenAdapter.smallScreen;
        }
        catch {
            // MediaQuery API 调用异常时，降级为大屏布局
            ScreenAdapter.smallScreen = false;
            return false;
        }
    }
    /**
     * 注册屏幕尺寸变化监听器
     * 当窗口宽度跨越断点值时，触发回调通知页面更新
     * @param callback - 状态变化回调函数，参数为是否小屏
     */
    static registerListener(callback: (isSmall: boolean) => void): void {
        try {
            ScreenAdapter.callback = callback;
            const mq = mediaQuery.matchMediaSync(`(width<${ScreenAdapter.BREAKPOINT}vp)`);
            ScreenAdapter.listener = mq;
            // 注册监听器
            mq.on('change', (result: mediaQuery.MediaQueryResult) => {
                ScreenAdapter.smallScreen = result.matches;
                if (ScreenAdapter.callback) {
                    ScreenAdapter.callback(result.matches);
                }
            });
        }
        catch {
            // 监听器注册失败，不影响初始检测结果
            // 页面将仅使用启动时检测的尺寸，不再动态响应变化
        }
    }
    /**
     * 注销屏幕尺寸变化监听器
     * 在页面 aboutToDisappear 中调用，避免内存泄漏
     */
    static unregisterListener(): void {
        try {
            if (ScreenAdapter.listener) {
                ScreenAdapter.listener.off('change');
                ScreenAdapter.listener = null;
            }
            ScreenAdapter.callback = null;
        }
        catch {
            // 注销失败时静默处理
        }
    }
    /**
     * 获取当前是否为小屏
     * @returns 是否小屏
     */
    static isSmallScreen(): boolean {
        return ScreenAdapter.smallScreen;
    }
    /**
     * 获取断点值
     * @returns 断点值（vp）
     */
    static getBreakpoint(): number {
        return ScreenAdapter.BREAKPOINT;
    }
}
