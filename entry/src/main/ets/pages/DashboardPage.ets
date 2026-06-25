import {
  COLOR_BG_PRIMARY, C_BG_PRIMARY_DARK,
  COLOR_BG_SECONDARY, C_BG_SECONDARY_DARK,
  COLOR_TEXT_PRIMARY, C_TEXT_PRIMARY_DARK,
  COLOR_TEXT_SECONDARY, C_TEXT_SECONDARY_DARK,
  COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK,
  COLOR_ACCENT_BLUE, COLOR_ACCENT_GREEN, COLOR_ACCENT_ORANGE, COLOR_ACCENT_RED,
  COLOR_GLASS_BG, C_GLASS_BG_DARK,
  COLOR_BORDER, C_BORDER_DARK,
  SPACE_XS, SPACE_SM, SPACE_MD, SPACE_LG, SPACE_XL,
  RADIUS_LG, RADIUS_MD,
  dc, APP_NAME
} from '../common/Constants'
import { SocketManager, ConnectionStatus } from '../common/SocketManager'
import { DashboardViewModel, GitChange, GitCommit } from '../viewmodel/DashboardViewModel'
import { WsMessage } from '../common/Models'

@Component
export struct DashboardPage {
  @StorageLink('isDarkMode') isDark: boolean = false
  @State branch: string = ''
  @State changes: GitChange[] = []
  @State commits: GitCommit[] = []
  @State connected: boolean = false
  @State loading: boolean = false
  private vm: DashboardViewModel = new DashboardViewModel()
  private socket: SocketManager = SocketManager.getInstance()
  private onMsgFn: (m: WsMessage) => void = () => {}
  private onStatusFn: (s: ConnectionStatus) => void = () => {}

  aboutToAppear(): void {
    this.connected = this.socket.getStatus() === ConnectionStatus.CONNECTED
    this.vm.init(() => {
      this.branch = this.vm.branch
      this.changes = [...this.vm.changes]
      this.commits = [...this.vm.commits]
    })
    // Set up listener BEFORE refresh so we don't miss the response
    this.onMsgFn = (m: WsMessage) => { this.vm.handleMessage(m); this.refreshState() }
    this.socket.onMessage(this.onMsgFn)
    this.onStatusFn = (s: ConnectionStatus) => {
      this.connected = s === ConnectionStatus.CONNECTED
      if (this.connected) this.doRefresh()
    }
    this.socket.onStatusChange(this.onStatusFn)
    if (this.connected) this.doRefresh()
  }

  aboutToDisappear(): void {
    this.socket.offMessage(this.onMsgFn)
    this.socket.offStatusChange(this.onStatusFn)
  }

  doRefresh(): void {
    this.loading = true
    this.vm.refresh()
    // Timeout loading if no response in 5s
    setTimeout(() => { this.loading = false }, 5000)
  }

  refreshState(): void {
    this.branch = this.vm.branch
    this.changes = [...this.vm.changes]
    this.commits = [...this.vm.commits]
    this.loading = false
  }

  changeLabel(type: string): string {
    return this.vm.changeLabel(type)
  }

  changeColor(type: string): string {
    return this.vm.changeColor(type)
  }

