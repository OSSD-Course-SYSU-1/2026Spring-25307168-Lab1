import hilog from "@ohos:hilog";
const TAG = 'DeviceCastManager';
const DOMAIN = 0x0000;
/**
 * 设备信息接口
 */
export interface DeviceInfo {
    deviceId: string; // 设备唯一标识
    deviceName: string; // 设备显示名称
    deviceType: string; // 设备类型: 'phone' | 'tablet' | '2in1'
    isOnline: boolean; // 是否在线
}
/**
 * 投送连接状态枚举
 */
export enum CastConnectionState {
    DISCONNECTED = "disconnected",
    CONNECTING = "connecting",
    CONNECTED = "connected" // 已连接
}
/**
 * 跨设备投送管理器（本地模拟实现）
 * 负责设备发现、连接管理和数据同步的协调
 * 当前版本为本地模拟，不依赖分布式设备管理API
 */
export class DeviceCastManager {
    // 单例实例
    private static instance: DeviceCastManager | null = null;
    // 已发现的设备列表
    private discoveredDevices: DeviceInfo[] = [];
    // 当前连接状态
    private connectionState: CastConnectionState = CastConnectionState.DISCONNECTED;
    // 当前连接的设备ID
    private connectedDeviceId: string = '';
    // 当前连接的设备名称
    private connectedDeviceName: string = '';
    // 是否支持分布式能力（本地模拟始终为false）
    private distributedSupported: boolean = false;
    // 状态变化回调
    private onConnectionStateChange: ((state: CastConnectionState) => void) | null = null;
    // 设备列表变化回调
    private onDeviceListChange: ((devices: DeviceInfo[]) => void) | null = null;
    private constructor() { }
    /**
     * 获取单例实例
     */
    static getInstance(): DeviceCastManager {
        if (!DeviceCastManager.instance) {
            DeviceCastManager.instance = new DeviceCastManager();
        }
        return DeviceCastManager.instance;
    }
    /**
     * 初始化（本地模拟，始终支持分布式能力以显示UI）
     */
    init(): void {
        this.distributedSupported = true;
        hilog.info(DOMAIN, TAG, 'DeviceCastManager initialized (local mode)');
    }
    /**
     * 检测是否支持分布式能力
     */
    isDistributedSupported(): boolean {
        return this.distributedSupported;
    }
    /**
     * 启动设备发现（本地模拟，无实际发现）
     */
    startDeviceDiscovery(): void {
        hilog.info(DOMAIN, TAG, 'Device discovery not supported in local mode');
    }
    /**
     * 停止设备发现
     */
    stopDeviceDiscovery(): void {
        hilog.info(DOMAIN, TAG, 'Device discovery stopped');
    }
    /**
     * 获取已发现的设备列表
     */
    getDiscoveredDevices(): DeviceInfo[] {
        return this.discoveredDevices;
    }
    /**
     * 连接指定设备（本地模拟，始终返回false）
     */
    async connectDevice(deviceId: string): Promise<boolean> {
        hilog.info(DOMAIN, TAG, 'Device connection not supported in local mode');
        return false;
    }
    /**
     * 断开当前连接
     */
    disconnectDevice(): void {
        this.connectedDeviceId = '';
        this.connectedDeviceName = '';
        this.setConnectionState(CastConnectionState.DISCONNECTED);
        hilog.info(DOMAIN, TAG, 'Device disconnected');
    }
    /**
     * 获取当前连接状态
     */
    getConnectionState(): CastConnectionState {
        return this.connectionState;
    }
    /**
     * 获取当前连接的设备名称
     */
    getConnectedDeviceName(): string {
        return this.connectedDeviceName;
    }
    /**
     * 注册连接状态变化回调
     */
    setOnConnectionStateChange(callback: (state: CastConnectionState) => void): void {
        this.onConnectionStateChange = callback;
    }
    /**
     * 注册设备列表变化回调
     */
    setOnDeviceListChange(callback: (devices: DeviceInfo[]) => void): void {
        this.onDeviceListChange = callback;
    }
    /**
     * 销毁管理器
     */
    destroy(): void {
        this.discoveredDevices = [];
        this.connectedDeviceId = '';
        this.connectedDeviceName = '';
        this.setConnectionState(CastConnectionState.DISCONNECTED);
        DeviceCastManager.instance = null;
        this.distributedSupported = false;
        hilog.info(DOMAIN, TAG, 'DeviceCastManager destroyed');
    }
    // ========== 私有方法 ==========
    /**
     * 设置连接状态并通知
     */
    private setConnectionState(state: CastConnectionState): void {
        this.connectionState = state;
        if (this.onConnectionStateChange) {
            this.onConnectionStateChange(state);
        }
    }
    /**
     * 通知设备列表变化
     */
    private notifyDeviceListChange(): void {
        if (this.onDeviceListChange) {
            this.onDeviceListChange([...this.discoveredDevices]);
        }
    }
}
