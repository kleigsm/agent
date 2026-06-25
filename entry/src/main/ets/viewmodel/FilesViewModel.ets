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
