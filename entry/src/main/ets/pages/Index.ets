import {
  COLOR_BG_PRIMARY, COLOR_BG_SECONDARY,
  COLOR_TEXT_SECONDARY, COLOR_TEXT_MUTED,
  COLOR_ACCENT_BLUE, COLOR_BORDER, COLOR_GLASS_BG,
  SPACE_XS, SPACE_SM, RADIUS_MD,
  FONT_CAPTION, ANIM_DURATION_NORMAL
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

  @Builder
  TabBarItem(tab: TabItem) {
    Column() {
      Text(tab.icon)
        .fontSize(18)
      Text(tab.title)
        .fontSize(10)
        .fontWeight(this.currentTabIndex === tab.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.currentTabIndex === tab.index ? COLOR_ACCENT_BLUE : COLOR_TEXT_MUTED)
        .margin({ top: 2 })
    }
    .width('100%')
    .height(48)
    .justifyContent(FlexAlign.Center)
    .borderRadius(RADIUS_MD)
    .backgroundColor(this.currentTabIndex === tab.index ? COLOR_GLASS_BG : Color.Transparent)
    .onClick(() => { this.currentTabIndex = tab.index })
    .animation({ duration: ANIM_DURATION_NORMAL, curve: Curve.EaseOut })
  }

  build() {
    Column() {
      Row() {
        ForEach(TABS, (tab: TabItem) => {
          this.TabBarItem(tab)
        }, (tab: TabItem) => tab.index.toString())
      }
      .width('100%')
      .padding({ left: SPACE_SM, right: SPACE_SM, top: 2, bottom: 2 })
      .backgroundColor(COLOR_BG_PRIMARY)

      Tabs({ index: this.currentTabIndex }) {
        TabContent() { ChatPage() }
        TabContent() { FilesPage() }
        TabContent() { TerminalPage() }
        TabContent() { SettingsPage() }
      }
      .barHeight(0)
      .width('100%')
      .layoutWeight(1)
      .onChange((index: number) => { this.currentTabIndex = index })
      .animationDuration(ANIM_DURATION_NORMAL)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLOR_BG_PRIMARY)
  }
}
