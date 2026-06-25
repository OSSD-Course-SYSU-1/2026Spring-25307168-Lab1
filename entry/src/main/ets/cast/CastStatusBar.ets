import { CastConnectionState } from './DeviceCastManager';
import { CastUI, getSizeValue } from '../constants/LayoutConstants';

/**
 * 投送状态栏组件
 * 在游戏页面顶部显示当前投送状态
 */
@Component
export struct CastStatusBar {
  // 连接状态
  @Prop connectionState: CastConnectionState = CastConnectionState.DISCONNECTED;

  // 目标设备名称
  @Prop targetDeviceName: string = '';

  // 是否为小屏
  @Prop isSmallScreen: boolean = false;

  // 断开连接回调
  onDisconnect: () => void = () => {};

  build() {
    if (this.connectionState === CastConnectionState.CONNECTED) {
      Row() {
        // 投送图标
        Text('📡')
          .fontSize(getSizeValue(CastUI.deviceNameFontSize, this.isSmallScreen))
          .margin({ right: 8 })

        // 状态文本
        Text(`已连接至 ${this.targetDeviceName}`)
          .fontSize(getSizeValue(CastUI.statusBarFontSize, this.isSmallScreen))
          .fontColor('#FFFFFF')
          .layoutWeight(1)

        // 断开按钮
        Button('断开')
          .height(getSizeValue(CastUI.connectButtonHeight, this.isSmallScreen) * 0.8)
          .fontSize(getSizeValue(CastUI.connectButtonFontSize, this.isSmallScreen))
          .fontColor('#FFFFFF')
          .backgroundColor('#FF6B6B')
          .borderRadius(12)
          .onClick(() => {
            this.onDisconnect();
          })
      }
      .width('90%')
      .height(getSizeValue(CastUI.statusBarHeight, this.isSmallScreen))
      .padding({ left: 15, right: 15 })
      .backgroundColor('rgba(78, 205, 196, 0.3)')
      .borderRadius(12)
      .alignItems(VerticalAlign.Center)
    }
  }
}