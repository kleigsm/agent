import type { FileNode } from '../common/Models';
export class FilesViewModel {
    currentPath: string = '/';
    entries: FileNode[] = [];
    fileContent: string = '';
    viewingFile: string = '';
    isLoading: boolean = false;
    parentPath: string = '/';
    setEntries(path: string, files: FileNode[]): void {
        this.currentPath = path;
        this.entries = files;
        this.parentPath = path === '/' ? '/' : path.substring(0, path.lastIndexOf('/')) || '/';
    }
    setFileContent(path: string, content: string): void {
        this.viewingFile = path;
        this.fileContent = content;
    }
    clearFileView(): void {
        this.viewingFile = '';
        this.fileContent = '';
    }
}
