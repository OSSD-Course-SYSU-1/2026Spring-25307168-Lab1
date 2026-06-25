import { DeviceInfo, CastConnectionState } from './DeviceCastManager';
import { CastUI, getSizeValue, getStringValue } from '../constants/LayoutConstants';

/**
 * 设备选择面板
 * 使用 @CustomDialog 装饰器实现自定义弹窗
 */
@CustomDialog
export struct DeviceSelectPanel {
  // 对话框控制器
  controller: CustomDialogController;

  // 设备列表
  @State devices: DeviceInfo[] = [];

  // 连接状态
  @State connectionState: CastConnectionState = CastConnectionState.DISCONNECTED;

  // 是否正在搜索设备
  @State isDiscovering: boolean = false;

  // 是否为小屏
  @State isSmallScreen: boolean = false;

  // 设备选择回调
  onDeviceSelect: (deviceId: string) => void = () => {};

  // 关闭回调
  onClose: () => void = () => {};

  // 重试回调
  onRetry: () => void = () => {};

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('选择投送设备')
          .fontSize(getSizeValue(CastUI.panelTitleFontSize, this.isSmallScreen))
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        // 关闭按钮
        Button() {
          Text('✕')
            .fontSize(getSizeValue(CastUI.connectButtonFontSize, this.isSmallScreen))
            .fontColor('#FFFFFF')
        }
        .width(getSizeValue(CastUI.connectButtonHeight, this.isSmallScreen))
        .height(getSizeValue(CastUI.connectButtonHeight, this.isSmallScreen))
        .backgroundColor('rgba(255, 255, 255, 0.2)')
        .borderRadius(getSizeValue(CastUI.connectButtonHeight, this.isSmallScreen) / 2)
        .onClick(() => {
          this.controller.close();
          this.onClose();
        })
      }
      .width('100%')
      .margin({ bottom: 20 })

      // 搜索状态指示器
      if (this.isDiscovering) {
        Row() {
          LoadingProgress()
            .width(20)
            .height(20)
            .color('#FFFFFF')
            .margin({ right: 10 })

          Text('正在搜索附近设备...')
            .fontSize(getSizeValue(CastUI.deviceNameFontSize, this.isSmallScreen))
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding(20)
      }

      // 设备列表
      if (this.devices.length > 0) {
        List() {
          ForEach(this.devices, (device: DeviceInfo) => {
            ListItem() {
              Row() {
                // 设备类型图标
                Text(this.getDeviceIcon(device.deviceType))
                  .fontSize(getSizeValue(CastUI.panelTitleFontSize, this.isSmallScreen))
                  .margin({ right: 15 })

                // 设备名称
                Text(device.deviceName)
                  .fontSize(getSizeValue(CastUI.deviceNameFontSize, this.isSmallScreen))
                  .fontColor('#FFFFFF')
                  .layoutWeight(1)

                // 连接按钮
                Button(this.getConnectButtonText(device.deviceId))
                  .width(getSizeValue(CastUI.connectButtonWidth, this.isSmallScreen))
                  .height(getSizeValue(CastUI.connectButtonHeight, this.isSmallScreen))
                  .fontSize(getSizeValue(CastUI.connectButtonFontSize, this.isSmallScreen))
                  .fontColor('#FFFFFF')
                  .backgroundColor(this.getConnectButtonColor(device.deviceId))
                  .borderRadius(getSizeValue(CastUI.connectButtonHeight, this.isSmallScreen) / 2)
                  .enabled(this.connectionState !== CastConnectionState.CONNECTING)
                  .onClick(() => {
                    this.onDeviceSelect(device.deviceId);
                  })
              }
              .width('100%')
              .height(getSizeValue(CastUI.deviceItemHeight, this.isSmallScreen))
              .padding({ left: 15, right: 15 })
              .backgroundColor('rgba(255, 255, 255, 0.1)')
              .borderRadius(12)
              .margin({ bottom: 10 })
            }
          }, (device: DeviceInfo) => device.deviceId)
        }
        .width('100%')
        .layoutWeight(1)
      } else if (!this.isDiscovering) {
        // 空状态
        Column() {
          Text('未发现可用设备')
            .fontSize(getSizeValue(CastUI.deviceNameFontSize, this.isSmallScreen))
            .fontColor('#CCCCCC')
            .margin({ bottom: 20 })

          Button('重新搜索')
            .width(getSizeValue(CastUI.connectButtonWidth, this.isSmallScreen) * 1.5)
            .height(getSizeValue(CastUI.connectButtonHeight, this.isSmallScreen))
            .fontSize(getSizeValue(CastUI.connectButtonFontSize, this.isSmallScreen))
            .fontColor('#FFFFFF')
            .backgroundColor('#4ECDC4')
            .borderRadius(getSizeValue(CastUI.connectButtonHeight, this.isSmallScreen) / 2)
            .onClick(() => {
              this.onRetry();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .layoutWeight(1)
      }
    }
    .width(getStringValue(CastUI.panelWidth, this.isSmallScreen))
    .padding(25)
    .backgroundColor('rgba(30, 30, 60, 0.95)')
    .borderRadius(20)
  }

  /**
   * 获取设备类型图标
   */
  private getDeviceIcon(deviceType: string): string {
    switch (deviceType) {
      case 'phone':
        return '📱';
      case 'tablet':
        return '📟';
      case '2in1':
        return '💻';
      default:
        return '📱';
    }
  }

  /**
   * 获取连接按钮文本
   */
  private getConnectButtonText(deviceId: string): string {
    if (this.connectionState === CastConnectionState.CONNECTING && this.isCurrentDevice(deviceId)) {
      return '连接中';
    }
    if (this.connectionState === CastConnectionState.CONNECTED && this.isCurrentDevice(deviceId)) {
      return '已连接';
    }
    return '连接';
  }

  /**
   * 获取连接按钮颜色
   */
  private getConnectButtonColor(deviceId: string): string {
    if (this.connectionState === CastConnectionState.CONNECTED && this.isCurrentDevice(deviceId)) {
      return '#4ECDC4';
    }
    return '#667eea';
  }

  /**
   * 判断是否为当前连接的设备
   */
  private isCurrentDevice(deviceId: string): boolean {
    return false; // 由外部管理器维护
  }
}