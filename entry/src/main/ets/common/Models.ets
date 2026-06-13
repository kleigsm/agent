@Observed
export class ChatMessage {
  id: string = ''
  role: string = 'user'
  content: string = ''
  isStreaming: boolean = false
  timestamp: number = Date.now()

  constructor(id: string, role: string, content: string) {
    this.id = id
    this.role = role
    this.content = content
    this.timestamp = Date.now()
  }
}

export class FileNode {
  name: string = ''
  type: string = 'file'
  path: string = ''
  size: number = 0
  modified: string = ''
}

export class TerminalOutput {
  data: string = ''
  isStderr: boolean = false
}

export class WsMessage {
  type: string = ''
  payload: Record<string, Object> = {}
}
