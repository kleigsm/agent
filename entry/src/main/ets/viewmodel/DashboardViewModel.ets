import { SocketManager, ConnectionStatus } from '../common/SocketManager'
import { WsMessage } from '../common/Models'

export interface GitChange { text: string; type: string }
export interface GitCommit { hash: string; msg: string }

export class DashboardViewModel {
  private socket: SocketManager = SocketManager.getInstance()
  branch: string = ''
  changes: GitChange[] = []
  commits: GitCommit[] = []
  connected: boolean = false

  onUpdate?: () => void

  init(onUpdate: () => void): void {
    this.onUpdate = onUpdate
    this.connected = this.socket.getStatus() === ConnectionStatus.CONNECTED
  }

  refresh(): void {
    if (!this.connected) return
    let p = new Object() as Record<string, Object>
    this.socket.send('project:status', p)
  }

  handleMessage(msg: WsMessage): void {
    if (msg.type === 'project:status') {
      let success = msg.payload['success'] as boolean
      if (!success) return
      this.branch = msg.payload['branch'] as string || ''
      let raw = msg.payload['changes'] as string[] || []
      this.changes = raw.map((c: string) => {
        let status = c.substring(0, 2).trim()
        let type = status.includes('M') ? 'modified' : status.includes('A') ? 'added' :
          status.includes('D') ? 'deleted' : status.includes('?') ? 'untracked' : 'modified'
        return { text: c.substring(3) || c, type: type }
      })
      this.commits = msg.payload['commits'] as GitCommit[] || []
      if (this.onUpdate) this.onUpdate()
    }
  }

  changeLabel(type: string): string {
    switch (type) {
      case 'modified': return 'M'
      case 'added': return 'A'
      case 'deleted': return 'D'
      case 'untracked': return '??'
      default: return 'M'
    }
  }

  changeColor(type: string): string {
    switch (type) {
      case 'modified': return '#FF9500'
      case 'added': return '#34C759'
      case 'deleted': return '#FF3B30'
      case 'untracked': return '#AEAEB2'
      default: return '#FF9500'
    }
  }
}
