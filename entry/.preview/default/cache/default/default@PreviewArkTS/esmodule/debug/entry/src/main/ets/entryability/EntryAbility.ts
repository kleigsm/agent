import UIAbility from "@ohos:app.ability.UIAbility";
import type Want from "@ohos:app.ability.Want";
import type AbilityConstant from "@ohos:app.ability.AbilityConstant";
import type window from "@ohos:window";
export default class EntryAbility extends UIAbility {
    onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
        console.info('EntryAbility onCreate');
    }
    onDestroy(): void {
        console.info('EntryAbility onDestroy');
    }
    onWindowStageCreate(windowStage: window.WindowStage): void {
        console.info('EntryAbility onWindowStageCreate');
        windowStage.loadContent('pages/Index', (err) => {
            if (err.code) {
                console.error('Failed to load content:', JSON.stringify(err));
                return;
            }
            console.info('Content loaded successfully');
        });
    }
    onWindowStageDestroy(): void {
        console.info('EntryAbility onWindowStageDestroy');
    }
    onForeground(): void {
        console.info('EntryAbility onForeground');
    }
    onBackground(): void {
        console.info('EntryAbility onBackground');
    }
}
