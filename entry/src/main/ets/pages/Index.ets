import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State isSmallScreen: boolean = false;

  aboutToAppear() {
    this.isSmallScreen = false;
  }

  build() {
    Column() {
      Text('打靶训练场')
        .fontSize(this.isSmallScreen ? 32 : 48)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .margin({ top: this.isSmallScreen ? 60 : 100 })

      Image($r('app.media.target_icon'))
        .width(this.isSmallScreen ? 120 : 180)
        .height(this.isSmallScreen ? 120 : 180)
        .margin({ top: this.isSmallScreen ? 40 : 60 })

      Button('开始游戏')
        .width(this.isSmallScreen ? 200 : 280)
        .height(this.isSmallScreen ? 50 : 70)
        .fontSize(this.isSmallScreen ? 20 : 28)
        .backgroundColor('#FF6B6B')
        .borderRadius(35)
        .margin({ top: this.isSmallScreen ? 60 : 80 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/GamePage' });
        })

      Button('历史记录')
        .width(this.isSmallScreen ? 200 : 280)
        .height(this.isSmallScreen ? 50 : 70)
        .fontSize(this.isSmallScreen ? 20 : 28)
        .backgroundColor('#4ECDC4')
        .borderRadius(35)
        .margin({ top: 20 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/RecordPage' });
        })
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      angle: 135,
      colors: [['#667eea', 0.0], ['#764ba2', 1.0]]
    })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }
}
