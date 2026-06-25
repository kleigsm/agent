import { UIAbility, Want, AbilityConstant } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    console.info('EntryAbility onCreate')
    // Restore dark mode preference
    let ctx = this.context.getApplicationContext()
    preferences.getPreferences(ctx, 'coderemote_settings').then(p => {
      p.get('dark_mode', false).then((v: preferences.ValueType) => {
        AppStorage.setOrCreate('isDarkMode', v as boolean)
      })
    })
  }

  onDestroy(): void {
    console.info('EntryAbility onDestroy')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    console.info('EntryAbility onWindowStageCreate')
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        console.error('Failed to load content:', JSON.stringify(err))
        return
      }
      console.info('Content loaded successfully')
    })
  }

  onWindowStageDestroy(): void {
    console.info('EntryAbility onWindowStageDestroy')
  }

  onForeground(): void {
    console.info('EntryAbility onForeground')
  }

  onBackground(): void {
    console.info('EntryAbility onBackground')
  }
}
