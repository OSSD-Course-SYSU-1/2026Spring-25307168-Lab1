if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface Index_Params {
    isSmallScreen?: boolean;
    isDistributedSupported?: boolean;
    dots?: FloatingDot[];
    animOffset?: number;
    castManager?: DeviceCastManager;
    dotId?: number;
    animTimer?: number;
}
import router from "@ohos:router";
import { ScreenAdapter } from "@bundle:com.example.targetgame/entry/ets/utils/ScreenAdapter";
import { IndexPage, getSizeValue } from "@bundle:com.example.targetgame/entry/ets/constants/LayoutConstants";
import { DeviceCastManager } from "@bundle:com.example.targetgame/entry/ets/cast/DeviceCastManager";
interface FloatingDot {
    id: number;
    x: number;
    y: number;
    size: number;
    opacity: number;
    speed: number;
}
class Index extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__isSmallScreen = new ObservedPropertySimplePU(false, this, "isSmallScreen");
        this.__isDistributedSupported = new ObservedPropertySimplePU(false, this, "isDistributedSupported");
        this.__dots = new ObservedPropertyObjectPU([], this, "dots");
        this.__animOffset = new ObservedPropertySimplePU(0, this, "animOffset");
        this.castManager = DeviceCastManager.getInstance();
        this.dotId = 0;
        this.animTimer = -1;
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: Index_Params) {
        if (params.isSmallScreen !== undefined) {
            this.isSmallScreen = params.isSmallScreen;
        }
        if (params.isDistributedSupported !== undefined) {
            this.isDistributedSupported = params.isDistributedSupported;
        }
        if (params.dots !== undefined) {
            this.dots = params.dots;
        }
        if (params.animOffset !== undefined) {
            this.animOffset = params.animOffset;
        }
        if (params.castManager !== undefined) {
            this.castManager = params.castManager;
        }
        if (params.dotId !== undefined) {
            this.dotId = params.dotId;
        }
        if (params.animTimer !== undefined) {
            this.animTimer = params.animTimer;
        }
    }
    updateStateVars(params: Index_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__isSmallScreen.purgeDependencyOnElmtId(rmElmtId);
        this.__isDistributedSupported.purgeDependencyOnElmtId(rmElmtId);
        this.__dots.purgeDependencyOnElmtId(rmElmtId);
        this.__animOffset.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__isSmallScreen.aboutToBeDeleted();
        this.__isDistributedSupported.aboutToBeDeleted();
        this.__dots.aboutToBeDeleted();
        this.__animOffset.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __isSmallScreen: ObservedPropertySimplePU<boolean>;
    get isSmallScreen() {
        return this.__isSmallScreen.get();
    }
    set isSmallScreen(newValue: boolean) {
        this.__isSmallScreen.set(newValue);
    }
    private __isDistributedSupported: ObservedPropertySimplePU<boolean>;
    get isDistributedSupported() {
        return this.__isDistributedSupported.get();
    }
    set isDistributedSupported(newValue: boolean) {
        this.__isDistributedSupported.set(newValue);
    }
    private __dots: ObservedPropertyObjectPU<FloatingDot[]>;
    get dots() {
        return this.__dots.get();
    }
    set dots(newValue: FloatingDot[]) {
        this.__dots.set(newValue);
    }
    private __animOffset: ObservedPropertySimplePU<number>;
    get animOffset() {
        return this.__animOffset.get();
    }
    set animOffset(newValue: number) {
        this.__animOffset.set(newValue);
    }
    private castManager: DeviceCastManager;
    private dotId: number;
    private animTimer: number;
    aboutToAppear() {
        this.isSmallScreen = ScreenAdapter.initScreenDetection();
        ScreenAdapter.registerListener((isSmall: boolean) => {
            this.isSmallScreen = isSmall;
        });
        this.castManager.init();
        this.isDistributedSupported = this.castManager.isDistributedSupported();
        this.initDots();
        this.startAnimation();
    }
    aboutToDisappear() {
        ScreenAdapter.unregisterListener();
        if (this.animTimer !== -1) {
            clearInterval(this.animTimer);
        }
    }
    private initDots() {
        for (let i = 0; i < 15; i++) {
            this.dots.push({
                id: this.dotId++,
                x: Math.random() * 100,
                y: Math.random() * 100,
                size: 2 + Math.random() * 5,
                opacity: 0.05 + Math.random() * 0.25,
                speed: 0.05 + Math.random() * 0.15
            });
        }
    }
    private startAnimation() {
        this.animTimer = setInterval(() => {
            this.animOffset += 1;
            const updated: FloatingDot[] = [];
            for (const d of this.dots) {
                let newY = d.y - d.speed;
                if (newY < -5)
                    newY = 105;
                updated.push({
                    id: d.id,
                    x: d.x + Math.sin(this.animOffset * 0.02 + d.id) * 0.05,
                    y: newY,
                    size: d.size,
                    opacity: d.opacity,
                    speed: d.speed
                });
            }
            this.dots = updated;
        }, 50);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Stack.create();
            Stack.width('100%');
            Stack.height('100%');
            Stack.linearGradient({
                angle: 135,
                colors: [['#1a1a3e', 0.0], ['#2d1b69', 0.5], ['#764ba2', 1.0]]
            });
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.height('100%');
            Column.justifyContent(FlexAlign.Start);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('打靶训练场');
            Text.fontSize(getSizeValue(IndexPage.titleFontSize, this.isSmallScreen));
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor('#FFFFFF');
            Text.textShadow({ radius: 8, color: 'rgba(0,0,0,0.3)', offsetX: 0, offsetY: 2 });
            Text.margin({ top: getSizeValue(IndexPage.titleMarginTop, this.isSmallScreen) });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Image.create({ "id": 16777234, "type": 20000, params: [], "bundleName": "com.example.targetgame", "moduleName": "entry" });
            Image.width(getSizeValue(IndexPage.iconSize, this.isSmallScreen));
            Image.height(getSizeValue(IndexPage.iconSize, this.isSmallScreen));
            Image.margin({ top: getSizeValue(IndexPage.iconMarginTop, this.isSmallScreen) });
            Image.shadow({ radius: 20, color: 'rgba(255,255,255,0.15)', offsetX: 0, offsetY: 0 });
        }, Image);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('开始游戏');
            Button.width(getSizeValue(IndexPage.buttonWidth, this.isSmallScreen));
            Button.height(getSizeValue(IndexPage.buttonHeight, this.isSmallScreen));
            Button.fontSize(getSizeValue(IndexPage.buttonFontSize, this.isSmallScreen));
            Button.backgroundColor('#FF6B6B');
            Button.borderRadius(35);
            Button.shadow({ radius: 12, color: 'rgba(255,107,107,0.4)', offsetX: 0, offsetY: 4 });
            Button.margin({ top: getSizeValue(IndexPage.buttonMarginTop, this.isSmallScreen) });
            Button.onClick(() => {
                router.pushUrl({ url: 'pages/GamePage' });
            });
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('历史记录');
            Button.width(getSizeValue(IndexPage.buttonWidth, this.isSmallScreen));
            Button.height(getSizeValue(IndexPage.buttonHeight, this.isSmallScreen));
            Button.fontSize(getSizeValue(IndexPage.buttonFontSize, this.isSmallScreen));
            Button.backgroundColor('#4ECDC4');
            Button.borderRadius(35);
            Button.shadow({ radius: 12, color: 'rgba(78,205,196,0.4)', offsetX: 0, offsetY: 4 });
            Button.margin({ top: 20 });
            Button.onClick(() => {
                router.pushUrl({ url: 'pages/RecordPage' });
            });
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.isDistributedSupported) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('支持跨设备投送，请在游戏页面使用');
                        Text.fontSize(this.isSmallScreen ? 14 : 16);
                        Text.fontColor('rgba(255, 255, 255, 0.6)');
                        Text.margin({ top: 30 });
                    }, Text);
                    Text.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = _item => {
                const dot = _item;
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Circle.create();
                    Circle.width(dot.size);
                    Circle.height(dot.size);
                    Circle.fill(`rgba(255, 255, 255, ${dot.opacity})`);
                    Circle.position({ x: `${dot.x}%`, y: `${dot.y}%` });
                }, Circle);
            };
            this.forEachUpdateFunction(elmtId, this.dots, forEachItemGenFunction, (dot: FloatingDot) => dot.id.toString(), false, false);
        }, ForEach);
        ForEach.pop();
        Stack.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "Index";
    }
}
registerNamedRoute(() => new Index(undefined, {}), "", { bundleName: "com.example.targetgame", moduleName: "entry", pagePath: "pages/Index", pageFullPath: "entry/src/main/ets/pages/Index", integratedHsp: "false", moduleType: "followWithHap" });
