import { FileNode } from '../common/Models';

export class FilesViewModel {
  currentPath: string = '/'
  entries: FileNode[] = []
  fileContent: string = ''
  viewingFile: string = ''
  isLoading: boolean = false
  parentPath: string = '/'
  diffContent: string = ''
  isEditing: boolean = false
  editContent: string = ''
  gitStatusMap: Record<string, string> = {}

  setGitStatus(map: Record<string, string>): void {
    this.gitStatusMap = map
  }

  getGitStatus(filePath: string): string {
    // filePath from listing is like "/src/main/ets/pages/Index.ets"
    // git status uses paths like "src/main/ets/pages/Index.ets"
    let key = filePath.replace(/^\//, '')
    return this.gitStatusMap[key] || ''
  }

  gitStatusColor(status: string): string {
    if (status === 'modified') return '#FF9500'
    if (status === 'added') return '#34C759'
    if (status === 'deleted') return '#FF3B30'
    return '#AEAEB2'
  }

  setEntries(path: string, files: FileNode[]): void {
    this.currentPath = path
    this.entries = files
    this.parentPath = path === '/' ? '/' : path.substring(0, path.lastIndexOf('/')) || '/'
  }

  setFileContent(path: string, content: string): void {
    this.viewingFile = path
    this.fileContent = content
    this.isEditing = false
    this.editContent = ''
    this.diffContent = ''
  }

  clearFileView(): void {
    this.viewingFile = ''
    this.fileContent = ''
    this.diffContent = ''
    this.isEditing = false
    this.editContent = ''
  }

  setDiffContent(path: string, diff: string): void {
    if (path === this.viewingFile) {
      this.diffContent = diff
    }
  }

  enterEditMode(): void {
    this.editContent = this.fileContent
    this.isEditing = true
  }

  cancelEdit(): void {
    this.isEditing = false
    this.editContent = ''
  }
}
