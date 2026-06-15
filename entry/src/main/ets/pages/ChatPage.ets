import { SocketManager, ConnectionStatus } from '../common/SocketManager';
import { ChatViewModel } from '../viewmodel/ChatViewModel';
import {
  EVENT_CHAT_SEND, EVENT_CHAT_STREAM, EVENT_CHAT_DONE, EVENT_CHAT_ERROR,
  COLOR_BG_PRIMARY, COLOR_BG_SECONDARY, COLOR_BG_INPUT,
  COLOR_TEXT_PRIMARY, COLOR_TEXT_SECONDARY, COLOR_TEXT_MUTED,
  COLOR_ACCENT_BLUE, COLOR_ACCENT_GREEN, COLOR_ACCENT_RED,
  COLOR_USER_BUBBLE, COLOR_BUBBLE_USER_TEXT, COLOR_BUBBLE_AI_TEXT,
  COLOR_AI_BUBBLE, COLOR_BORDER, COLOR_GLASS_BG, COLOR_GLASS_BORDER,
  COLOR_GLASS_HIGHLIGHT,
  SPACE_XS, SPACE_SM, SPACE_MD, SPACE_LG, SPACE_XL, SPACE_2XL,
  RADIUS_SM, RADIUS_MD, RADIUS_LG, RADIUS_XL,
  FONT_CAPTION, FONT_BODY_SM, FONT_BODY, FONT_BODY_LG,
  ANIM_DURATION_FAST, ANIM_DURATION_NORMAL,
  QUICK_COMMANDS, QuickCommand, BREATH_DURATION
} from '../common/Constants';
import { WsMessage, ChatMessage } from '../common/Models';

@Component
struct MessageBubble {
  @ObjectLink msg: ChatMessage

