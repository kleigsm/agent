import { SocketManager, ConnectionStatus } from '../common/SocketManager';
import { ChatViewModel } from '../viewmodel/ChatViewModel';
import {
  EVENT_CHAT_SEND, EVENT_CHAT_STREAM, EVENT_CHAT_DONE, EVENT_CHAT_ERROR,
  COLOR_BG_PRIMARY, COLOR_BG_SECONDARY, COLOR_BG_INPUT, COLOR_BG_HOVER,
  COLOR_TEXT_PRIMARY, COLOR_TEXT_SECONDARY, COLOR_TEXT_MUTED,
  COLOR_ACCENT_BLUE, COLOR_ACCENT_GREEN, COLOR_ACCENT_RED, COLOR_ACCENT_ORANGE,
  COLOR_USER_BUBBLE, COLOR_BUBBLE_USER_TEXT, COLOR_BUBBLE_AI_TEXT,
  COLOR_AI_BUBBLE, COLOR_BORDER, COLOR_STATUS_ONLINE, COLOR_STATUS_OFFLINE,
  COLOR_STATUS_WARNING,
  SPACE_XS, SPACE_SM, SPACE_MD, SPACE_LG, SPACE_XL, SPACE_2XL,
  RADIUS_SM, RADIUS_MD, RADIUS_LG, RADIUS_XL,
  FONT_CAPTION, FONT_BODY_SM, FONT_BODY, FONT_BODY_LG,
  ANIM_DURATION_FAST, QUICK_COMMANDS, QuickCommand
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
          // Role label
          Row() {
            if (this.msg.role === 'assistant') {
              Circle({ width: 6, height: 6 })
                .fill(this.msg.isStreaming ? COLOR_ACCENT_ORANGE : COLOR_ACCENT_GREEN)
                .margin({ right: SPACE_XS })
            }
            Text(this.msg.role === 'user' ? 'You' : (this.msg.toolName || 'Claude'))
              .fontSize(FONT_CAPTION)
              .fontColor(COLOR_TEXT_MUTED)
              .fontWeight(FontWeight.Medium)
          }
          .margin({ bottom: SPACE_XS })
          .alignSelf(this.msg.role === 'user' ? ItemAlign.End : ItemAlign.Start)

          // Message content
          Column() {
            Text(this.msg.content || (this.msg.isStreaming ? 'Thinking...' : ''))
              .fontSize(FONT_BODY)
              .fontColor(this.msg.role === 'user' ? COLOR_BUBBLE_USER_TEXT : COLOR_BUBBLE_AI_TEXT)
              .padding({ left: SPACE_LG, right: SPACE_LG, top: SPACE_MD, bottom: SPACE_MD })
              .textAlign(TextAlign.Start)
              .lineHeight(20)
          }
          .borderRadius(this.msg.role === 'user' ?
            { topLeft: RADIUS_XL, topRight: RADIUS_SM, bottomLeft: RADIUS_XL, bottomRight: RADIUS_XL } :
            { topLeft: RADIUS_SM, topRight: RADIUS_XL, bottomLeft: RADIUS_XL, bottomRight: RADIUS_XL })
          .backgroundColor(this.msg.role === 'user' ? COLOR_USER_BUBBLE : COLOR_AI_BUBBLE)
          .borderWidth(this.msg.role === 'assistant' ? 1 : 0)
          .borderColor(this.msg.role === 'assistant' ? COLOR_BORDER : Color.Transparent)
          .constraintSize({ maxWidth: '85%' })

          // Streaming indicator
          if (this.msg.isStreaming) {
            Row() {
              LoadingProgress()
                .width(14).height(14)
                .color(COLOR_ACCENT_BLUE)
              Text(' Claude is thinking...')
                .fontSize(FONT_CAPTION)
                .fontColor(COLOR_TEXT_MUTED)
            }
            .margin({ top: SPACE_XS })
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
    .padding({ top: SPACE_SM, bottom: SPACE_SM })
    .alignItems(this.msg.role === 'user' ? HorizontalAlign.End : HorizontalAlign.Start)
  }
}

@Component
export struct ChatPage {
  @State inputText: string = ''
  @State messages: ChatMessage[] = []
  @State isStreaming: boolean = false
  @State connectionStatus: ConnectionStatus = ConnectionStatus.DISCONNECTED
  private socketManager: SocketManager = SocketManager.getInstance()
  private chatVM: ChatViewModel = new ChatViewModel()
  private scroller: Scroller = new Scroller()
  private streamingMsgId: string = ''
  private onStatusFn: (status: ConnectionStatus) => void = () => {}
  private onMsgFn: (msg: WsMessage) => void = () => {}

  aboutToAppear(): void {
    this.connectionStatus = this.socketManager.getStatus()
    this.onStatusFn = (status: ConnectionStatus) => { this.connectionStatus = status }
    this.onMsgFn = (msg: WsMessage) => { this.handleMessage(msg) }
    this.socketManager.onStatusChange(this.onStatusFn)
    this.socketManager.onMessage(this.onMsgFn)
  }

