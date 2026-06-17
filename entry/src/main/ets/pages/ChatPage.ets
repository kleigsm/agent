import { SocketManager, ConnectionStatus } from '../common/SocketManager';
import { ChatViewModel } from '../viewmodel/ChatViewModel';
import {
  SPACE_XS, SPACE_SM, SPACE_MD, SPACE_LG, SPACE_XL,
  RADIUS_SM, RADIUS_MD, RADIUS_LG, RADIUS_XL,
  FONT_CAPTION, FONT_BODY_SM, FONT_BODY, FONT_BODY_LG,
  ANIM_DURATION_FAST, ANIM_DURATION_NORMAL, BREATH_DURATION,
  QUICK_COMMANDS, QuickCommand, getTheme, ThemeColors, LIGHT_THEME, DARK_THEME
} from '../common/Constants';
import { WsMessage, ChatMessage } from '../common/Models';
import { pasteboard } from '@kit.BasicServicesKit';

@Component
struct MessageBubble {
  @ObjectLink msg: ChatMessage
  @Prop theme: ThemeColors

  formatTime(ts: number): string {
    let d = new Date(ts)
    return d.getHours().toString().padStart(2,'0') + ':' + d.getMinutes().toString().padStart(2,'0')
  }

  build() {
    Column() {
      Row() {
        if (this.msg.role === 'user') Blank()
        Column() {
          Row() {
            if (this.msg.role === 'assistant') {
              Text(this.msg.isStreaming ? '●' : '').fontSize(8)
                .fontColor(this.theme.accentBlue).margin({ right: SPACE_XS })
            }
            Text(this.msg.role === 'user' ? '我' : 'Claude').fontSize(10)
              .fontColor(this.theme.textMuted).fontWeight(FontWeight.Medium)
            Text(' · ' + this.formatTime(this.msg.timestamp)).fontSize(10)
              .fontColor(this.theme.textMuted)
          }.margin({ bottom: 4 })
          .alignSelf(this.msg.role === 'user' ? ItemAlign.End : ItemAlign.Start)

          Column() {
            Text(this.msg.content || (this.msg.isStreaming ? '思考中...' : '')).fontSize(14)
              .fontColor(this.msg.role === 'user' ? '#FFFFFF' : this.theme.aiText)
              .padding({ left: 14, right: 14, top: 10, bottom: 10 }).textAlign(TextAlign.Start).lineHeight(20)
          }
          .borderRadius(this.msg.role === 'user' ?
            ({ topLeft: 18, topRight: 6, bottomLeft: 18, bottomRight: 18 }) :
            ({ topLeft: 6, topRight: 18, bottomLeft: 18, bottomRight: 18 }))
          .backgroundColor(this.msg.role === 'user' ? this.theme.accentBlue : this.theme.aiBubble)
          .borderWidth(this.msg.role === 'assistant' ? 1 : 0)
          .borderColor(this.msg.role === 'assistant' ? this.theme.border : Color.Transparent)
          .constraintSize({ maxWidth: '82%' })
          .onClick(() => {
            if (this.msg.role === 'assistant' && this.msg.content && !this.msg.isStreaming) {
              let pb = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.msg.content)
              pasteboard.getSystemPasteboard().setData(pb)
            }
          })

          if (this.msg.isStreaming) {
            Row() {
              LoadingProgress().width(12).height(12).color(this.theme.accentBlue)
              Text(' 生成中...').fontSize(10).fontColor(this.theme.textMuted)
            }.margin({ top: 4 }).alignSelf(ItemAlign.Start)
          }
        }
        .alignItems(this.msg.role === 'user' ? HorizontalAlign.End : HorizontalAlign.Start)
        if (this.msg.role === 'assistant') Blank()
      }.width('100%')
    }.width('100%').padding({ top: 6, bottom: 6 })
    .alignItems(this.msg.role === 'user' ? HorizontalAlign.End : HorizontalAlign.Start)
  }
}

