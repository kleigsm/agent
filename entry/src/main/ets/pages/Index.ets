import {
  COLOR_BG_PRIMARY, C_BG_PRIMARY_DARK,
  COLOR_BG_SECONDARY,
  COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK,
  COLOR_ACCENT_BLUE,
  COLOR_BORDER, C_BORDER_DARK,
  COLOR_GLASS_BG, C_GLASS_BG_DARK,
  COLOR_GLASS_BORDER, C_GLASS_BORDER_DARK,
  SPACE_XS, SPACE_SM,
  RADIUS_MD,
  FONT_CAPTION, ANIM_DURATION_NORMAL,
  dc
} from '../common/Constants';
import { ChatPage } from './ChatPage';
import { FilesPage } from './FilesPage';
import { TerminalPage } from './TerminalPage';
import { SettingsPage } from './SettingsPage';
import { BuildPage } from './BuildPage';
import { DashboardPage } from './DashboardPage';

interface TabItem {
  index: number
  title: string
  icon: string
}

const TABS: TabItem[] = [
  { index: 0, title: '总览', icon: '📊' },
  { index: 1, title: '对话', icon: '💬' },
  { index: 2, title: '文件', icon: '📁' },
  { index: 3, title: '终端', icon: '>_' },
  { index: 4, title: '编译', icon: '🔨' },
  { index: 5, title: '设置', icon: '⚙' },
]

@Entry
@Component
struct Index {
  @StorageLink('isDarkMode') isDark: boolean = false
  @StorageLink('switchToTab') @Watch('onTabSwitch') targetTab: number = -1
  @State currentTabIndex: number = 0

  aboutToAppear(): void {
    AppStorage.setOrCreate('switchToTab', -1)
  }

  onTabSwitch(): void {
    if (this.targetTab >= 0) {
      this.currentTabIndex = this.targetTab
      AppStorage.set('switchToTab', -1)
    }
  }

  @Builder
  TabBarItem(tab: TabItem) {
    Column() {
      Text(tab.icon)
        .fontSize(20)
        .scale(this.currentTabIndex === tab.index ? { x: 1.15, y: 1.15 } : { x: 1, y: 1 })
      Text(tab.title)
        .fontSize(10)
        .fontWeight(this.currentTabIndex === tab.index ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentTabIndex === tab.index ? COLOR_ACCENT_BLUE : dc(this.isDark, COLOR_TEXT_MUTED, C_TEXT_MUTED_DARK))
        .margin({ top: 2 })
    }
    .layoutWeight(1)
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
      Tabs({ index: this.currentTabIndex }) {
        TabContent() { DashboardPage() }
        TabContent() { ChatPage() }
        TabContent() { FilesPage() }
        TabContent() { TerminalPage() }
        TabContent() { BuildPage() }
        TabContent() { SettingsPage() }
      }
      .barHeight(0)
      .width('100%')
      .layoutWeight(1)
      .onChange((index: number) => { this.currentTabIndex = index })
      .animationDuration(ANIM_DURATION_NORMAL)

      Row() {
        ForEach(TABS, (tab: TabItem) => {
          this.TabBarItem(tab)
        }, (tab: TabItem) => tab.index.toString())
      }
      .width('100%')
      .padding({ left: SPACE_SM, right: SPACE_SM, top: SPACE_XS + 2, bottom: 4 })
      .backgroundColor(dc(this.isDark, COLOR_GLASS_BG, C_GLASS_BG_DARK))
      .backdropBlur(20)
      .borderWidth({ top: 0.5 })
      .borderColor(dc(this.isDark, COLOR_GLASS_BORDER, C_GLASS_BORDER_DARK))
    }
    .width('100%')
    .height('100%')
    .backgroundColor(dc(this.isDark, COLOR_BG_PRIMARY, C_BG_PRIMARY_DARK))
  }
}
