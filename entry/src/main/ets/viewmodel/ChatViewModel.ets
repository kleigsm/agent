import { ChatMessage, ChatSession } from '../common/Models'
import { SessionManager } from './SessionManager'

export class ChatViewModel {
  private sessionMgr: SessionManager = SessionManager.getInstance()
  isStreaming: boolean = false

  get messages(): ChatMessage[] {
    return this.sessionMgr.getCurrentMessages()
  }

  get sessions(): ChatSession[] {
    return this.sessionMgr.sessions
  }

  get currentSessionId(): string {
    return this.sessionMgr.currentSessionId
  }

  get currentTitle(): string {
    let s = this.sessionMgr.getCurrentSession()
    return s ? s.title : '对话'
  }

  async init(ctx: Context): Promise<void> {
    await this.sessionMgr.init(ctx)
    if (this.sessionMgr.sessions.length === 0) {
      this.sessionMgr.createSession()
    }
  }

  addUserMessage(content: string): void {
    const msg = new ChatMessage(
      'msg_' + Date.now() + '_' + Math.random().toString(36).substring(2, 11),
      'user',
      content
    )
    this.sessionMgr.addMessage(msg)
    this.sessionMgr.autoTitle(this.sessionMgr.currentSessionId)
  }

  startAssistantMessage(): string {
    const msgId = 'msg_' + Date.now() + '_' + Math.random().toString(36).substring(2, 11)
    const msg = new ChatMessage(msgId, 'assistant', '')
    msg.isStreaming = true
    this.sessionMgr.addMessage(msg)
    this.isStreaming = true
    return msgId
  }

  appendToMessage(msgId: string, chunk: string, lastMessage?: string): void {
    if (lastMessage) {
      this.sessionMgr.updateLastAssistant(lastMessage, true)
    } else {
      let msgs = this.sessionMgr.getCurrentMessages()
      for (let i = msgs.length - 1; i >= 0; i--) {
        if (msgs[i].id === msgId || msgs[i].role === 'assistant') {
          msgs[i].content += chunk
          break
        }
      }
    }
  }

  finishMessage(msgId: string): void {
    let msgs = this.sessionMgr.getCurrentMessages()
    for (let i = msgs.length - 1; i >= 0; i--) {
      if (msgs[i].id === msgId || (msgs[i].role === 'assistant' && msgs[i].isStreaming)) {
        msgs[i].isStreaming = false
        break
      }
    }
    this.isStreaming = false
    this.sessionMgr.persist()
  }

  clearMessages(): void {
    this.sessionMgr.clearCurrentSession()
    this.isStreaming = false
  }

  // ── Session management ──
  createSession(): ChatSession {
    return this.sessionMgr.createSession()
  }

  switchSession(id: string): void {
    this.sessionMgr.switchSession(id)
    this.isStreaming = false
  }

  deleteSession(id: string): void {
    this.sessionMgr.deleteSession(id)
  }

  renameSession(id: string, title: string): void {
    this.sessionMgr.renameSession(id, title)
  }

  async persistSessions(): Promise<void> {
    await this.sessionMgr.persist()
  }
}
