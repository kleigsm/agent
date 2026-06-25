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
  dc, DEFAULT_SERVER_URL
} from '../common/Constants';
import { preferences } from '@kit.ArkData';
import { SocketManager, ConnectionStatus } from '../common/SocketManager';
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
  { index: 0, title: '对话', icon: '💬' },
  { index: 1, title: '总览', icon: '📊' },
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
  @StorageLink('buildNotify') @Watch('onBuildNotify') buildNotify: string = ''
  @State currentTabIndex: number = 0
  @State showBuildBanner: boolean = false
  @State buildBannerText: string = ''

  aboutToAppear(): void {
    AppStorage.setOrCreate('switchToTab', -1)
    AppStorage.setOrCreate('buildNotify', '')
    // Auto-connect from saved settings
    let ctx = this.getUIContext().getHostContext()
    if (ctx) {
      try {
        preferences.getPreferences(ctx, 'coderemote_settings').then(p => {
          p.get('server_url', DEFAULT_SERVER_URL).then((u: preferences.ValueType) => {
            let url = u as string
            p.get('auth_token', '').then((t: preferences.ValueType) => {
              let token = t as string
              let sm = SocketManager.getInstance()
              if (sm.getStatus() === ConnectionStatus.DISCONNECTED) {
                sm.setAuthToken(token)
                sm.connect(url, token)
              }
            })
          })
        })
      } catch (_e) {}
    }
  }

  onTabSwitch(): void {
    if (this.targetTab >= 0) {
      this.currentTabIndex = this.targetTab
      AppStorage.set('switchToTab', -1)
    }
  }

  onBuildNotify(): void {
    if (this.buildNotify === 'success') {
      this.buildBannerText = '编译成功'
      this.showBuildBanner = true
    } else if (this.buildNotify === 'failed') {
      this.buildBannerText = '编译失败'
      this.showBuildBanner = true
    }
    if (this.buildNotify) {
      AppStorage.set('buildNotify', '')
      setTimeout(() => { this.showBuildBanner = false }, 3000)
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
      // Build notification banner
      if (this.showBuildBanner) {
        Row() {
          Text(this.buildBannerText === '编译成功' ? '✅' : '❌').fontSize(14)
          Text(' ' + this.buildBannerText).fontSize(13).fontColor('#FFFFFF').fontWeight(FontWeight.Bold)
        }
        .width('100%').height(36).justifyContent(FlexAlign.Center)
        .backgroundColor(this.buildBannerText === '编译成功' ? '#34C759' : '#FF3B30')
      }

      Tabs({ index: this.currentTabIndex }) {
        TabContent() { ChatPage() }
        TabContent() { DashboardPage() }
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