@Component
export struct ChatPage {
  @State inputText: string = ''
  @State messages: ChatMessage[] = []
  @State isStreaming: boolean = false
  @State connectionStatus: ConnectionStatus = ConnectionStatus.DISCONNECTED
  @State showQuickCommands: boolean = true
  @State showScrollBtn: boolean = false
  @StorageLink('isDarkMode') isDarkMode: boolean = false
  private theme: ThemeColors = LIGHT_THEME
  private socketManager: SocketManager = SocketManager.getInstance()
  private chatVM: ChatViewModel = new ChatViewModel()
  private scroller: Scroller = new Scroller()
  private streamingMsgId: string = ''
  private onStatusFn: (status: ConnectionStatus) => void = () => {}
  private onMsgFn: (msg: WsMessage) => void = () => {}

  aboutToAppear(): void {
    this.connectionStatus = this.socketManager.getStatus()
    this.onStatusFn = (s: ConnectionStatus) => { this.connectionStatus = s }
    this.onMsgFn = (m: WsMessage) => { this.handleMessage(m) }
    this.socketManager.onStatusChange(this.onStatusFn)
    this.socketManager.onMessage(this.onMsgFn)
  }

  aboutToDisappear(): void {
    this.socketManager.offStatusChange(this.onStatusFn)
    this.socketManager.offMessage(this.onMsgFn)
  }

  handleMessage(msg: WsMessage): void {
    if (msg.type === 'chat:stream') {
      let c = msg.payload['chunk'] as string
      this.chatVM.appendToMessage(this.streamingMsgId, c, undefined)
      this.messages = [...this.chatVM.messages]
      this.showQuickCommands = false; this.scrollToBottom()
    } else if (msg.type === 'chat:done') {
      this.chatVM.finishMessage(this.streamingMsgId)
      this.isStreaming = false; this.showQuickCommands = false
      this.messages = [...this.chatVM.messages]; this.streamingMsgId = ''; this.scrollToBottom()
    } else if (msg.type === 'chat:error') {
      this.chatVM.finishMessage(this.streamingMsgId)
      this.isStreaming = false; this.messages = [...this.chatVM.messages]; this.streamingMsgId = ''
    }
  }

  sendMessage(text?: string): void {
    let txt = (text || this.inputText).trim()
    if (!txt || this.isStreaming) return
    if (this.connectionStatus !== ConnectionStatus.CONNECTED) return
    this.chatVM.addUserMessage(txt)
    this.streamingMsgId = this.chatVM.startAssistantMessage()
    this.messages = [...this.chatVM.messages]; this.inputText = ''
    this.isStreaming = true; this.showQuickCommands = false
    let p = new Object() as Record<string, Object>
    p['message'] = txt
    this.socketManager.send('chat:send', p)
    this.scrollToBottom()
  }

  sendQuickCommand(cmd: QuickCommand): void { this.sendMessage(cmd.prompt) }

  makePayload(): Record<string, Object> { return new Object() as Record<string, Object> }

  scrollToBottom(): void {
    setTimeout(() => { this.scroller.scrollEdge(Edge.Bottom); this.showScrollBtn = false }, 80)
  }

  onScroll(offset: number): void {
    this.showScrollBtn = offset < -100
  }

  statusLabel(): string {
    switch (this.connectionStatus) {
      case ConnectionStatus.CONNECTED: return '已连接'
      case ConnectionStatus.CONNECTING: return '连接中...'
      case ConnectionStatus.RECONNECTING: return '重连中...'
      default: return '未连接'
    }
  }

