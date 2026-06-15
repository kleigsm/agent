import { SocketManager } from '../common/SocketManager';
import { FilesViewModel } from '../viewmodel/FilesViewModel';
import {
  EVENT_FILES_LIST, EVENT_FILES_READ, EVENT_FILES_RESULT,
  COLOR_BG_PRIMARY, COLOR_BG_SECONDARY, COLOR_BG_INPUT,
  COLOR_TEXT_PRIMARY, COLOR_TEXT_SECONDARY, COLOR_TEXT_MUTED,
  COLOR_ACCENT_BLUE, COLOR_ACCENT_ORANGE, COLOR_BORDER, COLOR_GLASS_BG,
  SPACE_XS, SPACE_SM, SPACE_MD, SPACE_LG, SPACE_XL,
  RADIUS_SM, RADIUS_MD, RADIUS_LG, RADIUS_FULL,
  FONT_CAPTION, FONT_BODY_SM, FONT_BODY
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
  @State breadcrumbs: string[] = ['/']
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
        this.breadcrumbs = this.buildBreadcrumbs(path)
        this.refreshState()
      } else if (typeof data === 'string' && msg.payload['operation'] === 'read') {
        this.filesVM.setFileContent(path, data)
        this.refreshState()
      }
    }
  }

  buildBreadcrumbs(path: string): string[] {
    const parts = path.split('/').filter(p => p)
    const crumbs = ['/']
    let current = ''
    for (const part of parts) {
      current += '/' + part
      crumbs.push(current)
    }
    return crumbs
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

  fileIcon(item: FileNode): string {
    if (item.type === 'directory') return '📁'
    const ext = item.name.split('.').pop()?.toLowerCase()
    switch (ext) {
      case 'ets': return '🔷'
      case 'ts': return '🔵'
      case 'js': return '🟨'
      case 'json': case 'json5': return '📋'
      case 'md': return '📝'
      case 'png': case 'jpg': case 'jpeg': case 'gif': return '🖼'
      default: return '📄'
    }
  }

  build() {
    Column() {
      // ── 导航栏 ──
      Row() {
        Button({ type: ButtonType.Circle }) {
          Text('↑').fontSize(16).fontColor(COLOR_TEXT_PRIMARY)
        }
        .width(34).height(34)
        .backgroundColor(COLOR_GLASS_BG)
        .enabled(this.currentPath !== '/')
        .onClick(() => this.navigateUp())

        Scroll() {
          Row() {
            ForEach(this.breadcrumbs, (crumb: string, index: number) => {
              Row() {
                if (index > 0) {
                  Text('/').fontSize(12).fontColor(COLOR_TEXT_MUTED).margin({ left: 4, right: 4 })
                }
                Text(index === 0 ? '/' : crumb.split('/').pop() || '')
                  .fontSize(12)
                  .fontColor(index === this.breadcrumbs.length - 1 ? COLOR_TEXT_PRIMARY : COLOR_ACCENT_BLUE)
                  .fontFamily('monospace')
                  .maxLines(1)
                  .onClick(() => { this.loadDirectory(crumb) })
              }
            }, (crumb: string, idx: number) => idx.toString())
          }
        }
        .layoutWeight(1)
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .margin({ left: SPACE_SM })

        Button('⟳')
          .fontSize(16)
          .fontColor(COLOR_ACCENT_BLUE)
          .backgroundColor(COLOR_GLASS_BG)
          .width(32).height(32)
          .borderRadius(RADIUS_FULL)
          .onClick(() => this.loadDirectory(this.currentPath))
      }
      .width('100%')
      .padding({ left: SPACE_MD, right: SPACE_MD, top: SPACE_SM, bottom: SPACE_SM })

      // ── 文件查看器 ──
      if (this.viewingFile) {
        Row() {
          Text('📄 ' + this.viewingFile.split('/').pop())
            .fontSize(13)
            .fontColor(COLOR_ACCENT_BLUE)
            .fontFamily('monospace')
            .layoutWeight(1)
            .maxLines(1)

          Button({ type: ButtonType.Circle }) {
            Text('✕').fontSize(12).fontColor(COLOR_TEXT_SECONDARY)
          }
          .width(28).height(28)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.filesVM.clearFileView()
            this.viewingFile = ''
            this.fileContent = ''
          })
        }
        .width('100%')
        .padding({ left: SPACE_LG, right: SPACE_XS, top: SPACE_XS, bottom: SPACE_XS })

        Scroll() {
          Text(this.fileContent || '空文件')
            .fontSize(12)
            .fontColor(COLOR_TEXT_PRIMARY)
            .fontFamily('monospace')
            .padding(SPACE_MD)
            .width('100%')
            .textAlign(TextAlign.Start)
            .lineHeight(18)
        }
        .layoutWeight(1)
        .width('100%')
        .backgroundColor(COLOR_BG_INPUT)
        .borderRadius(RADIUS_MD)
        .margin({ left: SPACE_SM, right: SPACE_SM, bottom: SPACE_SM })
      } else {
        if (this.isLoading && this.entries.length === 0) {
          Column() {
            LoadingProgress().width(28).height(28).color(COLOR_ACCENT_BLUE)
            Text('加载中...').fontSize(12).fontColor(COLOR_TEXT_MUTED).margin({ top: SPACE_SM })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        }

        List() {
          ForEach(this.entries, (item: FileNode) => {
            ListItem() {
              Row() {
                Text(this.fileIcon(item)).fontSize(20)
                Text(item.name)
                  .fontSize(14)
                  .fontColor(COLOR_TEXT_PRIMARY)
                  .maxLines(1)
                  .layoutWeight(1)
                  .margin({ left: SPACE_MD })
                if (item.type === 'file') {
                  Text(this.formatSize(item.size))
                    .fontSize(10)
                    .fontColor(COLOR_TEXT_MUTED)
                    .margin({ right: SPACE_SM })
                }
                Image($r('sys.symbol.chevron_right'))
                  .width(14).height(14)
                  .fillColor(COLOR_TEXT_MUTED)
              }
              .width('100%')
              .height(48)
              .padding({ left: SPACE_LG, right: SPACE_LG })
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                if (item.type === 'directory') this.loadDirectory(item.path)
                else this.loadFile(item.path)
              })
            }
          }, (item: FileNode) => item.path)

          if (this.entries.length === 0 && !this.isLoading) {
            ListItem() {
              Text('空目录')
                .fontSize(14)
                .fontColor(COLOR_TEXT_MUTED)
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding(40)
            }
          }
        }
        .layoutWeight(1)
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLOR_BG_PRIMARY)
  }
}
