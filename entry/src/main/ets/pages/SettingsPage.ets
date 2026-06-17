import { SocketManager, ConnectionStatus } from '../common/SocketManager';
import { SettingsViewModel } from '../viewmodel/SettingsViewModel';
import { DiscoveryManager } from '../common/DiscoveryManager';
import { DiscoveredServer, ConnectionHistory } from '../common/Models';
import {
  SPACE_SM, SPACE_MD, SPACE_LG, SPACE_XL,
  RADIUS_MD, RADIUS_LG, RADIUS_FULL, FONT_CAPTION, FONT_BODY_SM, FONT_BODY, FONT_BODY_LG, FONT_HEADING,
  ANIM_DURATION_NORMAL, APP_VERSION, APP_NAME,
  getTheme, ThemeColors, LIGHT_THEME, DARK_THEME
} from '../common/Constants';
import { preferences } from '@kit.ArkData';

@Component
export struct SettingsPage {
  @State serverUrl: string = ''; @State authToken: string = ''; @State errorMessage: string = ''
  @State connectionStatus: ConnectionStatus = ConnectionStatus.DISCONNECTED
  @State statusText: string = '未连接'; @State isScanning: boolean = false
  @State discoveredServers: DiscoveredServer[] = [] @State connectionHistory: ConnectionHistory[] = []
  @StorageLink('isDarkMode') isDarkMode: boolean = false
  private theme: ThemeColors = LIGHT_THEME
  private socketManager: SocketManager = SocketManager.getInstance()
  private settingsVM: SettingsViewModel = new SettingsViewModel()
  private discovery: DiscoveryManager = DiscoveryManager.getInstance()
  private onStatusFn: (s: ConnectionStatus) => void = () => {}
  private onErrorFn: (e: string) => void = () => {}

