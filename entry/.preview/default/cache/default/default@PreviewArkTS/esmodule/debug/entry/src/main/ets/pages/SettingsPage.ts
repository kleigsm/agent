if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface SettingsPage_Params {
    serverUrl?: string;
    authToken?: string;
    connectionStatus?: ConnectionStatus;
    statusText?: string;
    isScanning?: boolean;
    discoveredServers?: DiscoveredServer[];
    errorMessage?: string;
    socketManager?: SocketManager;
    settingsVM?: SettingsViewModel;
    discovery?: DiscoveryManager;
    onStatusFn?: (status: ConnectionStatus) => void;
    onErrorFn?: (error: string) => void;
}
import { SocketManager, ConnectionStatus } from "@normalized:N&&&entry/src/main/ets/common/SocketManager&";
import { SettingsViewModel } from "@normalized:N&&&entry/src/main/ets/viewmodel/SettingsViewModel&";
import { DiscoveryManager } from "@normalized:N&&&entry/src/main/ets/common/DiscoveryManager&";
import type { DiscoveredServer } from '../common/Models';
import { COLOR_BG_PRIMARY, COLOR_BG_SECONDARY, COLOR_BG_INPUT, COLOR_TEXT_PRIMARY, COLOR_TEXT_SECONDARY, COLOR_TEXT_MUTED, COLOR_ACCENT_BLUE, COLOR_ACCENT_RED, COLOR_STATUS_ONLINE, COLOR_STATUS_OFFLINE, COLOR_STATUS_WARNING, COLOR_BORDER, SPACE_SM, SPACE_MD, SPACE_LG, SPACE_XL, RADIUS_MD, RADIUS_LG, FONT_BODY, FONT_BODY_LG, FONT_HEADING } from "@normalized:N&&&entry/src/main/ets/common/Constants&";
export class SettingsPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__serverUrl = new ObservedPropertySimplePU('', this, "serverUrl");
        this.__authToken = new ObservedPropertySimplePU('', this, "authToken");
        this.__connectionStatus = new ObservedPropertySimplePU(ConnectionStatus.DISCONNECTED, this, "connectionStatus");
        this.__statusText = new ObservedPropertySimplePU('Disconnected', this, "statusText");
        this.__isScanning = new ObservedPropertySimplePU(false, this, "isScanning");
        this.__discoveredServers = new ObservedPropertyObjectPU([], this, "discoveredServers");
        this.__errorMessage = new ObservedPropertySimplePU('', this, "errorMessage");
        this.socketManager = SocketManager.getInstance();
        this.settingsVM = new SettingsViewModel();
        this.discovery = DiscoveryManager.getInstance();
        this.onStatusFn = () => { };
        this.onErrorFn = () => { };
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: SettingsPage_Params) {
        if (params.serverUrl !== undefined) {
            this.serverUrl = params.serverUrl;
        }
        if (params.authToken !== undefined) {
            this.authToken = params.authToken;
        }
        if (params.connectionStatus !== undefined) {
            this.connectionStatus = params.connectionStatus;
        }
        if (params.statusText !== undefined) {
            this.statusText = params.statusText;
        }
        if (params.isScanning !== undefined) {
            this.isScanning = params.isScanning;
        }
        if (params.discoveredServers !== undefined) {
            this.discoveredServers = params.discoveredServers;
        }
        if (params.errorMessage !== undefined) {
            this.errorMessage = params.errorMessage;
        }
        if (params.socketManager !== undefined) {
            this.socketManager = params.socketManager;
        }
        if (params.settingsVM !== undefined) {
            this.settingsVM = params.settingsVM;
        }
        if (params.discovery !== undefined) {
            this.discovery = params.discovery;
        }
        if (params.onStatusFn !== undefined) {
            this.onStatusFn = params.onStatusFn;
        }
        if (params.onErrorFn !== undefined) {
            this.onErrorFn = params.onErrorFn;
        }
    }
    updateStateVars(params: SettingsPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__serverUrl.purgeDependencyOnElmtId(rmElmtId);
        this.__authToken.purgeDependencyOnElmtId(rmElmtId);
        this.__connectionStatus.purgeDependencyOnElmtId(rmElmtId);
        this.__statusText.purgeDependencyOnElmtId(rmElmtId);
        this.__isScanning.purgeDependencyOnElmtId(rmElmtId);
        this.__discoveredServers.purgeDependencyOnElmtId(rmElmtId);
        this.__errorMessage.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__serverUrl.aboutToBeDeleted();
        this.__authToken.aboutToBeDeleted();
        this.__connectionStatus.aboutToBeDeleted();
        this.__statusText.aboutToBeDeleted();
        this.__isScanning.aboutToBeDeleted();
        this.__discoveredServers.aboutToBeDeleted();
        this.__errorMessage.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __serverUrl: ObservedPropertySimplePU<string>;
    get serverUrl() {
        return this.__serverUrl.get();
    }
    set serverUrl(newValue: string) {
        this.__serverUrl.set(newValue);
    }
    private __authToken: ObservedPropertySimplePU<string>;
    get authToken() {
        return this.__authToken.get();
    }
    set authToken(newValue: string) {
        this.__authToken.set(newValue);
    }
    private __connectionStatus: ObservedPropertySimplePU<ConnectionStatus>;
    get connectionStatus() {
        return this.__connectionStatus.get();
    }
    set connectionStatus(newValue: ConnectionStatus) {
        this.__connectionStatus.set(newValue);
    }
    private __statusText: ObservedPropertySimplePU<string>;
    get statusText() {
        return this.__statusText.get();
    }
    set statusText(newValue: string) {
        this.__statusText.set(newValue);
    }
    private __isScanning: ObservedPropertySimplePU<boolean>;
    get isScanning() {
        return this.__isScanning.get();
    }
    set isScanning(newValue: boolean) {
        this.__isScanning.set(newValue);
    }
    private __discoveredServers: ObservedPropertyObjectPU<DiscoveredServer[]>;
    get discoveredServers() {
        return this.__discoveredServers.get();
    }
    set discoveredServers(newValue: DiscoveredServer[]) {
        this.__discoveredServers.set(newValue);
    }
    private __errorMessage: ObservedPropertySimplePU<string>;
    get errorMessage() {
        return this.__errorMessage.get();
    }
    set errorMessage(newValue: string) {
        this.__errorMessage.set(newValue);
    }
    private socketManager: SocketManager;
    private settingsVM: SettingsViewModel;
    private discovery: DiscoveryManager;
    private onStatusFn: (status: ConnectionStatus) => void;
    private onErrorFn: (error: string) => void;
    aboutToAppear(): void {
        let hostCtx = this.getUIContext().getHostContext();
        if (hostCtx) {
            this.settingsVM.init(hostCtx).then(() => {
                this.serverUrl = this.settingsVM.serverUrl;
                this.authToken = this.settingsVM.authToken;
            });
        }
        this.connectionStatus = this.socketManager.getStatus();
        this.authToken = this.socketManager.getAuthToken();
        this.onStatusFn = (status: ConnectionStatus) => {
            this.connectionStatus = status;
            this.updateStatusText();
        };
        this.onErrorFn = (error: string) => {
            this.errorMessage = error;
        };
        this.socketManager.onStatusChange(this.onStatusFn);
        this.socketManager.onError(this.onErrorFn);
        this.updateStatusText();
    }
    aboutToDisappear(): void {
        this.socketManager.offStatusChange(this.onStatusFn);
        this.socketManager.offError(this.onErrorFn);
    }
    updateStatusText(): void {
        switch (this.connectionStatus) {
            case ConnectionStatus.CONNECTED:
                this.statusText = 'Connected';
                this.errorMessage = '';
                break;
            case ConnectionStatus.CONNECTING:
                this.statusText = 'Connecting...';
                break;
            case ConnectionStatus.RECONNECTING:
                this.statusText = 'Reconnecting...';
                break;
            case ConnectionStatus.ERROR:
                this.statusText = 'Error';
                break;
            default:
                this.statusText = 'Disconnected';
        }
    }
    handleConnect(): void {
        this.errorMessage = '';
        if (this.connectionStatus === ConnectionStatus.CONNECTED ||
            this.connectionStatus === ConnectionStatus.CONNECTING) {
            this.socketManager.disconnect();
        }
        else {
            this.settingsVM.saveServerUrl(this.serverUrl, this.authToken);
            this.socketManager.setAuthToken(this.authToken);
            this.socketManager.connect(this.serverUrl, this.authToken);
        }
    }
    async scanNetwork(): Promise<void> {
        this.isScanning = true;
        this.discoveredServers = [];
        this.discovery.clearServers();
        await this.discovery.scanNetwork((server: DiscoveredServer) => {
            this.discoveredServers = [...this.discovery.getServers()];
        });
        this.isScanning = false;
    }
    selectServer(server: DiscoveredServer): void {
        this.serverUrl = 'ws://' + server.host + ':' + server.port;
        this.authToken = server.token || '';
    }
    getButtonText(): string {
        if (this.connectionStatus === ConnectionStatus.CONNECTED)
            return 'Disconnect';
        if (this.connectionStatus === ConnectionStatus.CONNECTING ||
            this.connectionStatus === ConnectionStatus.RECONNECTING)
            return '...';
        return 'Connect';
    }
    isConnecting(): boolean {
        return this.connectionStatus === ConnectionStatus.CONNECTING ||
            this.connectionStatus === ConnectionStatus.RECONNECTING;
    }
    statusDotColor(): ResourceColor {
        switch (this.connectionStatus) {
            case ConnectionStatus.CONNECTED: return COLOR_STATUS_ONLINE;
            case ConnectionStatus.CONNECTING:
            case ConnectionStatus.RECONNECTING: return COLOR_STATUS_WARNING;
            default: return COLOR_STATUS_OFFLINE;
        }
    }
    getButtonColor(): ResourceColor {
        if (this.connectionStatus === ConnectionStatus.CONNECTED)
            return COLOR_ACCENT_RED;
        return COLOR_ACCENT_BLUE;
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/SettingsPage.ets(135:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor(COLOR_BG_PRIMARY);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // ── Header ──
            Text.create('Settings');
            Text.debugLine("entry/src/main/ets/pages/SettingsPage.ets(137:7)", "entry");
            // ── Header ──
            Text.fontSize(FONT_HEADING);
            // ── Header ──
            Text.fontColor(COLOR_TEXT_PRIMARY);
            // ── Header ──
            Text.fontWeight(FontWeight.Bold);
            // ── Header ──
            Text.width('100%');
            // ── Header ──
            Text.padding({ left: SPACE_XL, top: SPACE_LG, bottom: SPACE_LG });
            // ── Header ──
            Text.textAlign(TextAlign.Start);
        }, Text);
        // ── Header ──
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // ── Connection Status Card ──
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/SettingsPage.ets(146:7)", "entry");
            // ── Connection Status Card ──
            Column.width('100%');
            // ── Connection Status Card ──
            Column.backgroundColor(COLOR_BG_SECONDARY);
            // ── Connection Status Card ──
            Column.borderRadius(RADIUS_LG);
            // ── Connection Status Card ──
            Column.padding(SPACE_LG);
            // ── Connection Status Card ──
            Column.margin({ left: SPACE_LG, right: SPACE_LG });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/SettingsPage.ets(147:9)", "entry");
            Row.width('100%');
            Row.alignItems(VerticalAlign.Center);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Circle.create({ width: 12, height: 12 });
            Circle.debugLine("entry/src/main/ets/pages/SettingsPage.ets(148:11)", "entry");
            Circle.fill(this.statusDotColor());
        }, Circle);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.statusText);
            Text.debugLine("entry/src/main/ets/pages/SettingsPage.ets(151:11)", "entry");
            Text.fontSize(FONT_BODY_LG);
            Text.fontColor(COLOR_TEXT_PRIMARY);
            Text.fontWeight(FontWeight.Medium);
            Text.margin({ left: SPACE_SM });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
            Blank.debugLine("entry/src/main/ets/pages/SettingsPage.ets(157:11)", "entry");
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel(this.getButtonText());
            Button.debugLine("entry/src/main/ets/pages/SettingsPage.ets(159:11)", "entry");
            Button.fontSize(FONT_BODY);
            Button.fontColor('#FFFFFF');
            Button.fontWeight(FontWeight.Medium);
            Button.backgroundColor(this.getButtonColor());
            Button.borderRadius(RADIUS_MD);
            Button.height(40);
            Button.padding({ left: SPACE_XL, right: SPACE_XL });
            Button.enabled(!this.isConnecting());
            Button.onClick(() => this.handleConnect());
        }, Button);
        Button.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.errorMessage) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.errorMessage);
                        Text.debugLine("entry/src/main/ets/pages/SettingsPage.ets(174:11)", "entry");
                        Text.fontSize(FONT_BODY);
                        Text.fontColor(COLOR_ACCENT_RED);
                        Text.margin({ top: SPACE_SM });
                        Text.width('100%');
                    }, Text);
                    Text.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        // ── Connection Status Card ──
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // ── Server Address ──
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/SettingsPage.ets(188:7)", "entry");
            // ── Server Address ──
            Column.width('100%');
            // ── Server Address ──
            Column.backgroundColor(COLOR_BG_SECONDARY);
            // ── Server Address ──
            Column.borderRadius(RADIUS_LG);
            // ── Server Address ──
            Column.padding(SPACE_LG);
            // ── Server Address ──
            Column.margin({ left: SPACE_LG, right: SPACE_LG, top: SPACE_MD });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Server Address');
            Text.debugLine("entry/src/main/ets/pages/SettingsPage.ets(189:9)", "entry");
            Text.fontSize(12);
            Text.fontColor(COLOR_TEXT_MUTED);
            Text.fontWeight(FontWeight.Medium);
            Text.width('100%');
            Text.margin({ bottom: SPACE_SM });
            Text.textAlign(TextAlign.Start);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({ placeholder: 'ws://192.168.1.100:3000', text: this.serverUrl });
            TextInput.debugLine("entry/src/main/ets/pages/SettingsPage.ets(197:9)", "entry");
            TextInput.fontColor(COLOR_TEXT_PRIMARY);
            TextInput.fontFamily('monospace');
            TextInput.backgroundColor(COLOR_BG_INPUT);
            TextInput.borderRadius(RADIUS_MD);
            TextInput.borderWidth(1);
            TextInput.borderColor(COLOR_BORDER);
            TextInput.height(48);
            TextInput.padding({ left: SPACE_LG, right: SPACE_LG });
            TextInput.width('100%');
            TextInput.onChange((value: string) => { this.serverUrl = value; });
            TextInput.onFocus(() => { });
        }, TextInput);
        // ── Server Address ──
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // ── Auth Token ──
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/SettingsPage.ets(217:7)", "entry");
            // ── Auth Token ──
            Column.width('100%');
            // ── Auth Token ──
            Column.backgroundColor(COLOR_BG_SECONDARY);
            // ── Auth Token ──
            Column.borderRadius(RADIUS_LG);
            // ── Auth Token ──
            Column.padding(SPACE_LG);
            // ── Auth Token ──
            Column.margin({ left: SPACE_LG, right: SPACE_LG, top: SPACE_MD });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Auth Token');
            Text.debugLine("entry/src/main/ets/pages/SettingsPage.ets(218:9)", "entry");
            Text.fontSize(12);
            Text.fontColor(COLOR_TEXT_MUTED);
            Text.fontWeight(FontWeight.Medium);
            Text.width('100%');
            Text.margin({ bottom: SPACE_SM });
            Text.textAlign(TextAlign.Start);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({ placeholder: 'Enter server token...', text: this.authToken });
            TextInput.debugLine("entry/src/main/ets/pages/SettingsPage.ets(226:9)", "entry");
            TextInput.fontColor(COLOR_TEXT_PRIMARY);
            TextInput.fontFamily('monospace');
            TextInput.backgroundColor(COLOR_BG_INPUT);
            TextInput.borderRadius(RADIUS_MD);
            TextInput.borderWidth(1);
            TextInput.borderColor(COLOR_BORDER);
            TextInput.height(48);
            TextInput.padding({ left: SPACE_LG, right: SPACE_LG });
            TextInput.width('100%');
            TextInput.type(InputType.Password);
            TextInput.onChange((value: string) => { this.authToken = value; });
        }, TextInput);
        // ── Auth Token ──
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // ── Network Scan ──
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/SettingsPage.ets(246:7)", "entry");
            // ── Network Scan ──
            Column.width('100%');
            // ── Network Scan ──
            Column.backgroundColor(COLOR_BG_SECONDARY);
            // ── Network Scan ──
            Column.borderRadius(RADIUS_LG);
            // ── Network Scan ──
            Column.padding(SPACE_LG);
            // ── Network Scan ──
            Column.margin({ left: SPACE_LG, right: SPACE_LG, top: SPACE_MD });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/SettingsPage.ets(247:9)", "entry");
            Row.width('100%');
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Find Servers');
            Text.debugLine("entry/src/main/ets/pages/SettingsPage.ets(248:11)", "entry");
            Text.fontSize(FONT_BODY);
            Text.fontColor(COLOR_TEXT_PRIMARY);
            Text.fontWeight(FontWeight.Medium);
            Text.layoutWeight(1);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel(this.isScanning ? 'Scanning...' : 'Scan Network');
            Button.debugLine("entry/src/main/ets/pages/SettingsPage.ets(254:11)", "entry");
            Button.fontSize(FONT_BODY);
            Button.fontColor(this.isScanning ? COLOR_TEXT_SECONDARY : COLOR_ACCENT_BLUE);
            Button.backgroundColor(COLOR_BG_INPUT);
            Button.borderRadius(RADIUS_MD);
            Button.borderWidth(1);
            Button.borderColor(COLOR_BORDER);
            Button.height(36);
            Button.padding({ left: SPACE_LG, right: SPACE_LG });
            Button.enabled(!this.isScanning);
            Button.onClick(() => this.scanNetwork());
        }, Button);
        Button.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.isScanning) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        LoadingProgress.create();
                        LoadingProgress.debugLine("entry/src/main/ets/pages/SettingsPage.ets(269:11)", "entry");
                        LoadingProgress.width(24);
                        LoadingProgress.height(24);
                        LoadingProgress.color(COLOR_ACCENT_BLUE);
                        LoadingProgress.margin({ top: SPACE_MD });
                    }, LoadingProgress);
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.discoveredServers.length > 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        ForEach.create();
                        const forEachItemGenFunction = _item => {
                            const server = _item;
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                Row.create();
                                Row.debugLine("entry/src/main/ets/pages/SettingsPage.ets(277:13)", "entry");
                                Row.width('100%');
                                Row.padding({ top: SPACE_SM, bottom: SPACE_SM });
                                Row.border({ width: { top: 1 }, color: COLOR_BORDER });
                            }, Row);
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                Column.create();
                                Column.debugLine("entry/src/main/ets/pages/SettingsPage.ets(278:15)", "entry");
                                Column.layoutWeight(1);
                                Column.alignItems(HorizontalAlign.Start);
                            }, Column);
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                Text.create('ws://' + server.host + ':' + server.port);
                                Text.debugLine("entry/src/main/ets/pages/SettingsPage.ets(279:17)", "entry");
                                Text.fontSize(FONT_BODY);
                                Text.fontColor(COLOR_TEXT_PRIMARY);
                                Text.fontFamily('monospace');
                            }, Text);
                            Text.pop();
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                Text.create('Token: ' + server.token.substring(0, 8) + '...');
                                Text.debugLine("entry/src/main/ets/pages/SettingsPage.ets(284:17)", "entry");
                                Text.fontSize(12);
                                Text.fontColor(COLOR_TEXT_MUTED);
                                Text.margin({ top: 2 });
                            }, Text);
                            Text.pop();
                            Column.pop();
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                Button.createWithLabel('Use');
                                Button.debugLine("entry/src/main/ets/pages/SettingsPage.ets(292:15)", "entry");
                                Button.fontSize(12);
                                Button.fontColor('#FFFFFF');
                                Button.backgroundColor(COLOR_ACCENT_BLUE);
                                Button.borderRadius(RADIUS_MD);
                                Button.height(32);
                                Button.padding({ left: SPACE_MD, right: SPACE_MD });
                                Button.onClick(() => this.selectServer(server));
                            }, Button);
                            Button.pop();
                            Row.pop();
                        };
                        this.forEachUpdateFunction(elmtId, this.discoveredServers, forEachItemGenFunction, (server: DiscoveredServer) => server.host + ':' + server.port, false, false);
                    }, ForEach);
                    ForEach.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        // ── Network Scan ──
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // ── Help ──
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/SettingsPage.ets(314:7)", "entry");
            // ── Help ──
            Column.width('100%');
            // ── Help ──
            Column.backgroundColor(COLOR_BG_SECONDARY);
            // ── Help ──
            Column.borderRadius(RADIUS_LG);
            // ── Help ──
            Column.padding(SPACE_LG);
            // ── Help ──
            Column.margin({ left: SPACE_LG, right: SPACE_LG, top: SPACE_MD });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('How to use');
            Text.debugLine("entry/src/main/ets/pages/SettingsPage.ets(315:9)", "entry");
            Text.fontSize(FONT_BODY);
            Text.fontColor(COLOR_TEXT_PRIMARY);
            Text.fontWeight(FontWeight.Bold);
            Text.width('100%');
            Text.margin({ bottom: SPACE_SM });
            Text.textAlign(TextAlign.Start);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('1. Run "npm start" in the bridge folder on your PC\n' +
                '2. Copy the token shown in the PC terminal\n' +
                '3. Enter the PC IP + token above\n' +
                '   (or tap Scan Network to find it)\n' +
                '4. Tap Connect\n' +
                '5. Switch to Chat tab to start coding');
            Text.debugLine("entry/src/main/ets/pages/SettingsPage.ets(323:9)", "entry");
            Text.fontSize(12);
            Text.fontColor(COLOR_TEXT_SECONDARY);
            Text.width('100%');
            Text.lineHeight(20);
        }, Text);
        Text.pop();
        // ── Help ──
        Column.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
