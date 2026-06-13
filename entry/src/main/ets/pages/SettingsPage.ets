import { SocketManager, ConnectionStatus } from '../common/SocketManager';
import { SettingsViewModel } from '../viewmodel/SettingsViewModel';
import {
  COLOR_BG_DARK, COLOR_BG_CARD, COLOR_BG_INPUT, COLOR_TEXT_PRIMARY,
  COLOR_TEXT_SECONDARY, COLOR_TEXT_MUTED, COLOR_ACCENT_BLUE,
  COLOR_ACCENT_GREEN, COLOR_ACCENT_RED, COLOR_ACCENT_YELLOW
} from '../common/Constants';

@Component
export struct SettingsPage {
  @State serverUrl: string = ''
  @State connectionStatus: ConnectionStatus = ConnectionStatus.DISCONNECTED
  @State statusText: string = 'Disconnected'
  private socketManager: SocketManager = SocketManager.getInstance()
  private settingsVM: SettingsViewModel = new SettingsViewModel()
  private onStatusFn: (status: ConnectionStatus) => void = () => {}

  aboutToAppear(): void {
    let hostCtx = this.getUIContext().getHostContext()
    if (hostCtx) {
      this.settingsVM.init(hostCtx).then(() => {
        this.serverUrl = this.settingsVM.serverUrl
      })
    }
    this.connectionStatus = this.socketManager.getStatus()
    this.onStatusFn = (status: ConnectionStatus) => {
      this.connectionStatus = status
      this.updateStatusText()
    }
    this.socketManager.onStatusChange(this.onStatusFn)
    this.updateStatusText()
  }

  aboutToDisappear(): void {
    this.socketManager.offStatusChange(this.onStatusFn)
  }

  updateStatusText(): void {
    switch (this.connectionStatus) {
      case ConnectionStatus.CONNECTED:
        this.statusText = 'Connected'
        break
      case ConnectionStatus.CONNECTING:
        this.statusText = 'Connecting...'
        break
      case ConnectionStatus.RECONNECTING:
        this.statusText = 'Reconnecting...'
        break
      case ConnectionStatus.ERROR:
        this.statusText = 'Connection Error'
        break
      default:
        this.statusText = 'Disconnected'
    }
  }

  handleConnect(): void {
    if (this.connectionStatus === ConnectionStatus.CONNECTED ||
        this.connectionStatus === ConnectionStatus.CONNECTING) {
      this.socketManager.disconnect()
    } else {
      this.settingsVM.saveServerUrl(this.serverUrl)
      this.socketManager.connect(this.serverUrl)
    }
  }

  getButtonText(): string {
    if (this.connectionStatus === ConnectionStatus.CONNECTED) {
      return 'Disconnect'
    }
    if (this.connectionStatus === ConnectionStatus.CONNECTING ||
        this.connectionStatus === ConnectionStatus.RECONNECTING) {
      return 'Connecting...'
    }
    return 'Connect'
  }

  isConnecting(): boolean {
    return this.connectionStatus === ConnectionStatus.CONNECTING ||
      this.connectionStatus === ConnectionStatus.RECONNECTING
  }

  build() {
    Column() {
      Text('Settings')
        .fontSize(20)
        .fontColor(COLOR_TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .padding({ left: 16, top: 12, bottom: 16 })
        .textAlign(TextAlign.Start)

      Column() {
        Row() {
          Circle({ width: 10, height: 10 })
            .fill(this.statusDotColor())
            .margin({ right: 8 })

          Text(this.statusText)
            .fontSize(15)
            .fontColor(COLOR_TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)

          Blank()

          Button(this.getButtonText())
            .fontSize(13)
            .fontColor('#ffffff')
            .backgroundColor(this.getButtonColor())
            .borderRadius(18)
            .height(36)
            .padding({ left: 20, right: 20 })
            .enabled(!this.isConnecting())
            .onClick(() => this.handleConnect())
        }
        .width('100%')
        .padding(16)
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .backgroundColor(COLOR_BG_CARD)
      .borderRadius(12)
      .padding(0)
      .margin({ left: 12, right: 12 })

      Column() {
        Text('Server Address')
          .fontSize(12)
          .fontColor(COLOR_TEXT_MUTED)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .margin({ bottom: 8 })
          .textAlign(TextAlign.Start)

        TextInput({ placeholder: 'ws://192.168.1.100:3000', text: this.serverUrl })
          .fontColor(COLOR_TEXT_PRIMARY)
          .fontFamily('monospace')
          .backgroundColor(COLOR_BG_INPUT)
          .borderRadius(10)
          .height(46)
          .padding({ left: 14, right: 14 })
          .width('100%')
          .onChange((value: string) => {
            this.serverUrl = value
          })
      }
      .width('100%')
      .backgroundColor(COLOR_BG_CARD)
      .borderRadius(12)
      .padding(16)
      .margin({ left: 12, right: 12, top: 12 })

      Column() {
        Text('How to use')
          .fontSize(14)
          .fontColor(COLOR_TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .margin({ bottom: 8 })
          .textAlign(TextAlign.Start)

        Text(
          '1. Run the server on your PC:\n' +
          '   cd server-opencode && npm start\n\n' +
          '2. Ensure phone and PC are on the same WiFi\n\n' +
          '3. Enter the PC\'s IP address above\n' +
          '   (e.g., ws://192.168.1.100:3000)\n\n' +
          '4. Tap Connect to start controlling opencode\n\n' +
          '5. In Chat tab, type coding questions/instructions\n' +
          '   and opencode will respond in real-time'
        )
          .fontSize(12)
          .fontColor(COLOR_TEXT_SECONDARY)
          .width('100%')
          .lineHeight(20)
      }
      .width('100%')
      .backgroundColor(COLOR_BG_CARD)
      .borderRadius(12)
      .padding(16)
      .margin({ left: 12, right: 12, top: 12 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLOR_BG_DARK)
  }

  statusDotColor(): ResourceColor {
    switch (this.connectionStatus) {
      case ConnectionStatus.CONNECTED:
        return COLOR_ACCENT_GREEN
      case ConnectionStatus.CONNECTING:
      case ConnectionStatus.RECONNECTING:
        return COLOR_ACCENT_YELLOW
      default:
        return COLOR_ACCENT_RED
    }
  }

  getButtonColor(): ResourceColor {
    if (this.connectionStatus === ConnectionStatus.CONNECTED) {
      return COLOR_ACCENT_RED
    }
    return COLOR_ACCENT_BLUE
  }
}
