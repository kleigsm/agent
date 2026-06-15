if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface TerminalPage_Params {
    outputText?: string;
    commandInput?: string;
    isRunning?: boolean;
    cwd?: string;
    historyIndex?: number;
    socketManager?: SocketManager;
    termVM?: TerminalViewModel;
    outputScroller?: Scroller;
    onMsgFn?: (msg: WsMessage) => void;
}
import { SocketManager } from "@normalized:N&&&entry/src/main/ets/common/SocketManager&";
import { TerminalViewModel } from "@normalized:N&&&entry/src/main/ets/viewmodel/TerminalViewModel&";
import { EVENT_TERM_EXEC, EVENT_TERM_OUTPUT, EVENT_TERM_EXIT, COLOR_BG_PRIMARY, COLOR_BG_SECONDARY, COLOR_TEXT_PRIMARY, COLOR_TEXT_SECONDARY, COLOR_TEXT_MUTED, COLOR_ACCENT_BLUE, COLOR_ACCENT_GREEN, COLOR_ACCENT_RED, COLOR_ACCENT_ORANGE, COLOR_BORDER, SPACE_XS, SPACE_SM, SPACE_MD, SPACE_LG, RADIUS_SM, RADIUS_MD, FONT_BODY_SM, FONT_BODY_LG } from "@normalized:N&&&entry/src/main/ets/common/Constants&";
import type { WsMessage } from '../common/Models';
export class TerminalPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__outputText = new ObservedPropertySimplePU('', this, "outputText");
        this.__commandInput = new ObservedPropertySimplePU('', this, "commandInput");
        this.__isRunning = new ObservedPropertySimplePU(false, this, "isRunning");
        this.__cwd = new ObservedPropertySimplePU('/', this, "cwd");
        this.__historyIndex = new ObservedPropertySimplePU(-1, this, "historyIndex");
        this.socketManager = SocketManager.getInstance();
        this.termVM = new TerminalViewModel();
        this.outputScroller = new Scroller();
        this.onMsgFn = () => { };
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: TerminalPage_Params) {
        if (params.outputText !== undefined) {
            this.outputText = params.outputText;
        }
        if (params.commandInput !== undefined) {
            this.commandInput = params.commandInput;
        }
        if (params.isRunning !== undefined) {
            this.isRunning = params.isRunning;
        }
        if (params.cwd !== undefined) {
            this.cwd = params.cwd;
        }
        if (params.historyIndex !== undefined) {
            this.historyIndex = params.historyIndex;
        }
        if (params.socketManager !== undefined) {
            this.socketManager = params.socketManager;
        }
        if (params.termVM !== undefined) {
            this.termVM = params.termVM;
        }
        if (params.outputScroller !== undefined) {
            this.outputScroller = params.outputScroller;
        }
        if (params.onMsgFn !== undefined) {
            this.onMsgFn = params.onMsgFn;
        }
    }
    updateStateVars(params: TerminalPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__outputText.purgeDependencyOnElmtId(rmElmtId);
        this.__commandInput.purgeDependencyOnElmtId(rmElmtId);
        this.__isRunning.purgeDependencyOnElmtId(rmElmtId);
        this.__cwd.purgeDependencyOnElmtId(rmElmtId);
        this.__historyIndex.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__outputText.aboutToBeDeleted();
        this.__commandInput.aboutToBeDeleted();
        this.__isRunning.aboutToBeDeleted();
        this.__cwd.aboutToBeDeleted();
        this.__historyIndex.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __outputText: ObservedPropertySimplePU<string>;
    get outputText() {
        return this.__outputText.get();
    }
    set outputText(newValue: string) {
        this.__outputText.set(newValue);
    }
    private __commandInput: ObservedPropertySimplePU<string>;
    get commandInput() {
        return this.__commandInput.get();
    }
    set commandInput(newValue: string) {
        this.__commandInput.set(newValue);
    }
    private __isRunning: ObservedPropertySimplePU<boolean>;
    get isRunning() {
        return this.__isRunning.get();
    }
    set isRunning(newValue: boolean) {
        this.__isRunning.set(newValue);
    }
    private __cwd: ObservedPropertySimplePU<string>;
    get cwd() {
        return this.__cwd.get();
    }
    set cwd(newValue: string) {
        this.__cwd.set(newValue);
    }
    private __historyIndex: ObservedPropertySimplePU<number>;
    get historyIndex() {
        return this.__historyIndex.get();
    }
    set historyIndex(newValue: number) {
        this.__historyIndex.set(newValue);
    }
    private socketManager: SocketManager;
    private termVM: TerminalViewModel;
    private outputScroller: Scroller;
    private onMsgFn: (msg: WsMessage) => void;
    aboutToAppear(): void {
        this.onMsgFn = (msg: WsMessage) => { this.handleMessage(msg); };
        this.socketManager.onMessage(this.onMsgFn);
    }
    aboutToDisappear(): void {
        this.socketManager.offMessage(this.onMsgFn);
    }
    handleMessage(msg: WsMessage): void {
        if (msg.type === EVENT_TERM_OUTPUT) {
            const data = msg.payload['data'] as string;
            const isStderr = msg.payload['stderr'] as boolean;
            this.termVM.addOutput(data, isStderr);
            this.outputText = this.termVM.getOutputText();
            this.scrollOutputToBottom();
        }
        else if (msg.type === EVENT_TERM_EXIT) {
            const code = msg.payload['code'] as number;
            const color = code === 0 ? '' : '[ERR] ';
            this.termVM.addOutput('\n' + color + 'Process exited with code ' + code + '\n');
            this.isRunning = false;
            this.outputText = this.termVM.getOutputText();
            this.scrollOutputToBottom();
        }
    }
    executeCommand(): void {
        const cmd = this.commandInput.trim();
        if (!cmd || this.isRunning)
            return;
        this.termVM.addToHistory(cmd);
        this.historyIndex = this.termVM.commandHistory.length;
        this.termVM.addOutput('\x1b[32m$\x1b[0m ' + cmd + '\n');
        this.isRunning = true;
        this.outputText = this.termVM.getOutputText();
        this.commandInput = '';
        let payload = this.makePayload();
        payload['command'] = cmd;
        payload['cwd'] = this.cwd;
        this.socketManager.send(EVENT_TERM_EXEC, payload);
    }
    makePayload(): Record<string, Object> {
        let obj = new Object();
        return obj as Record<string, Object>;
    }
    scrollOutputToBottom(): void {
        setTimeout(() => {
            this.outputScroller.scrollEdge(Edge.Bottom);
        }, 50);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/TerminalPage.ets(82:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor(COLOR_BG_PRIMARY);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // ── Header ──
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/TerminalPage.ets(84:7)", "entry");
            // ── Header ──
            Row.width('100%');
            // ── Header ──
            Row.padding({ left: SPACE_MD, right: SPACE_MD, top: SPACE_SM, bottom: SPACE_SM });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/TerminalPage.ets(85:9)", "entry");
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Circle.create({ width: 8, height: 8 });
            Circle.debugLine("entry/src/main/ets/pages/TerminalPage.ets(86:11)", "entry");
            Circle.fill(COLOR_ACCENT_RED);
        }, Circle);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Circle.create({ width: 8, height: 8 });
            Circle.debugLine("entry/src/main/ets/pages/TerminalPage.ets(87:11)", "entry");
            Circle.fill(COLOR_ACCENT_ORANGE);
            Circle.margin({ left: SPACE_XS });
        }, Circle);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Circle.create({ width: 8, height: 8 });
            Circle.debugLine("entry/src/main/ets/pages/TerminalPage.ets(88:11)", "entry");
            Circle.fill(COLOR_ACCENT_GREEN);
            Circle.margin({ left: SPACE_XS });
        }, Circle);
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
            Blank.debugLine("entry/src/main/ets/pages/TerminalPage.ets(91:9)", "entry");
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Terminal');
            Text.debugLine("entry/src/main/ets/pages/TerminalPage.ets(93:9)", "entry");
            Text.fontSize(FONT_BODY_SM);
            Text.fontColor(COLOR_TEXT_MUTED);
            Text.fontFamily('monospace');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
            Blank.debugLine("entry/src/main/ets/pages/TerminalPage.ets(98:9)", "entry");
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/TerminalPage.ets(100:9)", "entry");
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.isRunning) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        LoadingProgress.create();
                        LoadingProgress.debugLine("entry/src/main/ets/pages/TerminalPage.ets(102:13)", "entry");
                        LoadingProgress.width(14);
                        LoadingProgress.height(14);
                        LoadingProgress.color(COLOR_ACCENT_BLUE);
                        LoadingProgress.margin({ right: SPACE_SM });
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
            Button.createWithLabel('Clear');
            Button.debugLine("entry/src/main/ets/pages/TerminalPage.ets(106:11)", "entry");
            Button.fontSize(FONT_BODY_SM);
            Button.fontColor(COLOR_TEXT_SECONDARY);
            Button.backgroundColor(COLOR_BG_SECONDARY);
            Button.height(28);
            Button.borderRadius(RADIUS_SM);
            Button.padding({ left: SPACE_MD, right: SPACE_MD });
            Button.onClick(() => {
                this.termVM.clearOutput();
                this.outputText = '';
            });
        }, Button);
        Button.pop();
        Row.pop();
        // ── Header ──
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Divider.create();
            Divider.debugLine("entry/src/main/ets/pages/TerminalPage.ets(122:7)", "entry");
            Divider.color(COLOR_BORDER);
            Divider.width('100%');
        }, Divider);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // ── Output area ──
            Scroll.create(this.outputScroller);
            Scroll.debugLine("entry/src/main/ets/pages/TerminalPage.ets(125:7)", "entry");
            // ── Output area ──
            Scroll.layoutWeight(1);
            // ── Output area ──
            Scroll.width('100%');
            // ── Output area ──
            Scroll.backgroundColor('#0C0D12');
            // ── Output area ──
            Scroll.borderRadius(RADIUS_MD);
            // ── Output area ──
            Scroll.margin({ left: SPACE_SM, right: SPACE_SM, top: SPACE_SM, bottom: SPACE_SM });
        }, Scroll);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.outputText || 'Ready. Type a command to execute on the remote PC.\n');
            Text.debugLine("entry/src/main/ets/pages/TerminalPage.ets(126:9)", "entry");
            Text.fontSize(FONT_BODY_SM);
            Text.fontColor(COLOR_TEXT_PRIMARY);
            Text.fontFamily('monospace');
            Text.padding(SPACE_MD);
            Text.width('100%');
            Text.textAlign(TextAlign.Start);
            Text.lineHeight(18);
            Text.copyOption(CopyOptions.LocalDevice);
        }, Text);
        Text.pop();
        // ── Output area ──
        Scroll.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // ── Input area ──
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/TerminalPage.ets(143:7)", "entry");
            // ── Input area ──
            Row.width('100%');
            // ── Input area ──
            Row.padding({ left: SPACE_MD, right: SPACE_MD, top: SPACE_SM, bottom: SPACE_MD });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('$');
            Text.debugLine("entry/src/main/ets/pages/TerminalPage.ets(144:9)", "entry");
            Text.fontSize(FONT_BODY_LG);
            Text.fontColor(COLOR_ACCENT_GREEN);
            Text.fontFamily('monospace');
            Text.fontWeight(FontWeight.Bold);
            Text.margin({ right: SPACE_SM });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({ placeholder: 'Enter command...', text: this.commandInput });
            TextInput.debugLine("entry/src/main/ets/pages/TerminalPage.ets(151:9)", "entry");
            TextInput.placeholderColor(COLOR_TEXT_MUTED);
            TextInput.fontColor(COLOR_TEXT_PRIMARY);
            TextInput.fontFamily('monospace');
            TextInput.backgroundColor(Color.Transparent);
            TextInput.layoutWeight(1);
            TextInput.height(40);
            TextInput.onChange((value: string) => { this.commandInput = value; });
            TextInput.onSubmit(() => { this.executeCommand(); });
        }, TextInput);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('Run');
            Button.debugLine("entry/src/main/ets/pages/TerminalPage.ets(161:9)", "entry");
            Button.fontSize(FONT_BODY_SM);
            Button.fontColor('#FFFFFF');
            Button.backgroundColor(this.commandInput.trim().length > 0 && !this.isRunning ?
                COLOR_ACCENT_BLUE : COLOR_BG_SECONDARY);
            Button.borderRadius(RADIUS_MD);
            Button.height(34);
            Button.padding({ left: SPACE_LG, right: SPACE_LG });
            Button.margin({ left: SPACE_SM });
            Button.enabled(this.commandInput.trim().length > 0 && !this.isRunning);
            Button.onClick(() => { this.executeCommand(); });
        }, Button);
        Button.pop();
        // ── Input area ──
        Row.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
