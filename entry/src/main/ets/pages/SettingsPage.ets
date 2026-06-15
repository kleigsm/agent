import { SocketManager, ConnectionStatus } from '../common/SocketManager';
import { SettingsViewModel } from '../viewmodel/SettingsViewModel';
import { DiscoveryManager } from '../common/DiscoveryManager';
import { DiscoveredServer } from '../common/Models';
import {
  COLOR_BG_PRIMARY, COLOR_BG_SECONDARY, COLOR_BG_INPUT,
  COLOR_TEXT_PRIMARY, COLOR_TEXT_SECONDARY, COLOR_TEXT_MUTED,
  COLOR_ACCENT_BLUE, COLOR_ACCENT_GREEN, COLOR_ACCENT_RED,
  COLOR_ACCENT_ORANGE, COLOR_STATUS_ONLINE, COLOR_STATUS_OFFLINE,
  COLOR_STATUS_WARNING, COLOR_BORDER, COLOR_BORDER_FOCUS,
  SPACE_SM, SPACE_MD, SPACE_LG, SPACE_XL,
  RADIUS_MD, RADIUS_LG, FONT_BODY, FONT_BODY_LG, FONT_HEADING,
  ANIM_DURATION_NORMAL, GRADIENT_ACCENT
} from '../common/Constants';

@Component
export struct SettingsPage {
  @State serverUrl: string = ''
  @State authToken: string = ''
  @State connectionStatus: ConnectionStatus = ConnectionStatus.DISCONNECTED
  @State statusText: string = 'Disconnected'
  @State isScanning: boolean = false
  @State discoveredServers: DiscoveredServer[] = []
  @State errorMessage: string = ''
  private socketManager: SocketManager = SocketManager.getInstance()
  private settingsVM: SettingsViewModel = new SettingsViewModel()
  private discovery: DiscoveryManager = DiscoveryManager.getInstance()
  private onStatusFn: (status: ConnectionStatus) => void = () => {}
  private onErrorFn: (error: string) => void = () => {}

  aboutToAppear(): void {
    let hostCtx = this.getUIContext().getHostContext()
    if (hostCtx) {
      this.settingsVM.init(hostCtx).then(() => {
        this.serverUrl = this.settingsVM.serverUrl
        this.authToken = this.settingsVM.authToken
      })
    }
    this.connectionStatus = this.socketManager.getStatus()
    this.authToken = this.socketManager.getAuthToken()

    this.onStatusFn = (status: ConnectionStatus) => {
      this.connectionStatus = status
      this.updateStatusText()
    }
    this.onErrorFn = (error: string) => {
      this.errorMessage = error
    }
    this.socketManager.onStatusChange(this.onStatusFn)
    this.socketManager.onError(this.onErrorFn)
    this.updateStatusText()
  }

  aboutToDisappear(): void {
    this.socketManager.offStatusChange(this.onStatusFn)
    this.socketManager.offError(this.onErrorFn)
  }

  updateStatusText(): void {
    switch (this.connectionStatus) {
      case ConnectionStatus.CONNECTED:
        this.statusText = 'Connected'
        this.errorMessage = ''
        break
      case ConnectionStatus.CONNECTING:
        this.statusText = 'Connecting...'
        break
      case ConnectionStatus.RECONNECTING:
        this.statusText = 'Reconnecting...'
        break
      case ConnectionStatus.ERROR:
        this.statusText = 'Error'
        break
      default:
        this.statusText = 'Disconnected'
    }
  }

  handleConnect(): void {
    this.errorMessage = ''
    if (this.connectionStatus === ConnectionStatus.CONNECTED ||
        this.connectionStatus === ConnectionStatus.CONNECTING) {
      this.socketManager.disconnect()
    } else {
      this.settingsVM.saveServerUrl(this.serverUrl, this.authToken)
      this.socketManager.setAuthToken(this.authToken)
      this.socketManager.connect(this.serverUrl, this.authToken)
    }
  }

  async scanNetwork(): Promise<void> {
    this.isScanning = true
    this.discoveredServers = []
    this.discovery.clearServers()

    await this.discovery.scanNetwork((server: DiscoveredServer) => {
      this.discoveredServers = [...this.discovery.getServers()]
    })

    this.isScanning = false
  }

