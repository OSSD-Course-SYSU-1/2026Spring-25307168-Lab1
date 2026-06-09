if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface Index_Params {
    isSmallScreen?: boolean;
}
import router from "@ohos:router";
class Index extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__isSmallScreen = new ObservedPropertySimplePU(false, this, "isSmallScreen");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: Index_Params) {
        if (params.isSmallScreen !== undefined) {
            this.isSmallScreen = params.isSmallScreen;
        }
    }
    updateStateVars(params: Index_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__isSmallScreen.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__isSmallScreen.aboutToBeDeleted();
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
    aboutToAppear() {
        this.isSmallScreen = false;
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.height('100%');
            Column.linearGradient({
                angle: 135,
                colors: [['#667eea', 0.0], ['#764ba2', 1.0]]
            });
            Column.justifyContent(FlexAlign.Start);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('打靶训练场');
            Text.fontSize(this.isSmallScreen ? 32 : 48);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor('#FFFFFF');
            Text.margin({ top: this.isSmallScreen ? 60 : 100 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Image.create({ "id": 16777225, "type": 20000, params: [], "bundleName": "com.example.targetgame", "moduleName": "entry" });
            Image.width(this.isSmallScreen ? 120 : 180);
            Image.height(this.isSmallScreen ? 120 : 180);
            Image.margin({ top: this.isSmallScreen ? 40 : 60 });
        }, Image);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('开始游戏');
            Button.width(this.isSmallScreen ? 200 : 280);
            Button.height(this.isSmallScreen ? 50 : 70);
            Button.fontSize(this.isSmallScreen ? 20 : 28);
            Button.backgroundColor('#FF6B6B');
            Button.borderRadius(35);
            Button.margin({ top: this.isSmallScreen ? 60 : 80 });
            Button.onClick(() => {
                router.pushUrl({ url: 'pages/GamePage' });
            });
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('历史记录');
            Button.width(this.isSmallScreen ? 200 : 280);
            Button.height(this.isSmallScreen ? 50 : 70);
            Button.fontSize(this.isSmallScreen ? 20 : 28);
            Button.backgroundColor('#4ECDC4');
            Button.borderRadius(35);
            Button.margin({ top: 20 });
            Button.onClick(() => {
                router.pushUrl({ url: 'pages/RecordPage' });
            });
        }, Button);
        Button.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "Index";
    }
}
registerNamedRoute(() => new Index(undefined, {}), "", { bundleName: "com.example.targetgame", moduleName: "entry", pagePath: "pages/Index", pageFullPath: "entry/src/main/ets/pages/Index", integratedHsp: "false", moduleType: "followWithHap" });