  build() {
    Column() {
      Row() {
        if (this.msg.role === 'user') {
          Blank()
        }

        Column() {
          Row() {
            if (this.msg.role === 'assistant') {
              Text(this.msg.isStreaming ? '●' : '')
                .fontSize(8)
                .fontColor(COLOR_ACCENT_BLUE)
                .margin({ right: SPACE_XS })
            }
            Text(this.msg.role === 'user' ? '我' : 'Claude')
              .fontSize(10)
              .fontColor(COLOR_TEXT_MUTED)
              .fontWeight(FontWeight.Medium)
          }
          .margin({ bottom: 4 })
          .alignSelf(this.msg.role === 'user' ? ItemAlign.End : ItemAlign.Start)

          Column() {
            Text(this.msg.content || (this.msg.isStreaming ? '思考中...' : ''))
              .fontSize(14)
              .fontColor(this.msg.role === 'user' ? COLOR_BUBBLE_USER_TEXT : COLOR_BUBBLE_AI_TEXT)
              .padding({ left: 14, right: 14, top: 10, bottom: 10 })
              .textAlign(TextAlign.Start)
              .lineHeight(20)
          }
          .borderRadius(this.msg.role === 'user' ?
            ({ topLeft: 18, topRight: 6, bottomLeft: 18, bottomRight: 18 }) :
            ({ topLeft: 6, topRight: 18, bottomLeft: 18, bottomRight: 18 }))
          .backgroundColor(this.msg.role === 'user' ? COLOR_USER_BUBBLE : COLOR_AI_BUBBLE)
          .borderWidth(this.msg.role === 'assistant' ? 1 : 0)
          .borderColor(this.msg.role === 'assistant' ? COLOR_BORDER : Color.Transparent)
          .constraintSize({ maxWidth: '82%' })

          if (this.msg.isStreaming) {
            Row() {
              LoadingProgress().width(12).height(12).color(COLOR_ACCENT_BLUE)
              Text(' 生成中...')
                .fontSize(10)
                .fontColor(COLOR_TEXT_MUTED)
            }
            .margin({ top: 4 })
            .alignSelf(ItemAlign.Start)
          }
        }
        .alignItems(this.msg.role === 'user' ? HorizontalAlign.End : HorizontalAlign.Start)

        if (this.msg.role === 'assistant') {
          Blank()
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding({ top: 6, bottom: 6 })
    .alignItems(this.msg.role === 'user' ? HorizontalAlign.End : HorizontalAlign.Start)
  }
}

@Component
export struct ChatPage {
  @State inputText: string = ''
  @State messages: ChatMessage[] = []
  @State isStreaming: boolean = false
  @State connectionStatus: ConnectionStatus = ConnectionStatus.DISCONNECTED
  @State dotOpacity: number = 0.4
  @State showQuickCommands: boolean = true
  private socketManager: SocketManager = SocketManager.getInstance()
  private chatVM: ChatViewModel = new ChatViewModel()
  private scroller: Scroller = new Scroller()
  private streamingMsgId: string = ''
  private breathTimer: number | null = null
  private onStatusFn: (status: ConnectionStatus) => void = () => {}
  private onMsgFn: (msg: WsMessage) => void = () => {}

  aboutToAppear(): void {
    this.connectionStatus = this.socketManager.getStatus()
    this.onStatusFn = (status: ConnectionStatus) => { this.connectionStatus = status }
    this.onMsgFn = (msg: WsMessage) => { this.handleMessage(msg) }
    this.socketManager.onStatusChange(this.onStatusFn)
    this.socketManager.onMessage(this.onMsgFn)
    // Start breathing dot when connected
    this.updateBreathing()
  }

  aboutToDisappear(): void {
    this.socketManager.offStatusChange(this.onStatusFn)
    this.socketManager.offMessage(this.onMsgFn)
    if (this.breathTimer) {
      clearInterval(this.breathTimer)
      this.breathTimer = null
    }
  }

  private updateBreathing(): void {
    if (this.connectionStatus === ConnectionStatus.CONNECTED) {
      this.dotOpacity = 1.0
    } else {
      this.dotOpacity = 0.4
    }
  }

  handleMessage(msg: WsMessage): void {
    if (msg.type === EVENT_CHAT_STREAM) {
      const chunk = msg.payload['chunk'] as string
      this.chatVM.appendToMessage(this.streamingMsgId, chunk, undefined)
      this.messages = [...this.chatVM.messages]
      this.showQuickCommands = false
      this.scrollToBottom()
    } else if (msg.type === EVENT_CHAT_DONE) {
      this.chatVM.finishMessage(this.streamingMsgId)
      this.isStreaming = false
      this.messages = [...this.chatVM.messages]
      this.streamingMsgId = ''
      this.showQuickCommands = false
      this.scrollToBottom()
    } else if (msg.type === EVENT_CHAT_ERROR) {
      this.chatVM.finishMessage(this.streamingMsgId)
      this.isStreaming = false
      this.messages = [...this.chatVM.messages]
      this.streamingMsgId = ''
    }
  }

  sendMessage(text?: string): void {
    const msgText = (text || this.inputText).trim()
    if (!msgText || this.isStreaming) return
    if (this.connectionStatus !== ConnectionStatus.CONNECTED) return

    this.chatVM.addUserMessage(msgText)
    this.streamingMsgId = this.chatVM.startAssistantMessage()
    this.messages = [...this.chatVM.messages]
    this.inputText = ''
    this.isStreaming = true
    this.showQuickCommands = false

    let payload = this.makePayload()
    payload['message'] = msgText
    this.socketManager.send(EVENT_CHAT_SEND, payload)
    this.scrollToBottom()
  }

  sendQuickCommand(cmd: QuickCommand): void {
    this.sendMessage(cmd.prompt)
  }

  makePayload(): Record<string, Object> {
    let obj = new Object()
    return obj as Record<string, Object>
  }

  scrollToBottom(): void {
    setTimeout(() => { this.scroller.scrollEdge(Edge.Bottom) }, 80)
  }

  build() {
    Column() {
      // ── 状态栏 ──
      Row() {
        Row() {
          Circle({ width: 10, height: 10 })
            .fill(this.connectionStatus === ConnectionStatus.CONNECTED
              ? COLOR_ACCENT_GREEN : COLOR_ACCENT_RED)
            .opacity(this.connectionStatus === ConnectionStatus.CONNECTED ? this.dotOpacity : 1)
            .shadow(this.connectionStatus === ConnectionStatus.CONNECTED
              ? { radius: 6, color: COLOR_ACCENT_GREEN + '60', offsetY: 0 }
              : { radius: 0, color: '#00000000', offsetY: 0 })

          Text(this.connectionStatus === ConnectionStatus.CONNECTED ? ' 已连接' :
               this.connectionStatus === ConnectionStatus.CONNECTING ? ' 连接中...' :
               this.connectionStatus === ConnectionStatus.RECONNECTING ? ' 重连中...' : ' 未连接')
            .fontSize(12)
            .fontColor(COLOR_TEXT_SECONDARY)
            .margin({ left: SPACE_XS })
        }

        Blank()

        Text('清空')
          .fontSize(12)
          .fontColor(COLOR_TEXT_SECONDARY)
          .padding({ left: 12, right: 12, top: 4, bottom: 4 })
          .borderRadius(10)
          .backgroundColor(COLOR_GLASS_BG)
          .onClick(() => {
            this.chatVM.clearMessages()
            this.messages = []
            this.showQuickCommands = true
          })
      }
      .width('100%')
      .padding({ left: SPACE_LG, right: SPACE_LG, top: SPACE_SM + 2, bottom: SPACE_SM })
      .backgroundColor(COLOR_GLASS_BG)
      .backdropBlur(12)

      // ── 快捷指令 ──
      if (this.showQuickCommands && this.messages.length === 0) {
        Column() {
          Text('选择指令或输入自定义需求')
            .fontSize(11)
            .fontColor(COLOR_TEXT_MUTED)
            .margin({ bottom: SPACE_SM })
            .width('100%')

          Grid() {
            ForEach(QUICK_COMMANDS, (cmd: QuickCommand, idx: number) => {
              GridItem() {
                Column() {
                  Text(cmd.icon)
                    .fontSize(20)
                  Text(cmd.label)
                    .fontSize(10)
                    .fontColor(COLOR_TEXT_SECONDARY)
                    .margin({ top: 2 })
                }
                .width('100%')
                .height(56)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(COLOR_GLASS_BG)
                .borderRadius(12)
                .borderWidth(1)
                .borderColor(COLOR_GLASS_BORDER)
                .onClick(() => { this.sendQuickCommand(cmd) })
              }
            }, (cmd: QuickCommand) => cmd.label)
          }
          .columnsTemplate('1fr 1fr 1fr 1fr')
          .columnsGap(8)
          .rowsGap(8)
          .width('100%')
          .height(122)
        }
        .width('100%')
        .padding({ left: SPACE_LG, right: SPACE_LG, top: SPACE_SM + 4, bottom: SPACE_XS + 4 })
      }

      // ── 消息列表 ──
      List({ scroller: this.scroller }) {
        ForEach(this.messages, (msg: ChatMessage) => {
          ListItem() {
            MessageBubble({ msg: msg })
          }
        }, (msg: ChatMessage) => msg.id)
      }
      .layoutWeight(1)
      .width('100%')
      .padding({ left: SPACE_MD, right: SPACE_MD })

      // ── 输入区 ──
      Row() {
        Row() {
          TextInput({ placeholder: '输入需求...', text: this.inputText })
            .placeholderColor(COLOR_TEXT_MUTED)
            .fontColor(COLOR_TEXT_PRIMARY)
            .fontSize(14)
            .backgroundColor(Color.Transparent)
            .layoutWeight(1)
            .height(44)
            .borderRadius(0)
            .onChange((value: string) => { this.inputText = value })
            .onSubmit(() => { this.sendMessage() })
        }
        .layoutWeight(1)
        .backgroundColor(COLOR_BG_SECONDARY)
        .borderRadius(22)
        .borderWidth(1)
        .borderColor(COLOR_BORDER)
        .padding({ left: SPACE_LG })
        .height(44)

        Button() {
          Text('→')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
        .width(40).height(40)
        .borderRadius(20)
        .backgroundColor(this.inputText.trim().length > 0 && !this.isStreaming ?
          COLOR_ACCENT_BLUE : COLOR_BG_SECONDARY)
        .margin({ left: SPACE_SM })
        .enabled(this.inputText.trim().length > 0 && !this.isStreaming)
        .onClick(() => { this.sendMessage() })
      }
      .width('100%')
      .padding({ left: SPACE_MD, right: SPACE_MD, top: SPACE_SM, bottom: SPACE_MD })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLOR_BG_PRIMARY)
  }
}
