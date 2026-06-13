import {
  COLOR_BG_DARK, COLOR_BG_CARD, COLOR_TEXT_MUTED, COLOR_ACCENT_BLUE
} from '../common/Constants';
import { ChatPage } from './ChatPage';
import { FilesPage } from './FilesPage';
import { TerminalPage } from './TerminalPage';
import { SettingsPage } from './SettingsPage';

@Entry
@Component
struct Index {
  @State currentTabIndex: number = 0

  @Builder
  TabBuilder(index: number, title: string, icon: string) {
    Column() {
      Text(icon)
        .fontSize(22)

      Text(title)
        .fontSize(10)
        .fontColor(this.currentTabIndex === index ? COLOR_ACCENT_BLUE : COLOR_TEXT_MUTED)
        .margin({ top: 2 })
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentTabIndex = index
    })
  }

  build() {
    Column() {
      Tabs({ index: this.currentTabIndex }) {
        TabContent() {
          ChatPage()
        }
        .tabBar(this.TabBuilder(0, 'Chat', '💬'))

        TabContent() {
          FilesPage()
        }
        .tabBar(this.TabBuilder(1, 'Files', '📁'))

        TabContent() {
          TerminalPage()
        }
        .tabBar(this.TabBuilder(2, 'Terminal', '⌨'))

        TabContent() {
          SettingsPage()
        }
        .tabBar(this.TabBuilder(3, 'Settings', '⚙'))
      }
      .barWidth('100%')
      .barHeight(60)
      .barBackgroundColor(COLOR_BG_CARD)
      .width('100%')
      .layoutWeight(1)
      .onChange((index: number) => {
        this.currentTabIndex = index
      })
      .animationDuration(200)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLOR_BG_DARK)
  }
}
