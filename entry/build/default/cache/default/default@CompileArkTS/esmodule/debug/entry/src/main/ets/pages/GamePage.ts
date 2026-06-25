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
    connectionState?: CastConnectionState;
    targetDeviceName?: string;
    discoveredDevices?: DeviceInfo[];
    isDiscovering?: boolean;
    isDistributedSupported?: boolean;
    hitCount?: number;
    missCount?: number;
    combo?: number;
    maxCombo?: number;
    lastHitTime?: number;
    totalReactionMs?: number;
    dots?: FloatingDot[];
    animOffset?: number;
    gameTimer?: number;
    targetTimer?: number;
    targetId?: number;
    gameAreaWidth?: number;
    gameAreaHeight?: number;
    MAX_ATTEMPTS?: number;
    PADDING?: number;
    gameStartTime?: number;
    castManager?: DeviceCastManager;
    distributedData?: DistributedGameData;
    dotId?: number;
    bgAnimTimer?: number;
    deviceSelectDialogController?: CustomDialogController;
}
import router from "@ohos:router";
import { ScreenAdapter } from "@bundle:com.example.targetgame/entry/ets/utils/ScreenAdapter";
import { GamePage as GP, CastUI, getSizeValue, getStringValue } from "@bundle:com.example.targetgame/entry/ets/constants/LayoutConstants";
import { DeviceCastManager, CastConnectionState } from "@bundle:com.example.targetgame/entry/ets/cast/DeviceCastManager";
import type { DeviceInfo } from "@bundle:com.example.targetgame/entry/ets/cast/DeviceCastManager";
import { DistributedGameData } from "@bundle:com.example.targetgame/entry/ets/cast/DistributedGameData";
import type { SyncableGameState, ControlEvent } from "@bundle:com.example.targetgame/entry/ets/cast/DistributedGameData";
import { DeviceSelectPanel } from "@bundle:com.example.targetgame/entry/ets/cast/DeviceSelectPanel";
import { CastStatusBar } from "@bundle:com.example.targetgame/entry/ets/cast/CastStatusBar";
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
    hits: number;
    misses: number;
    maxCombo: number;
    avgReactionMs: number;
}
interface SizeOption {
    value: number;
    label: string;
}
interface FloatingDot {
    id: number;
    x: number;
    y: number;
    size: number;
    opacity: number;
    speed: number;
}
let gameRecords: GameRecord[] = [];
let countOptions: number[] = [1, 2, 3, 4, 5];
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
        this.__connectionState = new ObservedPropertySimplePU(CastConnectionState.DISCONNECTED, this, "connectionState");
        this.__targetDeviceName = new ObservedPropertySimplePU('', this, "targetDeviceName");
        this.__discoveredDevices = new ObservedPropertyObjectPU([], this, "discoveredDevices");
        this.__isDiscovering = new ObservedPropertySimplePU(false, this, "isDiscovering");
        this.__isDistributedSupported = new ObservedPropertySimplePU(false, this, "isDistributedSupported");
        this.__hitCount = new ObservedPropertySimplePU(0, this, "hitCount");
        this.__missCount = new ObservedPropertySimplePU(0, this, "missCount");
        this.__combo = new ObservedPropertySimplePU(0, this, "combo");
        this.__maxCombo = new ObservedPropertySimplePU(0, this, "maxCombo");
        this.__lastHitTime = new ObservedPropertySimplePU(0, this, "lastHitTime");
        this.__totalReactionMs = new ObservedPropertySimplePU(0, this, "totalReactionMs");
        this.__dots = new ObservedPropertyObjectPU([], this, "dots");
        this.__animOffset = new ObservedPropertySimplePU(0, this, "animOffset");
        this.gameTimer = -1;
        this.targetTimer = -1;
        this.targetId = 0;
        this.gameAreaWidth = 0;
        this.gameAreaHeight = 0;
        this.MAX_ATTEMPTS = 100;
        this.PADDING = 10;
        this.gameStartTime = 0;
        this.castManager = DeviceCastManager.getInstance();
        this.distributedData = new DistributedGameData();
        this.dotId = 0;
        this.bgAnimTimer = -1;
        this.deviceSelectDialogController = new CustomDialogController({
            builder: () => {
                let jsDialog = new DeviceSelectPanel(this, {
                    devices: this.discoveredDevices,
                    connectionState: this.connectionState,
                    isDiscovering: this.isDiscovering,
                    isSmallScreen: this.isSmallScreen,
                    onDeviceSelect: (deviceId: string) => {
                        this.onDeviceSelected(deviceId);
                    },
                    onClose: () => {
                        this.castManager.stopDeviceDiscovery();
                        this.isDiscovering = false;
                    },
                    onRetry: () => {
                        this.startDeviceDiscovery();
                    }
                }, undefined, -1, () => { }, { page: "entry/src/main/ets/pages/GamePage.ets", line: 92, col: 14 });
                jsDialog.setController(this.deviceSelectDialogController);
                ViewPU.create(jsDialog);
                let paramsLambda = () => {
                    return {
                        devices: this.discoveredDevices,
                        connectionState: this.connectionState,
                        isDiscovering: this.isDiscovering,
                        isSmallScreen: this.isSmallScreen,
                        onDeviceSelect: (deviceId: string) => {
                            this.onDeviceSelected(deviceId);
                        },
                        onClose: () => {
                            this.castManager.stopDeviceDiscovery();
                            this.isDiscovering = false;
                        },
                        onRetry: () => {
                            this.startDeviceDiscovery();
                        }
                    };
                };
                jsDialog.paramsGenerator_ = paramsLambda;
            },
            autoCancel: true
        }, this);
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
        if (params.connectionState !== undefined) {
            this.connectionState = params.connectionState;
        }
        if (params.targetDeviceName !== undefined) {
            this.targetDeviceName = params.targetDeviceName;
        }
        if (params.discoveredDevices !== undefined) {
            this.discoveredDevices = params.discoveredDevices;
        }
        if (params.isDiscovering !== undefined) {
            this.isDiscovering = params.isDiscovering;
        }
        if (params.isDistributedSupported !== undefined) {
            this.isDistributedSupported = params.isDistributedSupported;
        }
        if (params.hitCount !== undefined) {
            this.hitCount = params.hitCount;
        }
        if (params.missCount !== undefined) {
            this.missCount = params.missCount;
        }
        if (params.combo !== undefined) {
            this.combo = params.combo;
        }
        if (params.maxCombo !== undefined) {
            this.maxCombo = params.maxCombo;
        }
        if (params.lastHitTime !== undefined) {
            this.lastHitTime = params.lastHitTime;
        }
        if (params.totalReactionMs !== undefined) {
            this.totalReactionMs = params.totalReactionMs;
        }
        if (params.dots !== undefined) {
            this.dots = params.dots;
        }
        if (params.animOffset !== undefined) {
            this.animOffset = params.animOffset;
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
        if (params.gameStartTime !== undefined) {
            this.gameStartTime = params.gameStartTime;
        }
        if (params.castManager !== undefined) {
            this.castManager = params.castManager;
        }
        if (params.distributedData !== undefined) {
            this.distributedData = params.distributedData;
        }
        if (params.dotId !== undefined) {
            this.dotId = params.dotId;
        }
        if (params.bgAnimTimer !== undefined) {
            this.bgAnimTimer = params.bgAnimTimer;
        }
        if (params.deviceSelectDialogController !== undefined) {
            this.deviceSelectDialogController = params.deviceSelectDialogController;
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
        this.__connectionState.purgeDependencyOnElmtId(rmElmtId);
        this.__targetDeviceName.purgeDependencyOnElmtId(rmElmtId);
        this.__discoveredDevices.purgeDependencyOnElmtId(rmElmtId);
        this.__isDiscovering.purgeDependencyOnElmtId(rmElmtId);
        this.__isDistributedSupported.purgeDependencyOnElmtId(rmElmtId);
        this.__hitCount.purgeDependencyOnElmtId(rmElmtId);
        this.__missCount.purgeDependencyOnElmtId(rmElmtId);
        this.__combo.purgeDependencyOnElmtId(rmElmtId);
        this.__maxCombo.purgeDependencyOnElmtId(rmElmtId);
        this.__lastHitTime.purgeDependencyOnElmtId(rmElmtId);
        this.__totalReactionMs.purgeDependencyOnElmtId(rmElmtId);
        this.__dots.purgeDependencyOnElmtId(rmElmtId);
        this.__animOffset.purgeDependencyOnElmtId(rmElmtId);
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
        this.__connectionState.aboutToBeDeleted();
        this.__targetDeviceName.aboutToBeDeleted();
        this.__discoveredDevices.aboutToBeDeleted();
        this.__isDiscovering.aboutToBeDeleted();
        this.__isDistributedSupported.aboutToBeDeleted();
        this.__hitCount.aboutToBeDeleted();
        this.__missCount.aboutToBeDeleted();
        this.__combo.aboutToBeDeleted();
        this.__maxCombo.aboutToBeDeleted();
        this.__lastHitTime.aboutToBeDeleted();
        this.__totalReactionMs.aboutToBeDeleted();
        this.__dots.aboutToBeDeleted();
        this.__animOffset.aboutToBeDeleted();
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
    private __targetCount: ObservedPropertySimplePU<number>;
    get targetCount() {
        return this.__targetCount.get();
    }
    set targetCount(newValue: number) {
        this.__targetCount.set(newValue);
    }
    private __targetSize: ObservedPropertySimplePU<number>;
    get targetSize() {
        return this.__targetSize.get();
    }
    set targetSize(newValue: number) {
        this.__targetSize.set(newValue);
    }
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
    private __connectionState: ObservedPropertySimplePU<CastConnectionState>;
    get connectionState() {
        return this.__connectionState.get();
    }
    set connectionState(newValue: CastConnectionState) {
        this.__connectionState.set(newValue);
    }
    private __targetDeviceName: ObservedPropertySimplePU<string>;
    get targetDeviceName() {
        return this.__targetDeviceName.get();
    }
    set targetDeviceName(newValue: string) {
        this.__targetDeviceName.set(newValue);
    }
    private __discoveredDevices: ObservedPropertyObjectPU<DeviceInfo[]>;
    get discoveredDevices() {
        return this.__discoveredDevices.get();
    }
    set discoveredDevices(newValue: DeviceInfo[]) {
        this.__discoveredDevices.set(newValue);
    }
    private __isDiscovering: ObservedPropertySimplePU<boolean>;
    get isDiscovering() {
        return this.__isDiscovering.get();
    }
    set isDiscovering(newValue: boolean) {
        this.__isDiscovering.set(newValue);
    }
    private __isDistributedSupported: ObservedPropertySimplePU<boolean>;
    get isDistributedSupported() {
        return this.__isDistributedSupported.get();
    }
    set isDistributedSupported(newValue: boolean) {
        this.__isDistributedSupported.set(newValue);
    }
    private __hitCount: ObservedPropertySimplePU<number>;
    get hitCount() {
        return this.__hitCount.get();
    }
    set hitCount(newValue: number) {
        this.__hitCount.set(newValue);
    }
    private __missCount: ObservedPropertySimplePU<number>;
    get missCount() {
        return this.__missCount.get();
    }
    set missCount(newValue: number) {
        this.__missCount.set(newValue);
    }
    private __combo: ObservedPropertySimplePU<number>;
    get combo() {
        return this.__combo.get();
    }
    set combo(newValue: number) {
        this.__combo.set(newValue);
    }
    private __maxCombo: ObservedPropertySimplePU<number>;
    get maxCombo() {
        return this.__maxCombo.get();
    }
    set maxCombo(newValue: number) {
        this.__maxCombo.set(newValue);
    }
    private __lastHitTime: ObservedPropertySimplePU<number>;
    get lastHitTime() {
        return this.__lastHitTime.get();
    }
    set lastHitTime(newValue: number) {
        this.__lastHitTime.set(newValue);
    }
    private __totalReactionMs: ObservedPropertySimplePU<number>;
    get totalReactionMs() {
        return this.__totalReactionMs.get();
    }
    set totalReactionMs(newValue: number) {
        this.__totalReactionMs.set(newValue);
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
    private gameTimer: number;
    private targetTimer: number;
    private targetId: number;
    private gameAreaWidth: number;
    private gameAreaHeight: number;
    private readonly MAX_ATTEMPTS: number;
    private readonly PADDING: number;
    private gameStartTime: number;
    private castManager: DeviceCastManager;
    private distributedData: DistributedGameData;
    private dotId: number;
    private bgAnimTimer: number;
    private deviceSelectDialogController: CustomDialogController;
    aboutToAppear() {
        this.isSmallScreen = ScreenAdapter.initScreenDetection();
        ScreenAdapter.registerListener((isSmall: boolean) => {
            this.isSmallScreen = isSmall;
        });
        this.isGamePreparing = true;
        this.initCast();
        this.initDots();
        this.startBgAnimation();
    }
    aboutToDisappear() {
        ScreenAdapter.unregisterListener();
        this.stopGame();
        this.distributedData.destroy();
        if (this.bgAnimTimer !== -1) {
            clearInterval(this.bgAnimTimer);
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
    private startBgAnimation() {
        this.bgAnimTimer = setInterval(() => {
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
    private initCast(): void {
        this.castManager.init();
        this.isDistributedSupported = this.castManager.isDistributedSupported();
        this.castManager.setOnConnectionStateChange((state: CastConnectionState) => {
            this.connectionState = state;
            if (state === CastConnectionState.CONNECTED) {
                this.targetDeviceName = this.castManager.getConnectedDeviceName();
                const sessionId = 'targetgame_' + Date.now();
                this.distributedData.createDistributedObject(sessionId);
                this.distributedData.onRemoteControl((event: ControlEvent) => {
                    this.handleRemoteControl(event);
                });
            }
            else if (state === CastConnectionState.DISCONNECTED) {
                this.targetDeviceName = '';
                this.distributedData.destroy();
            }
        });
        this.castManager.setOnDeviceListChange((devices: DeviceInfo[]) => {
            this.discoveredDevices = devices;
        });
    }
    private startDeviceDiscovery(): void {
        this.isDiscovering = true;
        this.discoveredDevices = [];
        this.castManager.startDeviceDiscovery();
        setTimeout(() => {
            this.isDiscovering = false;
        }, 5000);
    }
    private async onDeviceSelected(deviceId: string): Promise<void> {
        const success = await this.castManager.connectDevice(deviceId);
        if (success) {
            this.deviceSelectDialogController.close();
            this.castManager.stopDeviceDiscovery();
            this.isDiscovering = false;
        }
    }
    private disconnectCast(): void {
        this.castManager.disconnectDevice();
    }
    private syncGameStateToRemote(): void {
        if (this.connectionState !== CastConnectionState.CONNECTED) {
            return;
        }
        const state: SyncableGameState = {
            score: this.score,
            timeLeft: this.timeLeft,
            targetsJson: JSON.stringify(this.targets),
            isGameRunning: this.isGameRunning,
            isGameOver: this.isGameOver,
            isGamePreparing: this.isGamePreparing,
            targetCount: this.targetCount,
            targetSize: this.targetSize,
            gameDuration: this.gameDuration
        };
        this.distributedData.syncGameState(state);
    }
    private handleRemoteControl(event: ControlEvent): void {
        if (event.type === 'hit') {
            const target = this.targets.find(t => t.id === event.targetId);
            if (target) {
                this.hitTarget(target);
            }
        }
    }
    getTargetRadius(): number {
        if (this.targetSize === 1) {
            return getSizeValue(GP.targetRadiusSmall, this.isSmallScreen);
        }
        if (this.targetSize === 2) {
            return getSizeValue(GP.targetRadiusMedium, this.isSmallScreen);
        }
        return getSizeValue(GP.targetRadiusLarge, this.isSmallScreen);
    }
    isPositionValid(x: number, y: number, radius: number): boolean {
        const areaWidth = this.gameAreaWidth || getSizeValue(GP.defaultAreaWidth, this.isSmallScreen);
        const areaHeight = this.gameAreaHeight || getSizeValue(GP.defaultAreaHeight, this.isSmallScreen);
        if (x < radius || x > areaWidth - radius) {
            return false;
        }
        if (y < radius || y > areaHeight - radius) {
            return false;
        }
        for (const existingTarget of this.targets) {
            const distanceSquared = (x - existingTarget.x) ** 2 + (y - existingTarget.y) ** 2;
            const minDistanceSquared = (radius + existingTarget.radius + this.PADDING) ** 2;
            if (distanceSquared < minDistanceSquared) {
                return false;
            }
        }
        return true;
    }
    getAccuracy(): number {
        const total = this.hitCount + this.missCount;
        if (total === 0)
            return 0;
        return Math.round((this.hitCount / total) * 100);
    }
    getAvgReactionMs(): number {
        if (this.hitCount === 0)
            return 0;
        return Math.round(this.totalReactionMs / this.hitCount);
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
        this.hitCount = 0;
        this.missCount = 0;
        this.combo = 0;
        this.maxCombo = 0;
        this.lastHitTime = 0;
        this.totalReactionMs = 0;
        this.gameStartTime = Date.now();
        setTimeout(() => {
            this.fillTargets();
        }, 100);
        this.gameTimer = setInterval(() => {
            this.timeLeft--;
            if (this.timeLeft <= 0) {
                this.endGame();
            }
            this.syncGameStateToRemote();
        }, 1000);
    }
    fillTargets() {
        const needCount = this.targetCount - this.targets.length;
        for (let i = 0; i < needCount; i++) {
            this.createOneTarget();
        }
    }
    createOneTarget() {
        const radius = this.getTargetRadius();
        const areaWidth = this.gameAreaWidth || getSizeValue(GP.defaultAreaWidth, this.isSmallScreen);
        const areaHeight = this.gameAreaHeight || getSizeValue(GP.defaultAreaHeight, this.isSmallScreen);
        const minX = radius;
        const maxX = areaWidth - radius;
        const minY = radius;
        const maxY = areaHeight - radius;
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
    }
    hitTarget(target: Target) {
        if (!this.isGameRunning)
            return;
        const now = Date.now();
        if (this.lastHitTime > 0) {
            this.totalReactionMs += (now - this.lastHitTime);
        }
        this.lastHitTime = now;
        const baseScore = getSizeValue(GP.baseScore, this.isSmallScreen);
        const scoreMultiplier = baseScore / target.radius;
        const points = Math.floor(10 * scoreMultiplier);
        this.combo++;
        if (this.combo > this.maxCombo) {
            this.maxCombo = this.combo;
        }
        const comboBonus = this.combo > 1 ? Math.floor(points * (this.combo - 1) * 0.1) : 0;
        this.score += points + comboBonus;
        this.hitCount++;
        this.targets = this.targets.filter((t: Target) => t.id !== target.id);
        this.fillTargets();
        this.syncGameStateToRemote();
    }
    onMissClick() {
        if (!this.isGameRunning)
            return;
        this.missCount++;
        this.combo = 0;
    }
    endGame() {
        this.isGameRunning = false;
        this.isGameOver = true;
        this.targets = [];
        this.stopGame();
        this.saveScore();
        this.syncGameStateToRemote();
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
            date: new Date().toLocaleString(),
            hits: this.hitCount,
            misses: this.missCount,
            maxCombo: this.maxCombo,
            avgReactionMs: this.getAvgReactionMs()
        };
        gameRecords.push(newRecord);
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
                colors: [['#1a1a3e', 0.0], ['#2d1b69', 0.5], ['#764ba2', 1.0]]
            });
            Column.justifyContent(FlexAlign.Center);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            __Common__.create();
            __Common__.margin({ top: 5 });
        }, __Common__);
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new CastStatusBar(this, {
                        connectionState: this.connectionState,
                        targetDeviceName: this.targetDeviceName,
                        isSmallScreen: this.isSmallScreen,
                        onDisconnect: () => {
                            this.disconnectCast();
                        }
                    }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/GamePage.ets", line: 410, col: 9 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            connectionState: this.connectionState,
                            targetDeviceName: this.targetDeviceName,
                            isSmallScreen: this.isSmallScreen,
                            onDisconnect: () => {
                                this.disconnectCast();
                            }
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        connectionState: this.connectionState,
                        targetDeviceName: this.targetDeviceName,
                        isSmallScreen: this.isSmallScreen
                    });
                }
            }, { name: "CastStatusBar" });
        }
        __Common__.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
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
                        Text.fontSize(getSizeValue(GP.titleFontSize, this.isSmallScreen));
                        Text.fontColor('#FFFFFF');
                        Text.fontWeight(FontWeight.Bold);
                        Text.textShadow({ radius: 8, color: 'rgba(0,0,0,0.3)', offsetX: 0, offsetY: 2 });
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Row.create();
                        Row.margin({ top: 30 });
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('靶子数量:');
                        Text.fontSize(getSizeValue(GP.labelFontSize, this.isSmallScreen));
                        Text.fontColor('#FFFFFF');
                        Text.fontWeight(FontWeight.Bold);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        ForEach.create();
                        const forEachItemGenFunction = _item => {
                            const count = _item;
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                Button.createWithLabel(count.toString(), { type: ButtonType.Normal });
                                Button.width(getSizeValue(GP.countButtonSize, this.isSmallScreen));
                                Button.height(getSizeValue(GP.countButtonSize, this.isSmallScreen));
                                Button.fontSize(getSizeValue(GP.countButtonFontSize, this.isSmallScreen));
                                Button.fontColor('#FFFFFF');
                                Button.fontWeight(FontWeight.Bold);
                                Button.backgroundColor(this.targetCount === count ? '#FF6B6B' : 'rgba(255, 255, 255, 0.2)');
                                Button.borderRadius(getSizeValue(GP.countButtonBorderRadius, this.isSmallScreen));
                                Button.padding(0);
                                Button.margin({ left: 8 });
                                Button.onClick(() => {
                                    this.targetCount = count;
                                });
                            }, Button);
                            Button.pop();
                        };
                        this.forEachUpdateFunction(elmtId, countOptions, forEachItemGenFunction, (count: number) => count.toString(), false, false);
                    }, ForEach);
                    ForEach.pop();
                    Row.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Row.create();
                        Row.margin({ top: 20 });
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('靶子大小:');
                        Text.fontSize(getSizeValue(GP.labelFontSize, this.isSmallScreen));
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
                                Button.width(getSizeValue(GP.sizeButtonWidth, this.isSmallScreen));
                                Button.height(getSizeValue(GP.sizeButtonHeight, this.isSmallScreen));
                                Button.fontSize(getSizeValue(GP.sizeButtonFontSize, this.isSmallScreen));
                                Button.fontColor('#FFFFFF');
                                Button.fontWeight(FontWeight.Bold);
                                Button.backgroundColor(this.targetSize === item.value ? '#FF6B6B' : 'rgba(255, 255, 255, 0.2)');
                                Button.borderRadius(getSizeValue(GP.sizeButtonBorderRadius, this.isSmallScreen));
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
                    Row.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Row.create();
                        Row.margin({ top: 20 });
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('游戏时长:');
                        Text.fontSize(getSizeValue(GP.labelFontSize, this.isSmallScreen));
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
                                Button.width(getSizeValue(GP.durationButtonWidth, this.isSmallScreen));
                                Button.height(getSizeValue(GP.durationButtonHeight, this.isSmallScreen));
                                Button.fontSize(getSizeValue(GP.durationButtonFontSize, this.isSmallScreen));
                                Button.fontColor('#FFFFFF');
                                Button.fontWeight(FontWeight.Bold);
                                Button.backgroundColor(this.gameDuration === duration ? '#FF6B6B' : 'rgba(255, 255, 255, 0.2)');
                                Button.borderRadius(getSizeValue(GP.durationButtonBorderRadius, this.isSmallScreen));
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
                    Row.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel('开始游戏');
                        Button.width(getSizeValue(GP.startButtonWidth, this.isSmallScreen));
                        Button.height(getSizeValue(GP.startButtonHeight, this.isSmallScreen));
                        Button.fontSize(getSizeValue(GP.startButtonFontSize, this.isSmallScreen));
                        Button.backgroundColor('#4ECDC4');
                        Button.borderRadius(35);
                        Button.shadow({ radius: 12, color: 'rgba(78,205,196,0.4)', offsetX: 0, offsetY: 4 });
                        Button.margin({ top: 40 });
                        Button.onClick(() => {
                            this.startGame();
                        });
                    }, Button);
                    Button.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        If.create();
                        if (this.isDistributedSupported) {
                            this.ifElseBranchUpdateFunction(0, () => {
                                this.observeComponentCreation2((elmtId, isInitialRender) => {
                                    Button.createWithLabel('跨设备投送');
                                    Button.width(getSizeValue(CastUI.castButtonWidth, this.isSmallScreen));
                                    Button.height(getSizeValue(CastUI.castButtonHeight, this.isSmallScreen));
                                    Button.fontSize(getSizeValue(CastUI.castButtonFontSize, this.isSmallScreen));
                                    Button.backgroundColor('#667eea');
                                    Button.borderRadius(35);
                                    Button.margin({ top: 20 });
                                    Button.onClick(() => {
                                        this.startDeviceDiscovery();
                                        this.deviceSelectDialogController.open();
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
            if (!this.isGamePreparing && !this.isGameOver) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.width('100%');
                        Column.alignItems(HorizontalAlign.Center);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Row.create();
                        Row.width('92%');
                        Row.padding({ left: 16, right: 16, top: 12, bottom: 12 });
                        Row.backgroundColor('rgba(0, 0, 0, 0.4)');
                        Row.borderRadius(16);
                        Row.margin({ top: getSizeValue(GP.scoreMarginTop, this.isSmallScreen) });
                        Row.alignItems(VerticalAlign.Center);
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.alignItems(HorizontalAlign.Center);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(`${this.score}`);
                        Text.fontSize(this.isSmallScreen ? 28 : 36);
                        Text.fontColor('#FFD700');
                        Text.fontWeight(FontWeight.Bold);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('得分');
                        Text.fontSize(this.isSmallScreen ? 11 : 13);
                        Text.fontColor('rgba(255,255,255,0.6)');
                    }, Text);
                    Text.pop();
                    Column.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Blank.create();
                    }, Blank);
                    Blank.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.alignItems(HorizontalAlign.Center);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(`${this.timeLeft}s`);
                        Text.fontSize(this.isSmallScreen ? 28 : 36);
                        Text.fontColor(this.timeLeft <= 5 ? '#FF6B6B' : '#FFFFFF');
                        Text.fontWeight(FontWeight.Bold);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('剩余时间');
                        Text.fontSize(this.isSmallScreen ? 11 : 13);
                        Text.fontColor('rgba(255,255,255,0.6)');
                    }, Text);
                    Text.pop();
                    Column.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Blank.create();
                    }, Blank);
                    Blank.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.alignItems(HorizontalAlign.Center);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(`${this.getAccuracy()}%`);
                        Text.fontSize(this.isSmallScreen ? 22 : 28);
                        Text.fontColor('#4ECDC4');
                        Text.fontWeight(FontWeight.Bold);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('命中率');
                        Text.fontSize(this.isSmallScreen ? 11 : 13);
                        Text.fontColor('rgba(255,255,255,0.6)');
                    }, Text);
                    Text.pop();
                    Column.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        If.create();
                        if (this.combo > 1) {
                            this.ifElseBranchUpdateFunction(0, () => {
                                this.observeComponentCreation2((elmtId, isInitialRender) => {
                                    Blank.create();
                                }, Blank);
                                Blank.pop();
                                this.observeComponentCreation2((elmtId, isInitialRender) => {
                                    Column.create();
                                    Column.alignItems(HorizontalAlign.Center);
                                }, Column);
                                this.observeComponentCreation2((elmtId, isInitialRender) => {
                                    Text.create(`x${this.combo}`);
                                    Text.fontSize(this.isSmallScreen ? 22 : 28);
                                    Text.fontColor('#FF6B6B');
                                    Text.fontWeight(FontWeight.Bold);
                                }, Text);
                                Text.pop();
                                this.observeComponentCreation2((elmtId, isInitialRender) => {
                                    Text.create('连击');
                                    Text.fontSize(this.isSmallScreen ? 11 : 13);
                                    Text.fontColor('rgba(255,255,255,0.6)');
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
                    Row.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Progress.create({ value: this.timeLeft, total: this.gameDuration, type: ProgressType.Linear });
                        Progress.width('92%');
                        Progress.color(this.timeLeft <= 5 ? '#FF6B6B' : '#4ECDC4');
                        Progress.backgroundColor('rgba(255,255,255,0.1)');
                        Progress.borderRadius(4);
                        Progress.margin({ top: 8 });
                        Progress.style({ strokeWidth: this.isSmallScreen ? 6 : 8 });
                    }, Progress);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Stack.create();
                        Stack.width('92%');
                        Stack.height(getStringValue(GP.gameAreaHeight, this.isSmallScreen));
                        Stack.margin({ top: getSizeValue(GP.gameAreaMarginTop, this.isSmallScreen) });
                        Stack.onAreaChange((oldValue: Area, newValue: Area) => {
                            this.gameAreaWidth = newValue.width as number;
                            this.gameAreaHeight = newValue.height as number;
                        });
                        Stack.onClick(() => {
                            this.onMissClick();
                        });
                    }, Stack);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.width('100%');
                        Column.height('100%');
                        Column.backgroundColor('rgba(255, 255, 255, 0.06)');
                        Column.borderRadius(20);
                        Column.border({ width: 1, color: 'rgba(255,255,255,0.08)' });
                    }, Column);
                    Column.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        ForEach.create();
                        const forEachItemGenFunction = _item => {
                            const target = _item;
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                Stack.create();
                                Stack.width(target.radius * 2);
                                Stack.height(target.radius * 2);
                                Stack.position({ x: target.x - target.radius, y: target.y - target.radius });
                                Stack.opacity(target.opacity);
                                Stack.onClick(() => {
                                    this.hitTarget(target);
                                });
                            }, Stack);
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                Circle.create();
                                Circle.width(target.radius * 2);
                                Circle.height(target.radius * 2);
                                Circle.fill('rgba(255, 107, 107, 0.15)');
                            }, Circle);
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                Circle.create();
                                Circle.width(target.radius * 1.4);
                                Circle.height(target.radius * 1.4);
                                Circle.fill('rgba(255, 107, 107, 0.25)');
                            }, Circle);
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                Circle.create();
                                Circle.width(target.radius * 0.8);
                                Circle.height(target.radius * 0.8);
                                Circle.fill('#FF6B6B');
                            }, Circle);
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                Circle.create();
                                Circle.width(target.radius * 0.35);
                                Circle.height(target.radius * 0.35);
                                Circle.fill('#FFFFFF');
                            }, Circle);
                            Stack.pop();
                        };
                        this.forEachUpdateFunction(elmtId, this.targets, forEachItemGenFunction, (target: Target) => target.id.toString(), false, false);
                    }, ForEach);
                    ForEach.pop();
                    Stack.pop();
                    Column.pop();
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
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.isGameOver) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.width(getStringValue(GP.gameOverPanelWidth, this.isSmallScreen));
                        Column.padding(getSizeValue(GP.gameOverPanelPadding, this.isSmallScreen));
                        Column.backgroundColor('rgba(15, 15, 40, 0.92)');
                        Column.borderRadius(24);
                        Column.border({ width: 1, color: 'rgba(255,255,255,0.1)' });
                        Column.alignItems(HorizontalAlign.Center);
                        Column.justifyContent(FlexAlign.Center);
                        Column.shadow({ radius: 30, color: 'rgba(0,0,0,0.5)', offsetX: 0, offsetY: 10 });
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('游戏结束!');
                        Text.fontSize(getSizeValue(GP.gameOverTitleFontSize, this.isSmallScreen));
                        Text.fontColor('#FFFFFF');
                        Text.fontWeight(FontWeight.Bold);
                        Text.width('100%');
                        Text.textAlign(TextAlign.Center);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(`${this.score}`);
                        Text.fontSize(this.isSmallScreen ? 48 : 64);
                        Text.fontColor('#FFD700');
                        Text.fontWeight(FontWeight.Bold);
                        Text.width('100%');
                        Text.textAlign(TextAlign.Center);
                        Text.margin({ top: 8 });
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('最终得分');
                        Text.fontSize(this.isSmallScreen ? 14 : 16);
                        Text.fontColor('rgba(255,255,255,0.5)');
                        Text.width('100%');
                        Text.textAlign(TextAlign.Center);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Row.create();
                        Row.width('100%');
                        Row.margin({ top: 24 });
                        Row.padding({ top: 16, bottom: 16 });
                        Row.backgroundColor('rgba(255,255,255,0.05)');
                        Row.borderRadius(12);
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.layoutWeight(1);
                        Column.alignItems(HorizontalAlign.Center);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(`${this.hitCount}`);
                        Text.fontSize(this.isSmallScreen ? 22 : 28);
                        Text.fontColor('#4ECDC4');
                        Text.fontWeight(FontWeight.Bold);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('命中');
                        Text.fontSize(this.isSmallScreen ? 11 : 13);
                        Text.fontColor('rgba(255,255,255,0.5)');
                    }, Text);
                    Text.pop();
                    Column.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.layoutWeight(1);
                        Column.alignItems(HorizontalAlign.Center);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(`${this.missCount}`);
                        Text.fontSize(this.isSmallScreen ? 22 : 28);
                        Text.fontColor('#FF6B6B');
                        Text.fontWeight(FontWeight.Bold);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('失误');
                        Text.fontSize(this.isSmallScreen ? 11 : 13);
                        Text.fontColor('rgba(255,255,255,0.5)');
                    }, Text);
                    Text.pop();
                    Column.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.layoutWeight(1);
                        Column.alignItems(HorizontalAlign.Center);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(`${this.getAccuracy()}%`);
                        Text.fontSize(this.isSmallScreen ? 22 : 28);
                        Text.fontColor('#4ECDC4');
                        Text.fontWeight(FontWeight.Bold);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('命中率');
                        Text.fontSize(this.isSmallScreen ? 11 : 13);
                        Text.fontColor('rgba(255,255,255,0.5)');
                    }, Text);
                    Text.pop();
                    Column.pop();
                    Row.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Row.create();
                        Row.width('100%');
                        Row.margin({ top: 12 });
                        Row.padding({ top: 16, bottom: 16 });
                        Row.backgroundColor('rgba(255,255,255,0.05)');
                        Row.borderRadius(12);
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.layoutWeight(1);
                        Column.alignItems(HorizontalAlign.Center);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(`x${this.maxCombo}`);
                        Text.fontSize(this.isSmallScreen ? 22 : 28);
                        Text.fontColor('#FFD700');
                        Text.fontWeight(FontWeight.Bold);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('最大连击');
                        Text.fontSize(this.isSmallScreen ? 11 : 13);
                        Text.fontColor('rgba(255,255,255,0.5)');
                    }, Text);
                    Text.pop();
                    Column.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.layoutWeight(1);
                        Column.alignItems(HorizontalAlign.Center);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(`${this.getAvgReactionMs()}ms`);
                        Text.fontSize(this.isSmallScreen ? 22 : 28);
                        Text.fontColor('#667eea');
                        Text.fontWeight(FontWeight.Bold);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('平均反应');
                        Text.fontSize(this.isSmallScreen ? 11 : 13);
                        Text.fontColor('rgba(255,255,255,0.5)');
                    }, Text);
                    Text.pop();
                    Column.pop();
                    Row.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.margin({ top: 24 });
                        Column.alignItems(HorizontalAlign.Center);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel('再来一局');
                        Button.width(getSizeValue(GP.gameOverButtonWidth, this.isSmallScreen));
                        Button.height(getSizeValue(GP.gameOverButtonHeight, this.isSmallScreen));
                        Button.fontSize(getSizeValue(GP.gameOverButtonFontSize, this.isSmallScreen));
                        Button.backgroundColor('#4ECDC4');
                        Button.borderRadius(28);
                        Button.shadow({ radius: 8, color: 'rgba(78,205,196,0.4)', offsetX: 0, offsetY: 3 });
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
                        Button.width(getSizeValue(GP.gameOverButtonWidth, this.isSmallScreen));
                        Button.height(getSizeValue(GP.gameOverButtonHeight, this.isSmallScreen));
                        Button.fontSize(getSizeValue(GP.gameOverButtonFontSize, this.isSmallScreen));
                        Button.backgroundColor('#FF6B6B');
                        Button.borderRadius(28);
                        Button.shadow({ radius: 8, color: 'rgba(255,107,107,0.4)', offsetX: 0, offsetY: 3 });
                        Button.margin({ top: 12 });
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
export function getGameRecords(): GameRecord[] {
    return gameRecords;
}
export function clearGameRecords(): void {
    gameRecords = [];
}
registerNamedRoute(() => new GamePage(undefined, {}), "", { bundleName: "com.example.targetgame", moduleName: "entry", pagePath: "pages/GamePage", pageFullPath: "entry/src/main/ets/pages/GamePage", integratedHsp: "false", moduleType: "followWithHap" });
