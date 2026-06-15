import { SocketManager, ConnectionStatus } from '../common/SocketManager';
import { FilesViewModel } from '../viewmodel/FilesViewModel';
import {
  EVENT_FILES_LIST, EVENT_FILES_READ, EVENT_FILES_RESULT,
  COLOR_BG_PRIMARY, COLOR_BG_SECONDARY, COLOR_BG_INPUT,
  COLOR_TEXT_PRIMARY, COLOR_TEXT_SECONDARY, COLOR_TEXT_MUTED,
  COLOR_ACCENT_BLUE, COLOR_ACCENT_GREEN, COLOR_ACCENT_ORANGE,
  COLOR_ACCENT_RED, COLOR_ACCENT_CYAN, COLOR_BORDER, COLOR_DIVIDER,
  SPACE_XS, SPACE_SM, SPACE_MD, SPACE_LG, SPACE_XL,
  RADIUS_SM, RADIUS_MD, RADIUS_LG, RADIUS_FULL,
  FONT_CAPTION, FONT_BODY_SM, FONT_BODY, FONT_BODY_LG,
  ANIM_DURATION_FAST
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
      case 'svg': return '🎨'
      case 'hsp': case 'hap': return '📦'
      default: return '📄'
    }
  }

  build() {
    Column() {
      // ── Navigation bar ──
      Row() {
        Button({ type: ButtonType.Circle }) {
          Text('↑').fontSize(16).fontColor(COLOR_TEXT_PRIMARY)
        }
        .width(36).height(36)
        .backgroundColor(COLOR_BG_SECONDARY)
        .enabled(this.currentPath !== '/')
        .onClick(() => this.navigateUp())

        // Breadcrumbs
        Scroll() {
          Row() {
            ForEach(this.breadcrumbs, (crumb: string, index: number) => {
              Row() {
                if (index > 0) {
                  Text('/').fontSize(FONT_BODY_SM).fontColor(COLOR_TEXT_MUTED)
                    .margin({ left: SPACE_XS, right: SPACE_XS })
                }
                Text(index === 0 ? '/' : crumb.split('/').pop() || '')
                  .fontSize(FONT_BODY_SM)
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
          .fontSize(FONT_BODY_LG)
          .fontColor(COLOR_ACCENT_BLUE)
          .backgroundColor(COLOR_BG_SECONDARY)
          .width(34).height(34)
          .borderRadius(RADIUS_FULL)
          .onClick(() => this.loadDirectory(this.currentPath))
      }
      .width('100%')
      .padding({ left: SPACE_MD, right: SPACE_MD, top: SPACE_SM, bottom: SPACE_SM })

      Divider().color(COLOR_BORDER).width('100%')

      // ── File viewer (when a file is open) ──
      if (this.viewingFile) {
        Column() {
          Row() {
            Text('📄 ' + this.viewingFile.split('/').pop())
              .fontSize(FONT_BODY)
              .fontColor(COLOR_ACCENT_BLUE)
              .fontFamily('monospace')
              .layoutWeight(1)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Button({ type: ButtonType.Circle }) {
              Text('✕').fontSize(14).fontColor(COLOR_TEXT_SECONDARY)
            }
            .width(32).height(32)
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.filesVM.clearFileView()
              this.viewingFile = ''
              this.fileContent = ''
            })
          }
          .width('100%')
          .padding({ left: SPACE_LG, right: SPACE_SM, top: SPACE_SM, bottom: SPACE_SM })

          Scroll() {
            Text(this.fileContent || 'Empty file')
              .fontSize(FONT_BODY_SM)
              .fontColor(COLOR_TEXT_PRIMARY)
              .fontFamily('monospace')
              .padding(SPACE_LG)
              .width('100%')
              .textAlign(TextAlign.Start)
              .lineHeight(18)
          }
          .layoutWeight(1)
          .width('100%')
          .backgroundColor(COLOR_BG_INPUT)
          .borderRadius(RADIUS_MD)
          .margin({ left: SPACE_SM, right: SPACE_SM, bottom: SPACE_SM })
        }
        .layoutWeight(1)
        .width('100%')
      } else {
        // ── File list ──
        if (this.isLoading && this.entries.length === 0) {
          Column() {
            LoadingProgress().width(32).height(32).color(COLOR_ACCENT_BLUE)
            Text('Loading...')
              .fontSize(FONT_BODY_SM)
              .fontColor(COLOR_TEXT_MUTED)
              .margin({ top: SPACE_MD })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        }

        List() {
          ForEach(this.entries, (item: FileNode) => {
            ListItem() {
              Row() {
                Text(this.fileIcon(item))
                  .fontSize(22)

                Column() {
                  Text(item.name)
                    .fontSize(FONT_BODY)
                    .fontColor(COLOR_TEXT_PRIMARY)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .fontWeight(FontWeight.Medium)

                  Row() {
                    if (item.type === 'file') {
                      Text(this.formatSize(item.size))
                        .fontSize(FONT_CAPTION)
                        .fontColor(COLOR_TEXT_MUTED)
                    }
                    if (item.modified) {
                      Text(item.modified.substring(0, 10))
                        .fontSize(FONT_CAPTION)
                        .fontColor(COLOR_TEXT_MUTED)
                        .margin({ left: SPACE_SM })
                    }
                  }
                  .margin({ top: 2 })
                }
                .layoutWeight(1)
                .margin({ left: SPACE_MD })
                .alignItems(HorizontalAlign.Start)

                Image($r('sys.symbol.chevron_right'))
                  .width(16).height(16)
                  .fillColor(COLOR_TEXT_MUTED)
              }
              .width('100%')
              .height(52)
              .padding({ left: SPACE_LG, right: SPACE_LG })
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

          if (this.entries.length === 0 && !this.isLoading) {
            ListItem() {
              Text('Empty directory')
                .fontSize(FONT_BODY)
                .fontColor(COLOR_TEXT_MUTED)
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding(SPACE_3XL)
            }
          }
        }
        .layoutWeight(1)
        .width('100%')
        .divider({ strokeWidth: 0.5, color: COLOR_DIVIDER })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLOR_BG_PRIMARY)
  }
}
