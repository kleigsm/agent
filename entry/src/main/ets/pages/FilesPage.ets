import { SocketManager } from '../common/SocketManager'; import { FilesViewModel } from '../viewmodel/FilesViewModel';
import { EVENT_FILES_LIST, EVENT_FILES_READ, EVENT_FILES_RESULT,
  SPACE_XS, SPACE_SM, SPACE_MD, SPACE_LG, SPACE_XL,
  RADIUS_SM, RADIUS_MD, RADIUS_LG, RADIUS_FULL,
  FONT_CAPTION, FONT_BODY_SM, FONT_BODY, FONT_BODY_LG,
  getTheme, ThemeColors, LIGHT_THEME, DARK_THEME } from '../common/Constants';
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
  @State searchText: string = ''
  @StorageLink('isDarkMode') isDarkMode: boolean = false
  private theme: ThemeColors = LIGHT_THEME
  private socketManager: SocketManager = SocketManager.getInstance()
  private filesVM: FilesViewModel = new FilesViewModel()
  private onMsgFn: (msg: WsMessage) => void = () => {}

  aboutToAppear(): void { this.onMsgFn = (m: WsMessage) => { this.handleMessage(m) }; this.socketManager.onMessage(this.onMsgFn); this.loadDirectory('/') }
  aboutToDisappear(): void { this.socketManager.offMessage(this.onMsgFn) }

  handleMessage(msg: WsMessage): void {
    if (msg.type === EVENT_FILES_RESULT) {
      if (!msg.payload['success']) return
      let p = msg.payload['path'] as string; let d = msg.payload['data']
      if (Array.isArray(d)) { this.filesVM.setEntries(p, d as FileNode[]); this.breadcrumbs = this.buildBreadcrumbs(p); this.refreshState() }
      else if (typeof d === 'string') { this.filesVM.setFileContent(p, d); this.refreshState() }
    }
  }

  buildBreadcrumbs(path: string): string[] {
    let pts = path.split('/').filter(p => p); let crumbs = ['/']; let cur = ''
    for (let p of pts) { cur += '/' + p; crumbs.push(cur) }
    return crumbs
  }

  refreshState(): void { this.currentPath = this.filesVM.currentPath; this.entries = [...this.filesVM.entries]; this.parentPath = this.filesVM.parentPath; this.viewingFile = this.filesVM.viewingFile; this.fileContent = this.filesVM.fileContent; this.isLoading = false }

  loadDirectory(path: string): void { this.isLoading = true; this.filesVM.clearFileView(); let p = new Object() as Record<string,Object>; p['path'] = path; this.socketManager.send(EVENT_FILES_LIST, p) }
  loadFile(path: string): void { this.isLoading = true; let p = new Object() as Record<string,Object>; p['path'] = path; this.socketManager.send(EVENT_FILES_READ, p) }

  navigateUp(): void { if (this.currentPath !== '/') this.loadDirectory(this.parentPath) }

  formatSize(bytes: number): string { if (bytes < 1024) return bytes + ' B'; if (bytes < 1048576) return (bytes / 1024).toFixed(1) + ' KB'; return (bytes / 1048576).toFixed(1) + ' MB' }

  fileIcon(item: FileNode): string {
    if (item.type === 'directory') return '📁'
    switch (item.name.split('.').pop()?.toLowerCase()) {
      case 'ets': return '🔷'; case 'ts': return '🔵'; case 'js': return '🟨'
      case 'json': case 'json5': return '📋'; case 'md': return '📝'
      case 'png': case 'jpg': case 'jpeg': case 'gif': return '🖼'
      default: return '📄'
    }
  }

  get filteredEntries(): FileNode[] {
    if (!this.searchText.trim()) return this.entries
    return this.entries.filter(e => e.name.toLowerCase().includes(this.searchText.toLowerCase()))
  }

  build() {
    this.theme = this.isDarkMode ? DARK_THEME : LIGHT_THEME

    Column() {
      // Nav
      Row() {
        Button({ type: ButtonType.Circle }) { Text('↑').fontSize(16).fontColor(this.theme.textPrimary) }
        .width(34).height(34).backgroundColor(this.theme.glassBg).enabled(this.currentPath !== '/').onClick(() => this.navigateUp())
        Scroll() {
          Row() {
            ForEach(this.breadcrumbs, (c: string, i: number) => {
              Row() {
                if (i > 0) Text('/').fontSize(12).fontColor(this.theme.textMuted).margin({ left: 4, right: 4 })
                Text(i === 0 ? '/' : c.split('/').pop() || '').fontSize(12)
                  .fontColor(i === this.breadcrumbs.length - 1 ? this.theme.textPrimary : this.theme.accentBlue)
                  .fontFamily('monospace').maxLines(1).onClick(() => { this.loadDirectory(c) })
              }
            }, (c: string, idx: number) => idx.toString())
          }
        }.layoutWeight(1).scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off).margin({ left: SPACE_SM })
        Button('⟳').fontSize(16).fontColor(this.theme.accentBlue).backgroundColor(this.theme.glassBg)
        .width(32).height(32).borderRadius(RADIUS_FULL).onClick(() => this.loadDirectory(this.currentPath))
      }.width('100%').padding({ left: SPACE_MD, right: SPACE_MD, top: SPACE_SM, bottom: SPACE_SM })

      // Search
      if (!this.viewingFile) {
        TextInput({ placeholder: '搜索文件...', text: this.searchText })
          .fontColor(this.theme.textPrimary).backgroundColor(this.theme.bgInput).borderRadius(RADIUS_MD)
          .borderWidth(1).borderColor(this.theme.border).height(36).fontSize(13)
          .padding({ left: SPACE_LG }).margin({ left: SPACE_MD, right: SPACE_MD, bottom: SPACE_SM })
          .onChange((v: string) => { this.searchText = v })
      }

      // File viewer
      if (this.viewingFile) {
        Row() {
          Text('📄 ' + this.viewingFile.split('/').pop()).fontSize(13)
            .fontColor(this.theme.accentBlue).fontFamily('monospace').layoutWeight(1).maxLines(1)
          Button({ type: ButtonType.Circle }) { Text('✕').fontSize(12).fontColor(this.theme.textSecondary) }
          .width(28).height(28).backgroundColor(Color.Transparent).onClick(() => {
            this.filesVM.clearFileView(); this.viewingFile = ''; this.fileContent = ''
          })
        }.width('100%').padding({ left: SPACE_LG, right: SPACE_XS, top: SPACE_XS, bottom: SPACE_XS })

        Scroll() {
          Text(this.renderWithLineNumbers(this.fileContent)).fontSize(12)
            .fontColor(this.theme.terminalText).fontFamily('monospace')
            .padding(SPACE_MD).width('100%').textAlign(TextAlign.Start).lineHeight(18)
        }
        .layoutWeight(1).width('100%').backgroundColor(this.theme.terminalBg)
        .borderRadius(RADIUS_MD).margin({ left: SPACE_SM, right: SPACE_SM, bottom: SPACE_SM })
      } else {
        if (this.isLoading && this.entries.length === 0) {
          Column() { LoadingProgress().width(28).height(28).color(this.theme.accentBlue)
            Text('加载中...').fontSize(12).fontColor(this.theme.textMuted).margin({ top: SPACE_SM }) }
          .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
        }
        List() {
          ForEach(this.filteredEntries, (item: FileNode) => {
            ListItem() {
              Row() {
                Text(this.fileIcon(item)).fontSize(20)
                Text(item.name).fontSize(14).fontColor(this.theme.textPrimary).maxLines(1).layoutWeight(1).margin({ left: SPACE_MD })
                if (item.type === 'file') Text(this.formatSize(item.size)).fontSize(10).fontColor(this.theme.textMuted).margin({ right: SPACE_SM })
                Image($r('sys.symbol.chevron_right')).width(14).height(14).fillColor(this.theme.textMuted)
              }.width('100%').height(48).padding({ left: SPACE_LG, right: SPACE_LG }).alignItems(VerticalAlign.Center)
              .onClick(() => { if (item.type === 'directory') this.loadDirectory(item.path); else this.loadFile(item.path) })
            }
          }, (item: FileNode) => item.path)
          if (this.entries.length === 0 && !this.isLoading) {
            ListItem() { Text('空目录').fontSize(14).fontColor(this.theme.textMuted).width('100%').textAlign(TextAlign.Center).padding(40) }
          }
        }.layoutWeight(1).width('100%')
      }
    }.width('100%').height('100%').backgroundColor(this.theme.bgPrimary)
  }

  renderWithLineNumbers(content: string): string {
    if (!content) return '空文件'
    let lines = content.split('\n')
    return lines.map((l, i) => (i + 1).toString().padStart(4, ' ') + ' | ' + l).join('\n')
  }
}
