import { SocketManager } from '../common/SocketManager';
import { FilesViewModel } from '../viewmodel/FilesViewModel';
import {
  EVENT_FILES_LIST, EVENT_FILES_READ, EVENT_FILES_RESULT,
  COLOR_BG_PRIMARY, C_BG_PRIMARY_DARK,
  COLOR_BG_SECONDARY, C_BG_SECONDARY_DARK,
  COLOR_BG_INPUT, C_BG_INPUT_DARK,
  COLOR_TEXT_PRIMARY, C_TEXT_PRIMARY_DARK,
  COLOR_TEXT_SECONDARY, C_TEXT_SECONDARY_DARK,
  COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK,
  COLOR_ACCENT_BLUE, COLOR_ACCENT_ORANGE, COLOR_BORDER, C_BORDER_DARK,
  COLOR_GLASS_BG, C_GLASS_BG_DARK,
  SPACE_XS, SPACE_SM, SPACE_MD, SPACE_LG, SPACE_XL,
  RADIUS_SM, RADIUS_MD, RADIUS_LG, RADIUS_FULL,
  FONT_CAPTION, FONT_BODY_SM, FONT_BODY,
  dc
} from '../common/Constants';
import { WsMessage, FileNode } from '../common/Models';

@Component
export struct FilesPage {
  @StorageLink('isDarkMode') isDark: boolean = false
  @State currentPath: string = '/'
  @State entries: FileNode[] = []
  @State viewingFile: string = ''
  @State fileContent: string = ''
  @State isLoading: boolean = false
  @State parentPath: string = '/'
  @State breadcrumbs: string[] = ['/']
  @State diffContent: string = ''
  private socketManager: SocketManager = SocketManager.getInstance()
  private filesVM: FilesViewModel = new FilesViewModel()
  private onMsgFn: (msg: WsMessage) => void = () => {}

