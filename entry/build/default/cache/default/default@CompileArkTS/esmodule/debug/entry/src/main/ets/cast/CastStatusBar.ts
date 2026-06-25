if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface CastStatusBar_Params {
    connectionState?: CastConnectionState;
    targetDeviceName?: string;
    isSmallScreen?: boolean;
    // 断开连接回调
    onDisconnect?: () => void;
}
import { CastConnectionState } from "@bundle:com.example.targetgame/entry/ets/cast/DeviceCastManager";
import { CastUI, getSizeValue } from "@bundle:com.example.targetgame/entry/ets/constants/LayoutConstants";
export class CastStatusBar extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__connectionState = new SynchedPropertySimpleOneWayPU(params.connectionState, this, "connectionState");
        this.__targetDeviceName = new SynchedPropertySimpleOneWayPU(params.targetDeviceName, this, "targetDeviceName");
        this.__isSmallScreen = new SynchedPropertySimpleOneWayPU(params.isSmallScreen, this, "isSmallScreen");
        this.onDisconnect = () => { };
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: CastStatusBar_Params) {
        if (params.connectionState === undefined) {
            this.__connectionState.set(CastConnectionState.DISCONNECTED);
        }
        if (params.targetDeviceName === undefined) {
            this.__targetDeviceName.set('');
        }
        if (params.isSmallScreen === undefined) {
            this.__isSmallScreen.set(false);
        }
        if (params.onDisconnect !== undefined) {
            this.onDisconnect = params.onDisconnect;
        }
    }
    updateStateVars(params: CastStatusBar_Params) {
        this.__connectionState.reset(params.connectionState);
        this.__targetDeviceName.reset(params.targetDeviceName);
        this.__isSmallScreen.reset(params.isSmallScreen);
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__connectionState.purgeDependencyOnElmtId(rmElmtId);
        this.__targetDeviceName.purgeDependencyOnElmtId(rmElmtId);
        this.__isSmallScreen.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__connectionState.aboutToBeDeleted();
        this.__targetDeviceName.aboutToBeDeleted();
        this.__isSmallScreen.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    // 连接状态
    private __connectionState: SynchedPropertySimpleOneWayPU<CastConnectionState>;
    get connectionState() {
        return this.__connectionState.get();
    }
    set connectionState(newValue: CastConnectionState) {
        this.__connectionState.set(newValue);
    }
    // 目标设备名称
    private __targetDeviceName: SynchedPropertySimpleOneWayPU<string>;
    get targetDeviceName() {
        return this.__targetDeviceName.get();
    }
    set targetDeviceName(newValue: string) {
        this.__targetDeviceName.set(newValue);
    }
    // 是否为小屏
    private __isSmallScreen: SynchedPropertySimpleOneWayPU<boolean>;
    get isSmallScreen() {
        return this.__isSmallScreen.get();
    }
    set isSmallScreen(newValue: boolean) {
        this.__isSmallScreen.set(newValue);
    }
    // 断开连接回调
    private onDisconnect: () => void;
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.connectionState === CastConnectionState.CONNECTED) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Row.create();
                        Row.width('90%');
                        Row.height(getSizeValue(CastUI.statusBarHeight, this.isSmallScreen));
                        Row.padding({ left: 15, right: 15 });
                        Row.backgroundColor('rgba(78, 205, 196, 0.3)');
                        Row.borderRadius(12);
                        Row.alignItems(VerticalAlign.Center);
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 投送图标
                        Text.create('📡');
                        // 投送图标
                        Text.fontSize(getSizeValue(CastUI.deviceNameFontSize, this.isSmallScreen));
                        // 投送图标
                        Text.margin({ right: 8 });
                    }, Text);
                    // 投送图标
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 状态文本
                        Text.create(`已连接至 ${this.targetDeviceName}`);
                        // 状态文本
                        Text.fontSize(getSizeValue(CastUI.statusBarFontSize, this.isSmallScreen));
                        // 状态文本
                        Text.fontColor('#FFFFFF');
                        // 状态文本
                        Text.layoutWeight(1);
                    }, Text);
                    // 状态文本
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 断开按钮
                        Button.createWithLabel('断开');
                        // 断开按钮
                        Button.height(getSizeValue(CastUI.connectButtonHeight, this.isSmallScreen) * 0.8);
                        // 断开按钮
                        Button.fontSize(getSizeValue(CastUI.connectButtonFontSize, this.isSmallScreen));
                        // 断开按钮
                        Button.fontColor('#FFFFFF');
                        // 断开按钮
                        Button.backgroundColor('#FF6B6B');
                        // 断开按钮
                        Button.borderRadius(12);
                        // 断开按钮
                        Button.onClick(() => {
                            this.onDisconnect();
                        });
                    }, Button);
                    // 断开按钮
                    Button.pop();
                    Row.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
