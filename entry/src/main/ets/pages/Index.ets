import {
  COLOR_BG_PRIMARY, COLOR_BG_SECONDARY,
  COLOR_TEXT_MUTED, COLOR_ACCENT_BLUE,
  COLOR_BORDER, COLOR_GLASS_BG, COLOR_GLASS_BORDER,
  SPACE_XS, SPACE_SM,
  RADIUS_MD,
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
        .fontSize(20)
        .scale(this.currentTabIndex === tab.index ? { x: 1.15, y: 1.15 } : { x: 1, y: 1 })
      Text(tab.title)
        .fontSize(10)
        .fontWeight(this.currentTabIndex === tab.index ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentTabIndex === tab.index ? COLOR_ACCENT_BLUE : COLOR_TEXT_MUTED)
        .margin({ top: 2 })
    }
    .width('100%')
    .height(52)
    .justifyContent(FlexAlign.Center)
    .borderRadius(RADIUS_MD)
    .backgroundColor(this.currentTabIndex === tab.index
      ? 'rgba(0, 122, 255, 0.1)' : Color.Transparent)
    .onClick(() => { this.currentTabIndex = tab.index })
    .animation({ duration: ANIM_DURATION_NORMAL, curve: Curve.EaseOut })
  }

  build() {
    Column() {
      // ── 内容区 ──
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

      // ── 底部导航栏 ──
      Row() {
        ForEach(TABS, (tab: TabItem) => {
          this.TabBarItem(tab)
        }, (tab: TabItem) => tab.index.toString())
      }
      .width('100%')
      .padding({ left: SPACE_SM, right: SPACE_SM, top: SPACE_XS + 2, bottom: 4 })
      .backgroundColor(COLOR_GLASS_BG)
      .backdropBlur(20)
      .borderWidth({ top: 0.5 })
      .borderColor(COLOR_GLASS_BORDER)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLOR_BG_PRIMARY)
  }
}