  selectServer(server: DiscoveredServer): void {
    this.serverUrl = 'ws://' + server.host + ':' + server.port
    this.authToken = server.token || ''
  }

  getButtonText(): string {
    if (this.connectionStatus === ConnectionStatus.CONNECTED) return 'Disconnect'
    if (this.connectionStatus === ConnectionStatus.CONNECTING ||
        this.connectionStatus === ConnectionStatus.RECONNECTING) return '...'
    return 'Connect'
  }

  isConnecting(): boolean {
    return this.connectionStatus === ConnectionStatus.CONNECTING ||
      this.connectionStatus === ConnectionStatus.RECONNECTING
  }

  statusDotColor(): ResourceColor {
    switch (this.connectionStatus) {
      case ConnectionStatus.CONNECTED: return COLOR_STATUS_ONLINE
      case ConnectionStatus.CONNECTING:
      case ConnectionStatus.RECONNECTING: return COLOR_STATUS_WARNING
      default: return COLOR_STATUS_OFFLINE
    }
  }

  getButtonColor(): ResourceColor {
    if (this.connectionStatus === ConnectionStatus.CONNECTED) return COLOR_ACCENT_RED
    return COLOR_ACCENT_BLUE
  }

  build() {
    Column() {
      // ── Header ──
      Text('Settings')
        .fontSize(FONT_HEADING)
        .fontColor(COLOR_TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .padding({ left: SPACE_XL, top: SPACE_LG, bottom: SPACE_LG })
        .textAlign(TextAlign.Start)

      // ── Connection Status Card ──
      Column() {
        Row() {
          Circle({ width: 12, height: 12 })
            .fill(this.statusDotColor())

          Text(this.statusText)
            .fontSize(FONT_BODY_LG)
            .fontColor(COLOR_TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
            .margin({ left: SPACE_SM })

          Blank()

          Button(this.getButtonText())
            .fontSize(FONT_BODY)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)
            .backgroundColor(this.getButtonColor())
            .borderRadius(RADIUS_MD)
            .height(40)
            .padding({ left: SPACE_XL, right: SPACE_XL })
            .enabled(!this.isConnecting())
            .onClick(() => this.handleConnect())
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        if (this.errorMessage) {
          Text(this.errorMessage)
            .fontSize(FONT_BODY)
            .fontColor(COLOR_ACCENT_RED)
            .margin({ top: SPACE_SM })
            .width('100%')
        }
      }
      .width('100%')
      .backgroundColor(COLOR_BG_SECONDARY)
      .borderRadius(RADIUS_LG)
      .padding(SPACE_LG)
      .margin({ left: SPACE_LG, right: SPACE_LG })

      // ── Server Address ──
      Column() {
        Text('Server Address')
          .fontSize(12)
          .fontColor(COLOR_TEXT_MUTED)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .margin({ bottom: SPACE_SM })
          .textAlign(TextAlign.Start)

        TextInput({ placeholder: 'ws://192.168.1.100:3000', text: this.serverUrl })
          .fontColor(COLOR_TEXT_PRIMARY)
          .fontFamily('monospace')
          .backgroundColor(COLOR_BG_INPUT)
          .borderRadius(RADIUS_MD)
          .borderWidth(1)
          .borderColor(COLOR_BORDER)
          .height(48)
          .padding({ left: SPACE_LG, right: SPACE_LG })
          .width('100%')
          .onChange((value: string) => { this.serverUrl = value })
          .onFocus(() => { })
      }
      .width('100%')
      .backgroundColor(COLOR_BG_SECONDARY)
      .borderRadius(RADIUS_LG)
      .padding(SPACE_LG)
      .margin({ left: SPACE_LG, right: SPACE_LG, top: SPACE_MD })

      // ── Auth Token ──
      Column() {
        Text('Auth Token')
          .fontSize(12)
          .fontColor(COLOR_TEXT_MUTED)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .margin({ bottom: SPACE_SM })
          .textAlign(TextAlign.Start)

        TextInput({ placeholder: 'Enter server token...', text: this.authToken })
          .fontColor(COLOR_TEXT_PRIMARY)
          .fontFamily('monospace')
          .backgroundColor(COLOR_BG_INPUT)
          .borderRadius(RADIUS_MD)
          .borderWidth(1)
          .borderColor(COLOR_BORDER)
          .height(48)
          .padding({ left: SPACE_LG, right: SPACE_LG })
          .width('100%')
          .type(InputType.Password)
          .onChange((value: string) => { this.authToken = value })
      }
      .width('100%')
      .backgroundColor(COLOR_BG_SECONDARY)
      .borderRadius(RADIUS_LG)
      .padding(SPACE_LG)
      .margin({ left: SPACE_LG, right: SPACE_LG, top: SPACE_MD })

      // ── Network Scan ──
      Column() {
        Row() {
          Text('Find Servers')
            .fontSize(FONT_BODY)
            .fontColor(COLOR_TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)

          Button(this.isScanning ? 'Scanning...' : 'Scan Network')
            .fontSize(FONT_BODY)
            .fontColor(this.isScanning ? COLOR_TEXT_SECONDARY : COLOR_ACCENT_BLUE)
            .backgroundColor(COLOR_BG_INPUT)
            .borderRadius(RADIUS_MD)
            .borderWidth(1)
            .borderColor(COLOR_BORDER)
            .height(36)
            .padding({ left: SPACE_LG, right: SPACE_LG })
            .enabled(!this.isScanning)
            .onClick(() => this.scanNetwork())
        }
        .width('100%')

        if (this.isScanning) {
          LoadingProgress()
            .width(24).height(24)
            .color(COLOR_ACCENT_BLUE)
            .margin({ top: SPACE_MD })
        }

        if (this.discoveredServers.length > 0) {
          ForEach(this.discoveredServers, (server: DiscoveredServer) => {
            Row() {
              Column() {
                Text('ws://' + server.host + ':' + server.port)
                  .fontSize(FONT_BODY)
                  .fontColor(COLOR_TEXT_PRIMARY)
                  .fontFamily('monospace')

                Text('Token: ' + server.token.substring(0, 8) + '...')
                  .fontSize(12)
                  .fontColor(COLOR_TEXT_MUTED)
                  .margin({ top: 2 })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Button('Use')
                .fontSize(12)
                .fontColor('#FFFFFF')
                .backgroundColor(COLOR_ACCENT_BLUE)
                .borderRadius(RADIUS_MD)
                .height(32)
                .padding({ left: SPACE_MD, right: SPACE_MD })
                .onClick(() => this.selectServer(server))
            }
            .width('100%')
            .padding({ top: SPACE_SM, bottom: SPACE_SM })
            .border({ width: { top: 1 }, color: COLOR_BORDER })
          }, (server: DiscoveredServer) => server.host + ':' + server.port)
        }
      }
      .width('100%')
      .backgroundColor(COLOR_BG_SECONDARY)
      .borderRadius(RADIUS_LG)
      .padding(SPACE_LG)
      .margin({ left: SPACE_LG, right: SPACE_LG, top: SPACE_MD })

      // ── Help ──
      Column() {
        Text('How to use')
          .fontSize(FONT_BODY)
          .fontColor(COLOR_TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .margin({ bottom: SPACE_SM })
          .textAlign(TextAlign.Start)

        Text(
          '1. Run "npm start" in the bridge folder on your PC\n' +
          '2. Copy the token shown in the PC terminal\n' +
          '3. Enter the PC IP + token above\n' +
          '   (or tap Scan Network to find it)\n' +
          '4. Tap Connect\n' +
          '5. Switch to Chat tab to start coding'
        )
          .fontSize(12)
          .fontColor(COLOR_TEXT_SECONDARY)
          .width('100%')
          .lineHeight(20)
      }
      .width('100%')
      .backgroundColor(COLOR_BG_SECONDARY)
      .borderRadius(RADIUS_LG)
      .padding(SPACE_LG)
      .margin({ left: SPACE_LG, right: SPACE_LG, top: SPACE_MD })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLOR_BG_PRIMARY)
  }
}
