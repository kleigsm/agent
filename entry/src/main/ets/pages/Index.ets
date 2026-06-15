import {
  COLOR_BG_PRIMARY, COLOR_BG_SECONDARY, COLOR_BG_INPUT,
  COLOR_TEXT_PRIMARY, COLOR_TEXT_SECONDARY, COLOR_TEXT_MUTED,
  COLOR_ACCENT_BLUE, COLOR_BORDER,
  SPACE_XS, SPACE_SM, SPACE_MD, SPACE_LG,
  RADIUS_MD, RADIUS_LG, FONT_CAPTION, FONT_BODY_SM,
  ANIM_DURATION_NORMAL
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
  { index: 0, title: 'Chat', icon: '💬' },
  { index: 1, title: 'Files', icon: '📁' },
  { index: 2, title: 'Term', icon: '>_' },
  { index: 3, title: 'Settings', icon: '⚙' },
]

@Entry
@Component
struct Index {
  @State currentTabIndex: number = 0

  @Builder
  TabBarItem(tab: TabItem) {
    Column() {
      Text(tab.icon)
        .fontSize(this.currentTabIndex === tab.index ? 20 : 18)
        .scale(this.currentTabIndex === tab.index ? { x: 1.1, y: 1.1 } : { x: 1, y: 1 })
        .animation({ duration: ANIM_DURATION_NORMAL, curve: Curve.EaseOut })

      Text(tab.title)
        .fontSize(FONT_CAPTION)
        .fontWeight(this.currentTabIndex === tab.index ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentTabIndex === tab.index ? COLOR_ACCENT_BLUE : COLOR_TEXT_MUTED)
        .margin({ top: 2 })
        .animation({ duration: ANIM_DURATION_NORMAL })
    }
    .width('100%')
    .height(52)
    .justifyContent(FlexAlign.Center)
    .borderRadius(RADIUS_MD)
    .backgroundColor(this.currentTabIndex === tab.index ? COLOR_BG_SECONDARY : Color.Transparent)
    .margin({ top: SPACE_XS, bottom: SPACE_XS })
    .onClick(() => {
      this.currentTabIndex = tab.index
    })
  }

  build() {
    Column() {
      Row() {
        ForEach(TABS, (tab: TabItem) => {
          this.TabBarItem(tab)
        }, (tab: TabItem) => tab.index.toString())
      }
      .width('100%')
      .padding({ left: SPACE_SM, right: SPACE_SM })
      .backgroundColor(COLOR_BG_PRIMARY)

      Divider().color(COLOR_BORDER).width('100%').height(0.5)

      Tabs({ index: this.currentTabIndex }) {
        TabContent() { ChatPage() }
        TabContent() { FilesPage() }
        TabContent() { TerminalPage() }
        TabContent() { SettingsPage() }
      }
      .barHeight(0)
      .width('100%')
      .layoutWeight(1)
      .onChange((index: number) => {
        this.currentTabIndex = index
      })
      .animationDuration(ANIM_DURATION_NORMAL)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLOR_BG_PRIMARY)
  }
}