  aboutToAppear(): void {
    this.onMsgFn = (msg: WsMessage) => { this.handleMessage(msg) }
    this.socketManager.onMessage(this.onMsgFn)
    this.loadDirectory('/')
    // Request git status for file markers
    let sp = this.makePayload()
    this.socketManager.send('project:status', sp)
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
        // Also request diff for this file
        let p2 = this.makePayload()
        p2['path'] = path
        this.socketManager.send('files:diff', p2)
      }
    } else if (msg.type === 'project:status') {
      const success = msg.payload['success'] as boolean
      if (success) {
        let changes = msg.payload['changes'] as string[]
        if (changes) {
          let map: Record<string, string> = {}
          for (let c of changes) {
            let status = c.substring(0, 2).trim()
            let path = c.substring(3).trim()
            if (!path) continue
            let type = status.includes('M') ? 'modified' : status.includes('A') ? 'added' :
              status.includes('D') ? 'deleted' : status.includes('?') ? 'untracked' : 'modified'
            map[path] = type
          }
          this.filesVM.setGitStatus(map)
        }
      }
    } else if (msg.type === 'files:diff') {
      const success = msg.payload['success'] as boolean
      if (success) {
        const diff = msg.payload['diff'] as string
        if (diff) {
          this.diffContent = diff
        }
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
    this.diffContent = this.filesVM.diffContent
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

  saveEdit(): void {
    if (!this.viewingFile || !this.filesVM.isEditing) return
    let payload = this.makePayload()
    payload['path'] = this.viewingFile
    payload['content'] = this.filesVM.editContent
    this.socketManager.send('files:write', payload)
    this.filesVM.cancelEdit()
    // Reload file to reflect changes
    this.loadFile(this.viewingFile)
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
          Text('↑').fontSize(16).fontColor(dc(this.isDark, COLOR_TEXT_PRIMARY, C_TEXT_PRIMARY_DARK))
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
                  Text('/').fontSize(12).fontColor(dc(this.isDark, COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK)).margin({ left: 4, right: 4 })
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
            .fontSize(13).fontColor(COLOR_ACCENT_BLUE).fontFamily('monospace')
            .layoutWeight(1).maxLines(1)

          if (!this.filesVM.isEditing) {
            // Only allow editing for files < 50KB
            if (this.fileContent.length < 51200) {
              Button('编辑').fontSize(11).fontColor(COLOR_ACCENT_BLUE)
                .backgroundColor(COLOR_ACCENT_BLUE + '12').borderRadius(10).height(26)
                .onClick(() => { this.filesVM.enterEditMode(); this.refreshState() })
                .margin({ right: SPACE_SM })
            }
          } else {
            Button('保存').fontSize(11).fontColor('#FFFFFF')
              .backgroundColor(COLOR_ACCENT_BLUE).borderRadius(10).height(26)
              .onClick(() => { this.saveEdit() })
              .margin({ right: SPACE_XS })
            Button('取消').fontSize(11).fontColor(dc(this.isDark, COLOR_TEXT_SECONDARY, C_TEXT_SECONDARY_DARK))
              .backgroundColor(dc(this.isDark, COLOR_BG_INPUT, C_BG_INPUT_DARK)).borderRadius(10).height(26)
              .onClick(() => { this.filesVM.cancelEdit(); this.refreshState() })
              .margin({ right: SPACE_SM })
          }

          Button({ type: ButtonType.Circle }) {
            Text('✕').fontSize(12).fontColor(dc(this.isDark, COLOR_TEXT_SECONDARY, C_TEXT_SECONDARY_DARK))
          }
          .width(28).height(28).backgroundColor(Color.Transparent)
          .onClick(() => { this.filesVM.clearFileView(); this.refreshState() })
        }
        .width('100%')
        .padding({ left: SPACE_LG, right: SPACE_XS, top: SPACE_XS, bottom: SPACE_XS })

        if (this.filesVM.isEditing) {
          Scroll() {
            TextArea({ text: this.filesVM.editContent })
              .fontSize(12).fontColor(dc(this.isDark, COLOR_TEXT_PRIMARY, C_TEXT_PRIMARY_DARK))
              .fontFamily('monospace').padding(SPACE_MD).width('100%').height('100%')
              .backgroundColor(dc(this.isDark, COLOR_BG_INPUT, C_BG_INPUT_DARK))
              .onChange((v: string) => { this.filesVM.editContent = v })
          }
          .layoutWeight(1).width('100%')
          .backgroundColor(dc(this.isDark, COLOR_BG_INPUT, C_BG_INPUT_DARK))
          .borderRadius(RADIUS_MD)
          .margin({ left: SPACE_SM, right: SPACE_SM, bottom: SPACE_SM })
        } else if (this.diffContent) {
          // Diff view
          Scroll() {
            Column() {
              Text('--- 变更内容 (git diff) ---').fontSize(11)
                .fontColor(dc(this.isDark, COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK))
                .fontFamily('monospace').padding({ left: SPACE_MD, top: SPACE_MD }).width('100%')
              ForEach(this.diffContent.split('\n'), (line: string, idx: number) => {
                Row() {
                  Text(line).fontSize(11).fontFamily('monospace').lineHeight(16)
                    .fontColor(line[0] === '+' ? '#34C759' : line[0] === '-' ? '#FF3B30' :
                      line[0] === '@' ? COLOR_ACCENT_BLUE : dc(this.isDark, COLOR_TEXT_PRIMARY, C_TEXT_PRIMARY_DARK))
                    .backgroundColor(line[0] === '+' ? '#34C75915' : line[0] === '-' ? '#FF3B3015' : Color.Transparent)
                    .width('100%').padding({ left: SPACE_MD, right: SPACE_MD, top: 1, bottom: 1 })
                }.width('100%')
              }, (line: string, idx: number) => idx.toString())
            }.width('100%')
          }
          .layoutWeight(1).width('100%')
          .backgroundColor(dc(this.isDark, COLOR_BG_INPUT, C_BG_INPUT_DARK))
          .borderRadius(RADIUS_MD)
          .margin({ left: SPACE_SM, right: SPACE_SM, bottom: SPACE_SM })
        } else {
          Scroll() {
            Text(this.fileContent || '空文件')
              .fontSize(12)
              .fontColor(dc(this.isDark, COLOR_TEXT_PRIMARY, C_TEXT_PRIMARY_DARK))
              .fontFamily('monospace').padding(SPACE_MD).width('100%')
              .textAlign(TextAlign.Start).lineHeight(18)
          }
          .layoutWeight(1).width('100%')
          .backgroundColor(dc(this.isDark, COLOR_BG_INPUT, C_BG_INPUT_DARK))
          .borderRadius(RADIUS_MD)
          .margin({ left: SPACE_SM, right: SPACE_SM, bottom: SPACE_SM })
        }
      } else {
        if (this.isLoading && this.entries.length === 0) {
          Column() {
            LoadingProgress().width(28).height(28).color(COLOR_ACCENT_BLUE)
            Text('加载中...').fontSize(12).fontColor(dc(this.isDark, COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK)).margin({ top: SPACE_SM })
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
                  .fontColor(dc(this.isDark, COLOR_TEXT_PRIMARY, C_TEXT_PRIMARY_DARK))
                  .maxLines(1)
                  .layoutWeight(1)
                  .margin({ left: SPACE_MD })
                if (item.type === 'file') {
                  Text(this.formatSize(item.size))
                    .fontSize(10)
                    .fontColor(dc(this.isDark, COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK))
                    .margin({ right: SPACE_SM })
                }
                // Git status marker
                if (item.type === 'file') {
                  let gs = this.filesVM.getGitStatus(item.path)
                  if (gs) {
                    Text(gs === 'modified' ? 'M' : gs === 'added' ? 'A' : gs === 'deleted' ? 'D' : '??')
                      .fontSize(9).fontColor('#FFFFFF').fontWeight(FontWeight.Bold)
                      .backgroundColor(this.filesVM.gitStatusColor(gs)).borderRadius(3)
                      .padding({ left: 3, right: 3, top: 1, bottom: 1 })
                      .margin({ right: SPACE_SM })
                  }
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
                .fontColor(dc(this.isDark, COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK))
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
    .backgroundColor(dc(this.isDark, COLOR_BG_PRIMARY, C_BG_PRIMARY_DARK))
  }
}
