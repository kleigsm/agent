import { SocketManager } from '../common/SocketManager'
import { EVENT_TERM_EXEC, EVENT_TERM_OUTPUT, EVENT_TERM_EXIT } from '../common/Constants'
import { WsMessage } from '../common/Models'

export enum BuildStatus {
  IDLE = 'idle',
  BUILDING = 'building',
  SUCCESS = 'success',
  FAILED = 'failed'
}

export interface BuildLogLine {
  text: string
  level: 'info' | 'warn' | 'error' | 'success'
}

export interface BuildCommand {
  label: string
  icon: string
  cmd: string
}

export const BUILD_COMMANDS: BuildCommand[] = [
  { label: '构建 HAP', icon: '📦', cmd: 'hvigorw assembleHap' },
  { label: '清理构建', icon: '🧹', cmd: 'hvigorw clean' },
  { label: '运行测试', icon: '🧪', cmd: 'hvigorw test' },
  { label: '完整构建', icon: '🚀', cmd: 'hvigorw assembleHap --no-daemon' },
]

export class BuildViewModel {
  private socket: SocketManager = SocketManager.getInstance()
  private onMsgFn: (m: WsMessage) => void = () => {}
  status: BuildStatus = BuildStatus.IDLE
  progress: number = 0       // 0-100
  logLines: BuildLogLine[] = []
  exitCode: number = -1
  currentCommand: string = ''
  onUpdate?: () => void
  private scroller: Scroller | null = null

  init(onUpdate: () => void): void {
    this.onUpdate = onUpdate
    this.onMsgFn = (m: WsMessage) => { this.handleMessage(m) }
    this.socket.onMessage(this.onMsgFn)
  }

  destroy(): void {
    this.socket.offMessage(this.onMsgFn)
  }

  setScroller(s: Scroller): void {
    this.scroller = s
  }

  handleMessage(msg: WsMessage): void {
    if (msg.type === EVENT_TERM_OUTPUT) {
      let data = msg.payload['data'] as string
      let stderr = msg.payload['stderr'] as boolean
      if (data) {
        let lines = data.split('\n')
        for (let line of lines) {
          if (!line.trim()) continue
          let level: 'info' | 'warn' | 'error' | 'success' = stderr ? 'error' : 'info'

          // Parse for progress indicators
          let lower = line.toLowerCase()

          // Percentage pattern: 45%, [===   ] 60%
          let pctMatch = line.match(/(\d{1,3})%/)
          if (pctMatch) {
            let p = parseInt(pctMatch[1])
            if (p >= 0 && p <= 100) this.progress = p
            level = 'success'
          }

          // Step progress: [1/5], (2/8), BUILD STEP 3/6
          let stepMatch = line.match(/[\[(](\d+)\s*\/\s*(\d+)[)\]]/)
          if (!stepMatch) stepMatch = line.match(/step\s*(\d+)\s*\/\s*(\d+)/i)
          if (stepMatch) {
            let cur = parseInt(stepMatch[1])
            let total = parseInt(stepMatch[2])
            if (total > 0) this.progress = Math.round((cur / total) * 100)
          }

          // Task indicator: > hvigor TaskName
          if (line.includes('> hvigor') || line.includes('> Task')) {
            level = 'success'
            // Bump progress if no explicit indicator
            if (!pctMatch && !stepMatch && this.progress < 90) {
              this.progress = Math.min(this.progress + 5, 90)
            }
          }

          // Error indicators
          if (lower.includes('error') || lower.includes('fail') || lower.includes('exception')) {
            level = 'error'
          }
          // Warning indicators
          if (lower.includes('warn') || lower.includes('deprecat')) {
            level = level === 'error' ? 'error' : 'warn'
          }
          // Success indicators
          if (lower.includes('build successful') || lower.includes('success') || lower.includes('完成')) {
            level = 'success'
            this.progress = 100
          }

          this.logLines.push({ text: line, level: level })
        }
        // Trim log
        if (this.logLines.length > 500) {
          this.logLines = this.logLines.slice(-300)
        }
        if (this.onUpdate) this.onUpdate()
        // Auto-scroll
        setTimeout(() => { if (this.scroller) this.scroller.scrollEdge(Edge.Bottom) }, 50)
      }
    } else if (msg.type === EVENT_TERM_EXIT) {
      let code = msg.payload['code'] as number
      this.exitCode = code
      if (code === 0) {
        this.status = BuildStatus.SUCCESS
        this.progress = 100
        this.logLines.push({ text: '✅ 编译成功！', level: 'success' })
      } else {
        this.status = BuildStatus.FAILED
        this.logLines.push({ text: '❌ 编译失败 (exit code: ' + code + ')', level: 'error' })
      }
      if (this.onUpdate) this.onUpdate()
    }
  }

  runCommand(cmd: string): void {
    this.status = BuildStatus.BUILDING
    this.progress = 0
    this.logLines = []
    this.exitCode = -1
    this.currentCommand = cmd
    this.logLines.push({ text: '$ ' + cmd, level: 'info' })
    if (this.onUpdate) this.onUpdate()

    let p = new Object() as Record<string, Object>
    p['command'] = cmd
    this.socket.send(EVENT_TERM_EXEC, p)
  }

  runPreset(index: number): void {
    if (index >= 0 && index < BUILD_COMMANDS.length) {
      this.runCommand(BUILD_COMMANDS[index].cmd)
    }
  }

  clear(): void {
    this.status = BuildStatus.IDLE
    this.progress = 0
    this.logLines = []
    this.exitCode = -1
    this.currentCommand = ''
    if (this.onUpdate) this.onUpdate()
  }

  statusLabel(): string {
    switch (this.status) {
      case BuildStatus.BUILDING: return '编译中...'
      case BuildStatus.SUCCESS: return '编译成功 ✅'
      case BuildStatus.FAILED: return '编译失败 ❌'
      default: return '就绪'
    }
  }

  statusColor(): string {
    switch (this.status) {
      case BuildStatus.BUILDING: return '#007AFF'
      case BuildStatus.SUCCESS: return '#34C759'
      case BuildStatus.FAILED: return '#FF3B30'
      default: return '#AEAEB2'
    }
  }
}
