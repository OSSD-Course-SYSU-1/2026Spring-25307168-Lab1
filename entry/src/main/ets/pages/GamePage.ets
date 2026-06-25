import router from '@ohos.router';
import { ScreenAdapter } from '../utils/ScreenAdapter';
import { GamePage as GP, CastUI, getSizeValue, getStringValue } from '../constants/LayoutConstants';
import { DeviceCastManager, DeviceInfo, CastConnectionState } from '../cast/DeviceCastManager';
import { DistributedGameData, SyncableGameState, ControlEvent } from '../cast/DistributedGameData';
import { DeviceSelectPanel } from '../cast/DeviceSelectPanel';
import { CastStatusBar } from '../cast/CastStatusBar';

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

@Entry
@Component
struct GamePage {
  @State score: number = 0;
  @State timeLeft: number = 30;
  @State targets: Target[] = [];
  @State isGameRunning: boolean = false;
  @State isGameOver: boolean = false;
  @State isSmallScreen: boolean = false;
  @State targetCount: number = 1;
  @State targetSize: number = 2;
  @State gameDuration: number = 30;
  @State isGamePreparing: boolean = true;

  @State connectionState: CastConnectionState = CastConnectionState.DISCONNECTED;
  @State targetDeviceName: string = '';
  @State discoveredDevices: DeviceInfo[] = [];
  @State isDiscovering: boolean = false;
  @State isDistributedSupported: boolean = false;

  @State hitCount: number = 0;
  @State missCount: number = 0;
  @State combo: number = 0;
  @State maxCombo: number = 0;
  @State lastHitTime: number = 0;
  @State totalReactionMs: number = 0;
  @State dots: FloatingDot[] = [];
  @State animOffset: number = 0;

  private gameTimer: number = -1;
  private targetTimer: number = -1;
  private targetId: number = 0;
  private gameAreaWidth: number = 0;
  private gameAreaHeight: number = 0;
  private readonly MAX_ATTEMPTS: number = 100;
  private readonly PADDING: number = 10;
  private gameStartTime: number = 0;

  private castManager: DeviceCastManager = DeviceCastManager.getInstance();
  private distributedData: DistributedGameData = new DistributedGameData();
  private dotId: number = 0;
  private bgAnimTimer: number = -1;

