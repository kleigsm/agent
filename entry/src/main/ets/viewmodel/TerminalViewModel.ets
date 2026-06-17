import { TerminalOutput } from '../common/Models';

export class TerminalViewModel {
  outputLines: TerminalOutput[] = []
  commandHistory: string[] = []
  historyIndex: number = -1
  currentCommand: string = ''
  isRunning: boolean = false
  cwd: string = '/'

  addOutput(data: string, isStderr: boolean = false): void {
    this.outputLines.push({ data, isStderr } as TerminalOutput)
    if (this.outputLines.length > 500) {
      this.outputLines.splice(0, 100)
    }
  }

  addToHistory(command: string): void {
    this.commandHistory.push(command)
    if (this.commandHistory.length > 100) {
      this.commandHistory.shift()
    }
    this.historyIndex = this.commandHistory.length
  }

  navigateHistory(direction: number): string {
    const newIndex = this.historyIndex + direction
    if (newIndex >= 0 && newIndex < this.commandHistory.length) {
      this.historyIndex = newIndex
      return this.commandHistory[newIndex]
    }
    return this.currentCommand
  }

  clearOutput(): void {
    this.outputLines = []
  }

  getOutputText(): string {
    return this.outputLines.map(l => (l.isStderr ? '[ERR] ' : '') + l.data).join('')
  }
}