  aboutToAppear(): void {
    let ctx = this.getUIContext().getHostContext()
    if (ctx) {
      this.settingsVM.init(ctx).then(() => {
        this.serverUrl = this.settingsVM.serverUrl; this.authToken = this.settingsVM.authToken
        this.connectionHistory = this.settingsVM.connectionHistory
      })
    }
    this.connectionStatus = this.socketManager.getStatus()
    this.authToken = this.socketManager.getAuthToken()
    this.onStatusFn = (s: ConnectionStatus) => { this.connectionStatus = s; this.updateStatusText() }
    this.onErrorFn = (e: string) => { this.errorMessage = e }
    this.socketManager.onStatusChange(this.onStatusFn); this.socketManager.onError(this.onErrorFn)
    this.updateStatusText()
  }
  aboutToDisappear(): void { this.socketManager.offStatusChange(this.onStatusFn); this.socketManager.offError(this.onErrorFn) }

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
    if (this.connectionStatus === ConnectionStatus.CONNECTED || this.connectionStatus === ConnectionStatus.CONNECTING) {
      this.socketManager.disconnect()
    } else {
      this.settingsVM.saveServerUrl(this.serverUrl, this.authToken)
      this.settingsVM.addConnectionHistory(this.serverUrl)
      this.connectionHistory = [...this.settingsVM.connectionHistory]
      this.socketManager.setAuthToken(this.authToken)
      this.socketManager.connect(this.serverUrl, this.authToken)
    }
  }

  async scanNetwork(): Promise<void> {
    this.isScanning = true; this.discoveredServers = []; this.discovery.clearServers()
    await this.discovery.scanNetwork((s: DiscoveredServer) => { this.discoveredServers = [...this.discovery.getServers()] })
    this.isScanning = false
  }

  selectServer(server: DiscoveredServer): void { this.serverUrl = 'ws://' + server.host + ':' + server.port; this.authToken = server.token || '' }

  getButtonText(): string {
    if (this.connectionStatus === ConnectionStatus.CONNECTED) return '断开'
    if (this.connectionStatus === ConnectionStatus.CONNECTING || this.connectionStatus === ConnectionStatus.RECONNECTING) return '...'
    return '连接'
  }
  isConnecting(): boolean {
    return this.connectionStatus === ConnectionStatus.CONNECTING || this.connectionStatus === ConnectionStatus.RECONNECTING
  }

  toggleTheme(): void { this.isDarkMode = !this.isDarkMode }

  formatTime(ts: number): string {
    let d = new Date(ts); return d.getHours().toString().padStart(2,'0') + ':' + d.getMinutes().toString().padStart(2,'0') + ' ' + (d.getMonth()+1) + '/' + d.getDate()
  }

  build() {
    this.theme = this.isDarkMode ? DARK_THEME : LIGHT_THEME

    Column() {
      Text('设置').fontSize(FONT_HEADING).fontColor(this.theme.textPrimary).fontWeight(FontWeight.Bold)
        .width('100%').padding({ left: SPACE_XL, top: SPACE_LG, bottom: SPACE_LG }).textAlign(TextAlign.Start)

      // Connection card
      Column() {
        Row() {
          Circle({ width: 14, height: 14 }).fill(this.connectionStatus === ConnectionStatus.CONNECTED ? this.theme.accentGreen : this.theme.accentRed)
            .shadow(this.connectionStatus === ConnectionStatus.CONNECTED ? { radius: 8, color: this.theme.accentGreen + '40', offsetY: 0 } : { radius: 0, color: '#00000000', offsetY: 0 })
          Text(this.statusText).fontSize(FONT_BODY_LG).fontColor(this.theme.textPrimary).fontWeight(FontWeight.Medium).margin({ left: SPACE_SM })
          Blank()
          Button(this.getButtonText()).fontSize(14).fontColor('#FFFFFF').fontWeight(FontWeight.Medium)
            .backgroundColor(this.connectionStatus === ConnectionStatus.CONNECTED ? this.theme.accentRed : this.theme.accentBlue)
            .borderRadius(RADIUS_MD).height(40).padding({ left: SPACE_XL, right: SPACE_XL })
            .enabled(!this.isConnecting()).onClick(() => this.handleConnect())
        }.width('100%').alignItems(VerticalAlign.Center)
        if (this.errorMessage) Text(this.errorMessage).fontSize(13).fontColor(this.theme.accentRed).margin({ top: SPACE_SM }).width('100%')
      }
      .width('100%').backgroundColor(this.theme.glassBg).borderRadius(RADIUS_LG).borderWidth(1).borderColor(this.theme.glassBorder)
      .padding(SPACE_LG).margin({ left: SPACE_LG, right: SPACE_LG })

      // Server URL
      Column() {
        Text('服务器地址').fontSize(12).fontColor(this.theme.textMuted).margin({ bottom: SPACE_SM })
        TextInput({ placeholder: 'ws://192.168.1.100:3000', text: this.serverUrl })
          .fontColor(this.theme.textPrimary).fontFamily('monospace').fontSize(14)
          .backgroundColor(this.theme.bgInput).borderRadius(RADIUS_MD).borderWidth(1).borderColor(this.theme.border)
          .height(48).padding({ left: SPACE_LG }).width('100%').onChange((v: string) => { this.serverUrl = v })
      }
      .width('100%').backgroundColor(this.theme.glassBg).borderRadius(RADIUS_LG).borderWidth(1).borderColor(this.theme.glassBorder)
      .padding(SPACE_LG).margin({ left: SPACE_LG, right: SPACE_LG, top: SPACE_MD })

      // Token
      Column() {
        Text('认证令牌').fontSize(12).fontColor(this.theme.textMuted).margin({ bottom: SPACE_SM })
        TextInput({ placeholder: '输入服务器令牌...', text: this.authToken })
          .fontColor(this.theme.textPrimary).fontFamily('monospace').fontSize(14)
          .backgroundColor(this.theme.bgInput).borderRadius(RADIUS_MD).borderWidth(1).borderColor(this.theme.border)
          .height(48).padding({ left: SPACE_LG }).width('100%').type(InputType.Password).onChange((v: string) => { this.authToken = v })
      }
      .width('100%').backgroundColor(this.theme.glassBg).borderRadius(RADIUS_LG).borderWidth(1).borderColor(this.theme.glassBorder)
      .padding(SPACE_LG).margin({ left: SPACE_LG, right: SPACE_LG, top: SPACE_MD })

      // Theme toggle
      Column() {
        Row() {
          Text('深色模式').fontSize(FONT_BODY).fontColor(this.theme.textPrimary).layoutWeight(1)
          Toggle({ type: ToggleType.Switch, isOn: this.isDarkMode })
            .onChange((v: boolean) => { this.isDarkMode = v })
        }.width('100%')
      }
      .width('100%').backgroundColor(this.theme.glassBg).borderRadius(RADIUS_LG).borderWidth(1).borderColor(this.theme.glassBorder)
      .padding(SPACE_LG).margin({ left: SPACE_LG, right: SPACE_LG, top: SPACE_MD })

      // Connection history
      if (this.connectionHistory.length > 0) {
        Column() {
          Text('连接历史').fontSize(12).fontColor(this.theme.textMuted).margin({ bottom: SPACE_SM })
          ForEach(this.connectionHistory, (h: ConnectionHistory) => {
            Row() {
              Text(h.url).fontSize(12).fontColor(this.theme.textPrimary).fontFamily('monospace').layoutWeight(1).maxLines(1)
              Text(this.formatTime(h.time)).fontSize(10).fontColor(this.theme.textMuted)
              Button('使用').fontSize(10).fontColor(this.theme.accentBlue).backgroundColor(Color.Transparent)
                .onClick(() => { this.serverUrl = h.url })
            }.width('100%').padding({ top: 4, bottom: 4 })
          }, (h: ConnectionHistory) => h.id)
        }
        .width('100%').backgroundColor(this.theme.glassBg).borderRadius(RADIUS_LG).borderWidth(1).borderColor(this.theme.glassBorder)
        .padding(SPACE_LG).margin({ left: SPACE_LG, right: SPACE_LG, top: SPACE_MD })
      }

      // About
      Column() {
        Text('关于').fontSize(FONT_BODY_SM).fontColor(this.theme.textPrimary).fontWeight(FontWeight.Bold).margin({ bottom: 4 })
        Text(APP_NAME + ' v' + APP_VERSION).fontSize(12).fontColor(this.theme.textMuted)
        Text('移动端编程智能体 · 鸿蒙远程开发').fontSize(11).fontColor(this.theme.textMuted).margin({ top: 2 })
      }
      .width('100%').padding({ left: SPACE_XL, right: SPACE_XL, top: SPACE_LG })
    }.width('100%').height('100%').backgroundColor(this.theme.bgPrimary)
  }
}
