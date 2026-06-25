import hilog from "@ohos:hilog";
const TAG = 'DistributedGameData';
const DOMAIN = 0x0000;
/**
 * 可同步的游戏状态接口
 */
export interface SyncableGameState {
    score: number; // 当前分数
    timeLeft: number; // 剩余时间
    targetsJson: string; // 靶子列表（JSON序列化，分布式对象不支持数组直接同步）
    isGameRunning: boolean; // 游戏是否进行中
    isGameOver: boolean; // 游戏是否结束
    isGamePreparing: boolean; // 是否准备阶段
    targetCount: number; // 靶子数量
    targetSize: number; // 靶子大小
    gameDuration: number; // 游戏时长
}
/**
 * 远端控制事件接口
 */
export interface ControlEvent {
    type: string; // 事件类型: 'hit'
    targetId: number; // 目标靶子ID
    timestamp: number; // 事件时间戳
}
/**
 * 克隆游戏状态（替代展开运算符，符合ArkTS严格模式）
 */
function cloneGameState(state: SyncableGameState): SyncableGameState {
    return {
        score: state.score,
        timeLeft: state.timeLeft,
        targetsJson: state.targetsJson,
        isGameRunning: state.isGameRunning,
        isGameOver: state.isGameOver,
        isGamePreparing: state.isGamePreparing,
        targetCount: state.targetCount,
        targetSize: state.targetSize,
        gameDuration: state.gameDuration
    };
}
/**
 * 分布式游戏数据同步模块（本地模拟实现）
 * 封装跨设备游戏数据同步逻辑
 * 当前版本为本地模拟，不依赖分布式数据对象API
 */
export class DistributedGameData {
    // 会话ID
    private sessionId: string = '';
    // 远端控制事件回调
    private onRemoteControlCallback: ((event: ControlEvent) => void) | null = null;
    // 远端状态变更回调
    private onStateChangeCallback: ((state: SyncableGameState) => void) | null = null;
    // 本地游戏状态数据
    private gameState: SyncableGameState = this.createDefaultState();
    /**
     * 创建默认游戏状态
     */
    private createDefaultState(): SyncableGameState {
        return {
            score: 0,
            timeLeft: 30,
            targetsJson: '[]',
            isGameRunning: false,
            isGameOver: false,
            isGamePreparing: true,
            targetCount: 1,
            targetSize: 2,
            gameDuration: 30
        };
    }
    /**
     * 创建分布式数据对象（本地模拟，仅保存状态）
     * @param sessionId - 会话ID
     * @param initialState - 初始游戏状态
     */
    createDistributedObject(sessionId: string, initialState?: SyncableGameState): boolean {
        this.sessionId = sessionId;
        if (initialState) {
            this.gameState = cloneGameState(initialState);
        }
        hilog.info(DOMAIN, TAG, 'Local game data initialized with sessionId: %{public}s', sessionId);
        return true;
    }
    /**
     * 同步游戏状态（本地模拟，仅更新本地状态）
     * @param state - 当前游戏状态
     */
    syncGameState(state: SyncableGameState): void {
        this.gameState = cloneGameState(state);
    }
    /**
     * 发送远端控制事件（本地模拟，无实际发送）
     * @param event - 控制事件
     */
    sendControlEvent(event: ControlEvent): void {
        hilog.info(DOMAIN, TAG, 'Control event (local mode, not sent): %{public}s', event.type);
    }
    /**
     * 注册远端控制事件回调
     * @param callback - 控制事件回调
     */
    onRemoteControl(callback: (event: ControlEvent) => void): void {
        this.onRemoteControlCallback = callback;
    }
    /**
     * 注册远端状态变更回调
     * @param callback - 状态变更回调
     */
    onStateChange(callback: (state: SyncableGameState) => void): void {
        this.onStateChangeCallback = callback;
    }
    /**
     * 获取当前游戏状态
     */
    getGameState(): SyncableGameState {
        return cloneGameState(this.gameState);
    }
    /**
     * 获取会话ID
     */
    getSessionId(): string {
        return this.sessionId;
    }
    /**
     * 销毁数据对象
     */
    destroy(): void {
        this.onRemoteControlCallback = null;
        this.onStateChangeCallback = null;
        this.sessionId = '';
        hilog.info(DOMAIN, TAG, 'DistributedGameData destroyed');
    }
}
