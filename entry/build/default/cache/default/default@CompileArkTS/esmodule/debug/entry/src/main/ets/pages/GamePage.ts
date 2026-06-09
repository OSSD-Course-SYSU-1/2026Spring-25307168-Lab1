if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface GamePage_Params {
    score?: number;
    timeLeft?: number;
    targets?: Target[];
    isGameRunning?: boolean;
    isGameOver?: boolean;
    isSmallScreen?: boolean;
    targetCount?: number;
    targetSize?: number;
    gameDuration?: number;
    isGamePreparing?: boolean;
    gameTimer?: number;
    targetTimer?: number;
    targetId?: number;
    gameAreaWidth?: number;
    gameAreaHeight?: number;
    MAX_ATTEMPTS?: number;
    PADDING?: number;
}
import router from "@ohos:router";
interface Target {
    id: number;
    x: number;
    y: number;
    radius: number;
    opacity: number;
}
interface GameRecord {
    score: number;
    date: string;
}
interface SizeOption {
    value: number;
    label: string;
}
// 全局变量存储游戏记录
let gameRecords: GameRecord[] = [];
// 靶子大小选项
let sizeOptions: SizeOption[] = [
    { value: 1, label: '小' },
    { value: 2, label: '中' },
    { value: 3, label: '大' }
];
class GamePage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__score = new ObservedPropertySimplePU(0, this, "score");
        this.__timeLeft = new ObservedPropertySimplePU(30, this, "timeLeft");
        this.__targets = new ObservedPropertyObjectPU([], this, "targets");
        this.__isGameRunning = new ObservedPropertySimplePU(false, this, "isGameRunning");
        this.__isGameOver = new ObservedPropertySimplePU(false, this, "isGameOver");
        this.__isSmallScreen = new ObservedPropertySimplePU(false, this, "isSmallScreen");
        this.__targetCount = new ObservedPropertySimplePU(1, this, "targetCount");
        this.__targetSize = new ObservedPropertySimplePU(2, this, "targetSize");
        this.__gameDuration = new ObservedPropertySimplePU(30, this, "gameDuration");
        this.__isGamePreparing = new ObservedPropertySimplePU(true, this, "isGamePreparing");
        this.gameTimer = -1;
        this.targetTimer = -1;
        this.targetId = 0;
        this.gameAreaWidth = 0;
        this.gameAreaHeight = 0;
        this.MAX_ATTEMPTS = 100;
        this.PADDING = 10;
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: GamePage_Params) {
        if (params.score !== undefined) {
            this.score = params.score;
        }
        if (params.timeLeft !== undefined) {
            this.timeLeft = params.timeLeft;
        }
        if (params.targets !== undefined) {
            this.targets = params.targets;
        }
        if (params.isGameRunning !== undefined) {
            this.isGameRunning = params.isGameRunning;
        }
        if (params.isGameOver !== undefined) {
            this.isGameOver = params.isGameOver;
        }
        if (params.isSmallScreen !== undefined) {
            this.isSmallScreen = params.isSmallScreen;
        }
        if (params.targetCount !== undefined) {
            this.targetCount = params.targetCount;
        }
        if (params.targetSize !== undefined) {
            this.targetSize = params.targetSize;
        }
        if (params.gameDuration !== undefined) {
            this.gameDuration = params.gameDuration;
        }
        if (params.isGamePreparing !== undefined) {
            this.isGamePreparing = params.isGamePreparing;
        }
        if (params.gameTimer !== undefined) {
            this.gameTimer = params.gameTimer;
        }
        if (params.targetTimer !== undefined) {
            this.targetTimer = params.targetTimer;
        }
        if (params.targetId !== undefined) {
            this.targetId = params.targetId;
        }
        if (params.gameAreaWidth !== undefined) {
            this.gameAreaWidth = params.gameAreaWidth;
        }
        if (params.gameAreaHeight !== undefined) {
            this.gameAreaHeight = params.gameAreaHeight;
        }
        if (params.MAX_ATTEMPTS !== undefined) {
            this.MAX_ATTEMPTS = params.MAX_ATTEMPTS;
        }
        if (params.PADDING !== undefined) {
            this.PADDING = params.PADDING;
        }
    }
    updateStateVars(params: GamePage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__score.purgeDependencyOnElmtId(rmElmtId);
        this.__timeLeft.purgeDependencyOnElmtId(rmElmtId);
        this.__targets.purgeDependencyOnElmtId(rmElmtId);
        this.__isGameRunning.purgeDependencyOnElmtId(rmElmtId);
        this.__isGameOver.purgeDependencyOnElmtId(rmElmtId);
        this.__isSmallScreen.purgeDependencyOnElmtId(rmElmtId);
        this.__targetCount.purgeDependencyOnElmtId(rmElmtId);
        this.__targetSize.purgeDependencyOnElmtId(rmElmtId);
        this.__gameDuration.purgeDependencyOnElmtId(rmElmtId);
        this.__isGamePreparing.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__score.aboutToBeDeleted();
        this.__timeLeft.aboutToBeDeleted();
        this.__targets.aboutToBeDeleted();
        this.__isGameRunning.aboutToBeDeleted();
        this.__isGameOver.aboutToBeDeleted();
        this.__isSmallScreen.aboutToBeDeleted();
        this.__targetCount.aboutToBeDeleted();
        this.__targetSize.aboutToBeDeleted();
        this.__gameDuration.aboutToBeDeleted();
        this.__isGamePreparing.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __score: ObservedPropertySimplePU<number>;
    get score() {
        return this.__score.get();
    }
    set score(newValue: number) {
        this.__score.set(newValue);
    }
    private __timeLeft: ObservedPropertySimplePU<number>;
    get timeLeft() {
        return this.__timeLeft.get();
    }
    set timeLeft(newValue: number) {
        this.__timeLeft.set(newValue);
    }
    private __targets: ObservedPropertyObjectPU<Target[]>;
    get targets() {
        return this.__targets.get();
    }
    set targets(newValue: Target[]) {
        this.__targets.set(newValue);
    }
    private __isGameRunning: ObservedPropertySimplePU<boolean>;
    get isGameRunning() {
        return this.__isGameRunning.get();
    }
    set isGameRunning(newValue: boolean) {
        this.__isGameRunning.set(newValue);
    }
    private __isGameOver: ObservedPropertySimplePU<boolean>;
    get isGameOver() {
        return this.__isGameOver.get();
    }
    set isGameOver(newValue: boolean) {
        this.__isGameOver.set(newValue);
    }
    private __isSmallScreen: ObservedPropertySimplePU<boolean>;
    get isSmallScreen() {
        return this.__isSmallScreen.get();
    }
    set isSmallScreen(newValue: boolean) {
        this.__isSmallScreen.set(newValue);
    }
    // 靶子数量：屏幕上同时保持的靶子数量
    private __targetCount: ObservedPropertySimplePU<number>;
    get targetCount() {
        return this.__targetCount.get();
    }
    set targetCount(newValue: number) {
        this.__targetCount.set(newValue);
    }
    // 靶子大小：1=小, 2=中, 3=大
    private __targetSize: ObservedPropertySimplePU<number>;
    get targetSize() {
        return this.__targetSize.get();
    }
    set targetSize(newValue: number) {
        this.__targetSize.set(newValue);
    }
    // 游戏时长（秒）：15, 30, 60
    private __gameDuration: ObservedPropertySimplePU<number>;
    get gameDuration() {
        return this.__gameDuration.get();
    }
    set gameDuration(newValue: number) {
        this.__gameDuration.set(newValue);
    }
    private __isGamePreparing: ObservedPropertySimplePU<boolean>;
    get isGamePreparing() {
        return this.__isGamePreparing.get();
    }
    set isGamePreparing(newValue: boolean) {
        this.__isGamePreparing.set(newValue);
    }
    private gameTimer: number;
    private targetTimer: number;
    private targetId: number;
    private gameAreaWidth: number;
    private gameAreaHeight: number;
    private readonly MAX_ATTEMPTS: number;
    private readonly PADDING: number;
    aboutToAppear() {
        this.isSmallScreen = false;
        this.isGamePreparing = true;
    }
    aboutToDisappear() {
        this.stopGame();
    }
    // 获取当前靶子半径（根据大小选择）
    getTargetRadius(): number {
        if (this.isSmallScreen) {
            if (this.targetSize === 1)
                return 20; // 小
            if (this.targetSize === 2)
                return 30; // 中
            return 40; // 大
        }
        else {
            if (this.targetSize === 1)
                return 35; // 小
            if (this.targetSize === 2)
                return 55; // 中
            return 75; // 大
        }
    }
    // 位置验证方法：检查给定位置是否有效（不超出边界且不与已存在靶子重叠）
    isPositionValid(x: number, y: number, radius: number): boolean {
        const areaWidth = this.gameAreaWidth || (this.isSmallScreen ? 300 : 500);
        const areaHeight = this.gameAreaHeight || (this.isSmallScreen ? 400 : 600);
        // 边界验证
        if (x < radius || x > areaWidth - radius) {
            return false;
        }
        if (y < radius || y > areaHeight - radius) {
            return false;
        }
        // 距离验证：检查与所有已存在靶子的距离
        for (const existingTarget of this.targets) {
            const distanceSquared = (x - existingTarget.x) ** 2 + (y - existingTarget.y) ** 2;
            const minDistanceSquared = (radius + existingTarget.radius + this.PADDING) ** 2;
            if (distanceSquared < minDistanceSquared) {
                return false;
            }
        }
        return true;
    }
    startGame() {
        this.stopGame();
        this.score = 0;
        this.timeLeft = this.gameDuration;
        this.targets = [];
        this.isGameRunning = true;
        this.isGameOver = false;
        this.isGamePreparing = false;
        this.targetId = 0;
        // 延迟生成靶子，确保游戏区域尺寸已通过onAreaChange获取
        setTimeout(() => {
            this.fillTargets();
        }, 100);
        this.gameTimer = setInterval(() => {
            this.timeLeft--;
            if (this.timeLeft <= 0) {
                this.endGame();
            }
        }, 1000);
    }
    // 补充靶子到 targetCount 个
    fillTargets() {
        const needCount = this.targetCount - this.targets.length;
        for (let i = 0; i < needCount; i++) {
            this.createOneTarget();
        }
    }
    // 创建单个靶子（固定大小，不自动消失）
    createOneTarget() {
        const radius = this.getTargetRadius();
        const areaWidth = this.gameAreaWidth || (this.isSmallScreen ? 300 : 500);
        const areaHeight = this.gameAreaHeight || (this.isSmallScreen ? 400 : 600);
        // 计算有效区域边界
        const minX = radius;
        const maxX = areaWidth - radius;
        const minY = radius;
        const maxY = areaHeight - radius;
        // 尝试-验证-重试机制：最多尝试 MAX_ATTEMPTS 次
        for (let i = 0; i < this.MAX_ATTEMPTS; i++) {
            const x = minX + Math.random() * (maxX - minX);
            const y = minY + Math.random() * (maxY - minY);
            if (this.isPositionValid(x, y, radius)) {
                const newTarget: Target = {
                    id: this.targetId++,
                    x: x,
                    y: y,
                    radius: radius,
                    opacity: 1.0
                };
                this.targets.push(newTarget);
                return;
            }
        }
        // 超过最大尝试次数，放弃生成
    }
    hitTarget(target: Target) {
        if (!this.isGameRunning)
            return;
        const baseScore = this.isSmallScreen ? 30 : 50;
        const scoreMultiplier = baseScore / target.radius;
        const points = Math.floor(10 * scoreMultiplier);
        this.score += points;
        // 移除被击中的靶子
        this.targets = this.targets.filter((t: Target) => t.id !== target.id);
        // 立即补充靶子，保持屏幕上始终有 targetCount 个
        this.fillTargets();
    }
    endGame() {
        this.isGameRunning = false;
        this.isGameOver = true;
        this.targets = [];
        this.stopGame();
        this.saveScore();
    }
    stopGame() {
        if (this.gameTimer !== -1) {
            clearInterval(this.gameTimer);
            this.gameTimer = -1;
        }
        if (this.targetTimer !== -1) {
            clearInterval(this.targetTimer);
            this.targetTimer = -1;
        }
    }
    saveScore() {
        const newRecord: GameRecord = {
            score: this.score,
            date: new Date().toLocaleString()
        };
        gameRecords.push(newRecord);
        // 按分数排序，保留前10条记录
        gameRecords.sort((a: GameRecord, b: GameRecord) => b.score - a.score);
        if (gameRecords.length > 10) {
            gameRecords = gameRecords.slice(0, 10);
        }
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Stack.create();
            Stack.width('100%');
            Stack.height('100%');
            Stack.alignContent(Alignment.Center);
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.height('100%');
            Column.linearGradient({
                angle: 135,
                colors: [['#667eea', 0.0], ['#764ba2', 1.0]]
            });
            Column.justifyContent(FlexAlign.Center);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // 准备阶段：显示靶子数量选择 + 靶子大小选择 + 开始按钮
            if (this.isGamePreparing) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.width('100%');
                        Column.height('100%');
                        Column.justifyContent(FlexAlign.Center);
                        Column.alignItems(HorizontalAlign.Center);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('打靶训练');
                        Text.fontSize(this.isSmallScreen ? 28 : 40);
                        Text.fontColor('#FFFFFF');
                        Text.fontWeight(FontWeight.Bold);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 靶子数量选择区域
                        Row.create();
                        // 靶子数量选择区域
                        Row.margin({ top: 30 });
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('靶子数量:');
                        Text.fontSize(this.isSmallScreen ? 16 : 20);
                        Text.fontColor('#FFFFFF');
                        Text.fontWeight(FontWeight.Bold);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        ForEach.create();
                        const forEachItemGenFunction = _item => {
                            const count = _item;
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                Button.createWithLabel(count.toString());
                                Button.width(this.isSmallScreen ? 36 : 48);
                                Button.height(this.isSmallScreen ? 36 : 48);
                                Button.fontSize(this.isSmallScreen ? 16 : 20);
                                Button.fontColor('#FFFFFF');
                                Button.fontWeight(FontWeight.Bold);
                                Button.backgroundColor(this.targetCount === count ? '#FF6B6B' : 'rgba(255, 255, 255, 0.3)');
                                Button.borderRadius(this.isSmallScreen ? 18 : 24);
                                Button.margin({ left: 8 });
                                Button.onClick(() => {
                                    this.targetCount = count;
                                });
                            }, Button);
                            Button.pop();
                        };
                        this.forEachUpdateFunction(elmtId, [1, 2, 3, 4, 5], forEachItemGenFunction, (count: number) => count.toString(), false, false);
                    }, ForEach);
                    ForEach.pop();
                    // 靶子数量选择区域
                    Row.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 靶子大小选择区域
                        Row.create();
                        // 靶子大小选择区域
                        Row.margin({ top: 20 });
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('靶子大小:');
                        Text.fontSize(this.isSmallScreen ? 16 : 20);
                        Text.fontColor('#FFFFFF');
                        Text.fontWeight(FontWeight.Bold);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        ForEach.create();
                        const forEachItemGenFunction = _item => {
                            const item = _item;
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                Button.createWithLabel(item.label);
                                Button.width(this.isSmallScreen ? 50 : 64);
                                Button.height(this.isSmallScreen ? 36 : 48);
                                Button.fontSize(this.isSmallScreen ? 16 : 20);
                                Button.fontColor('#FFFFFF');
                                Button.fontWeight(FontWeight.Bold);
                                Button.backgroundColor(this.targetSize === item.value ? '#FF6B6B' : 'rgba(255, 255, 255, 0.3)');
                                Button.borderRadius(this.isSmallScreen ? 18 : 24);
                                Button.margin({ left: 8 });
                                Button.onClick(() => {
                                    this.targetSize = item.value;
                                });
                            }, Button);
                            Button.pop();
                        };
                        this.forEachUpdateFunction(elmtId, sizeOptions, forEachItemGenFunction, (item: SizeOption) => item.value.toString(), false, false);
                    }, ForEach);
                    ForEach.pop();
                    // 靶子大小选择区域
                    Row.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 游戏时长选择区域
                        Row.create();
                        // 游戏时长选择区域
                        Row.margin({ top: 20 });
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('游戏时长:');
                        Text.fontSize(this.isSmallScreen ? 16 : 20);
                        Text.fontColor('#FFFFFF');
                        Text.fontWeight(FontWeight.Bold);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        ForEach.create();
                        const forEachItemGenFunction = _item => {
                            const duration = _item;
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                Button.createWithLabel(duration + 's');
                                Button.width(this.isSmallScreen ? 60 : 80);
                                Button.height(this.isSmallScreen ? 36 : 48);
                                Button.fontSize(this.isSmallScreen ? 14 : 18);
                                Button.fontColor('#FFFFFF');
                                Button.fontWeight(FontWeight.Bold);
                                Button.backgroundColor(this.gameDuration === duration ? '#FF6B6B' : 'rgba(255, 255, 255, 0.3)');
                                Button.borderRadius(this.isSmallScreen ? 18 : 24);
                                Button.margin({ left: 8 });
                                Button.onClick(() => {
                                    this.gameDuration = duration;
                                });
                            }, Button);
                            Button.pop();
                        };
                        this.forEachUpdateFunction(elmtId, [15, 30, 60], forEachItemGenFunction, (duration: number) => duration.toString(), false, false);
                    }, ForEach);
                    ForEach.pop();
                    // 游戏时长选择区域
                    Row.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel('开始游戏');
                        Button.width(this.isSmallScreen ? 200 : 280);
                        Button.height(this.isSmallScreen ? 50 : 70);
                        Button.fontSize(this.isSmallScreen ? 20 : 28);
                        Button.backgroundColor('#4ECDC4');
                        Button.borderRadius(35);
                        Button.margin({ top: 40 });
                        Button.onClick(() => {
                            this.startGame();
                        });
                    }, Button);
                    Button.pop();
                    Column.pop();
                });
            }
            // 游戏进行中：显示得分/时间 + 游戏区域
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // 游戏进行中：显示得分/时间 + 游戏区域
            if (!this.isGamePreparing && !this.isGameOver) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Row.create();
                        Row.width('90%');
                        Row.padding(this.isSmallScreen ? 10 : 20);
                        Row.backgroundColor('rgba(0, 0, 0, 0.3)');
                        Row.borderRadius(15);
                        Row.margin({ top: this.isSmallScreen ? 10 : 20 });
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(`得分: ${this.score}`);
                        Text.fontSize(this.isSmallScreen ? 20 : 28);
                        Text.fontColor('#FFFFFF');
                        Text.fontWeight(FontWeight.Bold);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Blank.create();
                    }, Blank);
                    Blank.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(`时间: ${this.timeLeft}s`);
                        Text.fontSize(this.isSmallScreen ? 20 : 28);
                        Text.fontColor('#FFFFFF');
                        Text.fontWeight(FontWeight.Bold);
                    }, Text);
                    Text.pop();
                    Row.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Stack.create();
                        Stack.width('90%');
                        Stack.height(this.isSmallScreen ? '55%' : '65%');
                        Stack.margin({ top: this.isSmallScreen ? 10 : 20 });
                        Stack.onAreaChange((oldValue: Area, newValue: Area) => {
                            this.gameAreaWidth = newValue.width as number;
                            this.gameAreaHeight = newValue.height as number;
                        });
                    }, Stack);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.width('100%');
                        Column.height('100%');
                        Column.backgroundColor('rgba(255, 255, 255, 0.1)');
                        Column.borderRadius(20);
                    }, Column);
                    Column.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        ForEach.create();
                        const forEachItemGenFunction = _item => {
                            const target = _item;
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                // 纯白统一圆形靶子
                                Circle.create();
                                // 纯白统一圆形靶子
                                Circle.width(target.radius * 2);
                                // 纯白统一圆形靶子
                                Circle.height(target.radius * 2);
                                // 纯白统一圆形靶子
                                Circle.fill('#FFFFFF');
                                // 纯白统一圆形靶子
                                Circle.position({ x: target.x - target.radius, y: target.y - target.radius });
                                // 纯白统一圆形靶子
                                Circle.opacity(target.opacity);
                                // 纯白统一圆形靶子
                                Circle.onClick(() => {
                                    this.hitTarget(target);
                                });
                            }, Circle);
                        };
                        this.forEachUpdateFunction(elmtId, this.targets, forEachItemGenFunction, (target: Target) => target.id.toString(), false, false);
                    }, ForEach);
                    ForEach.pop();
                    Stack.pop();
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
            If.create();
            // 游戏结束面板 — 使用Stack叠加在屏幕中央
            if (this.isGameOver) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.width(this.isSmallScreen ? '70%' : '60%');
                        Column.padding(this.isSmallScreen ? 30 : 40);
                        Column.backgroundColor('rgba(0, 0, 0, 0.85)');
                        Column.borderRadius(20);
                        Column.alignItems(HorizontalAlign.Center);
                        Column.justifyContent(FlexAlign.Center);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('游戏结束!');
                        Text.fontSize(this.isSmallScreen ? 28 : 36);
                        Text.fontColor('#FFFFFF');
                        Text.fontWeight(FontWeight.Bold);
                        Text.width('100%');
                        Text.textAlign(TextAlign.Center);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(`最终得分: ${this.score}`);
                        Text.fontSize(this.isSmallScreen ? 24 : 32);
                        Text.fontColor('#FFD700');
                        Text.fontWeight(FontWeight.Bold);
                        Text.width('100%');
                        Text.textAlign(TextAlign.Center);
                        Text.margin({ top: 20 });
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.margin({ top: 30 });
                        Column.alignItems(HorizontalAlign.Center);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel('再来一局');
                        Button.width(this.isSmallScreen ? 200 : 260);
                        Button.height(this.isSmallScreen ? 44 : 56);
                        Button.fontSize(this.isSmallScreen ? 18 : 22);
                        Button.backgroundColor('#4ECDC4');
                        Button.borderRadius(28);
                        Button.onClick(() => {
                            this.stopGame();
                            this.isGameOver = false;
                            this.isGameRunning = false;
                            this.isGamePreparing = true;
                        });
                    }, Button);
                    Button.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel('返回首页');
                        Button.width(this.isSmallScreen ? 200 : 260);
                        Button.height(this.isSmallScreen ? 44 : 56);
                        Button.fontSize(this.isSmallScreen ? 18 : 22);
                        Button.backgroundColor('#FF6B6B');
                        Button.borderRadius(28);
                        Button.margin({ top: 15 });
                        Button.onClick(() => {
                            router.back();
                        });
                    }, Button);
                    Button.pop();
                    Column.pop();
                    Column.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        Stack.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "GamePage";
    }
}
// 导出获取记录的函数
export function getGameRecords(): GameRecord[] {
    return gameRecords;
}
// 导出清除记录的函数
export function clearGameRecords(): void {
    gameRecords = [];
}
registerNamedRoute(() => new GamePage(undefined, {}), "", { bundleName: "com.example.targetgame", moduleName: "entry", pagePath: "pages/GamePage", pageFullPath: "entry/src/main/ets/pages/GamePage", integratedHsp: "false", moduleType: "followWithHap" });
