if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface RecordPage_Params {
    records?: GameRecord[];
    isSmallScreen?: boolean;
}
import router from "@ohos:router";
import { getGameRecords, clearGameRecords } from "@bundle:com.example.targetgame/entry/ets/pages/GamePage";
interface GameRecord {
    score: number;
    date: string;
}
class RecordPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__records = new ObservedPropertyObjectPU([], this, "records");
        this.__isSmallScreen = new ObservedPropertySimplePU(false, this, "isSmallScreen");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: RecordPage_Params) {
        if (params.records !== undefined) {
            this.records = params.records;
        }
        if (params.isSmallScreen !== undefined) {
            this.isSmallScreen = params.isSmallScreen;
        }
    }
    updateStateVars(params: RecordPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__records.purgeDependencyOnElmtId(rmElmtId);
        this.__isSmallScreen.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__records.aboutToBeDeleted();
        this.__isSmallScreen.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __records: ObservedPropertyObjectPU<GameRecord[]>;
    get records() {
        return this.__records.get();
    }
    set records(newValue: GameRecord[]) {
        this.__records.set(newValue);
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
        this.records = getGameRecords();
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
            Text.create('历史记录');
            Text.fontSize(this.isSmallScreen ? 28 : 36);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor('#FFFFFF');
            Text.margin({ top: this.isSmallScreen ? 40 : 60 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.records.length > 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.width('80%');
                        Column.padding(this.isSmallScreen ? 20 : 30);
                        Column.backgroundColor('rgba(255, 215, 0, 0.2)');
                        Column.borderRadius(15);
                        Column.margin({ top: this.isSmallScreen ? 20 : 30 });
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('最高分');
                        Text.fontSize(this.isSmallScreen ? 18 : 24);
                        Text.fontColor('#FFD700');
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(`${this.records[0].score}`);
                        Text.fontSize(this.isSmallScreen ? 36 : 48);
                        Text.fontColor('#FFFFFF');
                        Text.fontWeight(FontWeight.Bold);
                        Text.margin({ top: 10 });
                    }, Text);
                    Text.pop();
                    Column.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.records.length > 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        List.create();
                        List.width('90%');
                        List.height(this.isSmallScreen ? '35%' : '45%');
                        List.margin({ top: this.isSmallScreen ? 20 : 30 });
                        List.padding({ left: 10, right: 10 });
                    }, List);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        ForEach.create();
                        const forEachItemGenFunction = (_item, index: number) => {
                            const record = _item;
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
                                        Row.padding(this.isSmallScreen ? 12 : 16);
                                        Row.backgroundColor('rgba(255, 255, 255, 0.1)');
                                        Row.borderRadius(10);
                                        Row.margin({ bottom: 10 });
                                    }, Row);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(`第${index + 1}名`);
                                        Text.fontSize(this.isSmallScreen ? 16 : 20);
                                        Text.fontColor('#FFFFFF');
                                        Text.width(this.isSmallScreen ? 60 : 80);
                                    }, Text);
                                    Text.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(`${record.score}分`);
                                        Text.fontSize(this.isSmallScreen ? 18 : 24);
                                        Text.fontColor('#FFD700');
                                        Text.fontWeight(FontWeight.Bold);
                                        Text.width(this.isSmallScreen ? 80 : 100);
                                        Text.textAlign(TextAlign.Start);
                                    }, Text);
                                    Text.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(record.date);
                                        Text.fontSize(this.isSmallScreen ? 12 : 16);
                                        Text.fontColor('#CCCCCC');
                                        Text.layoutWeight(1);
                                    }, Text);
                                    Text.pop();
                                    Row.pop();
                                    ListItem.pop();
                                };
                                this.observeComponentCreation2(itemCreation2, ListItem);
                                ListItem.pop();
                            }
                        };
                        this.forEachUpdateFunction(elmtId, this.records, forEachItemGenFunction, (record: GameRecord, index: number) => index.toString(), true, true);
                    }, ForEach);
                    ForEach.pop();
                    List.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.width('90%');
                        Column.height(this.isSmallScreen ? '35%' : '45%');
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('暂无游戏记录');
                        Text.fontSize(this.isSmallScreen ? 20 : 24);
                        Text.fontColor('#CCCCCC');
                        Text.margin({ top: this.isSmallScreen ? 60 : 100 });
                    }, Text);
                    Text.pop();
                    Column.pop();
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.margin({ top: this.isSmallScreen ? 30 : 40 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('返回首页');
            Button.width(this.isSmallScreen ? 140 : 180);
            Button.height(this.isSmallScreen ? 45 : 55);
            Button.fontSize(this.isSmallScreen ? 18 : 22);
            Button.backgroundColor('#4ECDC4');
            Button.borderRadius(28);
            Button.onClick(() => {
                router.back();
            });
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.records.length > 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel('清除记录');
                        Button.width(this.isSmallScreen ? 140 : 180);
                        Button.height(this.isSmallScreen ? 45 : 55);
                        Button.fontSize(this.isSmallScreen ? 18 : 22);
                        Button.backgroundColor('#FF6B6B');
                        Button.borderRadius(28);
                        Button.margin({ left: 20 });
                        Button.onClick(() => {
                            clearGameRecords();
                            this.records = [];
                        });
                    }, Button);
                    Button.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        Row.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "RecordPage";
    }
}
registerNamedRoute(() => new RecordPage(undefined, {}), "", { bundleName: "com.example.targetgame", moduleName: "entry", pagePath: "pages/RecordPage", pageFullPath: "entry/src/main/ets/pages/RecordPage", integratedHsp: "false", moduleType: "followWithHap" });
