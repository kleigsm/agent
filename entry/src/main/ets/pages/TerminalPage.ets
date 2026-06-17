import { SocketManager } from '../common/SocketManager'; import { TerminalViewModel } from '../viewmodel/TerminalViewModel';
import { EVENT_TERM_EXEC, EVENT_TERM_OUTPUT, EVENT_TERM_EXIT,
  SPACE_XS, SPACE_SM, SPACE_MD, SPACE_LG, SPACE_XL,
  RADIUS_SM, RADIUS_MD, RADIUS_LG, FONT_BODY_SM, FONT_BODY,
  getTheme, ThemeColors, LIGHT_THEME, DARK_THEME } from '../common/Constants';
import { WsMessage } from '../common/Models';

@Component
export struct TerminalPage {
  @State outputText: string = ''
  @State commandInput: string = ''
  @State isRunning: boolean = false
  @State cwd: string = '/'
  @StorageLink('isDarkMode') isDarkMode: boolean = false
  private theme: ThemeColors = LIGHT_THEME
  private socketManager: SocketManager = SocketManager.getInstance()
  private termVM: TerminalViewModel = new TerminalViewModel()
  private outputScroller: Scroller = new Scroller()
  private onMsgFn: (msg: WsMessage) => void = () => {}

  aboutToAppear(): void { this.onMsgFn = (m: WsMessage) => { this.handleMessage(m) }; this.socketManager.onMessage(this.onMsgFn) }
  aboutToDisappear(): void { this.socketManager.offMessage(this.onMsgFn) }

  handleMessage(msg: WsMessage): void {
    if (msg.type === EVENT_TERM_OUTPUT) {
      let data = msg.payload['data'] as string; let isErr = msg.payload['stderr'] as boolean
      this.termVM.addOutput(data, isErr)
      this.outputText = this.termVM.getOutputText()
      this.scrollOutputToBottom()
    } else if (msg.type === EVENT_TERM_EXIT) {
      let code = msg.payload['code'] as number
      this.termVM.addOutput('\n进程已退出，代码: ' + code + '\n')
      this.isRunning = false; this.outputText = this.termVM.getOutputText(); this.scrollOutputToBottom()
    }
  }

  executeCommand(): void {
    let cmd = this.commandInput.trim()
    if (!cmd || this.isRunning) return
    this.termVM.addToHistory(cmd)
    this.termVM.addOutput('$ ' + cmd + '\n')
    this.isRunning = true; this.outputText = this.termVM.getOutputText(); this.commandInput = ''
    let p = new Object() as Record<string,Object>
    p['command'] = cmd; p['cwd'] = this.cwd
    this.socketManager.send(EVENT_TERM_EXEC, p)
  }

  scrollOutputToBottom(): void { setTimeout(() => { this.outputScroller.scrollEdge(Edge.Bottom) }, 50) }

  build() {
    this.theme = this.isDarkMode ? DARK_THEME : LIGHT_THEME

    Column() {
      // Header with cwd
      Row() {
        Row() {
          Circle({ width: 10, height: 10 }).fill(this.theme.accentRed)
          Circle({ width: 10, height: 10 }).fill(this.theme.accentOrange).margin({ left: 6 })
          Circle({ width: 10, height: 10 }).fill(this.theme.accentGreen).margin({ left: 6 })
        }
        Text(' 终端 · ' + this.cwd).fontSize(12).fontColor(this.theme.textMuted)
          .fontFamily('monospace').maxLines(1).layoutWeight(1).margin({ left: SPACE_SM })
        Row() {
          if (this.isRunning) LoadingProgress().width(14).height(14).color(this.theme.accentBlue).margin({ right: SPACE_SM })
          Button('清屏').fontSize(11).fontColor(this.theme.textSecondary)
            .backgroundColor(this.theme.bgSecondary).height(26).borderRadius(RADIUS_SM)
            .onClick(() => { this.termVM.clearOutput(); this.outputText = '' })
        }
      }.width('100%').padding({ left: SPACE_MD, right: SPACE_MD, top: SPACE_SM, bottom: SPACE_SM })

      // Output
      Scroll(this.outputScroller) {
        Text(this.outputText || '就绪。输入命令在远程 PC 上执行。\n')
          .fontSize(13).fontFamily('monospace')
          .fontColor(this.theme.terminalText).padding(SPACE_MD).width('100%').textAlign(TextAlign.Start).lineHeight(18)
      }
      .layoutWeight(1).width('100%').backgroundColor(this.theme.terminalBg)
      .borderRadius(RADIUS_MD).margin({ left: SPACE_SM, right: SPACE_SM, top: SPACE_SM, bottom: SPACE_SM })

      // Input
      Row() {
        Text('$').fontSize(16).fontColor(this.theme.accentGreen).fontFamily('monospace').fontWeight(FontWeight.Bold).margin({ right: SPACE_SM })
        TextInput({ placeholder: '输入命令...', text: this.commandInput })
          .placeholderColor(this.theme.textMuted).fontColor(this.theme.textPrimary).fontFamily('monospace')
          .backgroundColor(Color.Transparent).layoutWeight(1).height(40)
          .onChange((v: string) => { this.commandInput = v }).onSubmit(() => { this.executeCommand() })
        Button('运行').fontSize(12).fontColor('#FFFFFF')
          .backgroundColor(this.commandInput.trim().length > 0 && !this.isRunning ? this.theme.accentBlue : this.theme.bgSecondary)
          .borderRadius(RADIUS_MD).height(32).padding({ left: SPACE_LG, right: SPACE_LG }).margin({ left: SPACE_SM })
          .enabled(this.commandInput.trim().length > 0 && !this.isRunning).onClick(() => { this.executeCommand() })
      }
      .width('100%').padding({ left: SPACE_MD, right: SPACE_MD, top: SPACE_SM, bottom: SPACE_MD })
    }.width('100%').height('100%').backgroundColor(this.theme.bgPrimary)
  }
}
