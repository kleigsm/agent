import {
  COLOR_BG_PRIMARY, C_BG_PRIMARY_DARK,
  COLOR_BG_SECONDARY, C_BG_SECONDARY_DARK,
  COLOR_TEXT_PRIMARY, C_TEXT_PRIMARY_DARK,
  COLOR_TEXT_SECONDARY, C_TEXT_SECONDARY_DARK,
  COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK,
  COLOR_ACCENT_BLUE, COLOR_ACCENT_GREEN, COLOR_ACCENT_RED,
  COLOR_GLASS_BG, C_GLASS_BG_DARK,
  COLOR_GLASS_BORDER, C_GLASS_BORDER_DARK,
  COLOR_BORDER, C_BORDER_DARK,
  SPACE_XS, SPACE_SM, SPACE_MD, SPACE_LG, SPACE_XL,
  RADIUS_LG, dc, APP_NAME
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
  private vm: DashboardViewModel = new DashboardViewModel()
  private socket: SocketManager = SocketManager.getInstance()
  private onMsgFn: (m: WsMessage) => void = () => {}

  aboutToAppear(): void {
    this.connected = this.socket.getStatus() === ConnectionStatus.CONNECTED
    this.vm.init(() => {
      this.branch = this.vm.branch
      this.changes = [...this.vm.changes]
      this.commits = [...this.vm.commits]
    })
    this.onMsgFn = (m: WsMessage) => { this.vm.handleMessage(m); this.refreshState() }
    this.socket.onMessage(this.onMsgFn)
    if (this.connected) this.vm.refresh()
  }

  aboutToDisappear(): void {
    this.socket.offMessage(this.onMsgFn)
  }

  refreshState(): void {
    this.branch = this.vm.branch
    this.changes = [...this.vm.changes]
    this.commits = [...this.vm.commits]
    this.connected = this.vm.connected
  }

  getChangeType(ch: GitChange): string { return this.vm.changeLabel(ch.type) }
  getChangeColor(ch: GitChange): string { return this.vm.changeColor(ch.type) }

  build() {
    Column() {
      // ── Header ──
      Row() {
        Text('📊').fontSize(20)
        Text(' 总览').fontSize(18).fontColor(dc(this.isDark, COLOR_TEXT_PRIMARY, C_TEXT_PRIMARY_DARK)).fontWeight(FontWeight.Bold)
        Blank()
        Circle({ width: 8, height: 8 }).fill(this.connected ? COLOR_ACCENT_GREEN : COLOR_ACCENT_RED)
        Text(this.connected ? ' 已连接' : ' 未连接').fontSize(11).fontColor(dc(this.isDark, COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK)).margin({ left: SPACE_XS })
      }
      .width('100%').padding({ left: SPACE_LG, right: SPACE_LG, top: SPACE_SM + 2, bottom: SPACE_SM })
      .backgroundColor(dc(this.isDark, COLOR_GLASS_BG, C_GLASS_BG_DARK)).backdropBlur(12)

      Scroll() {
        Column() {
          // ── Project info card ──
          Row() {
            Column() {
              Text(APP_NAME).fontSize(20).fontColor(dc(this.isDark, COLOR_TEXT_PRIMARY, C_TEXT_PRIMARY_DARK)).fontWeight(FontWeight.Bold)
              Row() {
                Text('⎇ ' + (this.branch || '?')).fontSize(12).fontColor(COLOR_ACCENT_BLUE).fontFamily('monospace')
                  .backgroundColor(COLOR_ACCENT_BLUE + '12').borderRadius(6)
                  .padding({ left: SPACE_SM, right: SPACE_SM, top: 2, bottom: 2 })
              }.margin({ top: SPACE_XS })
            }.layoutWeight(1).alignItems(HorizontalAlign.Start)
            Button('刷新').fontSize(12).fontColor(COLOR_ACCENT_BLUE)
              .backgroundColor(COLOR_ACCENT_BLUE + '12').borderRadius(16).height(32)
              .onClick(() => { this.vm.refresh() })
          }
          .width('100%').padding(SPACE_LG)
          .backgroundColor(dc(this.isDark, COLOR_BG_SECONDARY, C_BG_SECONDARY_DARK))
          .borderRadius(RADIUS_LG).margin({ left: SPACE_LG, right: SPACE_LG, top: SPACE_MD })

          // ── File changes ──
          Column() {
            Text('文件变更').fontSize(13).fontColor(dc(this.isDark, COLOR_TEXT_SECONDARY, C_TEXT_SECONDARY_DARK))
              .fontWeight(FontWeight.Medium).width('100%').margin({ bottom: SPACE_SM })
            if (this.changes.length === 0) {
              Text('工作区干净 ✨').fontSize(12).fontColor(dc(this.isDark, COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK)).width('100%')
            }
            ForEach(this.changes, (ch: GitChange) => {
              Row() {
                Text(this.getChangeType(ch)).fontSize(10).fontColor('#FFFFFF').fontFamily('monospace')
                  .backgroundColor(this.getChangeColor(ch)).borderRadius(4)
                  .padding({ left: 4, right: 4, top: 1, bottom: 1 }).width(24).textAlign(TextAlign.Center)
                Text(ch.text).fontSize(12).fontColor(dc(this.isDark, COLOR_TEXT_PRIMARY, C_TEXT_PRIMARY_DARK))
                  .fontFamily('monospace').margin({ left: SPACE_SM }).maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis }).layoutWeight(1)
              }.width('100%').padding({ top: 4, bottom: 4 })
            }, (ch: GitChange) => ch.text)
          }
          .width('100%').padding(SPACE_LG)
          .backgroundColor(dc(this.isDark, COLOR_BG_SECONDARY, C_BG_SECONDARY_DARK))
          .borderRadius(RADIUS_LG).margin({ left: SPACE_LG, right: SPACE_LG, top: SPACE_MD })

          // ── Recent commits ──
          Column() {
            Text('最近提交').fontSize(13).fontColor(dc(this.isDark, COLOR_TEXT_SECONDARY, C_TEXT_SECONDARY_DARK))
              .fontWeight(FontWeight.Medium).width('100%').margin({ bottom: SPACE_SM })
            if (this.commits.length === 0) {
              Text('暂无提交').fontSize(12).fontColor(dc(this.isDark, COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK)).width('100%')
            }
            ForEach(this.commits, (c: GitCommit) => {
              Row() {
                Text(c.hash.substring(0, 7)).fontSize(11).fontColor(COLOR_ACCENT_BLUE)
                  .fontFamily('monospace').backgroundColor(COLOR_ACCENT_BLUE + '12')
                  .borderRadius(4).padding({ left: 4, right: 4, top: 1, bottom: 1 })
                Text(c.msg).fontSize(12).fontColor(dc(this.isDark, COLOR_TEXT_PRIMARY, C_TEXT_PRIMARY_DARK))
                  .margin({ left: SPACE_SM }).maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis }).layoutWeight(1)
              }.width('100%').padding({ top: 4, bottom: 4 })
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
    .width('100%').height('100%').backgroundColor(dc(this.isDark, COLOR_BG_PRIMARY, C_BG_PRIMARY_DARK))
  }
}
