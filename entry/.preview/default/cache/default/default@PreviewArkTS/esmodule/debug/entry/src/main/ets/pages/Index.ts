if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface Index_Params {
    currentTabIndex?: number;
}
import { COLOR_BG_PRIMARY, COLOR_BG_SECONDARY, COLOR_TEXT_MUTED, COLOR_ACCENT_BLUE, COLOR_BORDER, SPACE_XS, SPACE_SM, RADIUS_MD, FONT_CAPTION, ANIM_DURATION_NORMAL } from "@normalized:N&&&entry/src/main/ets/common/Constants&";
import { ChatPage } from "@normalized:N&&&entry/src/main/ets/pages/ChatPage&";
import { FilesPage } from "@normalized:N&&&entry/src/main/ets/pages/FilesPage&";
import { TerminalPage } from "@normalized:N&&&entry/src/main/ets/pages/TerminalPage&";
import { SettingsPage } from "@normalized:N&&&entry/src/main/ets/pages/SettingsPage&";
interface TabItem {
    index: number;
    title: string;
    icon: string;
}
const TABS: TabItem[] = [
    { index: 0, title: 'Chat', icon: '💬' },
    { index: 1, title: 'Files', icon: '📁' },
    { index: 2, title: 'Term', icon: '>_' },
    { index: 3, title: 'Settings', icon: '⚙' },
];
class Index extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__currentTabIndex = new ObservedPropertySimplePU(0, this, "currentTabIndex");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: Index_Params) {
        if (params.currentTabIndex !== undefined) {
            this.currentTabIndex = params.currentTabIndex;
        }
    }
    updateStateVars(params: Index_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__currentTabIndex.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__currentTabIndex.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __currentTabIndex: ObservedPropertySimplePU<number>;
    get currentTabIndex() {
        return this.__currentTabIndex.get();
    }
    set currentTabIndex(newValue: number) {
        this.__currentTabIndex.set(newValue);
    }
    TabBarItem(tab: TabItem, parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/Index.ets(34:5)", "entry");
            Column.width('100%');
            Column.height(52);
            Column.justifyContent(FlexAlign.Center);
            Column.borderRadius(RADIUS_MD);
            Column.backgroundColor(this.currentTabIndex === tab.index ? COLOR_BG_SECONDARY : Color.Transparent);
            Column.margin({ top: SPACE_XS, bottom: SPACE_XS });
            Column.onClick(() => {
                this.currentTabIndex = tab.index;
            });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(tab.icon);
            Text.debugLine("entry/src/main/ets/pages/Index.ets(35:7)", "entry");
            Context.animation({ duration: ANIM_DURATION_NORMAL, curve: Curve.EaseOut });
            Text.fontSize(this.currentTabIndex === tab.index ? 20 : 18);
            Text.scale(this.currentTabIndex === tab.index ? { x: 1.1, y: 1.1 } : { x: 1, y: 1 });
            Context.animation(null);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(tab.title);
            Text.debugLine("entry/src/main/ets/pages/Index.ets(40:7)", "entry");
            Context.animation({ duration: ANIM_DURATION_NORMAL });
            Text.fontSize(FONT_CAPTION);
            Text.fontWeight(this.currentTabIndex === tab.index ? FontWeight.Bold : FontWeight.Normal);
            Text.fontColor(this.currentTabIndex === tab.index ? COLOR_ACCENT_BLUE : COLOR_TEXT_MUTED);
            Text.margin({ top: 2 });
            Context.animation(null);
        }, Text);
        Text.pop();
        Column.pop();
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/Index.ets(59:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor(COLOR_BG_PRIMARY);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/Index.ets(60:7)", "entry");
            Row.width('100%');
            Row.padding({ left: SPACE_SM, right: SPACE_SM });
            Row.backgroundColor(COLOR_BG_PRIMARY);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = _item => {
                const tab = _item;
                this.TabBarItem.bind(this)(tab);
            };
            this.forEachUpdateFunction(elmtId, TABS, forEachItemGenFunction, (tab: TabItem) => tab.index.toString(), false, false);
        }, ForEach);
        ForEach.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Divider.create();
            Divider.debugLine("entry/src/main/ets/pages/Index.ets(69:7)", "entry");
            Divider.color(COLOR_BORDER);
            Divider.width('100%');
            Divider.height(0.5);
        }, Divider);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Tabs.create({ index: this.currentTabIndex });
            Tabs.debugLine("entry/src/main/ets/pages/Index.ets(71:7)", "entry");
            Tabs.barHeight(0);
            Tabs.width('100%');
            Tabs.layoutWeight(1);
            Tabs.onChange((index: number) => {
                this.currentTabIndex = index;
            });
            Tabs.animationDuration(ANIM_DURATION_NORMAL);
        }, Tabs);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TabContent.create(() => {
                {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        if (isInitialRender) {
                            let componentCall = new ChatPage(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 72, col: 24 });
                            ViewPU.create(componentCall);
                            let paramsLambda = () => {
                                return {};
                            };
                            componentCall.paramsGenerator_ = paramsLambda;
                        }
                        else {
                            this.updateStateVarsOfChildByElmtId(elmtId, {});
                        }
                    }, { name: "ChatPage" });
                }
            });
            TabContent.debugLine("entry/src/main/ets/pages/Index.ets(72:9)", "entry");
        }, TabContent);
        TabContent.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TabContent.create(() => {
                {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        if (isInitialRender) {
                            let componentCall = new FilesPage(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 73, col: 24 });
                            ViewPU.create(componentCall);
                            let paramsLambda = () => {
                                return {};
                            };
                            componentCall.paramsGenerator_ = paramsLambda;
                        }
                        else {
                            this.updateStateVarsOfChildByElmtId(elmtId, {});
                        }
                    }, { name: "FilesPage" });
                }
            });
            TabContent.debugLine("entry/src/main/ets/pages/Index.ets(73:9)", "entry");
        }, TabContent);
        TabContent.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TabContent.create(() => {
                {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        if (isInitialRender) {
                            let componentCall = new TerminalPage(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 74, col: 24 });
                            ViewPU.create(componentCall);
                            let paramsLambda = () => {
                                return {};
                            };
                            componentCall.paramsGenerator_ = paramsLambda;
                        }
                        else {
                            this.updateStateVarsOfChildByElmtId(elmtId, {});
                        }
                    }, { name: "TerminalPage" });
                }
            });
            TabContent.debugLine("entry/src/main/ets/pages/Index.ets(74:9)", "entry");
        }, TabContent);
        TabContent.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TabContent.create(() => {
                {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        if (isInitialRender) {
                            let componentCall = new SettingsPage(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 75, col: 24 });
                            ViewPU.create(componentCall);
                            let paramsLambda = () => {
                                return {};
                            };
                            componentCall.paramsGenerator_ = paramsLambda;
                        }
                        else {
                            this.updateStateVarsOfChildByElmtId(elmtId, {});
                        }
                    }, { name: "SettingsPage" });
                }
            });
            TabContent.debugLine("entry/src/main/ets/pages/Index.ets(75:9)", "entry");
        }, TabContent);
        TabContent.pop();
        Tabs.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "Index";
    }
}
registerNamedRoute(() => new Index(undefined, {}), "", { bundleName: "com.coderemote.harmonyos", moduleName: "entry", pagePath: "pages/Index", pageFullPath: "entry/src/main/ets/pages/Index", integratedHsp: "false", moduleType: "followWithHap" });