  build() {
    Column() {
      // ── Header ──
      Row() {
        Text('📊 项目总览').fontSize(18).fontColor(dc(this.isDark, COLOR_TEXT_PRIMARY, C_TEXT_PRIMARY_DARK)).fontWeight(FontWeight.Bold)
        Blank()
        Circle({ width: 8, height: 8 }).fill(this.connected ? COLOR_ACCENT_GREEN : COLOR_ACCENT_RED)
        Text(this.connected ? ' 已连接' : ' 未连接').fontSize(11).fontColor(dc(this.isDark, COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK))
      }
      .width('100%').padding({ left: SPACE_LG, right: SPACE_LG, top: SPACE_SM + 2, bottom: SPACE_SM })
      .backgroundColor(dc(this.isDark, COLOR_GLASS_BG, C_GLASS_BG_DARK)).backdropBlur(12)

      if (!this.connected) {
        Column() {
          Text('🔌').fontSize(40).margin({ top: SPACE_XL })
          Text('未连接到 Bridge').fontSize(16).fontColor(dc(this.isDark, COLOR_TEXT_PRIMARY, C_TEXT_PRIMARY_DARK)).fontWeight(FontWeight.Bold)
          Text('请先在「设置」页连接服务器').fontSize(13).fontColor(dc(this.isDark, COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK)).margin({ top: SPACE_SM })
        }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        Column() {
          Column() {
            // ── Project info ──
            Row() {
              Text('📁 ' + APP_NAME).fontSize(16).fontColor(dc(this.isDark, COLOR_TEXT_PRIMARY, C_TEXT_PRIMARY_DARK)).fontWeight(FontWeight.Bold)
              Text('⎇ ' + (this.branch || 'master')).fontSize(12).fontColor(COLOR_ACCENT_BLUE).fontFamily('monospace')
                .backgroundColor(COLOR_ACCENT_BLUE + '12').borderRadius(6)
                .padding({ left: SPACE_SM, right: SPACE_SM, top: 2, bottom: 2 }).margin({ left: SPACE_SM })
              Blank()
              if (this.loading) {
                LoadingProgress().width(16).height(16).color(COLOR_ACCENT_BLUE)
              } else {
                Text('刷新').fontSize(12).fontColor(COLOR_ACCENT_BLUE)
                  .onClick(() => { this.doRefresh() })
              }
            }
            .width('100%').padding(SPACE_LG)
            .backgroundColor(dc(this.isDark, COLOR_BG_SECONDARY, C_BG_SECONDARY_DARK))
            .borderRadius(RADIUS_LG).margin({ left: SPACE_LG, right: SPACE_LG, top: SPACE_MD })

            // ── Changes ──
            Column() {
              Row() {
                Text('文件变更').fontSize(13).fontColor(dc(this.isDark, COLOR_TEXT_SECONDARY, C_TEXT_SECONDARY_DARK)).fontWeight(FontWeight.Medium)
                Blank()
                if (this.changes.length > 0) {
                  Text(this.changes.length + ' 个文件').fontSize(11).fontColor(dc(this.isDark, COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK))
                }
              }.width('100%').margin({ bottom: SPACE_SM })

              if (this.changes.length === 0) {
                Text('工作区干净 ✨').fontSize(12).fontColor(dc(this.isDark, COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK)).width('100%')
              }
              ForEach(this.changes.slice(0, 10), (ch: GitChange) => {
                Row() {
                  Text(this.changeLabel(ch.type)).fontSize(10).fontColor('#FFFFFF').fontFamily('monospace').fontWeight(FontWeight.Bold)
                    .backgroundColor(this.changeColor(ch.type)).borderRadius(4)
                    .padding({ left: 4, right: 4, top: 1, bottom: 1 })
                  Text(ch.text).fontSize(12).fontColor(dc(this.isDark, COLOR_TEXT_PRIMARY, C_TEXT_PRIMARY_DARK))
                    .fontFamily('monospace').margin({ left: SPACE_SM }).maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis }).layoutWeight(1)
                }.width('100%').padding({ top: 3, bottom: 3 })
              }, (ch: GitChange, i: number) => i.toString())
              if (this.changes.length > 10) {
                Text('... 还有 ' + (this.changes.length - 10) + ' 个文件').fontSize(11).fontColor(dc(this.isDark, COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK)).margin({ top: SPACE_XS })
              }
            }
            .width('100%').padding(SPACE_LG)
            .backgroundColor(dc(this.isDark, COLOR_BG_SECONDARY, C_BG_SECONDARY_DARK))
            .borderRadius(RADIUS_LG).margin({ left: SPACE_LG, right: SPACE_LG, top: SPACE_MD })

            // ── Recent commits ──
            Column() {
              Text('最近提交').fontSize(13).fontColor(dc(this.isDark, COLOR_TEXT_SECONDARY, C_TEXT_SECONDARY_DARK)).fontWeight(FontWeight.Medium)
                .width('100%').margin({ bottom: SPACE_SM })
              if (this.commits.length === 0) {
                Text('暂无提交记录').fontSize(12).fontColor(dc(this.isDark, COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK)).width('100%')
              }
              ForEach(this.commits, (c: GitCommit) => {
                Row() {
                  Text(c.hash.substring(0, 7)).fontSize(11).fontColor(COLOR_ACCENT_BLUE).fontFamily('monospace')
                    .backgroundColor(COLOR_ACCENT_BLUE + '12').borderRadius(4)
                    .padding({ left: 4, right: 4, top: 1, bottom: 1 })
                  Text(c.msg).fontSize(12).fontColor(dc(this.isDark, COLOR_TEXT_PRIMARY, C_TEXT_PRIMARY_DARK))
                    .margin({ left: SPACE_SM }).maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis }).layoutWeight(1)
                }.width('100%').padding({ top: 3, bottom: 3 })
              }, (c: GitCommit) => c.hash)
            }
            .width('100%').padding(SPACE_LG)
            .backgroundColor(dc(this.isDark, COLOR_BG_SECONDARY, C_BG_SECONDARY_DARK))
            .borderRadius(RADIUS_LG).margin({ left: SPACE_LG, right: SPACE_LG, top: SPACE_MD })

            Column().height(SPACE_XL)
          }.width('100%')
        }
        .layoutWeight(1).width('100%')
      }
    }
    .width('100%').height('100%').backgroundColor(dc(this.isDark, COLOR_BG_PRIMARY, C_BG_PRIMARY_DARK))
  }
}