  aboutToDisappear(): void {
    this.socketManager.offStatusChange(this.onStatusFn)
    this.socketManager.offMessage(this.onMsgFn)
  }

  handleMessage(msg: WsMessage): void {
    if (msg.type === EVENT_CHAT_STREAM) {
      const chunk = msg.payload['chunk'] as string
      this.chatVM.appendToMessage(this.streamingMsgId, chunk, undefined)
      this.messages = [...this.chatVM.messages]
      this.scrollToBottom()
    } else if (msg.type === EVENT_CHAT_DONE) {
      this.chatVM.finishMessage(this.streamingMsgId)
      this.isStreaming = false
      this.messages = [...this.chatVM.messages]
      this.streamingMsgId = ''
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
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom)
    }, 80)
  }

  build() {
    Column() {
      // ── Status bar ──
      Row() {
        Circle({ width: 8, height: 8 })
          .fill(this.statusColor())

        Text(this.statusLabel())
          .fontSize(FONT_BODY_SM)
          .fontColor(COLOR_TEXT_MUTED)
          .margin({ left: SPACE_SM })

        Blank()

        Text('Clear')
          .fontSize(FONT_BODY_SM)
          .fontColor(COLOR_TEXT_SECONDARY)
          .padding({ left: SPACE_MD, right: SPACE_MD, top: SPACE_XS, bottom: SPACE_XS })
          .borderRadius(RADIUS_SM)
          .backgroundColor(COLOR_BG_SECONDARY)
          .onClick(() => {
            this.chatVM.clearMessages()
            this.messages = []
          })
      }
      .width('100%')
      .padding({ left: SPACE_LG, right: SPACE_LG, top: SPACE_SM, bottom: SPACE_SM })

      Divider().color(COLOR_BORDER).width('100%')

      // ── Quick commands ──
      if (this.messages.length === 0) {
        Column() {
          Text('Quick Commands')
            .fontSize(FONT_BODY_SM)
            .fontColor(COLOR_TEXT_MUTED)
            .margin({ bottom: SPACE_MD })
            .width('100%')
            .textAlign(TextAlign.Start)

          Grid() {
            ForEach(QUICK_COMMANDS, (cmd: QuickCommand) => {
              GridItem() {
                Column() {
                  Text(cmd.icon)
                    .fontSize(24)
                    .margin({ bottom: SPACE_XS })
                  Text(cmd.label)
                    .fontSize(FONT_CAPTION)
                    .fontColor(COLOR_TEXT_SECONDARY)
                }
                .width('100%')
                .padding({ top: SPACE_MD, bottom: SPACE_MD })
                .justifyContent(FlexAlign.Center)
                .backgroundColor(COLOR_BG_SECONDARY)
                .borderRadius(RADIUS_MD)
                .borderWidth(1)
                .borderColor(COLOR_BORDER)
                .onClick(() => {
                  this.sendQuickCommand(cmd)
                })
              }
            }, (cmd: QuickCommand) => cmd.label)
          }
          .columnsTemplate('1fr 1fr 1fr 1fr')
          .columnsGap(SPACE_SM)
          .rowsGap(SPACE_SM)
          .width('100%')
        }
        .width('100%')
        .padding({ left: SPACE_LG, right: SPACE_LG, top: SPACE_LG })
      }

      // ── Message list ──
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

      Divider().color(COLOR_BORDER).width('100%')

      // ── Input area ──
      Row() {
        TextInput({ placeholder: 'Ask Claude...', text: this.inputText })
          .placeholderColor(COLOR_TEXT_MUTED)
          .fontColor(COLOR_TEXT_PRIMARY)
          .backgroundColor(COLOR_BG_SECONDARY)
          .borderRadius(RADIUS_XL)
          .borderWidth(1)
          .borderColor(COLOR_BORDER)
          .height(44)
          .layoutWeight(1)
          .padding({ left: SPACE_LG, right: SPACE_LG })
          .onChange((value: string) => { this.inputText = value })
          .onSubmit(() => { this.sendMessage() })

        Button({ type: ButtonType.Circle }) {
          Text('↑')
            .fontSize(18)
            .fontColor('#FFFFFF')
        }
        .width(40).height(40)
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

  statusColor(): ResourceColor {
    switch (this.connectionStatus) {
      case ConnectionStatus.CONNECTED: return COLOR_STATUS_ONLINE
      case ConnectionStatus.CONNECTING:
      case ConnectionStatus.RECONNECTING: return COLOR_STATUS_WARNING
      default: return COLOR_STATUS_OFFLINE
    }
  }

  statusLabel(): string {
    switch (this.connectionStatus) {
      case ConnectionStatus.CONNECTED: return 'Connected'
      case ConnectionStatus.CONNECTING: return 'Connecting...'
      case ConnectionStatus.RECONNECTING: return 'Reconnecting...'
      case ConnectionStatus.ERROR: return 'Connection Error'
      default: return 'Disconnected'
    }
  }
}
