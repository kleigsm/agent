import {
  COLOR_BG_PRIMARY, C_BG_PRIMARY_DARK,
  COLOR_BG_SECONDARY, C_BG_SECONDARY_DARK,
  COLOR_BG_INPUT, C_BG_INPUT_DARK,
  COLOR_TEXT_PRIMARY, C_TEXT_PRIMARY_DARK,
  COLOR_TEXT_SECONDARY, C_TEXT_SECONDARY_DARK,
  COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK,
  COLOR_ACCENT_BLUE, COLOR_ACCENT_GREEN, COLOR_ACCENT_RED,
  COLOR_BORDER, C_BORDER_DARK,
  COLOR_GLASS_BG, C_GLASS_BG_DARK,
  COLOR_GLASS_BORDER, C_GLASS_BORDER_DARK,
  SPACE_XS, SPACE_SM, SPACE_MD, SPACE_LG, SPACE_XL,
  RADIUS_MD, RADIUS_LG, ANIM_DURATION_NORMAL, FONT_BODY, FONT_BODY_SM, FONT_CAPTION,
  dc
} from '../common/Constants'
import { BuildViewModel, BuildStatus, BuildLogLine, BUILD_COMMANDS, BuildCommand } from '../viewmodel/BuildViewModel'
import { SocketManager, ConnectionStatus } from '../common/SocketManager'

@Component
export struct BuildPage {
  @StorageLink('isDarkMode') isDark: boolean = false
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
    return dc(this.isDark, '#AEAEB2', '#6B7280')
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

  // One-click AI fix: gather error lines, send to chat
  aiFix(): void {
    let errors: string[] = []
    for (let line of this.logLines) {
      if (line.level === 'error') errors.push(line.text)
    }
    if (errors.length === 0) return
    // Limit to 10 error lines to avoid flooding context
    let snippet = errors.slice(0, 10).join('\n')
    let prompt = '编译失败了，以下是错误日志，请帮我修复代码问题：\n\n```\n' + snippet + '\n```\n\n项目路径是 ' + (this.currentCmd || '当前项目') + '，请分析错误原因并修复。'
    AppStorage.set('pendingMessageFn', () => prompt)
    let switcher = AppStorage.get<Function>('switchTab')
    if (switcher) switcher(0)
  }

