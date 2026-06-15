import { SocketManager } from '../common/SocketManager';
import { TerminalViewModel } from '../viewmodel/TerminalViewModel';
import {
  EVENT_TERM_EXEC, EVENT_TERM_OUTPUT, EVENT_TERM_EXIT,
  COLOR_BG_PRIMARY, COLOR_BG_SECONDARY, COLOR_BG_INPUT,
  COLOR_TEXT_PRIMARY, COLOR_TEXT_SECONDARY, COLOR_TEXT_MUTED,
  COLOR_ACCENT_BLUE, COLOR_ACCENT_GREEN, COLOR_ACCENT_RED,
  COLOR_ACCENT_ORANGE, COLOR_BORDER, COLOR_STATUS_ONLINE,
  SPACE_XS, SPACE_SM, SPACE_MD, SPACE_LG, SPACE_XL,
  RADIUS_SM, RADIUS_MD, RADIUS_LG, RADIUS_FULL,
  FONT_CAPTION, FONT_BODY_SM, FONT_BODY, FONT_BODY_LG
} from '../common/Constants';
import { WsMessage, TerminalOutput } from '../common/Models';

@Component
export struct TerminalPage {
  @State outputText: string = ''
  @State commandInput: string = ''
  @State isRunning: boolean = false
  @State cwd: string = '/'
  @State historyIndex: number = -1
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
      const color = code === 0 ? '' : '[ERR] '
      this.termVM.addOutput('\n' + color + 'Process exited with code ' + code + '\n')
      this.isRunning = false
      this.outputText = this.termVM.getOutputText()
      this.scrollOutputToBottom()
    }
  }

  executeCommand(): void {
    const cmd = this.commandInput.trim()
    if (!cmd || this.isRunning) return

    this.termVM.addToHistory(cmd)
    this.historyIndex = this.termVM.commandHistory.length
    this.termVM.addOutput('\x1b[32m$\x1b[0m ' + cmd + '\n')
    this.isRunning = true
    this.outputText = this.termVM.getOutputText()
    this.commandInput = ''

    let payload = this.makePayload()
    payload['command'] = cmd
    payload['cwd'] = this.cwd
    this.socketManager.send(EVENT_TERM_EXEC, payload)
  }

  makePayload(): Record<string, Object> {
    let obj = new Object()
    return obj as Record<string, Object>
  }

  scrollOutputToBottom(): void {
    setTimeout(() => {
      this.outputScroller.scrollEdge(Edge.Bottom)
    }, 50)
  }

  build() {
    Column() {
      // ── Header ──
      Row() {
        Row() {
          Circle({ width: 8, height: 8 }).fill(COLOR_ACCENT_RED)
          Circle({ width: 8, height: 8 }).fill(COLOR_ACCENT_ORANGE).margin({ left: SPACE_XS })
          Circle({ width: 8, height: 8 }).fill(COLOR_ACCENT_GREEN).margin({ left: SPACE_XS })
        }

        Blank()

        Text('Terminal')
          .fontSize(FONT_BODY_SM)
          .fontColor(COLOR_TEXT_MUTED)
          .fontFamily('monospace')

        Blank()

        Row() {
          if (this.isRunning) {
            LoadingProgress().width(14).height(14).color(COLOR_ACCENT_BLUE)
              .margin({ right: SPACE_SM })
          }

          Button('Clear')
            .fontSize(FONT_BODY_SM)
            .fontColor(COLOR_TEXT_SECONDARY)
            .backgroundColor(COLOR_BG_SECONDARY)
            .height(28)
            .borderRadius(RADIUS_SM)
            .padding({ left: SPACE_MD, right: SPACE_MD })
            .onClick(() => {
              this.termVM.clearOutput()
              this.outputText = ''
            })
        }
      }
      .width('100%')
      .padding({ left: SPACE_MD, right: SPACE_MD, top: SPACE_SM, bottom: SPACE_SM })

      Divider().color(COLOR_BORDER).width('100%')

      // ── Output area ──
      Scroll(this.outputScroller) {
        Text(this.outputText || 'Ready. Type a command to execute on the remote PC.\n')
          .fontSize(FONT_BODY_SM)
          .fontColor(COLOR_TEXT_PRIMARY)
          .fontFamily('monospace')
          .padding(SPACE_MD)
          .width('100%')
          .textAlign(TextAlign.Start)
          .lineHeight(18)
          .copyOption(CopyOptions.LocalDevice)
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor('#0C0D12')
      .borderRadius(RADIUS_MD)
      .margin({ left: SPACE_SM, right: SPACE_SM, top: SPACE_SM, bottom: SPACE_SM })

      // ── Input area ──
      Row() {
        Text('$')
          .fontSize(FONT_BODY_LG)
          .fontColor(COLOR_ACCENT_GREEN)
          .fontFamily('monospace')
          .fontWeight(FontWeight.Bold)
          .margin({ right: SPACE_SM })

        TextInput({ placeholder: 'Enter command...', text: this.commandInput })
          .placeholderColor(COLOR_TEXT_MUTED)
          .fontColor(COLOR_TEXT_PRIMARY)
          .fontFamily('monospace')
          .backgroundColor(Color.Transparent)
          .layoutWeight(1)
          .height(40)
          .onChange((value: string) => { this.commandInput = value })
          .onSubmit(() => { this.executeCommand() })

        Button('Run')
          .fontSize(FONT_BODY_SM)
          .fontColor('#FFFFFF')
          .backgroundColor(this.commandInput.trim().length > 0 && !this.isRunning ?
            COLOR_ACCENT_BLUE : COLOR_BG_SECONDARY)
          .borderRadius(RADIUS_MD)
          .height(34)
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
    .backgroundColor(COLOR_BG_PRIMARY)
  }
}
