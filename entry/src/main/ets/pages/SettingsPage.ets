import { SocketManager, ConnectionStatus } from '../common/SocketManager';
import { SettingsViewModel } from '../viewmodel/SettingsViewModel';
import { DiscoveryManager } from '../common/DiscoveryManager';
import { DiscoveredServer } from '../common/Models';
import {
  COLOR_BG_PRIMARY, COLOR_BG_SECONDARY, COLOR_BG_INPUT,
  COLOR_TEXT_PRIMARY, COLOR_TEXT_SECONDARY, COLOR_TEXT_MUTED,
  COLOR_ACCENT_BLUE, COLOR_ACCENT_GREEN, COLOR_ACCENT_RED,
  COLOR_ACCENT_ORANGE, COLOR_BORDER, COLOR_GLASS_BG, COLOR_GLASS_BORDER,
  SPACE_SM, SPACE_MD, SPACE_LG, SPACE_XL,
  RADIUS_MD, RADIUS_LG,
  FONT_CAPTION, FONT_BODY_SM, FONT_BODY, FONT_BODY_LG, FONT_HEADING
} from '../common/Constants';

@Component
export struct SettingsPage {
  @State serverUrl: string = ''
  @State authToken: string = ''
  @State connectionStatus: ConnectionStatus = ConnectionStatus.DISCONNECTED
  @State statusText: string = '未连接'
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
    this.onErrorFn = (error: string) => { this.errorMessage = error }
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
      case ConnectionStatus.CONNECTED: this.statusText = '已连接'; this.errorMessage = ''; break
      case ConnectionStatus.CONNECTING: this.statusText = '连接中...'; break
      case ConnectionStatus.RECONNECTING: this.statusText = '重连中...'; break
      case ConnectionStatus.ERROR: this.statusText = '错误'; break
      default: this.statusText = '未连接'
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
    if (this.connectionStatus === ConnectionStatus.CONNECTED) return '断开'
    if (this.connectionStatus === ConnectionStatus.CONNECTING ||
        this.connectionStatus === ConnectionStatus.RECONNECTING) return '...'
    return '连接'
  }

  isConnecting(): boolean {
    return this.connectionStatus === ConnectionStatus.CONNECTING ||
      this.connectionStatus === ConnectionStatus.RECONNECTING
  }

  statusDotColor(): ResourceColor {
    switch (this.connectionStatus) {
      case ConnectionStatus.CONNECTED: return COLOR_ACCENT_GREEN
      case ConnectionStatus.CONNECTING:
      case ConnectionStatus.RECONNECTING: return COLOR_ACCENT_ORANGE
      default: return COLOR_ACCENT_RED
    }
  }

  build() {
    Column() {
      Text('设置')
        .fontSize(FONT_HEADING)
        .fontColor(COLOR_TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .padding({ left: SPACE_XL, top: SPACE_LG, bottom: SPACE_LG })
        .textAlign(TextAlign.Start)

      // ── 连接状态卡 ──
      Column() {
        Row() {
          Circle({ width: 14, height: 14 })
            .fill(this.statusDotColor())
            .shadow(this.connectionStatus === ConnectionStatus.CONNECTED
              ? { radius: 8, color: COLOR_ACCENT_GREEN + '40', offsetY: 0 }
              : { radius: 0, color: '#00000000', offsetY: 0 })

          Text(this.statusText)
            .fontSize(FONT_BODY_LG)
            .fontColor(COLOR_TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
            .margin({ left: SPACE_SM })

          Blank()

          Button(this.getButtonText())
            .fontSize(14)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)
            .backgroundColor(this.connectionStatus === ConnectionStatus.CONNECTED
              ? COLOR_ACCENT_RED : COLOR_ACCENT_BLUE)
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
            .fontSize(13)
            .fontColor(COLOR_ACCENT_RED)
            .margin({ top: SPACE_SM })
            .width('100%')
        }
      }
      .width('100%')
      .backgroundColor(COLOR_GLASS_BG)
      .borderRadius(RADIUS_LG)
      .borderWidth(1)
      .borderColor(COLOR_GLASS_BORDER)
      .padding(SPACE_LG)
      .margin({ left: SPACE_LG, right: SPACE_LG })

      // ── 服务器地址 ──
      Column() {
        Text('服务器地址')
          .fontSize(12)
          .fontColor(COLOR_TEXT_MUTED)
          .margin({ bottom: SPACE_SM })

        TextInput({ placeholder: 'ws://192.168.1.100:3000', text: this.serverUrl })
          .fontColor(COLOR_TEXT_PRIMARY)
          .fontFamily('monospace')
          .fontSize(14)
          .backgroundColor(COLOR_BG_INPUT)
          .borderRadius(RADIUS_MD)
          .borderWidth(1)
          .borderColor(COLOR_BORDER)
          .height(48)
          .padding({ left: SPACE_LG })
          .width('100%')
          .onChange((value: string) => { this.serverUrl = value })
      }
      .width('100%')
      .backgroundColor(COLOR_GLASS_BG)
      .borderRadius(RADIUS_LG)
      .borderWidth(1)
      .borderColor(COLOR_GLASS_BORDER)
      .padding(SPACE_LG)
      .margin({ left: SPACE_LG, right: SPACE_LG, top: SPACE_MD })

      // ── 认证令牌 ──
      Column() {
        Text('认证令牌')
          .fontSize(12)
          .fontColor(COLOR_TEXT_MUTED)
          .margin({ bottom: SPACE_SM })

        TextInput({ placeholder: '输入服务器令牌...', text: this.authToken })
          .fontColor(COLOR_TEXT_PRIMARY)
          .fontFamily('monospace')
          .fontSize(14)
          .backgroundColor(COLOR_BG_INPUT)
          .borderRadius(RADIUS_MD)
          .borderWidth(1)
          .borderColor(COLOR_BORDER)
          .height(48)
          .padding({ left: SPACE_LG })
          .width('100%')
          .type(InputType.Password)
          .onChange((value: string) => { this.authToken = value })
      }
      .width('100%')
      .backgroundColor(COLOR_GLASS_BG)
      .borderRadius(RADIUS_LG)
      .borderWidth(1)
      .borderColor(COLOR_GLASS_BORDER)
      .padding(SPACE_LG)
      .margin({ left: SPACE_LG, right: SPACE_LG, top: SPACE_MD })

      // ── 网络扫描 ──
      Column() {
        Row() {
          Text('发现服务器')
            .fontSize(14)
            .fontColor(COLOR_TEXT_PRIMARY)
            .layoutWeight(1)
          Button(this.isScanning ? '扫描中...' : '扫描网络')
            .fontSize(13)
            .fontColor(this.isScanning ? COLOR_TEXT_SECONDARY : COLOR_ACCENT_BLUE)
            .backgroundColor(COLOR_BG_INPUT)
            .borderRadius(RADIUS_MD)
            .borderWidth(1)
            .borderColor(COLOR_BORDER)
            .height(34)
            .enabled(!this.isScanning)
            .onClick(() => this.scanNetwork())
        }
        .width('100%')

        if (this.isScanning) {
          LoadingProgress().width(22).height(22).color(COLOR_ACCENT_BLUE).margin({ top: SPACE_MD })
        }

        ForEach(this.discoveredServers, (server: DiscoveredServer) => {
          Row() {
            Column() {
              Text('ws://' + server.host + ':' + server.port)
                .fontSize(13).fontColor(COLOR_TEXT_PRIMARY).fontFamily('monospace')
              Text('令牌: ' + server.token.substring(0, 10) + '...')
                .fontSize(11).fontColor(COLOR_TEXT_MUTED).margin({ top: 2 })
            }
            .layoutWeight(1).alignItems(HorizontalAlign.Start)
            Button('使用').fontSize(11).fontColor('#FFFFFF')
              .backgroundColor(COLOR_ACCENT_BLUE).borderRadius(RADIUS_MD).height(30)
              .onClick(() => this.selectServer(server))
          }
          .width('100%').padding({ top: SPACE_SM }).border({ width: { top: 0.5 }, color: COLOR_BORDER })
        }, (server: DiscoveredServer) => server.host + ':' + server.port)
      }
      .width('100%')
      .backgroundColor(COLOR_GLASS_BG)
      .borderRadius(RADIUS_LG)
      .borderWidth(1)
      .borderColor(COLOR_GLASS_BORDER)
      .padding(SPACE_LG)
      .margin({ left: SPACE_LG, right: SPACE_LG, top: SPACE_MD })

      // ── 帮助 ──
      Text(
        '1. 在 PC 上运行 npm start\n' +
        '2. 复制终端中显示的令牌\n' +
        '3. 填写服务器地址和令牌\n' +
        '4. 点击"连接"'
      )
        .fontSize(11)
        .fontColor(COLOR_TEXT_MUTED)
        .width('100%')
        .padding(SPACE_LG)
        .lineHeight(20)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLOR_BG_PRIMARY)
  }
}
