if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface RecordPage_Params {
    records?: GameRecord[];
    isSmallScreen?: boolean;
    dots?: FloatingDot[];
    animOffset?: number;
    dotId?: number;
    animTimer?: number;
}
import router from "@ohos:router";
import { getGameRecords, clearGameRecords } from "@bundle:com.example.targetgame/entry/ets/pages/GamePage";
import { ScreenAdapter } from "@bundle:com.example.targetgame/entry/ets/utils/ScreenAdapter";
import { RecordPage as RP, getSizeValue, getStringValue } from "@bundle:com.example.targetgame/entry/ets/constants/LayoutConstants";
interface GameRecord {
    score: number;
    date: string;
    hits: number;
    misses: number;
    maxCombo: number;
    avgReactionMs: number;
}
interface FloatingDot {
    id: number;
    x: number;
    y: number;
    size: number;
    opacity: number;
    speed: number;
}
class RecordPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__records = new ObservedPropertyObjectPU([], this, "records");
        this.__isSmallScreen = new ObservedPropertySimplePU(false, this, "isSmallScreen");
        this.__dots = new ObservedPropertyObjectPU([], this, "dots");
        this.__animOffset = new ObservedPropertySimplePU(0, this, "animOffset");
        this.dotId = 0;
        this.animTimer = -1;
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
        if (params.dots !== undefined) {
            this.dots = params.dots;
        }
        if (params.animOffset !== undefined) {
            this.animOffset = params.animOffset;
        }
        if (params.dotId !== undefined) {
            this.dotId = params.dotId;
        }
        if (params.animTimer !== undefined) {
            this.animTimer = params.animTimer;
        }
    }
    updateStateVars(params: RecordPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__records.purgeDependencyOnElmtId(rmElmtId);
        this.__isSmallScreen.purgeDependencyOnElmtId(rmElmtId);
        this.__dots.purgeDependencyOnElmtId(rmElmtId);
        this.__animOffset.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__records.aboutToBeDeleted();
        this.__isSmallScreen.aboutToBeDeleted();
        this.__dots.aboutToBeDeleted();
        this.__animOffset.aboutToBeDeleted();
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
    private dotId: number;
    private animTimer: number;
    aboutToAppear() {
        this.isSmallScreen = ScreenAdapter.initScreenDetection();
        ScreenAdapter.registerListener((isSmall: boolean) => {
            this.isSmallScreen = isSmall;
        });
        this.records = getGameRecords();
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
        for (let i = 0; i < 12; i++) {
            this.dots.push({
                id: this.dotId++,
                x: Math.random() * 100,
                y: Math.random() * 100,
                size: 2 + Math.random() * 4,
                opacity: 0.05 + Math.random() * 0.2,
                speed: 0.05 + Math.random() * 0.12
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
                    x: d.x + Math.sin(this.animOffset * 0.02 + d.id) * 0.03,
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
            Text.create('历史记录');
            Text.fontSize(getSizeValue(RP.titleFontSize, this.isSmallScreen));
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor('#FFFFFF');
            Text.textShadow({ radius: 8, color: 'rgba(0,0,0,0.3)', offsetX: 0, offsetY: 2 });
            Text.margin({ top: getSizeValue(RP.titleMarginTop, this.isSmallScreen) });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.records.length > 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.width('80%');
                        Column.padding(getSizeValue(RP.highScorePadding, this.isSmallScreen));
                        Column.backgroundColor('rgba(255, 215, 0, 0.15)');
                        Column.borderRadius(15);
                        Column.border({ width: 1, color: 'rgba(255, 215, 0, 0.2)' });
                        Column.margin({ top: getSizeValue(RP.highScoreMarginTop, this.isSmallScreen) });
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('最高分');
                        Text.fontSize(getSizeValue(RP.highScoreFontSize, this.isSmallScreen));
                        Text.fontColor('#FFD700');
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(`${this.records[0].score}`);
                        Text.fontSize(getSizeValue(RP.scoreFontSize, this.isSmallScreen));
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
                        List.height(getStringValue(RP.listHeight, this.isSmallScreen));
                        List.margin({ top: getSizeValue(RP.listMarginTop, this.isSmallScreen) });
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
                                        Column.create();
                                        Column.width('100%');
                                        Column.padding(getSizeValue(RP.listItemPadding, this.isSmallScreen));
                                        Column.backgroundColor('rgba(255, 255, 255, 0.06)');
                                        Column.borderRadius(12);
                                        Column.border({ width: 1, color: 'rgba(255,255,255,0.06)' });
                                        Column.margin({ bottom: 10 });
                                    }, Column);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Row.create();
                                        Row.width('100%');
                                    }, Row);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(`#${index + 1}`);
                                        Text.fontSize(getSizeValue(RP.rankFontSize, this.isSmallScreen));
                                        Text.fontColor('#FFD700');
                                        Text.fontWeight(FontWeight.Bold);
                                        Text.width(getSizeValue(RP.rankWidth, this.isSmallScreen));
                                    }, Text);
                                    Text.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(`${record.score}分`);
                                        Text.fontSize(getSizeValue(RP.scoreValueFontSize, this.isSmallScreen));
                                        Text.fontColor('#FFFFFF');
                                        Text.fontWeight(FontWeight.Bold);
                                        Text.layoutWeight(1);
                                    }, Text);
                                    Text.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(record.date);
                                        Text.fontSize(getSizeValue(RP.dateFontSize, this.isSmallScreen));
                                        Text.fontColor('rgba(255,255,255,0.4)');
                                    }, Text);
                                    Text.pop();
                                    Row.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Row.create();
                                        Row.margin({ top: 6 });
                                    }, Row);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(`命中 ${record.hits}`);
                                        Text.fontSize(this.isSmallScreen ? 11 : 13);
                                        Text.fontColor('#4ECDC4');
                                    }, Text);
                                    Text.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(`失误 ${record.misses}`);
                                        Text.fontSize(this.isSmallScreen ? 11 : 13);
                                        Text.fontColor('#FF6B6B');
                                        Text.margin({ left: 12 });
                                    }, Text);
                                    Text.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(`连击 x${record.maxCombo}`);
                                        Text.fontSize(this.isSmallScreen ? 11 : 13);
                                        Text.fontColor('#FFD700');
                                        Text.margin({ left: 12 });
                                    }, Text);
                                    Text.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(`${record.avgReactionMs}ms`);
                                        Text.fontSize(this.isSmallScreen ? 11 : 13);
                                        Text.fontColor('#667eea');
                                        Text.margin({ left: 12 });
                                    }, Text);
                                    Text.pop();
                                    Row.pop();
                                    Column.pop();
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
                        Column.height(getStringValue(RP.listHeight, this.isSmallScreen));
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('暂无游戏记录');
                        Text.fontSize(getSizeValue(RP.emptyTextFontSize, this.isSmallScreen));
                        Text.fontColor('#CCCCCC');
                        Text.margin({ top: getSizeValue(RP.emptyTextMarginTop, this.isSmallScreen) });
                    }, Text);
                    Text.pop();
                    Column.pop();
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.margin({ top: getSizeValue(RP.buttonMarginTop, this.isSmallScreen) });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('返回首页');
            Button.width(getSizeValue(RP.buttonWidth, this.isSmallScreen));
            Button.height(getSizeValue(RP.buttonHeight, this.isSmallScreen));
            Button.fontSize(getSizeValue(RP.buttonFontSize, this.isSmallScreen));
            Button.backgroundColor('#4ECDC4');
            Button.borderRadius(28);
            Button.shadow({ radius: 8, color: 'rgba(78,205,196,0.4)', offsetX: 0, offsetY: 3 });
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
                        Button.width(getSizeValue(RP.buttonWidth, this.isSmallScreen));
                        Button.height(getSizeValue(RP.buttonHeight, this.isSmallScreen));
                        Button.fontSize(getSizeValue(RP.buttonFontSize, this.isSmallScreen));
                        Button.backgroundColor('#FF6B6B');
                        Button.borderRadius(28);
                        Button.shadow({ radius: 8, color: 'rgba(255,107,107,0.4)', offsetX: 0, offsetY: 3 });
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
        return "RecordPage";
    }
}
registerNamedRoute(() => new RecordPage(undefined, {}), "", { bundleName: "com.example.targetgame", moduleName: "entry", pagePath: "pages/RecordPage", pageFullPath: "entry/src/main/ets/pages/RecordPage", integratedHsp: "false", moduleType: "followWithHap" });