  build() {
    Stack() {
      Column() {
        // ── Header ──
        Row() {
          Text('🔨').fontSize(20)
          Text(' 编译').fontSize(18).fontColor(dc(this.isDark, COLOR_TEXT_PRIMARY, C_TEXT_PRIMARY_DARK)).fontWeight(FontWeight.Bold)
          Blank()
          Circle({ width: 8, height: 8 })
            .fill(this.connected ? COLOR_ACCENT_GREEN : COLOR_ACCENT_RED)
          Text(this.connected ? ' 已连接' : ' 未连接')
            .fontSize(11).fontColor(dc(this.isDark, COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK)).margin({ left: SPACE_XS })
        }
        .width('100%').padding({ left: SPACE_LG, right: SPACE_LG, top: SPACE_SM + 2, bottom: SPACE_SM })
        .backgroundColor(dc(this.isDark, COLOR_GLASS_BG, C_GLASS_BG_DARK)).backdropBlur(12)

        Column() {
          // ── Status card ──
          Row() {
            Column() {
              Text(this.statusLabel).fontSize(18).fontColor(dc(this.isDark, COLOR_TEXT_PRIMARY, C_TEXT_PRIMARY_DARK)).fontWeight(FontWeight.Bold)
              if (this.currentCmd) {
                Text(this.currentCmd).fontSize(11).fontColor(dc(this.isDark, COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK))
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
            Row() {}
            .width(this.progress + '%').height('100%').borderRadius(4)
            .linearGradient({ direction: GradientDirection.Left, colors: [[COLOR_ACCENT_BLUE, 0], [COLOR_ACCENT_GREEN, 1]] })
            .animation({ duration: 300, curve: Curve.EaseOut })
          }
          .width('100%').height(6).backgroundColor(dc(this.isDark, COLOR_BG_INPUT, C_BG_INPUT_DARK)).borderRadius(4)
          .padding({ left: SPACE_LG, right: SPACE_LG })

          Row() {
            Text(this.progress + '%').fontSize(24).fontWeight(FontWeight.Bold)
              .fontColor(this.status === BuildStatus.SUCCESS ? COLOR_ACCENT_GREEN :
                this.status === BuildStatus.FAILED ? COLOR_ACCENT_RED : COLOR_ACCENT_BLUE)
              .margin({ top: SPACE_SM })

            if (this.status === BuildStatus.FAILED) {
              Button() { Text('🔧 AI 修复').fontSize(12).fontColor('#FFFFFF') }
              .backgroundColor(COLOR_ACCENT_BLUE).borderRadius(16).height(32)
              .margin({ left: SPACE_MD, top: SPACE_SM })
              .onClick(() => { this.aiFix() })
            }
          }
        }
        .width('100%').padding({ top: SPACE_LG, bottom: SPACE_LG })
        .backgroundColor(dc(this.isDark, COLOR_BG_SECONDARY, C_BG_SECONDARY_DARK)).margin({ top: SPACE_MD })

        // ── Preset buttons ──
        Column() {
          Text('预设命令').fontSize(12).fontColor(dc(this.isDark, COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK))
            .width('100%').padding({ left: SPACE_LG, bottom: SPACE_SM })
          Grid() {
            ForEach(BUILD_COMMANDS, (cmd: BuildCommand, idx: number) => {
              GridItem() {
                Column() {
                  Text(cmd.icon).fontSize(22)
                  Text(cmd.label).fontSize(10).fontColor(dc(this.isDark, COLOR_TEXT_SECONDARY, C_TEXT_SECONDARY_DARK)).margin({ top: 2 })
                }
                .width('100%').height(56).justifyContent(FlexAlign.Center)
                .backgroundColor(this.isBuilding() || !this.connected ? dc(this.isDark, COLOR_BG_INPUT, C_BG_INPUT_DARK) : dc(this.isDark, COLOR_BG_SECONDARY, C_BG_SECONDARY_DARK))
                .borderRadius(12).borderWidth(1).borderColor(dc(this.isDark, COLOR_BORDER, C_BORDER_DARK))
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
            .placeholderColor(dc(this.isDark, COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK)).fontColor(dc(this.isDark, COLOR_TEXT_PRIMARY, C_TEXT_PRIMARY_DARK)).fontSize(13)
            .backgroundColor(Color.Transparent).layoutWeight(1).height(40)
            .onChange((v: string) => { this.customCmd = v }).onSubmit(() => { this.runCustom() })
          Button('运行').fontSize(12).fontColor('#FFFFFF')
            .backgroundColor(this.customCmd.trim() && !this.isBuilding() && this.connected ? COLOR_ACCENT_BLUE : COLOR_TEXT_MUTED)
            .borderRadius(16).height(32).padding({ left: SPACE_MD, right: SPACE_MD })
            .enabled(Boolean(this.customCmd.trim() && !this.isBuilding() && this.connected))
            .onClick(() => { this.runCustom() })
        }
        .width('100%').backgroundColor(dc(this.isDark, COLOR_BG_SECONDARY, C_BG_SECONDARY_DARK)).borderRadius(22)
        .borderWidth(1).borderColor(dc(this.isDark, COLOR_BORDER, C_BORDER_DARK))
        .padding({ left: SPACE_LG, right: SPACE_XS }).height(44)
        .margin({ left: SPACE_LG, right: SPACE_LG, top: SPACE_MD })

        // ── Log output ──
        Row() {
          Text('输出日志').fontSize(12).fontColor(dc(this.isDark, COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK)).layoutWeight(1)
          if (this.logLines.length > 0) {
            Text('清空').fontSize(11).fontColor(COLOR_ACCENT_BLUE)
              .onClick(() => { this.buildVM.clear(); this.status = BuildStatus.IDLE; this.progress = 0; this.logLines = [] })
          }
        }.width('100%').padding({ left: SPACE_LG, right: SPACE_LG, top: SPACE_LG, bottom: SPACE_SM })

        List({ scroller: this.scroller }) {
          if (this.logLines.length === 0) {
            ListItem() {
              Text('选择预设命令或输入自定义命令开始编译')
                .fontSize(13).fontColor(dc(this.isDark, COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK)).width('100%').textAlign(TextAlign.Center).padding(SPACE_XL)
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
        .backgroundColor(dc(this.isDark, COLOR_BG_SECONDARY, C_BG_SECONDARY_DARK))
      }
      .width('100%').height('100%').backgroundColor(dc(this.isDark, COLOR_BG_PRIMARY, C_BG_PRIMARY_DARK))
    }
    .width('100%').height('100%')
  }
}
