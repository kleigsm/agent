import { SocketManager } from '../common/SocketManager';
import { TerminalViewModel } from '../viewmodel/TerminalViewModel';
import {
  EVENT_TERM_EXEC, EVENT_TERM_OUTPUT, EVENT_TERM_EXIT,
  COLOR_BG_PRIMARY, C_BG_PRIMARY_DARK,
  COLOR_BG_SECONDARY, C_BG_SECONDARY_DARK,
  COLOR_BG_INPUT, C_BG_INPUT_DARK,
  COLOR_TEXT_PRIMARY, C_TEXT_PRIMARY_DARK,
  COLOR_TEXT_SECONDARY, C_TEXT_SECONDARY_DARK,
  COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK,
  COLOR_ACCENT_BLUE, COLOR_ACCENT_GREEN, COLOR_ACCENT_RED,
  COLOR_ACCENT_ORANGE, COLOR_BORDER, C_BORDER_DARK,
  SPACE_XS, SPACE_SM, SPACE_MD, SPACE_LG, SPACE_XL,
  RADIUS_SM, RADIUS_MD, RADIUS_LG, RADIUS_FULL,
  FONT_CAPTION, FONT_BODY_SM, FONT_BODY, FONT_BODY_LG,
  dc
} from '../common/Constants';
import { WsMessage } from '../common/Models';

@Component
export struct TerminalPage {
  @StorageLink('isDarkMode') isDark: boolean = false
  @State outputText: string = ''
  @State commandInput: string = ''
  @State isRunning: boolean = false
  private socketManager: SocketManager = SocketManager.getInstance()
  private termVM: TerminalViewModel = new TerminalViewModel()
  private outputScroller: Scroller = new Scroller()
  private onMsgFn: (msg: WsMessage) => void = () => {}

  aboutToAppear(): void {
    this.onMsgFn = (msg: WsMessage) => { this.handleMessage(msg) }
    this.socketManager.onMessage(this.onMsgFn)
  }

  aboutToDisappear(): void {
    this.socketManager.offMessage(this.onMsgFn)
  }

  handleMessage(msg: WsMessage): void {
    if (msg.type === EVENT_TERM_OUTPUT) {
      const data = msg.payload['data'] as string
      const isStderr = msg.payload['stderr'] as boolean
      this.termVM.addOutput(data, isStderr)
      this.outputText = this.termVM.getOutputText()
      this.scrollOutputToBottom()
    } else if (msg.type === EVENT_TERM_EXIT) {
      const code = msg.payload['code'] as number
      this.termVM.addOutput('\n进程已退出，代码: ' + code + '\n')
      this.isRunning = false
      this.outputText = this.termVM.getOutputText()
      this.scrollOutputToBottom()
    }
  }

  executeCommand(): void {
    const cmd = this.commandInput.trim()
    if (!cmd || this.isRunning) return
    this.termVM.addToHistory(cmd)
    this.termVM.addOutput('$ ' + cmd + '\n')
    this.isRunning = true
    this.outputText = this.termVM.getOutputText()
    this.commandInput = ''
    let payload = this.makePayload()
    payload['command'] = cmd
    this.socketManager.send(EVENT_TERM_EXEC, payload)
  }

  makePayload(): Record<string, Object> {
    let obj = new Object()
    return obj as Record<string, Object>
  }

  scrollOutputToBottom(): void {
    setTimeout(() => { this.outputScroller.scrollEdge(Edge.Bottom) }, 50)
  }

  build() {
    Column() {
      // ── 标题栏 ──
      Row() {
        Row() {
          Circle({ width: 10, height: 10 }).fill(COLOR_ACCENT_RED)
          Circle({ width: 10, height: 10 }).fill(COLOR_ACCENT_ORANGE).margin({ left: 6 })
          Circle({ width: 10, height: 10 }).fill(COLOR_ACCENT_GREEN).margin({ left: 6 })
        }
        Blank()
        Text('终端')
          .fontSize(12)
          .fontColor(dc(this.isDark, COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK))
          .fontFamily('monospace')
        Blank()
        Row() {
          if (this.isRunning) {
            LoadingProgress().width(14).height(14).color(COLOR_ACCENT_BLUE).margin({ right: SPACE_SM })
          }
          Button('清屏')
            .fontSize(11)
            .fontColor(dc(this.isDark, COLOR_TEXT_SECONDARY, C_TEXT_SECONDARY_DARK))
            .backgroundColor(dc(this.isDark, COLOR_BG_SECONDARY, C_BG_SECONDARY_DARK))
            .height(26)
            .borderRadius(RADIUS_SM)
            .onClick(() => { this.termVM.clearOutput(); this.outputText = '' })
        }
      }
      .width('100%')
      .padding({ left: SPACE_MD, right: SPACE_MD, top: SPACE_SM, bottom: SPACE_SM })

      // ── 输出区 (always dark to mimic terminal) ──
      Scroll(this.outputScroller) {
        Text(this.outputText || '就绪。输入命令在远程 PC 上执行。\n')
          .fontSize(13)
          .fontColor('#E5E5EA')
          .fontFamily('monospace')
          .padding(SPACE_MD)
          .width('100%')
          .textAlign(TextAlign.Start)
          .lineHeight(18)
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor('#1D1D1F')
      .borderRadius(RADIUS_MD)
      .margin({ left: SPACE_SM, right: SPACE_SM, top: SPACE_SM, bottom: SPACE_SM })

      // ── 输入区 ──
      Row() {
        Text('$')
          .fontSize(16)
          .fontColor(COLOR_ACCENT_GREEN)
          .fontFamily('monospace')
          .fontWeight(FontWeight.Bold)
          .margin({ right: SPACE_SM })

        TextInput({ placeholder: '输入命令...', text: this.commandInput })
          .placeholderColor(dc(this.isDark, COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK))
          .fontColor(dc(this.isDark, COLOR_TEXT_PRIMARY, C_TEXT_PRIMARY_DARK))
          .fontFamily('monospace')
          .backgroundColor(Color.Transparent)
          .layoutWeight(1)
          .height(40)
          .onChange((value: string) => { this.commandInput = value })
          .onSubmit(() => { this.executeCommand() })

        Button('运行')
          .fontSize(12)
          .fontColor('#FFFFFF')
          .backgroundColor(this.commandInput.trim().length > 0 && !this.isRunning ?
            COLOR_ACCENT_BLUE : dc(this.isDark, COLOR_BG_SECONDARY, C_BG_SECONDARY_DARK))
          .borderRadius(RADIUS_MD)
          .height(32)
          .padding({ left: SPACE_LG, right: SPACE_LG })
          .margin({ left: SPACE_SM })
          .enabled(this.commandInput.trim().length > 0 && !this.isRunning)
          .onClick(() => { this.executeCommand() })
      }
      .width('100%')
      .padding({ left: SPACE_MD, right: SPACE_MD, top: SPACE_SM, bottom: SPACE_MD })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(dc(this.isDark, COLOR_BG_PRIMARY, C_BG_PRIMARY_DARK))
  }
}
