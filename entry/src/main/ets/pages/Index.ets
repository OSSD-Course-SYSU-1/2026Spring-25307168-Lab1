import router from '@ohos.router';
import { ScreenAdapter } from '../utils/ScreenAdapter';
import { IndexPage, getSizeValue } from '../constants/LayoutConstants';
import { DeviceCastManager } from '../cast/DeviceCastManager';
import { ParticleBackground } from '../components/ParticleBackground';

interface FloatingDot {
  id: number;
  x: number;
  y: number;
  size: number;
  opacity: number;
  speed: number;
}

@Entry
@Component
struct Index {
  @State isSmallScreen: boolean = false;
  @State isDistributedSupported: boolean = false;
  @State dots: FloatingDot[] = [];
  @State animOffset: number = 0;

  private castManager: DeviceCastManager = DeviceCastManager.getInstance();
  private dotId: number = 0;
  private animTimer: number = -1;

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
        if (newY < -5) newY = 105;
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

  build() {
    Stack() {
      Column() {
        Text('打靶训练场')
          .fontSize(getSizeValue(IndexPage.titleFontSize, this.isSmallScreen))
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .textShadow({ radius: 8, color: 'rgba(0,0,0,0.3)', offsetX: 0, offsetY: 2 })
          .margin({ top: getSizeValue(IndexPage.titleMarginTop, this.isSmallScreen) })

        Image($r('app.media.target_icon'))
          .width(getSizeValue(IndexPage.iconSize, this.isSmallScreen))
          .height(getSizeValue(IndexPage.iconSize, this.isSmallScreen))
          .margin({ top: getSizeValue(IndexPage.iconMarginTop, this.isSmallScreen) })
          .shadow({ radius: 20, color: 'rgba(255,255,255,0.15)', offsetX: 0, offsetY: 0 })

        Button('开始游戏')
          .width(getSizeValue(IndexPage.buttonWidth, this.isSmallScreen))
          .height(getSizeValue(IndexPage.buttonHeight, this.isSmallScreen))
          .fontSize(getSizeValue(IndexPage.buttonFontSize, this.isSmallScreen))
          .backgroundColor('#FF6B6B')
          .borderRadius(35)
          .shadow({ radius: 12, color: 'rgba(255,107,107,0.4)', offsetX: 0, offsetY: 4 })
          .margin({ top: getSizeValue(IndexPage.buttonMarginTop, this.isSmallScreen) })
          .onClick(() => {
            router.pushUrl({ url: 'pages/GamePage' });
          })

        Button('历史记录')
          .width(getSizeValue(IndexPage.buttonWidth, this.isSmallScreen))
          .height(getSizeValue(IndexPage.buttonHeight, this.isSmallScreen))
          .fontSize(getSizeValue(IndexPage.buttonFontSize, this.isSmallScreen))
          .backgroundColor('#4ECDC4')
          .borderRadius(35)
          .shadow({ radius: 12, color: 'rgba(78,205,196,0.4)', offsetX: 0, offsetY: 4 })
          .margin({ top: 20 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/RecordPage' });
          })

        if (this.isDistributedSupported) {
          Text('支持跨设备投送，请在游戏页面使用')
            .fontSize(this.isSmallScreen ? 14 : 16)
            .fontColor('rgba(255, 255, 255, 0.6)')
            .margin({ top: 30 })
        }
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)

      ForEach(this.dots, (dot: FloatingDot) => {
        Circle()
          .width(dot.size)
          .height(dot.size)
          .fill(`rgba(255, 255, 255, ${dot.opacity})`)
          .position({ x: `${dot.x}%`, y: `${dot.y}%` })
      }, (dot: FloatingDot) => dot.id.toString())
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      angle: 135,
      colors: [['#1a1a3e', 0.0], ['#2d1b69', 0.5], ['#764ba2', 1.0]]
    })
  }
}
