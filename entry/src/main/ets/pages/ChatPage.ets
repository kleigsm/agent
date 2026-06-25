import { SocketManager, ConnectionStatus } from '../common/SocketManager';
import { ChatViewModel } from '../viewmodel/ChatViewModel';
import { SessionManager } from '../viewmodel/SessionManager';
import {
  EVENT_CHAT_SEND, EVENT_CHAT_STREAM, EVENT_CHAT_DONE, EVENT_CHAT_ERROR,
  COLOR_BG_PRIMARY, COLOR_BG_SECONDARY, COLOR_BG_INPUT,
  COLOR_TEXT_PRIMARY, COLOR_TEXT_SECONDARY, COLOR_TEXT_MUTED,
  COLOR_ACCENT_BLUE, COLOR_ACCENT_GREEN, COLOR_ACCENT_RED,
  COLOR_USER_BUBBLE, COLOR_BUBBLE_USER_TEXT, COLOR_BUBBLE_AI_TEXT,
  COLOR_AI_BUBBLE, COLOR_BORDER, COLOR_GLASS_BG, COLOR_GLASS_BORDER,
  SPACE_XS, SPACE_SM, SPACE_MD, SPACE_LG, SPACE_XL,
  RADIUS_XL, ANIM_DURATION_NORMAL,
  QUICK_COMMANDS, QuickCommand
} from '../common/Constants';
import { WsMessage, ChatMessage, ChatSession } from '../common/Models';
import { pasteboard } from '@kit.BasicServicesKit';
import { MarkdownRenderer } from '../common/MarkdownRenderer';

@Component
struct MessageBubble {
  @ObjectLink msg: ChatMessage

  formatTime(ts: number): string {
    let d = new Date(ts)
    return d.getHours().toString().padStart(2,'0') + ':' + d.getMinutes().toString().padStart(2,'0')
  }

