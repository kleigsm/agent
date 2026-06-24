import {
  COLOR_BG_PRIMARY, COLOR_BG_SECONDARY, COLOR_BG_INPUT,
  COLOR_TEXT_PRIMARY, COLOR_TEXT_SECONDARY, COLOR_TEXT_MUTED,
  COLOR_ACCENT_BLUE, COLOR_ACCENT_GREEN, COLOR_ACCENT_RED,
  COLOR_BORDER, COLOR_GLASS_BG, COLOR_GLASS_BORDER,
  SPACE_XS, SPACE_SM, SPACE_MD, SPACE_LG, SPACE_XL,
  RADIUS_MD, RADIUS_LG, ANIM_DURATION_NORMAL, FONT_BODY, FONT_BODY_SM, FONT_CAPTION
} from '../common/Constants'
import { BuildViewModel, BuildStatus, BuildLogLine, BUILD_COMMANDS, BuildCommand } from '../viewmodel/BuildViewModel'
import { SocketManager, ConnectionStatus } from '../common/SocketManager'

@Component
export struct BuildPage {
  @State status: BuildStatus = BuildStatus.IDLE
  @State progress: number = 0
  @State logLines: BuildLogLine[] = []
  @State statusLabel: string = '就绪'
  @State currentCmd: string = ''
  @State connected: boolean = false
  private buildVM: BuildViewModel = new BuildViewModel()
  private scroller: Scroller = new Scroller()
  @State customCmd: string = ''

  aboutToAppear(): void {
    this.connected = SocketManager.getInstance().getStatus() === ConnectionStatus.CONNECTED
    this.buildVM.init(() => {
      this.status = this.buildVM.status
      this.progress = this.buildVM.progress
      this.logLines = [...this.buildVM.logLines]
      this.statusLabel = this.buildVM.statusLabel()
      this.currentCmd = this.buildVM.currentCommand
    })
    this.buildVM.setScroller(this.scroller)
  }

  aboutToDisappear(): void {
    this.buildVM.destroy()
  }

  getLogColor(level: string): string {
    if (level === 'error') return '#FF3B30'
    if (level === 'warn') return '#FF9500'
    if (level === 'success') return '#34C759'
    return '#AEAEB2'
  }

  isBuilding(): boolean {
    return this.status === BuildStatus.BUILDING
  }

  runPreset(idx: number): void {
    if (this.isBuilding() || !this.connected) return
    this.buildVM.runPreset(idx)
  }

  runCustom(): void {
    if (!this.customCmd.trim() || this.isBuilding() || !this.connected) return
    this.buildVM.runCommand(this.customCmd.trim())
    this.customCmd = ''
  }

