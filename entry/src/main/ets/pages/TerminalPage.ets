import { SocketManager } from '../common/SocketManager';
import { TerminalViewModel } from '../viewmodel/TerminalViewModel';
import {
  EVENT_TERM_EXEC, EVENT_TERM_OUTPUT, EVENT_TERM_EXIT,
  COLOR_BG_DARK, COLOR_BG_INPUT, COLOR_TEXT_PRIMARY, COLOR_TEXT_MUTED,
  COLOR_ACCENT_BLUE, COLOR_ACCENT_GREEN, COLOR_SURFACE, COLOR_BORDER
} from '../common/Constants';
import { WsMessage, TerminalOutput } from '../common/Models';

@Component
export struct TerminalPage {
  @State outputText: string = ''
  @State commandInput: string = ''
  @State isRunning: boolean = false
  @State cwd: string = '/'
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
      this.termVM.addOutput('\n[Process exited with code ' + code + ']\n')
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
      Row() {
        Text('Terminal')
          .fontSize(14)
          .fontColor(COLOR_TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)

        Button('Clear')
          .fontSize(12)
          .fontColor(COLOR_TEXT_MUTED)
          .backgroundColor(COLOR_SURFACE)
          .height(28)
          .onClick(() => {
            this.termVM.clearOutput()
            this.outputText = ''
          })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 4 })

      Divider().color(COLOR_BORDER).margin({ left: 12, right: 12 })

      Scroll(this.outputScroller) {
        Text(this.outputText || 'Ready. Type a command to execute on the remote PC.\n')
          .fontSize(13)
          .fontColor(COLOR_TEXT_PRIMARY)
          .fontFamily('monospace')
          .padding(12)
          .width('100%')
          .textAlign(TextAlign.Start)
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor(COLOR_BG_INPUT)
      .borderRadius(8)
      .margin({ left: 8, right: 8, top: 4, bottom: 4 })

      Row() {
        Text('$')
          .fontSize(14)
          .fontColor(COLOR_ACCENT_GREEN)
          .fontFamily('monospace')
          .margin({ right: 8 })

        TextInput({ placeholder: 'Enter command...', text: this.commandInput })
          .placeholderColor(COLOR_TEXT_MUTED)
          .fontColor(COLOR_TEXT_PRIMARY)
          .fontFamily('monospace')
          .backgroundColor(Color.Transparent)
          .layoutWeight(1)
          .height(40)
          .onChange((value: string) => {
            this.commandInput = value
          })
          .onSubmit(() => {
            this.executeCommand()
          })

        Button('Run')
          .fontSize(13)
          .fontColor('#ffffff')
          .backgroundColor(COLOR_ACCENT_BLUE)
          .borderRadius(16)
          .height(34)
          .padding({ left: 14, right: 14 })
          .margin({ left: 8 })
          .enabled(this.commandInput.trim().length > 0 && !this.isRunning)
          .onClick(() => {
            this.executeCommand()
          })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 4, bottom: 12 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLOR_BG_DARK)
  }
}