  build() {
    Column() {
      Row() {
        if (this.msg.role === 'user') { Blank() }
        Column() {
          Row() {
            if (this.msg.role === 'assistant') {
              Text(this.msg.isStreaming ? '●' : '').fontSize(8)
                .fontColor(COLOR_ACCENT_BLUE).margin({ right: SPACE_XS })
            }
            Text(this.msg.role === 'user' ? '我' : 'Claude').fontSize(10)
              .fontColor(COLOR_TEXT_MUTED).fontWeight(FontWeight.Medium)
            Text(' · ' + this.formatTime(this.msg.timestamp)).fontSize(10).fontColor(COLOR_TEXT_MUTED)
          }.margin({ bottom: 4 })
          .alignSelf(this.msg.role === 'user' ? ItemAlign.End : ItemAlign.Start)

          Column() {
            if (this.msg.role === 'assistant') {
              if (this.msg.content) {
                Column() {
                  MarkdownRenderer({ content: this.msg.content })
                }.padding({ left: 14, right: 14, top: 10, bottom: 10 }).width('100%')
              } else {
                Text(this.msg.isStreaming ? '思考中...' : '').fontSize(14)
                  .fontColor(COLOR_BUBBLE_AI_TEXT)
                  .padding({ left: 14, right: 14, top: 10, bottom: 10 })
              }
            } else {
              Text(this.msg.content).fontSize(14)
                .fontColor(COLOR_BUBBLE_USER_TEXT)
                .padding({ left: 14, right: 14, top: 10, bottom: 10 }).textAlign(TextAlign.Start).lineHeight(20)
            }
          }
          .borderRadius(this.msg.role === 'user' ?
            ({ topLeft: 18, topRight: 6, bottomLeft: 18, bottomRight: 18 }) :
            ({ topLeft: 6, topRight: 18, bottomLeft: 18, bottomRight: 18 }))
          .backgroundColor(this.msg.role === 'user' ? COLOR_USER_BUBBLE : COLOR_AI_BUBBLE)
          .borderWidth(this.msg.role === 'assistant' ? 1 : 0)
          .borderColor(COLOR_BORDER).constraintSize({ maxWidth: '82%' })
          .onClick(() => {
            if (this.msg.role === 'assistant' && this.msg.content && !this.msg.isStreaming) {
              pasteboard.getSystemPasteboard().setData(
                pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.msg.content)
              )
            }
          })

          if (this.msg.isStreaming) {
            Row() {
              LoadingProgress().width(12).height(12).color(COLOR_ACCENT_BLUE)
              Text(' 生成中...').fontSize(10).fontColor(COLOR_TEXT_MUTED)
            }.margin({ top: 4 }).alignSelf(ItemAlign.Start)
          }
        }
        .alignItems(this.msg.role === 'user' ? HorizontalAlign.End : HorizontalAlign.Start)
        if (this.msg.role === 'assistant') { Blank() }
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
  @State showDrawer: boolean = false
  @State sessionTitle: string = '对话'
  @State sessionCount: number = 1
  private socketManager: SocketManager = SocketManager.getInstance()
  private chatVM: ChatViewModel = new ChatViewModel()
  private sessionMgr: SessionManager = SessionManager.getInstance()
  private scroller: Scroller = new Scroller()
  private streamingMsgId: string = ''
  private onStatusFn: (s: ConnectionStatus) => void = () => {}
  private onMsgFn: (m: WsMessage) => void = () => {}

  aboutToAppear(): void {
    let ctx = this.getUIContext().getHostContext()
    if (ctx) {
      this.chatVM.init(ctx).then(() => { this.refreshUI() })
    }
    this.connectionStatus = this.socketManager.getStatus()
    this.onStatusFn = (s: ConnectionStatus) => { this.connectionStatus = s }
    this.onMsgFn = (m: WsMessage) => { this.handleMessage(m) }
    this.socketManager.onStatusChange(this.onStatusFn); this.socketManager.onMessage(this.onMsgFn)
  }
  aboutToDisappear(): void { this.socketManager.offStatusChange(this.onStatusFn); this.socketManager.offMessage(this.onMsgFn) }

  refreshUI(): void {
    this.messages = [...this.chatVM.messages]
    this.sessionTitle = this.chatVM.currentTitle
    this.sessionCount = this.chatVM.sessions.length
    this.showQuickCommands = this.messages.length === 0
  }

  handleMessage(msg: WsMessage): void {
    if (msg.type === EVENT_CHAT_STREAM) {
      this.chatVM.appendToMessage(this.streamingMsgId, msg.payload['chunk'] as string, undefined)
      this.messages = [...this.chatVM.messages]; this.showQuickCommands = false; this.scrollToBottom()
    } else if (msg.type === EVENT_CHAT_DONE) {
      this.chatVM.finishMessage(this.streamingMsgId); this.isStreaming = false
      this.messages = [...this.chatVM.messages]; this.streamingMsgId = ''; this.scrollToBottom()
      this.refreshUI()
    } else if (msg.type === EVENT_CHAT_ERROR) {
      this.chatVM.finishMessage(this.streamingMsgId); this.isStreaming = false
      this.messages = [...this.chatVM.messages]; this.streamingMsgId = ''
    }
  }

  sendMessage(text?: string): void {
    let t = (text || this.inputText).trim()
    if (!t || this.isStreaming || this.connectionStatus !== ConnectionStatus.CONNECTED) return
    this.chatVM.addUserMessage(t); this.streamingMsgId = this.chatVM.startAssistantMessage()
    this.messages = [...this.chatVM.messages]; this.inputText = ''; this.isStreaming = true
    let p = new Object() as Record<string, Object>; p['message'] = t
    this.socketManager.send(EVENT_CHAT_SEND, p); this.showQuickCommands = false; this.scrollToBottom()
    this.sessionTitle = this.chatVM.currentTitle
  }
  sendQuickCommand(cmd: QuickCommand): void { this.sendMessage(cmd.prompt) }
  scrollToBottom(): void { setTimeout(() => { this.scroller.scrollEdge(Edge.Bottom); this.showScrollBtn = false }, 80) }

  statusLabel(): string {
    switch (this.connectionStatus) {
      case ConnectionStatus.CONNECTED: return '已连接'
      case ConnectionStatus.CONNECTING: return '连接中...'
      case ConnectionStatus.RECONNECTING: return '重连中...'
      default: return '未连接'
    }
  }

  // ── Session drawer ──
  onNewSession(): void {
    this.chatVM.createSession()
    this.refreshUI()
    this.showDrawer = false
  }
  onSwitchSession(id: string): void {
    this.chatVM.switchSession(id)
    this.refreshUI()
    this.showDrawer = false
    this.scroller.scrollEdge(Edge.Bottom)
  }
  onDeleteSession(id: string): void {
    this.chatVM.deleteSession(id)
    this.refreshUI()
  }
  formatSessionTime(ts: number): string {
    let d = new Date(ts)
    return (d.getMonth()+1).toString().padStart(2,'0') + '/' + d.getDate().toString().padStart(2,'0')
  }

  build() {
    Stack() {
      Column() {
        // ── Top bar ──
        Row() {
          Row() {
            Circle({ width: 10, height: 10 })
              .fill(this.connectionStatus === ConnectionStatus.CONNECTED ? COLOR_ACCENT_GREEN : COLOR_ACCENT_RED)
              .shadow(this.connectionStatus === ConnectionStatus.CONNECTED
                ? { radius: 6, color: COLOR_ACCENT_GREEN + '60', offsetY: 0 }
                : { radius: 0, color: '#00000000', offsetY: 0 })
          }.onClick(() => { this.showDrawer = true })

          Text(' ' + this.sessionTitle).fontSize(13).fontColor(COLOR_TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1).margin({ left: SPACE_XS })
            .onClick(() => { this.showDrawer = true })

          if (this.sessionCount > 1) {
            Text(this.sessionCount.toString()).fontSize(10).fontColor(COLOR_ACCENT_BLUE)
              .backgroundColor(COLOR_ACCENT_BLUE + '18').borderRadius(8)
              .padding({ left: 6, right: 6, top: 1, bottom: 1 }).margin({ right: SPACE_SM })
          }

          Text('清空').fontSize(12).fontColor(COLOR_TEXT_SECONDARY)
            .padding({ left: 12, right: 12, top: 4, bottom: 4 }).borderRadius(10)
            .backgroundColor(COLOR_GLASS_BG)
            .onClick(() => { this.chatVM.clearMessages(); this.messages = []; this.showQuickCommands = true; this.refreshUI() })
        }
        .width('100%').padding({ left: SPACE_LG, right: SPACE_LG, top: SPACE_SM + 2, bottom: SPACE_SM })
        .backgroundColor(COLOR_GLASS_BG).backdropBlur(12)

        if (this.showQuickCommands) {
          Column() {
            Text('👋 你好！我能帮你做什么？').fontSize(16).fontColor(COLOR_TEXT_PRIMARY).fontWeight(FontWeight.Bold)
            Text('选择一个快捷指令，或直接输入你的需求').fontSize(12).fontColor(COLOR_TEXT_MUTED).margin({ top: 4, bottom: SPACE_MD })
            Grid() {
              ForEach(QUICK_COMMANDS, (cmd: QuickCommand) => {
                GridItem() {
                  Column() {
                    Text(cmd.icon).fontSize(20)
                    Text(cmd.label).fontSize(10).fontColor(COLOR_TEXT_SECONDARY).margin({ top: 2 })
                  }
                  .width('100%').height(56).justifyContent(FlexAlign.Center)
                  .backgroundColor(COLOR_GLASS_BG).borderRadius(12).borderWidth(1).borderColor(COLOR_GLASS_BORDER)
                  .onClick(() => { this.sendQuickCommand(cmd) })
                }
              }, (cmd: QuickCommand) => cmd.label)
            }
            .columnsTemplate('1fr 1fr 1fr 1fr').columnsGap(8).rowsGap(8).width('100%').height(122)
          }
          .width('100%').padding({ left: SPACE_LG, right: SPACE_LG, top: SPACE_LG, bottom: SPACE_XS + 4 })
        }

        Stack() {
          List({ scroller: this.scroller }) {
            ForEach(this.messages, (msg: ChatMessage) => {
              ListItem() { MessageBubble({ msg: msg }) }
            }, (msg: ChatMessage) => msg.id)
          }
          .layoutWeight(1).width('100%').padding({ left: SPACE_MD, right: SPACE_MD })
          .onScrollIndex((idx: number) => { this.showScrollBtn = idx < this.messages.length - 3 })

          if (this.showScrollBtn && this.messages.length > 3) {
            Column() {
              Button({ type: ButtonType.Circle }) { Text('↓').fontSize(16).fontColor(COLOR_ACCENT_BLUE) }
              .width(36).height(36).backgroundColor(COLOR_BG_SECONDARY)
              .shadow({ radius: 4, color: '#00000015', offsetY: 2 })
              .onClick(() => { this.scrollToBottom() })
            }.align(Alignment.BottomEnd).padding({ right: SPACE_MD, bottom: SPACE_SM })
          }
        }.layoutWeight(1).width('100%')

        Row() {
          Row() {
            TextInput({ placeholder: '输入需求...', text: this.inputText })
              .placeholderColor(COLOR_TEXT_MUTED).fontColor(COLOR_TEXT_PRIMARY).fontSize(14)
              .backgroundColor(Color.Transparent).layoutWeight(1).height(44).borderRadius(0)
              .onChange((v: string) => { this.inputText = v }).onSubmit(() => { this.sendMessage() })
          }
          .layoutWeight(1).backgroundColor(COLOR_BG_SECONDARY).borderRadius(22)
          .borderWidth(1).borderColor(COLOR_BORDER).padding({ left: SPACE_LG }).height(44)
          Button() { Text('→').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF') }
          .width(40).height(40).borderRadius(20)
          .backgroundColor(this.inputText.trim() && !this.isStreaming ? COLOR_ACCENT_BLUE : COLOR_BG_SECONDARY)
          .margin({ left: SPACE_SM })
          .enabled(this.inputText.trim().length > 0 && !this.isStreaming)
          .onClick(() => { this.sendMessage() })
        }
        .width('100%').padding({ left: SPACE_MD, right: SPACE_MD, top: SPACE_SM, bottom: SPACE_MD })
      }
      .width('100%').height('100%').backgroundColor(COLOR_BG_PRIMARY)

      // ── Session Drawer ──
      if (this.showDrawer) {
        Column() {
          // backdrop
        }
        .width('100%').height('100%').backgroundColor('#00000040')
        .onClick(() => { this.showDrawer = false })
        .zIndex(1)

        Column() {
          // Drawer header
          Row() {
            Text('会话列表').fontSize(18).fontColor(COLOR_TEXT_PRIMARY).fontWeight(FontWeight.Bold).layoutWeight(1)
            Button() { Text('+').fontSize(20).fontWeight(FontWeight.Bold).fontColor(COLOR_ACCENT_BLUE) }
            .width(36).height(36).borderRadius(18).backgroundColor(COLOR_ACCENT_BLUE + '15')
            .onClick(() => { this.onNewSession() })
          }.width('100%').padding({ left: SPACE_LG, right: SPACE_LG, top: SPACE_MD, bottom: SPACE_MD })

          // Session list
          List() {
            ForEach(this.chatVM.sessions, (session: ChatSession) => {
              ListItem() {
                Row() {
                  Column() {
                    Text(session.title).fontSize(14)
                      .fontColor(session.id === this.chatVM.currentSessionId ? COLOR_ACCENT_BLUE : COLOR_TEXT_PRIMARY)
                      .fontWeight(session.id === this.chatVM.currentSessionId ? FontWeight.Bold : FontWeight.Normal)
                      .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis }).width('100%')
                    Row() {
                      Text(this.formatSessionTime(session.updatedAt)).fontSize(11).fontColor(COLOR_TEXT_MUTED)
                      Text(' · ' + session.messages.length + '条消息').fontSize(11).fontColor(COLOR_TEXT_MUTED)
                    }.margin({ top: 2 })
                  }.layoutWeight(1).alignItems(HorizontalAlign.Start)

                  if (session.id === this.chatVM.currentSessionId) {
                    Circle({ width: 8, height: 8 }).fill(COLOR_ACCENT_BLUE).margin({ right: SPACE_MD })
                  }

                  if (this.chatVM.sessions.length > 1) {
                    Text('🗑').fontSize(16).opacity(0.5)
                      .onClick(() => { this.onDeleteSession(session.id) })
                  }
                }
                .width('100%').padding({ left: SPACE_LG, right: SPACE_LG, top: SPACE_MD, bottom: SPACE_MD })
                .backgroundColor(session.id === this.chatVM.currentSessionId ? COLOR_ACCENT_BLUE + '0C' : Color.Transparent)
                .borderRadius(12).margin({ left: SPACE_SM, right: SPACE_SM, bottom: 2 })
                .onClick(() => { this.onSwitchSession(session.id) })
              }
            }, (session: ChatSession) => session.id)
          }.layoutWeight(1).width('100%')
        }
        .width('80%').height('100%').backgroundColor(COLOR_BG_SECONDARY)
        .position({ x: 0, y: 0 }).zIndex(2)
        .shadow({ radius: 16, color: '#00000020', offsetX: 4, offsetY: 0 })
      }
    }
    .width('100%').height('100%')
  }
}
