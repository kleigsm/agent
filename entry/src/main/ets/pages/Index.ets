import {
  SPACE_XS, SPACE_SM, RADIUS_MD,
  FONT_CAPTION, ANIM_DURATION_NORMAL, ANIM_DURATION_FAST,
  getTheme, ThemeColors, DARK_THEME, LIGHT_THEME, APP_VERSION, APP_NAME
} from '../common/Constants';
import { ChatPage } from './ChatPage';
import { FilesPage } from './FilesPage';
import { TerminalPage } from './TerminalPage';
import { SettingsPage } from './SettingsPage';

interface TabItem {
  index: number
  title: string
  icon: string
}

const TABS: TabItem[] = [
  { index: 0, title: '对话', icon: '💬' },
  { index: 1, title: '文件', icon: '📁' },
  { index: 2, title: '终端', icon: '>_' },
  { index: 3, title: '设置', icon: '⚙' },
]

@Entry
@Component
struct Index {
  @State currentTabIndex: number = 0
  @State toastMsg: string = ''
  @State toastVisible: boolean = false
  @StorageLink('isDarkMode') isDarkMode: boolean = false
  private theme: ThemeColors = LIGHT_THEME

  aboutToAppear(): void {
    AppStorage.setOrCreate<string>('globalToast', '')
  }

  showToast(msg: string): void {
    this.toastMsg = msg
    this.toastVisible = true
    setTimeout(() => { this.toastVisible = false }, 2500)
  }

  @Builder
  TabBarItem(tab: TabItem) {
    Column() {
      Text(tab.icon).fontSize(20)
        .scale(this.currentTabIndex === tab.index ? { x: 1.15, y: 1.15 } : { x: 1, y: 1 })
      Text(tab.title).fontSize(10)
        .fontWeight(this.currentTabIndex === tab.index ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentTabIndex === tab.index ? this.theme.accentBlue : this.theme.textMuted)
        .margin({ top: 2 })
    }
    .layoutWeight(1).height(52).justifyContent(FlexAlign.Center).borderRadius(RADIUS_MD)
    .backgroundColor(this.currentTabIndex === tab.index
      ? (this.isDarkMode ? 'rgba(88,166,255,0.15)' : 'rgba(0,122,255,0.1)')
      : Color.Transparent)
    .onClick(() => { this.currentTabIndex = tab.index })
    .animation({ duration: ANIM_DURATION_NORMAL, curve: Curve.EaseOut })
  }

  build() {
    this.theme = this.isDarkMode ? DARK_THEME : LIGHT_THEME

    Stack() {
      Column() {
        Tabs({ index: this.currentTabIndex }) {
          TabContent() { ChatPage() }
          TabContent() { FilesPage() }
          TabContent() { TerminalPage() }
          TabContent() { SettingsPage() }
        }
        .barHeight(0).width('100%').layoutWeight(1)
        .onChange((index: number) => { this.currentTabIndex = index })
        .animationDuration(ANIM_DURATION_NORMAL)

        Row() {
          ForEach(TABS, (t: TabItem) => { this.TabBarItem(t) }, (t: TabItem) => t.index.toString())
        }
        .width('100%').padding({ left: SPACE_SM, right: SPACE_SM, top: SPACE_XS + 2, bottom: 4 })
        .backgroundColor(this.theme.glassBg).backdropBlur(20)
        .borderWidth({ top: 0.5 }).borderColor(this.theme.glassBorder)
      }
      .width('100%').height('100%').backgroundColor(this.theme.bgPrimary)

      // Global toast
      if (this.toastVisible) {
        Column() {
          Text(this.toastMsg)
            .fontSize(14).fontColor('#FFFFFF')
            .padding({ left: 20, right: 20, top: 10, bottom: 10 })
            .borderRadius(20).backgroundColor('rgba(0,0,0,0.82)')
        }
        .position({ bottom: 100, left: '20%', right: '20%' })
        .transition({ type: TransitionType.All, opacity: 1 })
      }
    }
    .width('100%').height('100%')
  }
}
