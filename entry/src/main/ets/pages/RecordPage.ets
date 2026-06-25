import router from '@ohos.router';
import { getGameRecords, clearGameRecords } from './GamePage';
import { ScreenAdapter } from '../utils/ScreenAdapter';
import { RecordPage as RP, getSizeValue, getStringValue } from '../constants/LayoutConstants';

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

@Entry
@Component
struct RecordPage {
  @State records: GameRecord[] = [];
  @State isSmallScreen: boolean = false;
  @State dots: FloatingDot[] = [];
  @State animOffset: number = 0;

  private dotId: number = 0;
  private animTimer: number = -1;

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

  build() {
    Stack() {
      Column() {
        Text('历史记录')
          .fontSize(getSizeValue(RP.titleFontSize, this.isSmallScreen))
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .textShadow({ radius: 8, color: 'rgba(0,0,0,0.3)', offsetX: 0, offsetY: 2 })
          .margin({ top: getSizeValue(RP.titleMarginTop, this.isSmallScreen) })

        if (this.records.length > 0) {
          Column() {
            Text('最高分')
              .fontSize(getSizeValue(RP.highScoreFontSize, this.isSmallScreen))
              .fontColor('#FFD700')

            Text(`${this.records[0].score}`)
              .fontSize(getSizeValue(RP.scoreFontSize, this.isSmallScreen))
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .margin({ top: 10 })
          }
          .width('80%')
          .padding(getSizeValue(RP.highScorePadding, this.isSmallScreen))
          .backgroundColor('rgba(255, 215, 0, 0.15)')
          .borderRadius(15)
          .border({ width: 1, color: 'rgba(255, 215, 0, 0.2)' })
          .margin({ top: getSizeValue(RP.highScoreMarginTop, this.isSmallScreen) })
        }

        if (this.records.length > 0) {
          List() {
            ForEach(this.records, (record: GameRecord, index: number) => {
              ListItem() {
                Column() {
                  Row() {
                    Text(`#${index + 1}`)
                      .fontSize(getSizeValue(RP.rankFontSize, this.isSmallScreen))
                      .fontColor('#FFD700')
                      .fontWeight(FontWeight.Bold)
                      .width(getSizeValue(RP.rankWidth, this.isSmallScreen))

                    Text(`${record.score}分`)
                      .fontSize(getSizeValue(RP.scoreValueFontSize, this.isSmallScreen))
                      .fontColor('#FFFFFF')
                      .fontWeight(FontWeight.Bold)
                      .layoutWeight(1)

                    Text(record.date)
                      .fontSize(getSizeValue(RP.dateFontSize, this.isSmallScreen))
                      .fontColor('rgba(255,255,255,0.4)')
                  }
                  .width('100%')

                  Row() {
                    Text(`命中 ${record.hits}`)
                      .fontSize(this.isSmallScreen ? 11 : 13)
                      .fontColor('#4ECDC4')

                    Text(`失误 ${record.misses}`)
                      .fontSize(this.isSmallScreen ? 11 : 13)
                      .fontColor('#FF6B6B')
                      .margin({ left: 12 })

                    Text(`连击 x${record.maxCombo}`)
                      .fontSize(this.isSmallScreen ? 11 : 13)
                      .fontColor('#FFD700')
                      .margin({ left: 12 })

                    Text(`${record.avgReactionMs}ms`)
                      .fontSize(this.isSmallScreen ? 11 : 13)
                      .fontColor('#667eea')
                      .margin({ left: 12 })
                  }
                  .margin({ top: 6 })
                }
                .width('100%')
                .padding(getSizeValue(RP.listItemPadding, this.isSmallScreen))
                .backgroundColor('rgba(255, 255, 255, 0.06)')
                .borderRadius(12)
                .border({ width: 1, color: 'rgba(255,255,255,0.06)' })
                .margin({ bottom: 10 })
              }
            }, (record: GameRecord, index: number) => index.toString())
          }
          .width('90%')
          .height(getStringValue(RP.listHeight, this.isSmallScreen))
          .margin({ top: getSizeValue(RP.listMarginTop, this.isSmallScreen) })
          .padding({ left: 10, right: 10 })
        } else {
          Column() {
            Text('暂无游戏记录')
              .fontSize(getSizeValue(RP.emptyTextFontSize, this.isSmallScreen))
              .fontColor('#CCCCCC')
              .margin({ top: getSizeValue(RP.emptyTextMarginTop, this.isSmallScreen) })
          }
          .width('90%')
          .height(getStringValue(RP.listHeight, this.isSmallScreen))
        }

        Row() {
          Button('返回首页')
            .width(getSizeValue(RP.buttonWidth, this.isSmallScreen))
            .height(getSizeValue(RP.buttonHeight, this.isSmallScreen))
            .fontSize(getSizeValue(RP.buttonFontSize, this.isSmallScreen))
            .backgroundColor('#4ECDC4')
            .borderRadius(28)
            .shadow({ radius: 8, color: 'rgba(78,205,196,0.4)', offsetX: 0, offsetY: 3 })
            .onClick(() => {
              router.back();
            })

          if (this.records.length > 0) {
            Button('清除记录')
              .width(getSizeValue(RP.buttonWidth, this.isSmallScreen))
              .height(getSizeValue(RP.buttonHeight, this.isSmallScreen))
              .fontSize(getSizeValue(RP.buttonFontSize, this.isSmallScreen))
              .backgroundColor('#FF6B6B')
              .borderRadius(28)
              .shadow({ radius: 8, color: 'rgba(255,107,107,0.4)', offsetX: 0, offsetY: 3 })
              .margin({ left: 20 })
              .onClick(() => {
                clearGameRecords();
                this.records = [];
              })
          }
        }
        .margin({ top: getSizeValue(RP.buttonMarginTop, this.isSmallScreen) })
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
