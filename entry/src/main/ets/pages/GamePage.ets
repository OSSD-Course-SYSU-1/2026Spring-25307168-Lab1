import router from '@ohos.router';

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

@Entry
@Component
struct GamePage {
  @State score: number = 0;
  @State timeLeft: number = 30;
  @State targets: Target[] = [];
  @State isGameRunning: boolean = false;
  @State isGameOver: boolean = false;
  @State isSmallScreen: boolean = false;
  // 靶子数量：屏幕上同时保持的靶子数量
  @State targetCount: number = 1;
  // 靶子大小：1=小, 2=中, 3=大
  @State targetSize: number = 2;
  // 游戏时长（秒）：15, 30, 60
  @State gameDuration: number = 30;
  @State isGamePreparing: boolean = true;

  private gameTimer: number = -1;
  private targetTimer: number = -1;
  private targetId: number = 0;
  private gameAreaWidth: number = 0;
  private gameAreaHeight: number = 0;
  private readonly MAX_ATTEMPTS: number = 100;
  private readonly PADDING: number = 10;

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
      if (this.targetSize === 1) return 20; // 小
      if (this.targetSize === 2) return 30; // 中
      return 40; // 大
    } else {
      if (this.targetSize === 1) return 35; // 小
      if (this.targetSize === 2) return 55; // 中
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
    if (!this.isGameRunning) return;

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

  build() {
    Stack() {
      Column() {
        // 准备阶段：显示靶子数量选择 + 靶子大小选择 + 开始按钮
        if (this.isGamePreparing) {
          Column() {
            Text('打靶训练')
              .fontSize(this.isSmallScreen ? 28 : 40)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)

            // 靶子数量选择区域
            Row() {
              Text('靶子数量:')
                .fontSize(this.isSmallScreen ? 16 : 20)
                .fontColor('#FFFFFF')
                .fontWeight(FontWeight.Bold)

              ForEach([1, 2, 3, 4, 5], (count: number) => {
                Button(count.toString())
                  .width(this.isSmallScreen ? 36 : 48)
                  .height(this.isSmallScreen ? 36 : 48)
                  .fontSize(this.isSmallScreen ? 16 : 20)
                  .fontColor('#FFFFFF')
                  .fontWeight(FontWeight.Bold)
                  .backgroundColor(this.targetCount === count ? '#FF6B6B' : 'rgba(255, 255, 255, 0.3)')
                  .borderRadius(this.isSmallScreen ? 18 : 24)
                  .margin({ left: 8 })
                  .onClick(() => {
                    this.targetCount = count;
                  })
              }, (count: number) => count.toString())
            }
            .margin({ top: 30 })

            // 靶子大小选择区域
            Row() {
              Text('靶子大小:')
                .fontSize(this.isSmallScreen ? 16 : 20)
                .fontColor('#FFFFFF')
                .fontWeight(FontWeight.Bold)

              ForEach(sizeOptions, (item: SizeOption) => {
                Button(item.label)
                  .width(this.isSmallScreen ? 50 : 64)
                  .height(this.isSmallScreen ? 36 : 48)
                  .fontSize(this.isSmallScreen ? 16 : 20)
                  .fontColor('#FFFFFF')
                  .fontWeight(FontWeight.Bold)
                  .backgroundColor(this.targetSize === item.value ? '#FF6B6B' : 'rgba(255, 255, 255, 0.3)')
                  .borderRadius(this.isSmallScreen ? 18 : 24)
                  .margin({ left: 8 })
                  .onClick(() => {
                    this.targetSize = item.value;
                  })
              }, (item: SizeOption) => item.value.toString())

            }
            .margin({ top: 20 })

            // 游戏时长选择区域
            Row() {
              Text('游戏时长:')
                .fontSize(this.isSmallScreen ? 16 : 20)
                .fontColor('#FFFFFF')
                .fontWeight(FontWeight.Bold)

              ForEach([15, 30, 60], (duration: number) => {
                Button(duration + 's')
                  .width(this.isSmallScreen ? 60 : 80)
                  .height(this.isSmallScreen ? 36 : 48)
                  .fontSize(this.isSmallScreen ? 14 : 18)
                  .fontColor('#FFFFFF')
                  .fontWeight(FontWeight.Bold)
                  .backgroundColor(this.gameDuration === duration ? '#FF6B6B' : 'rgba(255, 255, 255, 0.3)')
                  .borderRadius(this.isSmallScreen ? 18 : 24)
                  .margin({ left: 8 })
                  .onClick(() => {
                    this.gameDuration = duration;
                  })
              }, (duration: number) => duration.toString())
            }
            .margin({ top: 20 })

            Button('开始游戏')
              .width(this.isSmallScreen ? 200 : 280)
              .height(this.isSmallScreen ? 50 : 70)
              .fontSize(this.isSmallScreen ? 20 : 28)
              .backgroundColor('#4ECDC4')
              .borderRadius(35)
              .margin({ top: 40 })
              .onClick(() => {
                this.startGame();
              })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }

        // 游戏进行中：显示得分/时间 + 游戏区域
        if (!this.isGamePreparing && !this.isGameOver) {
          Row() {
            Text(`得分: ${this.score}`)
              .fontSize(this.isSmallScreen ? 20 : 28)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)

            Blank()

            Text(`时间: ${this.timeLeft}s`)
              .fontSize(this.isSmallScreen ? 20 : 28)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
          }
          .width('90%')
          .padding(this.isSmallScreen ? 10 : 20)
          .backgroundColor('rgba(0, 0, 0, 0.3)')
          .borderRadius(15)
          .margin({ top: this.isSmallScreen ? 10 : 20 })

          Stack() {
            Column()
              .width('100%')
              .height('100%')
              .backgroundColor('rgba(255, 255, 255, 0.1)')
              .borderRadius(20)

            ForEach(this.targets, (target: Target) => {
              // 纯白统一圆形靶子
              Circle()
                .width(target.radius * 2)
                .height(target.radius * 2)
                .fill('#FFFFFF')
                .position({ x: target.x - target.radius, y: target.y - target.radius })
                .opacity(target.opacity)
                .onClick(() => {
                  this.hitTarget(target);
                })
            }, (target: Target) => target.id.toString())
          }
          .width('90%')
          .height(this.isSmallScreen ? '55%' : '65%')
          .margin({ top: this.isSmallScreen ? 10 : 20 })
          .onAreaChange((oldValue: Area, newValue: Area) => {
            this.gameAreaWidth = newValue.width as number;
            this.gameAreaHeight = newValue.height as number;
          })
        }
      }
      .width('100%')
      .height('100%')
      .linearGradient({
        angle: 135,
        colors: [['#667eea', 0.0], ['#764ba2', 1.0]]
      })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      // 游戏结束面板 — 使用Stack叠加在屏幕中央
      if (this.isGameOver) {
        Column() {
          Text('游戏结束!')
            .fontSize(this.isSmallScreen ? 28 : 36)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .textAlign(TextAlign.Center)

          Text(`最终得分: ${this.score}`)
            .fontSize(this.isSmallScreen ? 24 : 32)
            .fontColor('#FFD700')
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ top: 20 })

          Column() {
            Button('再来一局')
              .width(this.isSmallScreen ? 200 : 260)
              .height(this.isSmallScreen ? 44 : 56)
              .fontSize(this.isSmallScreen ? 18 : 22)
              .backgroundColor('#4ECDC4')
              .borderRadius(28)
              .onClick(() => {
                this.stopGame();
                this.isGameOver = false;
                this.isGameRunning = false;
                this.isGamePreparing = true;
              })

            Button('返回首页')
              .width(this.isSmallScreen ? 200 : 260)
              .height(this.isSmallScreen ? 44 : 56)
              .fontSize(this.isSmallScreen ? 18 : 22)
              .backgroundColor('#FF6B6B')
              .borderRadius(28)
              .margin({ top: 15 })
              .onClick(() => {
                router.back();
              })
          }
          .margin({ top: 30 })
          .alignItems(HorizontalAlign.Center)
        }
        .width(this.isSmallScreen ? '70%' : '60%')
        .padding(this.isSmallScreen ? 30 : 40)
        .backgroundColor('rgba(0, 0, 0, 0.85)')
        .borderRadius(20)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
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
