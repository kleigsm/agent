import { ChatSession, ChatMessage } from '../common/Models'
import { preferences } from '@kit.ArkData'

const PREF_NAME = 'coderm_session'
const KEY_SESSIONS = 'sessions'
const KEY_CURRENT = 'currentId'

export class SessionManager {
  private static inst: SessionManager | null = null
  private prefs: preferences.Preferences | null = null
  sessions: ChatSession[] = []
  currentSessionId: string = ''

  static getInstance(): SessionManager {
    if (!SessionManager.inst) SessionManager.inst = new SessionManager()
    return SessionManager.inst
  }

  async init(ctx: Context): Promise<void> {
    try {
      this.prefs = await preferences.getPreferences(ctx, PREF_NAME)
      let json: string = ''
      try { json = await this.prefs.get(KEY_SESSIONS, '') as string } catch (_e) {}
      if (json) {
        try {
          let raw = JSON.parse(json) as Array<Record<string, Object>>
          this.sessions = raw.map((r: Record<string, Object>) => {
            let s = new ChatSession()
            s.id = r['id'] as string
            s.title = r['title'] as string
            s.createdAt = r['createdAt'] as number
            s.updatedAt = r['updatedAt'] as number
            let msgs = r['messages'] as Array<Record<string, Object>>
            if (msgs) {
              s.messages = msgs.map((m: Record<string, Object>) => {
                let msg = new ChatMessage(m['id'] as string, m['role'] as string, m['content'] as string)
                msg.timestamp = m['timestamp'] as number
                msg.isStreaming = false
                return msg
              })
            }
            return s
          })
        } catch (e) {
          console.error('[SessionManager] parse error:', e)
          this.sessions = []
        }
      }
      let curId: string = ''
      try { curId = await this.prefs.get(KEY_CURRENT, '') as string } catch (_e) {}
      if (curId && this.sessions.find(s => s.id === curId)) {
        this.currentSessionId = curId
      } else if (this.sessions.length > 0) {
        this.currentSessionId = this.sessions[0].id
      }
    } catch (e) {
      console.error('[SessionManager] init error:', e)
    }
  }

  getCurrentSession(): ChatSession | null {
    return this.sessions.find(s => s.id === this.currentSessionId) || null
  }

  getCurrentMessages(): ChatMessage[] {
    let s = this.getCurrentSession()
    return s ? s.messages : []
  }

  createSession(): ChatSession {
    let s = new ChatSession()
    s.id = 's_' + Date.now()
    s.title = '新对话'
    s.createdAt = Date.now()
    s.updatedAt = Date.now()
    s.messages = []
    this.sessions.unshift(s)
    this.currentSessionId = s.id
    this.save()
    return s
  }

  switchSession(id: string): void {
    if (this.sessions.find(s => s.id === id)) {
      this.currentSessionId = id
      this.saveCurrent()
    }
  }

  deleteSession(id: string): void {
    let idx = this.sessions.findIndex(s => s.id === id)
    if (idx === -1) return
    this.sessions.splice(idx, 1)
    if (this.currentSessionId === id) {
      this.currentSessionId = this.sessions.length > 0 ? this.sessions[0].id : ''
    }
    if (!this.currentSessionId) {
      this.createSession()
    } else {
      this.save()
    }
  }

  /** Auto-title: use first user message, truncated to 20 chars */
  autoTitle(sessionId: string): void {
    let s = this.sessions.find(s => s.id === sessionId)
    if (!s || s.title !== '新对话') return
    let firstUser = s.messages.find(m => m.role === 'user')
    if (firstUser) {
      let t = firstUser.content.replace(/\n/g, ' ').trim()
      s.title = t.length > 20 ? t.substring(0, 20) + '…' : t
      s.updatedAt = Date.now()
      this.save()
    }
  }

  renameSession(id: string, newTitle: string): void {
    let s = this.sessions.find(s => s.id === id)
    if (s && newTitle.trim()) {
      s.title = newTitle.trim()
      s.updatedAt = Date.now()
      this.save()
    }
  }

  addMessage(msg: ChatMessage): void {
    let s = this.getCurrentSession()
    if (s) {
      s.messages.push(msg)
      s.updatedAt = Date.now()
    }
  }

  updateLastAssistant(content: string, isStreaming: boolean): void {
    let s = this.getCurrentSession()
    if (!s) return
    for (let i = s.messages.length - 1; i >= 0; i--) {
      if (s.messages[i].role === 'assistant') {
        s.messages[i].content = content
        s.messages[i].isStreaming = isStreaming
        s.updatedAt = Date.now()
        return
      }
    }
  }

  clearCurrentSession(): void {
    let s = this.getCurrentSession()
    if (s) {
      s.messages = []
      s.title = '新对话'
      s.updatedAt = Date.now()
      this.save()
    }
  }

  private serializeSessions(): string {
    let data: Record<string, Object>[] = []
    for (let s of this.sessions) {
      let msgs: Record<string, Object>[] = []
      for (let m of s.messages) {
        let msgObj: Record<string, Object> = {}
        msgObj['id'] = m.id
        msgObj['role'] = m.role
        msgObj['content'] = m.content
        msgObj['timestamp'] = m.timestamp
        msgs.push(msgObj)
      }
      let sessObj: Record<string, Object> = {}
      sessObj['id'] = s.id
      sessObj['title'] = s.title
      sessObj['createdAt'] = s.createdAt
      sessObj['updatedAt'] = s.updatedAt
      sessObj['messages'] = msgs
      data.push(sessObj)
    }
    return JSON.stringify(data)
  }

  private async save(): Promise<void> {
    if (!this.prefs) return
    try {
      let data = this.serializeSessions()
      await this.prefs.put(KEY_SESSIONS, data)
      await this.prefs.put(KEY_CURRENT, this.currentSessionId)
      await this.prefs.flush()
    } catch (e) {
      console.error('[SessionManager] save error:', e)
    }
  }

  private async saveCurrent(): Promise<void> {
    if (!this.prefs) return
    try {
      await this.prefs.put(KEY_CURRENT, this.currentSessionId)
      await this.prefs.flush()
    } catch (e) {
      console.error('[SessionManager] saveCurrent error:', e)
    }
  }

  /** Call save explicitly when messages change (debounced externally) */
  async persist(): Promise<void> {
    await this.save()
  }
}
