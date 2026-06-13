import { SocketManager, ConnectionStatus } from '../common/SocketManager';
import { FilesViewModel } from '../viewmodel/FilesViewModel';
import {
  EVENT_FILES_LIST, EVENT_FILES_READ, EVENT_FILES_RESULT,
  COLOR_BG_DARK, COLOR_BG_INPUT, COLOR_TEXT_PRIMARY, COLOR_TEXT_MUTED,
  COLOR_ACCENT_BLUE, COLOR_ACCENT_YELLOW, COLOR_SURFACE, COLOR_BORDER
} from '../common/Constants';
import { WsMessage, FileNode } from '../common/Models';

@Component
export struct FilesPage {
  @State currentPath: string = '/'
  @State entries: FileNode[] = []
  @State viewingFile: string = ''
  @State fileContent: string = ''
  @State isLoading: boolean = false
  @State parentPath: string = '/'
  private socketManager: SocketManager = SocketManager.getInstance()
  private filesVM: FilesViewModel = new FilesViewModel()
  private onMsgFn: (msg: WsMessage) => void = () => {}

  aboutToAppear(): void {
    this.onMsgFn = (msg: WsMessage) => { this.handleMessage(msg) }
    this.socketManager.onMessage(this.onMsgFn)
    this.loadDirectory('/')
  }

  aboutToDisappear(): void {
    this.socketManager.offMessage(this.onMsgFn)
  }

  handleMessage(msg: WsMessage): void {
    if (msg.type === EVENT_FILES_RESULT) {
      const success = msg.payload['success'] as boolean
      if (!success) return

      const path = msg.payload['path'] as string
      const data = msg.payload['data']

      if (Array.isArray(data)) {
        this.filesVM.setEntries(path, data as FileNode[])
        this.refreshState()
      } else if (typeof data === 'string' && msg.payload['operation'] === 'read') {
        this.filesVM.setFileContent(path, data)
        this.refreshState()
      }
    }
  }

  refreshState(): void {
    this.currentPath = this.filesVM.currentPath
    this.entries = [...this.filesVM.entries]
    this.parentPath = this.filesVM.parentPath
    this.viewingFile = this.filesVM.viewingFile
    this.fileContent = this.filesVM.fileContent
    this.isLoading = false
  }

  loadDirectory(path: string): void {
    this.isLoading = true
    this.filesVM.clearFileView()
    let payload = this.makePayload()
    payload['path'] = path
    this.socketManager.send(EVENT_FILES_LIST, payload)
  }

  loadFile(path: string): void {
    this.isLoading = true
    let payload = this.makePayload()
    payload['path'] = path
    this.socketManager.send(EVENT_FILES_READ, payload)
  }

  makePayload(): Record<string, Object> {
    let obj = new Object()
    return obj as Record<string, Object>
  }

  navigateUp(): void {
    if (this.currentPath !== '/') {
      this.loadDirectory(this.parentPath)
    }
  }

  formatSize(bytes: number): string {
    if (bytes < 1024) return bytes + ' B'
    if (bytes < 1048576) return (bytes / 1024).toFixed(1) + ' KB'
    return (bytes / 1048576).toFixed(1) + ' MB'
  }

  build() {
    Column() {
      Row() {
        Button('..')
          .fontSize(16)
          .fontColor(COLOR_TEXT_PRIMARY)
          .width(36)
          .height(36)
          .backgroundColor(COLOR_SURFACE)
          .borderRadius(18)
          .enabled(this.currentPath !== '/')
          .onClick(() => this.navigateUp())

        Text(this.currentPath)
          .fontSize(14)
          .fontColor(COLOR_TEXT_PRIMARY)
          .fontFamily('monospace')
          .layoutWeight(1)
          .margin({ left: 8 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Button('Refresh')
          .fontSize(12)
          .fontColor(COLOR_ACCENT_BLUE)
          .backgroundColor(COLOR_SURFACE)
          .height(32)
          .onClick(() => this.loadDirectory(this.currentPath))
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 4 })

      Divider().color(COLOR_BORDER).margin({ left: 12, right: 12 })

      if (this.viewingFile) {
        Column() {
          Row() {
            Text(this.viewingFile)
              .fontSize(12)
              .fontColor(COLOR_ACCENT_BLUE)
              .fontFamily('monospace')
              .layoutWeight(1)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Button('X')
              .fontSize(14)
              .fontColor(COLOR_TEXT_MUTED)
              .width(32)
              .height(32)
              .backgroundColor(Color.Transparent)
              .onClick(() => {
                this.filesVM.clearFileView()
                this.viewingFile = ''
                this.fileContent = ''
              })
          }
          .width('100%')
          .padding({ left: 12, right: 4, top: 8, bottom: 4 })

          Scroll() {
            Text(this.fileContent || 'Empty file')
              .fontSize(13)
              .fontColor(COLOR_TEXT_PRIMARY)
              .fontFamily('monospace')
              .padding(12)
              .width('100%')
              .textAlign(TextAlign.Start)
          }
          .layoutWeight(1)
          .width('100%')
          .backgroundColor(COLOR_BG_INPUT)
          .borderRadius(8)
          .margin({ left: 8, right: 8, bottom: 8 })
        }
        .layoutWeight(1)
        .width('100%')
      } else {
        if (this.isLoading) {
          LoadingProgress()
            .width(40)
            .height(40)
            .color(COLOR_ACCENT_BLUE)
            .margin({ top: 40 })
        }

        List() {
          ForEach(this.entries, (item: FileNode) => {
            ListItem() {
              Row() {
                Text(item.type === 'directory' ? '[D]' : '[F]')
                  .fontSize(13)
                  .fontColor(item.type === 'directory' ? COLOR_ACCENT_YELLOW : COLOR_ACCENT_BLUE)
                  .fontFamily('monospace')

                Column() {
                  Text(item.name)
                    .fontSize(14)
                    .fontColor(COLOR_TEXT_PRIMARY)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  Row() {
                    if (item.type === 'file') {
                      Text(this.formatSize(item.size))
                        .fontSize(11)
                        .fontColor(COLOR_TEXT_MUTED)
                        .margin({ right: 12 })
                    }
                    Text(item.modified || '')
                      .fontSize(11)
                      .fontColor(COLOR_TEXT_MUTED)
                  }
                }
                .layoutWeight(1)
                .margin({ left: 10 })

                Text('>')
                  .fontSize(14)
                  .fontColor(COLOR_TEXT_MUTED)
              }
              .width('100%')
              .height(56)
              .padding({ left: 16, right: 16 })
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                if (item.type === 'directory') {
                  this.loadDirectory(item.path)
                } else {
                  this.loadFile(item.path)
                }
              })
            }
          }, (item: FileNode) => item.path)
        }
        .layoutWeight(1)
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLOR_BG_DARK)
  }
}
