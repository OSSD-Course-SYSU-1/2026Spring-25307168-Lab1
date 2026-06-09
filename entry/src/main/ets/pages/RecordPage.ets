import router from '@ohos.router';
import { getGameRecords, clearGameRecords } from './GamePage';

interface GameRecord {
  score: number;
  date: string;
}

@Entry
@Component
struct RecordPage {
  @State records: GameRecord[] = [];
  @State isSmallScreen: boolean = false;

  aboutToAppear() {
    this.isSmallScreen = false;
    this.records = getGameRecords();
  }

  build() {
    Column() {
      Text('历史记录')
        .fontSize(this.isSmallScreen ? 28 : 36)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .margin({ top: this.isSmallScreen ? 40 : 60 })

      if (this.records.length > 0) {
        Column() {
          Text('最高分')
            .fontSize(this.isSmallScreen ? 18 : 24)
            .fontColor('#FFD700')
          
          Text(`${this.records[0].score}`)
            .fontSize(this.isSmallScreen ? 36 : 48)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .margin({ top: 10 })
        }
        .width('80%')
        .padding(this.isSmallScreen ? 20 : 30)
        .backgroundColor('rgba(255, 215, 0, 0.2)')
        .borderRadius(15)
        .margin({ top: this.isSmallScreen ? 20 : 30 })
      }

      if (this.records.length > 0) {
        List() {
          ForEach(this.records, (record: GameRecord, index: number) => {
            ListItem() {
              Row() {
                Text(`第${index + 1}名`)
                  .fontSize(this.isSmallScreen ? 16 : 20)
                  .fontColor('#FFFFFF')
                  .width(this.isSmallScreen ? 60 : 80)

                Text(`${record.score}分`)
                  .fontSize(this.isSmallScreen ? 18 : 24)
                  .fontColor('#FFD700')
                  .fontWeight(FontWeight.Bold)
                  .width(this.isSmallScreen ? 80 : 100)
                  .textAlign(TextAlign.Start)

                Text(record.date)
                  .fontSize(this.isSmallScreen ? 12 : 16)
                  .fontColor('#CCCCCC')
                  .layoutWeight(1)
              }
              .width('100%')
              .padding(this.isSmallScreen ? 12 : 16)
              .backgroundColor('rgba(255, 255, 255, 0.1)')
              .borderRadius(10)
              .margin({ bottom: 10 })
            }
          }, (record: GameRecord, index: number) => index.toString())
        }
        .width('90%')
        .height(this.isSmallScreen ? '35%' : '45%')
        .margin({ top: this.isSmallScreen ? 20 : 30 })
        .padding({ left: 10, right: 10 })
      } else {
        Column() {
          Text('暂无游戏记录')
            .fontSize(this.isSmallScreen ? 20 : 24)
            .fontColor('#CCCCCC')
            .margin({ top: this.isSmallScreen ? 60 : 100 })
        }
        .width('90%')
        .height(this.isSmallScreen ? '35%' : '45%')
      }

      Row() {
        Button('返回首页')
          .width(this.isSmallScreen ? 140 : 180)
          .height(this.isSmallScreen ? 45 : 55)
          .fontSize(this.isSmallScreen ? 18 : 22)
          .backgroundColor('#4ECDC4')
          .borderRadius(28)
          .onClick(() => {
            router.back();
          })

        if (this.records.length > 0) {
          Button('清除记录')
            .width(this.isSmallScreen ? 140 : 180)
            .height(this.isSmallScreen ? 45 : 55)
            .fontSize(this.isSmallScreen ? 18 : 22)
            .backgroundColor('#FF6B6B')
            .borderRadius(28)
            .margin({ left: 20 })
            .onClick(() => {
              clearGameRecords();
              this.records = [];
            })
        }
      }
      .margin({ top: this.isSmallScreen ? 30 : 40 })
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