  private deviceSelectDialogController: CustomDialogController = new CustomDialogController({
    builder: DeviceSelectPanel({
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
    }),
    autoCancel: true
  });

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
        if (newY < -5) newY = 105;
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
      } else if (state === CastConnectionState.DISCONNECTED) {
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
    if (total === 0) return 0;
    return Math.round((this.hitCount / total) * 100);
  }

  getAvgReactionMs(): number {
    if (this.hitCount === 0) return 0;
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
    if (!this.isGameRunning) return;

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
    if (!this.isGameRunning) return;
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

  build() {
    Stack() {
      Column() {
        CastStatusBar({
          connectionState: this.connectionState,
          targetDeviceName: this.targetDeviceName,
          isSmallScreen: this.isSmallScreen,
          onDisconnect: () => {
            this.disconnectCast();
          }
        })
        .margin({ top: 5 })

        if (this.isGamePreparing) {
          Column() {
            Text('打靶训练')
              .fontSize(getSizeValue(GP.titleFontSize, this.isSmallScreen))
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .textShadow({ radius: 8, color: 'rgba(0,0,0,0.3)', offsetX: 0, offsetY: 2 })

            Row() {
              Text('靶子数量:')
                .fontSize(getSizeValue(GP.labelFontSize, this.isSmallScreen))
                .fontColor('#FFFFFF')
                .fontWeight(FontWeight.Bold)

              ForEach(countOptions, (count: number) => {
                Button(count.toString(), { type: ButtonType.Normal })
                  .width(getSizeValue(GP.countButtonSize, this.isSmallScreen))
                  .height(getSizeValue(GP.countButtonSize, this.isSmallScreen))
                  .fontSize(getSizeValue(GP.countButtonFontSize, this.isSmallScreen))
                  .fontColor('#FFFFFF')
                  .fontWeight(FontWeight.Bold)
                  .backgroundColor(this.targetCount === count ? '#FF6B6B' : 'rgba(255, 255, 255, 0.2)')
                  .borderRadius(getSizeValue(GP.countButtonBorderRadius, this.isSmallScreen))
                  .padding(0)
                  .margin({ left: 8 })
                  .onClick(() => {
                    this.targetCount = count;
                  })
              }, (count: number) => count.toString())
            }
            .margin({ top: 30 })

            Row() {
              Text('靶子大小:')
                .fontSize(getSizeValue(GP.labelFontSize, this.isSmallScreen))
                .fontColor('#FFFFFF')
                .fontWeight(FontWeight.Bold)

              ForEach(sizeOptions, (item: SizeOption) => {
                Button(item.label)
                  .width(getSizeValue(GP.sizeButtonWidth, this.isSmallScreen))
                  .height(getSizeValue(GP.sizeButtonHeight, this.isSmallScreen))
                  .fontSize(getSizeValue(GP.sizeButtonFontSize, this.isSmallScreen))
                  .fontColor('#FFFFFF')
                  .fontWeight(FontWeight.Bold)
                  .backgroundColor(this.targetSize === item.value ? '#FF6B6B' : 'rgba(255, 255, 255, 0.2)')
                  .borderRadius(getSizeValue(GP.sizeButtonBorderRadius, this.isSmallScreen))
                  .margin({ left: 8 })
                  .onClick(() => {
                    this.targetSize = item.value;
                  })
              }, (item: SizeOption) => item.value.toString())
            }
            .margin({ top: 20 })

            Row() {
              Text('游戏时长:')
                .fontSize(getSizeValue(GP.labelFontSize, this.isSmallScreen))
                .fontColor('#FFFFFF')
                .fontWeight(FontWeight.Bold)

              ForEach([15, 30, 60], (duration: number) => {
                Button(duration + 's')
                  .width(getSizeValue(GP.durationButtonWidth, this.isSmallScreen))
                  .height(getSizeValue(GP.durationButtonHeight, this.isSmallScreen))
                  .fontSize(getSizeValue(GP.durationButtonFontSize, this.isSmallScreen))
                  .fontColor('#FFFFFF')
                  .fontWeight(FontWeight.Bold)
                  .backgroundColor(this.gameDuration === duration ? '#FF6B6B' : 'rgba(255, 255, 255, 0.2)')
                  .borderRadius(getSizeValue(GP.durationButtonBorderRadius, this.isSmallScreen))
                  .margin({ left: 8 })
                  .onClick(() => {
                    this.gameDuration = duration;
                  })
              }, (duration: number) => duration.toString())
            }
            .margin({ top: 20 })

            Button('开始游戏')
              .width(getSizeValue(GP.startButtonWidth, this.isSmallScreen))
              .height(getSizeValue(GP.startButtonHeight, this.isSmallScreen))
              .fontSize(getSizeValue(GP.startButtonFontSize, this.isSmallScreen))
              .backgroundColor('#4ECDC4')
              .borderRadius(35)
              .shadow({ radius: 12, color: 'rgba(78,205,196,0.4)', offsetX: 0, offsetY: 4 })
              .margin({ top: 40 })
              .onClick(() => {
                this.startGame();
              })

            if (this.isDistributedSupported) {
              Button('跨设备投送')
                .width(getSizeValue(CastUI.castButtonWidth, this.isSmallScreen))
                .height(getSizeValue(CastUI.castButtonHeight, this.isSmallScreen))
                .fontSize(getSizeValue(CastUI.castButtonFontSize, this.isSmallScreen))
                .backgroundColor('#667eea')
                .borderRadius(35)
                .margin({ top: 20 })
                .onClick(() => {
                  this.startDeviceDiscovery();
                  this.deviceSelectDialogController.open();
                })
            }
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }

        if (!this.isGamePreparing && !this.isGameOver) {
          Column() {
            Row() {
              Column() {
                Text(`${this.score}`)
                  .fontSize(this.isSmallScreen ? 28 : 36)
                  .fontColor('#FFD700')
                  .fontWeight(FontWeight.Bold)
                Text('得分')
                  .fontSize(this.isSmallScreen ? 11 : 13)
                  .fontColor('rgba(255,255,255,0.6)')
              }
              .alignItems(HorizontalAlign.Center)

              Blank()

              Column() {
                Text(`${this.timeLeft}s`)
                  .fontSize(this.isSmallScreen ? 28 : 36)
                  .fontColor(this.timeLeft <= 5 ? '#FF6B6B' : '#FFFFFF')
                  .fontWeight(FontWeight.Bold)
                Text('剩余时间')
                  .fontSize(this.isSmallScreen ? 11 : 13)
                  .fontColor('rgba(255,255,255,0.6)')
              }
              .alignItems(HorizontalAlign.Center)

              Blank()

              Column() {
                Text(`${this.getAccuracy()}%`)
                  .fontSize(this.isSmallScreen ? 22 : 28)
                  .fontColor('#4ECDC4')
                  .fontWeight(FontWeight.Bold)
                Text('命中率')
                  .fontSize(this.isSmallScreen ? 11 : 13)
                  .fontColor('rgba(255,255,255,0.6)')
              }
              .alignItems(HorizontalAlign.Center)

              if (this.combo > 1) {
                Blank()
                Column() {
                  Text(`x${this.combo}`)
                    .fontSize(this.isSmallScreen ? 22 : 28)
                    .fontColor('#FF6B6B')
                    .fontWeight(FontWeight.Bold)
                  Text('连击')
                    .fontSize(this.isSmallScreen ? 11 : 13)
                    .fontColor('rgba(255,255,255,0.6)')
                }
                .alignItems(HorizontalAlign.Center)
              }
            }
            .width('92%')
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .backgroundColor('rgba(0, 0, 0, 0.4)')
            .borderRadius(16)
            .margin({ top: getSizeValue(GP.scoreMarginTop, this.isSmallScreen) })
            .alignItems(VerticalAlign.Center)

            Progress({ value: this.timeLeft, total: this.gameDuration, type: ProgressType.Linear })
              .width('92%')
              .color(this.timeLeft <= 5 ? '#FF6B6B' : '#4ECDC4')
              .backgroundColor('rgba(255,255,255,0.1)')
              .borderRadius(4)
              .margin({ top: 8 })
              .style({ strokeWidth: this.isSmallScreen ? 6 : 8 })

            Stack() {
              Column()
                .width('100%')
                .height('100%')
                .backgroundColor('rgba(255, 255, 255, 0.06)')
                .borderRadius(20)
                .border({ width: 1, color: 'rgba(255,255,255,0.08)' })

              ForEach(this.targets, (target: Target) => {
                Stack() {
                  Circle()
                    .width(target.radius * 2)
                    .height(target.radius * 2)
                    .fill('rgba(255, 107, 107, 0.15)')
                  Circle()
                    .width(target.radius * 1.4)
                    .height(target.radius * 1.4)
                    .fill('rgba(255, 107, 107, 0.25)')
                  Circle()
                    .width(target.radius * 0.8)
                    .height(target.radius * 0.8)
                    .fill('#FF6B6B')
                  Circle()
                    .width(target.radius * 0.35)
                    .height(target.radius * 0.35)
                    .fill('#FFFFFF')
                }
                .width(target.radius * 2)
                .height(target.radius * 2)
                .position({ x: target.x - target.radius, y: target.y - target.radius })
                .opacity(target.opacity)
                .onClick(() => {
                  this.hitTarget(target);
                })
              }, (target: Target) => target.id.toString())
            }
            .width('92%')
            .height(getStringValue(GP.gameAreaHeight, this.isSmallScreen))
            .margin({ top: getSizeValue(GP.gameAreaMarginTop, this.isSmallScreen) })
            .onAreaChange((oldValue: Area, newValue: Area) => {
              this.gameAreaWidth = newValue.width as number;
              this.gameAreaHeight = newValue.height as number;
            })
            .onClick(() => {
              this.onMissClick();
            })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
      .linearGradient({
        angle: 135,
        colors: [['#1a1a3e', 0.0], ['#2d1b69', 0.5], ['#764ba2', 1.0]]
      })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      ForEach(this.dots, (dot: FloatingDot) => {
        Circle()
          .width(dot.size)
          .height(dot.size)
          .fill(`rgba(255, 255, 255, ${dot.opacity})`)
          .position({ x: `${dot.x}%`, y: `${dot.y}%` })
      }, (dot: FloatingDot) => dot.id.toString())

      if (this.isGameOver) {
        Column() {
          Text('游戏结束!')
            .fontSize(getSizeValue(GP.gameOverTitleFontSize, this.isSmallScreen))
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .textAlign(TextAlign.Center)

          Text(`${this.score}`)
            .fontSize(this.isSmallScreen ? 48 : 64)
            .fontColor('#FFD700')
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ top: 8 })

          Text('最终得分')
            .fontSize(this.isSmallScreen ? 14 : 16)
            .fontColor('rgba(255,255,255,0.5)')
            .width('100%')
            .textAlign(TextAlign.Center)

          Row() {
            Column() {
              Text(`${this.hitCount}`)
                .fontSize(this.isSmallScreen ? 22 : 28)
                .fontColor('#4ECDC4')
                .fontWeight(FontWeight.Bold)
              Text('命中')
                .fontSize(this.isSmallScreen ? 11 : 13)
                .fontColor('rgba(255,255,255,0.5)')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            Column() {
              Text(`${this.missCount}`)
                .fontSize(this.isSmallScreen ? 22 : 28)
                .fontColor('#FF6B6B')
                .fontWeight(FontWeight.Bold)
              Text('失误')
                .fontSize(this.isSmallScreen ? 11 : 13)
                .fontColor('rgba(255,255,255,0.5)')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            Column() {
              Text(`${this.getAccuracy()}%`)
                .fontSize(this.isSmallScreen ? 22 : 28)
                .fontColor('#4ECDC4')
                .fontWeight(FontWeight.Bold)
              Text('命中率')
                .fontSize(this.isSmallScreen ? 11 : 13)
                .fontColor('rgba(255,255,255,0.5)')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .margin({ top: 24 })
          .padding({ top: 16, bottom: 16 })
          .backgroundColor('rgba(255,255,255,0.05)')
          .borderRadius(12)

          Row() {
            Column() {
              Text(`x${this.maxCombo}`)
                .fontSize(this.isSmallScreen ? 22 : 28)
                .fontColor('#FFD700')
                .fontWeight(FontWeight.Bold)
              Text('最大连击')
                .fontSize(this.isSmallScreen ? 11 : 13)
                .fontColor('rgba(255,255,255,0.5)')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            Column() {
              Text(`${this.getAvgReactionMs()}ms`)
                .fontSize(this.isSmallScreen ? 22 : 28)
                .fontColor('#667eea')
                .fontWeight(FontWeight.Bold)
              Text('平均反应')
                .fontSize(this.isSmallScreen ? 11 : 13)
                .fontColor('rgba(255,255,255,0.5)')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .margin({ top: 12 })
          .padding({ top: 16, bottom: 16 })
          .backgroundColor('rgba(255,255,255,0.05)')
          .borderRadius(12)

          Column() {
            Button('再来一局')
              .width(getSizeValue(GP.gameOverButtonWidth, this.isSmallScreen))
              .height(getSizeValue(GP.gameOverButtonHeight, this.isSmallScreen))
              .fontSize(getSizeValue(GP.gameOverButtonFontSize, this.isSmallScreen))
              .backgroundColor('#4ECDC4')
              .borderRadius(28)
              .shadow({ radius: 8, color: 'rgba(78,205,196,0.4)', offsetX: 0, offsetY: 3 })
              .onClick(() => {
                this.stopGame();
                this.isGameOver = false;
                this.isGameRunning = false;
                this.isGamePreparing = true;
              })

            Button('返回首页')
              .width(getSizeValue(GP.gameOverButtonWidth, this.isSmallScreen))
              .height(getSizeValue(GP.gameOverButtonHeight, this.isSmallScreen))
              .fontSize(getSizeValue(GP.gameOverButtonFontSize, this.isSmallScreen))
              .backgroundColor('#FF6B6B')
              .borderRadius(28)
              .shadow({ radius: 8, color: 'rgba(255,107,107,0.4)', offsetX: 0, offsetY: 3 })
              .margin({ top: 12 })
              .onClick(() => {
                router.back();
              })
          }
          .margin({ top: 24 })
          .alignItems(HorizontalAlign.Center)
        }
        .width(getStringValue(GP.gameOverPanelWidth, this.isSmallScreen))
        .padding(getSizeValue(GP.gameOverPanelPadding, this.isSmallScreen))
        .backgroundColor('rgba(15, 15, 40, 0.92)')
        .borderRadius(24)
        .border({ width: 1, color: 'rgba(255,255,255,0.1)' })
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .shadow({ radius: 30, color: 'rgba(0,0,0,0.5)', offsetX: 0, offsetY: 10 })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
  }
}

export function getGameRecords(): GameRecord[] {
  return gameRecords;
}

export function clearGameRecords(): void {
  gameRecords = [];
}