  build() {
    this.theme = this.isDarkMode ? DARK_THEME : LIGHT_THEME

    Column() {
      // Status bar
      Row() {
        Circle({ width: 10, height: 10 })
          .fill(this.connectionStatus === ConnectionStatus.CONNECTED
            ? this.theme.accentGreen : this.theme.accentRed)
          .shadow(this.connectionStatus === ConnectionStatus.CONNECTED
            ? { radius: 6, color: this.theme.accentGreen + '60', offsetY: 0 }
            : { radius: 0, color: '#00000000', offsetY: 0 })
        Text(' ' + this.statusLabel()).fontSize(12).fontColor(this.theme.textSecondary).margin({ left: SPACE_XS })
        Blank()
        Text('清空').fontSize(12).fontColor(this.theme.textSecondary)
          .padding({ left: 12, right: 12, top: 4, bottom: 4 }).borderRadius(10)
          .backgroundColor(this.theme.glassBg)
          .onClick(() => { this.chatVM.clearMessages(); this.messages = []; this.showQuickCommands = true })
      }
      .width('100%').padding({ left: SPACE_LG, right: SPACE_LG, top: SPACE_SM + 2, bottom: SPACE_SM })
      .backgroundColor(this.theme.glassBg).backdropBlur(12)

      // Welcome + Quick commands
      if (this.showQuickCommands && this.messages.length === 0) {
        Column() {
          Text('👋 你好！我能帮你做什么？').fontSize(FONT_BODY_LG)
            .fontColor(this.theme.textPrimary).fontWeight(FontWeight.Bold).margin({ bottom: 4 })
          Text('选择一个快捷指令，或直接输入你的需求').fontSize(12).fontColor(this.theme.textMuted).margin({ bottom: SPACE_MD })

          Grid() {
            ForEach(QUICK_COMMANDS, (cmd: QuickCommand) => {
              GridItem() {
                Column() {
                  Text(cmd.icon).fontSize(20)
                  Text(cmd.label).fontSize(10).fontColor(this.theme.textSecondary).margin({ top: 2 })
                }
                .width('100%').height(56).justifyContent(FlexAlign.Center)
                .backgroundColor(this.theme.glassBg).borderRadius(12)
                .borderWidth(1).borderColor(this.theme.glassBorder)
                .onClick(() => { this.sendQuickCommand(cmd) })
              }
            }, (cmd: QuickCommand) => cmd.label)
          }
          .columnsTemplate('1fr 1fr 1fr 1fr').columnsGap(8).rowsGap(8).width('100%').height(122)
        }
        .width('100%').padding({ left: SPACE_LG, right: SPACE_LG, top: SPACE_LG, bottom: SPACE_XS + 4 })
      }

      // Messages
      Stack() {
        List({ scroller: this.scroller }) {
          ForEach(this.messages, (msg: ChatMessage) => {
            ListItem() { MessageBubble({ msg: msg, theme: this.theme }) }
          }, (msg: ChatMessage) => msg.id)
        }
        .layoutWeight(1).width('100%').padding({ left: SPACE_MD, right: SPACE_MD })
        .onScrollIndex((idx: number) => { this.showScrollBtn = idx < this.messages.length - 3 })

        if (this.showScrollBtn && this.messages.length > 3) {
          Column() {
            Button({ type: ButtonType.Circle }) {
              Text('↓').fontSize(16).fontColor(this.theme.accentBlue)
            }
            .width(36).height(36).backgroundColor(this.theme.bgSecondary)
            .shadow({ radius: 4, color: '#00000015', offsetY: 2 })
            .onClick(() => { this.scrollToBottom() })
          }.align(Alignment.BottomEnd).padding({ right: SPACE_MD, bottom: SPACE_SM })
        }
      }.layoutWeight(1).width('100%')

      // Input
      Row() {
        Row() {
          TextInput({ placeholder: '输入需求...', text: this.inputText })
            .placeholderColor(this.theme.textMuted).fontColor(this.theme.textPrimary).fontSize(14)
            .backgroundColor(Color.Transparent).layoutWeight(1).height(44).borderRadius(0)
            .onChange((v: string) => { this.inputText = v }).onSubmit(() => { this.sendMessage() })
        }
        .layoutWeight(1).backgroundColor(this.theme.bgSecondary).borderRadius(22)
        .borderWidth(1).borderColor(this.theme.border).padding({ left: SPACE_LG }).height(44)

        Button() { Text('→').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF') }
        .width(40).height(40).borderRadius(20)
        .backgroundColor(this.inputText.trim().length > 0 && !this.isStreaming
          ? this.theme.accentBlue : this.theme.bgSecondary)
        .margin({ left: SPACE_SM })
        .enabled(this.inputText.trim().length > 0 && !this.isStreaming)
        .onClick(() => { this.sendMessage() })
      }
      .width('100%').padding({ left: SPACE_MD, right: SPACE_MD, top: SPACE_SM, bottom: SPACE_MD })
    }
    .width('100%').height('100%').backgroundColor(this.theme.bgPrimary)
  }
}
