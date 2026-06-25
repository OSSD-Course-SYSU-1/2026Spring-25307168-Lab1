if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface DeviceSelectPanel_Params {
    // 对话框控制器
    controller?: CustomDialogController;
    devices?: DeviceInfo[];
    connectionState?: CastConnectionState;
    isDiscovering?: boolean;
    isSmallScreen?: boolean;
    // 设备选择回调
    onDeviceSelect?: (deviceId: string) => void;
    // 关闭回调
    onClose?: () => void;
    // 重试回调
    onRetry?: () => void;
}
import { CastConnectionState } from "@bundle:com.example.targetgame/entry/ets/cast/DeviceCastManager";
import type { DeviceInfo } from "@bundle:com.example.targetgame/entry/ets/cast/DeviceCastManager";
import { CastUI, getSizeValue, getStringValue } from "@bundle:com.example.targetgame/entry/ets/constants/LayoutConstants";
export class DeviceSelectPanel extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.controller = undefined;
        this.__devices = new ObservedPropertyObjectPU([], this, "devices");
        this.__connectionState = new ObservedPropertySimplePU(CastConnectionState.DISCONNECTED, this, "connectionState");
        this.__isDiscovering = new ObservedPropertySimplePU(false, this, "isDiscovering");
        this.__isSmallScreen = new ObservedPropertySimplePU(false, this, "isSmallScreen");
        this.onDeviceSelect = () => { };
        this.onClose = () => { };
        this.onRetry = () => { };
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: DeviceSelectPanel_Params) {
        if (params.controller !== undefined) {
            this.controller = params.controller;
        }
        if (params.devices !== undefined) {
            this.devices = params.devices;
        }
        if (params.connectionState !== undefined) {
            this.connectionState = params.connectionState;
        }
        if (params.isDiscovering !== undefined) {
            this.isDiscovering = params.isDiscovering;
        }
        if (params.isSmallScreen !== undefined) {
            this.isSmallScreen = params.isSmallScreen;
        }
        if (params.onDeviceSelect !== undefined) {
            this.onDeviceSelect = params.onDeviceSelect;
        }
        if (params.onClose !== undefined) {
            this.onClose = params.onClose;
        }
        if (params.onRetry !== undefined) {
            this.onRetry = params.onRetry;
        }
    }
    updateStateVars(params: DeviceSelectPanel_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__devices.purgeDependencyOnElmtId(rmElmtId);
        this.__connectionState.purgeDependencyOnElmtId(rmElmtId);
        this.__isDiscovering.purgeDependencyOnElmtId(rmElmtId);
        this.__isSmallScreen.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__devices.aboutToBeDeleted();
        this.__connectionState.aboutToBeDeleted();
        this.__isDiscovering.aboutToBeDeleted();
        this.__isSmallScreen.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    // 对话框控制器
    private controller: CustomDialogController;
    setController(ctr: CustomDialogController) {
        this.
        // 对话框控制器
        controller = ctr;
    }
    // 设备列表
    private __devices: ObservedPropertyObjectPU<DeviceInfo[]>;
    get devices() {
        return this.__devices.get();
    }
    set devices(newValue: DeviceInfo[]) {
        this.__devices.set(newValue);
    }
    // 连接状态
    private __connectionState: ObservedPropertySimplePU<CastConnectionState>;
    get connectionState() {
        return this.__connectionState.get();
    }
    set connectionState(newValue: CastConnectionState) {
        this.__connectionState.set(newValue);
    }
    // 是否正在搜索设备
    private __isDiscovering: ObservedPropertySimplePU<boolean>;
    get isDiscovering() {
        return this.__isDiscovering.get();
    }
    set isDiscovering(newValue: boolean) {
        this.__isDiscovering.set(newValue);
    }
    // 是否为小屏
    private __isSmallScreen: ObservedPropertySimplePU<boolean>;
    get isSmallScreen() {
        return this.__isSmallScreen.get();
    }
    set isSmallScreen(newValue: boolean) {
        this.__isSmallScreen.set(newValue);
    }
    // 设备选择回调
    private onDeviceSelect: (deviceId: string) => void;
    // 关闭回调
    private onClose: () => void;
    // 重试回调
    private onRetry: () => void;
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width(getStringValue(CastUI.panelWidth, this.isSmallScreen));
            Column.padding(25);
            Column.backgroundColor('rgba(30, 30, 60, 0.95)');
            Column.borderRadius(20);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 标题栏
            Row.create();
            // 标题栏
            Row.width('100%');
            // 标题栏
            Row.margin({ bottom: 20 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('选择投送设备');
            Text.fontSize(getSizeValue(CastUI.panelTitleFontSize, this.isSmallScreen));
            Text.fontColor('#FFFFFF');
            Text.fontWeight(FontWeight.Bold);
            Text.layoutWeight(1);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 关闭按钮
            Button.createWithChild();
            // 关闭按钮
            Button.width(getSizeValue(CastUI.connectButtonHeight, this.isSmallScreen));
            // 关闭按钮
            Button.height(getSizeValue(CastUI.connectButtonHeight, this.isSmallScreen));
            // 关闭按钮
            Button.backgroundColor('rgba(255, 255, 255, 0.2)');
            // 关闭按钮
            Button.borderRadius(getSizeValue(CastUI.connectButtonHeight, this.isSmallScreen) / 2);
            // 关闭按钮
            Button.onClick(() => {
                this.controller.close();
                this.onClose();
            });
        }, Button);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('✕');
            Text.fontSize(getSizeValue(CastUI.connectButtonFontSize, this.isSmallScreen));
            Text.fontColor('#FFFFFF');
        }, Text);
        Text.pop();
        // 关闭按钮
        Button.pop();
        // 标题栏
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // 搜索状态指示器
            if (this.isDiscovering) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Row.create();
                        Row.width('100%');
                        Row.justifyContent(FlexAlign.Center);
                        Row.padding(20);
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        LoadingProgress.create();
                        LoadingProgress.width(20);
                        LoadingProgress.height(20);
                        LoadingProgress.color('#FFFFFF');
                        LoadingProgress.margin({ right: 10 });
                    }, LoadingProgress);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('正在搜索附近设备...');
                        Text.fontSize(getSizeValue(CastUI.deviceNameFontSize, this.isSmallScreen));
                        Text.fontColor('#CCCCCC');
                    }, Text);
                    Text.pop();
                    Row.pop();
                });
            }
            // 设备列表
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // 设备列表
            if (this.devices.length > 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        List.create();
                        List.width('100%');
                        List.layoutWeight(1);
                    }, List);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        ForEach.create();
                        const forEachItemGenFunction = _item => {
                            const device = _item;
                            {
                                const itemCreation = (elmtId, isInitialRender) => {
                                    ViewStackProcessor.StartGetAccessRecordingFor(elmtId);
                                    ListItem.create(deepRenderFunction, true);
                                    if (!isInitialRender) {
                                        ListItem.pop();
                                    }
                                    ViewStackProcessor.StopGetAccessRecording();
                                };
                                const itemCreation2 = (elmtId, isInitialRender) => {
                                    ListItem.create(deepRenderFunction, true);
                                };
                                const deepRenderFunction = (elmtId, isInitialRender) => {
                                    itemCreation(elmtId, isInitialRender);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Row.create();
                                        Row.width('100%');
                                        Row.height(getSizeValue(CastUI.deviceItemHeight, this.isSmallScreen));
                                        Row.padding({ left: 15, right: 15 });
                                        Row.backgroundColor('rgba(255, 255, 255, 0.1)');
                                        Row.borderRadius(12);
                                        Row.margin({ bottom: 10 });
                                    }, Row);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        // 设备类型图标
                                        Text.create(this.getDeviceIcon(device.deviceType));
                                        // 设备类型图标
                                        Text.fontSize(getSizeValue(CastUI.panelTitleFontSize, this.isSmallScreen));
                                        // 设备类型图标
                                        Text.margin({ right: 15 });
                                    }, Text);
                                    // 设备类型图标
                                    Text.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        // 设备名称
                                        Text.create(device.deviceName);
                                        // 设备名称
                                        Text.fontSize(getSizeValue(CastUI.deviceNameFontSize, this.isSmallScreen));
                                        // 设备名称
                                        Text.fontColor('#FFFFFF');
                                        // 设备名称
                                        Text.layoutWeight(1);
                                    }, Text);
                                    // 设备名称
                                    Text.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        // 连接按钮
                                        Button.createWithLabel(this.getConnectButtonText(device.deviceId));
                                        // 连接按钮
                                        Button.width(getSizeValue(CastUI.connectButtonWidth, this.isSmallScreen));
                                        // 连接按钮
                                        Button.height(getSizeValue(CastUI.connectButtonHeight, this.isSmallScreen));
                                        // 连接按钮
                                        Button.fontSize(getSizeValue(CastUI.connectButtonFontSize, this.isSmallScreen));
                                        // 连接按钮
                                        Button.fontColor('#FFFFFF');
                                        // 连接按钮
                                        Button.backgroundColor(this.getConnectButtonColor(device.deviceId));
                                        // 连接按钮
                                        Button.borderRadius(getSizeValue(CastUI.connectButtonHeight, this.isSmallScreen) / 2);
                                        // 连接按钮
                                        Button.enabled(this.connectionState !== CastConnectionState.CONNECTING);
                                        // 连接按钮
                                        Button.onClick(() => {
                                            this.onDeviceSelect(device.deviceId);
                                        });
                                    }, Button);
                                    // 连接按钮
                                    Button.pop();
                                    Row.pop();
                                    ListItem.pop();
                                };
                                this.observeComponentCreation2(itemCreation2, ListItem);
                                ListItem.pop();
                            }
                        };
                        this.forEachUpdateFunction(elmtId, this.devices, forEachItemGenFunction, (device: DeviceInfo) => device.deviceId, false, false);
                    }, ForEach);
                    ForEach.pop();
                    List.pop();
                });
            }
            else if (!this.isDiscovering) {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 空状态
                        Column.create();
                        // 空状态
                        Column.width('100%');
                        // 空状态
                        Column.justifyContent(FlexAlign.Center);
                        // 空状态
                        Column.alignItems(HorizontalAlign.Center);
                        // 空状态
                        Column.layoutWeight(1);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('未发现可用设备');
                        Text.fontSize(getSizeValue(CastUI.deviceNameFontSize, this.isSmallScreen));
                        Text.fontColor('#CCCCCC');
                        Text.margin({ bottom: 20 });
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel('重新搜索');
                        Button.width(getSizeValue(CastUI.connectButtonWidth, this.isSmallScreen) * 1.5);
                        Button.height(getSizeValue(CastUI.connectButtonHeight, this.isSmallScreen));
                        Button.fontSize(getSizeValue(CastUI.connectButtonFontSize, this.isSmallScreen));
                        Button.fontColor('#FFFFFF');
                        Button.backgroundColor('#4ECDC4');
                        Button.borderRadius(getSizeValue(CastUI.connectButtonHeight, this.isSmallScreen) / 2);
                        Button.onClick(() => {
                            this.onRetry();
                        });
                    }, Button);
                    Button.pop();
                    // 空状态
                    Column.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(2, () => {
                });
            }
        }, If);
        If.pop();
        Column.pop();
    }
    /**
     * 获取设备类型图标
     */
    private getDeviceIcon(deviceType: string): string {
        switch (deviceType) {
            case 'phone':
                return '📱';
            case 'tablet':
                return '📟';
            case '2in1':
                return '💻';
            default:
                return '📱';
        }
    }
    /**
     * 获取连接按钮文本
     */
    private getConnectButtonText(deviceId: string): string {
        if (this.connectionState === CastConnectionState.CONNECTING && this.isCurrentDevice(deviceId)) {
            return '连接中';
        }
        if (this.connectionState === CastConnectionState.CONNECTED && this.isCurrentDevice(deviceId)) {
            return '已连接';
        }
        return '连接';
    }
    /**
     * 获取连接按钮颜色
     */
    private getConnectButtonColor(deviceId: string): string {
        if (this.connectionState === CastConnectionState.CONNECTED && this.isCurrentDevice(deviceId)) {
            return '#4ECDC4';
        }
        return '#667eea';
    }
    /**
     * 判断是否为当前连接的设备
     */
    private isCurrentDevice(deviceId: string): boolean {
        return false; // 由外部管理器维护
    }
    rerender() {
        this.updateDirtyElements();
    }
}