  build() {
    Stack() {
      Column() {
        // ── Header ──
        Row() {
          Text('🔨').fontSize(20)
          Text(' 编译').fontSize(18).fontColor(COLOR_TEXT_PRIMARY).fontWeight(FontWeight.Bold)
          Blank()
          // Connection dot
          Circle({ width: 8, height: 8 })
            .fill(this.connected ? COLOR_ACCENT_GREEN : COLOR_ACCENT_RED)
          Text(this.connected ? ' 已连接' : ' 未连接')
            .fontSize(11).fontColor(COLOR_TEXT_MUTED).margin({ left: SPACE_XS })
        }
        .width('100%').padding({ left: SPACE_LG, right: SPACE_LG, top: SPACE_SM + 2, bottom: SPACE_SM })
        .backgroundColor(COLOR_GLASS_BG).backdropBlur(12)

        Column() {
          // ── Status card ──
          Row() {
            Column() {
              Text(this.statusLabel).fontSize(18).fontColor(COLOR_TEXT_PRIMARY).fontWeight(FontWeight.Bold)
              if (this.currentCmd) {
                Text(this.currentCmd).fontSize(11).fontColor(COLOR_TEXT_MUTED)
                  .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis }).margin({ top: 2 })
              }
            }.layoutWeight(1).alignItems(HorizontalAlign.Start)

            if (this.status === BuildStatus.BUILDING) {
              LoadingProgress().width(28).height(28).color(COLOR_ACCENT_BLUE)
            } else if (this.status === BuildStatus.SUCCESS) {
              Text('✅').fontSize(28)
            } else if (this.status === BuildStatus.FAILED) {
              Text('❌').fontSize(28)
            }
          }.width('100%').padding(SPACE_LG)

          // ── Progress bar ──
          Row() {
            Row() {
            }
            .width(this.progress + '%').height('100%')
            .borderRadius(4)
            .linearGradient({
              direction: GradientDirection.Left,
              colors: [
                [COLOR_ACCENT_BLUE, 0],
                [COLOR_ACCENT_GREEN, 1]
              ]
            })
            .animation({ duration: 300, curve: Curve.EaseOut })
          }
          .width('100%').height(6).backgroundColor(COLOR_BG_INPUT).borderRadius(4)
          .padding({ left: SPACE_LG, right: SPACE_LG })

          Text(this.progress + '%').fontSize(24).fontWeight(FontWeight.Bold)
            .fontColor(this.status === BuildStatus.SUCCESS ? COLOR_ACCENT_GREEN :
              this.status === BuildStatus.FAILED ? COLOR_ACCENT_RED : COLOR_ACCENT_BLUE)
            .margin({ top: SPACE_SM })
        }
        .width('100%').padding({ top: SPACE_LG, bottom: SPACE_LG })
        .backgroundColor(COLOR_BG_SECONDARY).margin({ top: SPACE_MD })

        // ── Preset buttons ──
        Column() {
          Text('预设命令').fontSize(12).fontColor(COLOR_TEXT_MUTED)
            .width('100%').padding({ left: SPACE_LG, bottom: SPACE_SM })
          Grid() {
            ForEach(BUILD_COMMANDS, (cmd: BuildCommand, idx: number) => {
              GridItem() {
                Column() {
                  Text(cmd.icon).fontSize(22)
                  Text(cmd.label).fontSize(10).fontColor(COLOR_TEXT_SECONDARY).margin({ top: 2 })
                }
                .width('100%').height(56).justifyContent(FlexAlign.Center)
                .backgroundColor(this.isBuilding() || !this.connected ? COLOR_BG_INPUT : COLOR_BG_SECONDARY)
                .borderRadius(12).borderWidth(1).borderColor(COLOR_BORDER)
                .opacity(this.isBuilding() || !this.connected ? 0.5 : 1)
                .onClick(() => { this.runPreset(idx) })
              }
            }, (cmd: BuildCommand) => cmd.label)
          }
          .columnsTemplate('1fr 1fr 1fr 1fr').columnsGap(8).rowsGap(8)
          .width('100%').padding({ left: SPACE_LG, right: SPACE_LG })
        }.width('100%').margin({ top: SPACE_LG })

        // ── Custom command ──
        Row() {
          TextInput({ placeholder: '输入自定义命令...', text: this.customCmd })
            .placeholderColor(COLOR_TEXT_MUTED).fontColor(COLOR_TEXT_PRIMARY).fontSize(13)
            .backgroundColor(Color.Transparent).layoutWeight(1).height(40)
            .onChange((v: string) => { this.customCmd = v })
            .onSubmit(() => { this.runCustom() })
          Button('运行').fontSize(12).fontColor('#FFFFFF')
            .backgroundColor(this.customCmd.trim() && !this.isBuilding() && this.connected ?
              COLOR_ACCENT_BLUE : COLOR_TEXT_MUTED)
            .borderRadius(16).height(32).padding({ left: SPACE_MD, right: SPACE_MD })
            .enabled(Boolean(this.customCmd.trim() && !this.isBuilding() && this.connected))
            .onClick(() => { this.runCustom() })
        }
        .width('100%').backgroundColor(COLOR_BG_SECONDARY).borderRadius(22)
        .borderWidth(1).borderColor(COLOR_BORDER)
        .padding({ left: SPACE_LG, right: SPACE_XS }).height(44)
        .margin({ left: SPACE_LG, right: SPACE_LG, top: SPACE_MD })

        // ── Log output ──
        Row() {
          Text('输出日志').fontSize(12).fontColor(COLOR_TEXT_MUTED).layoutWeight(1)
          if (this.logLines.length > 0) {
            Text('清空').fontSize(11).fontColor(COLOR_ACCENT_BLUE)
              .onClick(() => { this.buildVM.clear(); this.status = BuildStatus.IDLE; this.progress = 0; this.logLines = [] })
          }
        }.width('100%').padding({ left: SPACE_LG, right: SPACE_LG, top: SPACE_LG, bottom: SPACE_SM })

        List({ scroller: this.scroller }) {
          if (this.logLines.length === 0) {
            ListItem() {
              Text('选择预设命令或输入自定义命令开始编译')
                .fontSize(13).fontColor(COLOR_TEXT_MUTED).width('100%').textAlign(TextAlign.Center).padding(SPACE_XL)
            }
          }
          ForEach(this.logLines, (line: BuildLogLine, idx: number) => {
            ListItem() {
              Text((idx + 1).toString().padStart(3, ' ') + ' │ ' + line.text)
                .fontSize(11).fontColor(this.getLogColor(line.level))
                .fontFamily('monospace')
                .width('100%').padding({ left: SPACE_LG, right: SPACE_LG, top: 2, bottom: 2 })
            }
          }, (line: BuildLogLine, idx: number) => idx.toString())
        }
        .layoutWeight(1).width('100%').margin({ top: SPACE_XS })
        .backgroundColor(COLOR_BG_SECONDARY)
      }
      .width('100%').height('100%').backgroundColor(COLOR_BG_PRIMARY)
    }
    .width('100%').height('100%')
  }
}
