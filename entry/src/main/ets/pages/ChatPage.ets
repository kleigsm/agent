import { SocketManager, ConnectionStatus } from '../common/SocketManager';
import { ChatViewModel } from '../viewmodel/ChatViewModel';
import {
  EVENT_CHAT_SEND, EVENT_CHAT_STREAM, EVENT_CHAT_DONE, EVENT_CHAT_ERROR,
  COLOR_BG_DARK, COLOR_BG_INPUT, COLOR_TEXT_PRIMARY, COLOR_TEXT_MUTED,
  COLOR_ACCENT_BLUE, COLOR_ACCENT_GREEN, COLOR_ACCENT_RED, COLOR_ACCENT_YELLOW,
  COLOR_USER_BUBBLE, COLOR_AI_BUBBLE, COLOR_SURFACE
} from '../common/Constants';
import { WsMessage, ChatMessage } from '../common/Models';

@Component
struct MessageItem {
  @ObjectLink msg: ChatMessage

  build() {
    Column() {
      Row() {
        if (this.msg.role === 'user') {
          Blank()
        }

        Column() {
          Text(this.msg.role === 'user' ? 'You' : 'opencode')
            .fontSize(11)
            .fontColor(COLOR_TEXT_MUTED)
            .margin({ bottom: 2 })
            .alignSelf(this.msg.role === 'user' ? ItemAlign.End : ItemAlign.Start)

          Text(this.msg.content || (this.msg.isStreaming ? 'Thinking...' : ''))
            .fontSize(14)
            .fontColor(this.msg.role === 'user' ? '#ffffff' : COLOR_TEXT_PRIMARY)
            .padding(12)
            .borderRadius(16)
            .backgroundColor(this.msg.role === 'user' ? COLOR_USER_BUBBLE : COLOR_AI_BUBBLE)
            .constraintSize({ maxWidth: '80%' })
            .textAlign(this.msg.role === 'user' ? TextAlign.End : TextAlign.Start)
        }
        .alignItems(this.msg.role === 'user' ? HorizontalAlign.End : HorizontalAlign.Start)

        if (this.msg.role === 'assistant') {
          Blank()
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding({ top: 4, bottom: 4 })
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

  sendMessage(): void {
    const text = this.inputText.trim()
    if (!text || this.isStreaming) return
    if (this.connectionStatus !== ConnectionStatus.CONNECTED) return

    this.chatVM.addUserMessage(text)
    this.streamingMsgId = this.chatVM.startAssistantMessage()
    this.messages = [...this.chatVM.messages]
    this.inputText = ''
    this.isStreaming = true

    let payload = this.makePayload()
    payload['message'] = text
    payload['history'] = JSON.stringify(this.chatVM.messages.slice(0, -2))
    this.socketManager.send(EVENT_CHAT_SEND, payload)
    this.scrollToBottom()
  }

  makePayload(): Record<string, Object> {
    let obj = new Object()
    return obj as Record<string, Object>
  }

  scrollToBottom(): void {
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom)
    }, 100)
  }

  build() {
    Column() {
      Row() {
        Circle({ width: 8, height: 8 })
          .fill(this.statusColor())
          .margin({ right: 6 })

        Text(this.statusText())
          .fontSize(12)
          .fontColor(COLOR_TEXT_MUTED)

        Blank()

        Button('Clear')
          .fontSize(12)
          .fontColor(COLOR_TEXT_MUTED)
          .backgroundColor(COLOR_SURFACE)
          .height(28)
          .onClick(() => {
            this.chatVM.clearMessages()
            this.messages = []
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 4 })

      List({ scroller: this.scroller }) {
        ForEach(this.messages, (msg: ChatMessage) => {
          ListItem() {
            MessageItem({ msg: msg })
          }
        }, (msg: ChatMessage) => msg.id)
      }
      .layoutWeight(1)
      .width('100%')
      .padding({ left: 8, right: 8 })

      Row() {
        TextInput({ placeholder: 'Ask opencode...', text: this.inputText })
          .placeholderColor(COLOR_TEXT_MUTED)
          .fontColor(COLOR_TEXT_PRIMARY)
          .backgroundColor(COLOR_BG_INPUT)
          .borderRadius(20)
          .height(44)
          .layoutWeight(1)
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.inputText = value
          })
          .onSubmit(() => {
            this.sendMessage()
          })

        Button('Send')
          .fontSize(14)
          .fontColor('#ffffff')
          .backgroundColor(COLOR_ACCENT_BLUE)
          .borderRadius(20)
          .height(44)
          .padding({ left: 16, right: 16 })
          .margin({ left: 8 })
          .enabled(this.inputText.trim().length > 0 && !this.isStreaming)
          .onClick(() => {
            this.sendMessage()
          })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 12 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLOR_BG_DARK)
  }

  statusColor(): ResourceColor {
    switch (this.connectionStatus) {
      case ConnectionStatus.CONNECTED:
        return COLOR_ACCENT_GREEN
      case ConnectionStatus.CONNECTING:
      case ConnectionStatus.RECONNECTING:
        return COLOR_ACCENT_YELLOW
      default:
        return COLOR_ACCENT_RED
    }
  }

  statusText(): string {
    switch (this.connectionStatus) {
      case ConnectionStatus.CONNECTED:
        return 'Connected'
      case ConnectionStatus.CONNECTING:
        return 'Connecting...'
      case ConnectionStatus.RECONNECTING:
        return 'Reconnecting...'
      case ConnectionStatus.ERROR:
        return 'Error'
      default:
        return 'Disconnected'
    }
  }
}
