if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface ChatPage_Params {
    inputText?: string;
    messages?: ChatMessage[];
    isStreaming?: boolean;
    connectionStatus?: ConnectionStatus;
    socketManager?: SocketManager;
    chatVM?: ChatViewModel;
    scroller?: Scroller;
    streamingMsgId?: string;
    onStatusFn?: (status: ConnectionStatus) => void;
    onMsgFn?: (msg: WsMessage) => void;
}
interface MessageBubble_Params {
    msg?: ChatMessage;
}
import { SocketManager, ConnectionStatus } from "@normalized:N&&&entry/src/main/ets/common/SocketManager&";
import { ChatViewModel } from "@normalized:N&&&entry/src/main/ets/viewmodel/ChatViewModel&";
import { EVENT_CHAT_SEND, EVENT_CHAT_STREAM, EVENT_CHAT_DONE, EVENT_CHAT_ERROR, COLOR_BG_PRIMARY, COLOR_BG_SECONDARY, COLOR_TEXT_PRIMARY, COLOR_TEXT_SECONDARY, COLOR_TEXT_MUTED, COLOR_ACCENT_BLUE, COLOR_ACCENT_GREEN, COLOR_ACCENT_ORANGE, COLOR_USER_BUBBLE, COLOR_BUBBLE_USER_TEXT, COLOR_BUBBLE_AI_TEXT, COLOR_AI_BUBBLE, COLOR_BORDER, COLOR_STATUS_ONLINE, COLOR_STATUS_OFFLINE, COLOR_STATUS_WARNING, SPACE_XS, SPACE_SM, SPACE_MD, SPACE_LG, RADIUS_SM, RADIUS_MD, RADIUS_XL, FONT_CAPTION, FONT_BODY_SM, FONT_BODY, QUICK_COMMANDS } from "@normalized:N&&&entry/src/main/ets/common/Constants&";
import type { QuickCommand } from "@normalized:N&&&entry/src/main/ets/common/Constants&";
import type { WsMessage, ChatMessage } from '../common/Models';
class MessageBubble extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__msg = new SynchedPropertyNesedObjectPU(params.msg, this, "msg");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: MessageBubble_Params) {
        this.__msg.set(params.msg);
    }
    updateStateVars(params: MessageBubble_Params) {
        this.__msg.set(params.msg);
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__msg.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__msg.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __msg: SynchedPropertyNesedObjectPU<ChatMessage>;
    get msg() {
        return this.__msg.get();
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/ChatPage.ets(23:5)", "entry");
            Column.width('100%');
            Column.padding({ top: SPACE_SM, bottom: SPACE_SM });
            Column.alignItems(this.msg.role === 'user' ? HorizontalAlign.End : HorizontalAlign.Start);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/ChatPage.ets(24:7)", "entry");
            Row.width('100%');
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.msg.role === 'user') {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Blank.create();
                        Blank.debugLine("entry/src/main/ets/pages/ChatPage.ets(26:11)", "entry");
                    }, Blank);
                    Blank.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/ChatPage.ets(29:9)", "entry");
            Column.alignItems(this.msg.role === 'user' ? HorizontalAlign.End : HorizontalAlign.Start);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // Role label
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/ChatPage.ets(31:11)", "entry");
            // Role label
            Row.margin({ bottom: SPACE_XS });
            // Role label
            Row.alignSelf(this.msg.role === 'user' ? ItemAlign.End : ItemAlign.Start);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.msg.role === 'assistant') {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Circle.create({ width: 6, height: 6 });
                        Circle.debugLine("entry/src/main/ets/pages/ChatPage.ets(33:15)", "entry");
                        Circle.fill(this.msg.isStreaming ? COLOR_ACCENT_ORANGE : COLOR_ACCENT_GREEN);
                        Circle.margin({ right: SPACE_XS });
                    }, Circle);
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.msg.role === 'user' ? 'You' : (this.msg.toolName || 'Claude'));
            Text.debugLine("entry/src/main/ets/pages/ChatPage.ets(37:13)", "entry");
            Text.fontSize(FONT_CAPTION);
            Text.fontColor(COLOR_TEXT_MUTED);
            Text.fontWeight(FontWeight.Medium);
        }, Text);
        Text.pop();
        // Role label
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // Message content
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/ChatPage.ets(46:11)", "entry");
            // Message content
            Column.borderRadius(this.msg.role === 'user' ?
                { topLeft: RADIUS_XL, topRight: RADIUS_SM, bottomLeft: RADIUS_XL, bottomRight: RADIUS_XL } :
                { topLeft: RADIUS_SM, topRight: RADIUS_XL, bottomLeft: RADIUS_XL, bottomRight: RADIUS_XL });
            // Message content
            Column.backgroundColor(this.msg.role === 'user' ? COLOR_USER_BUBBLE : COLOR_AI_BUBBLE);
            // Message content
            Column.borderWidth(this.msg.role === 'assistant' ? 1 : 0);
            // Message content
            Column.borderColor(this.msg.role === 'assistant' ? COLOR_BORDER : Color.Transparent);
            // Message content
            Column.constraintSize({ maxWidth: '85%' });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.msg.content || (this.msg.isStreaming ? 'Thinking...' : ''));
            Text.debugLine("entry/src/main/ets/pages/ChatPage.ets(47:13)", "entry");
            Text.fontSize(FONT_BODY);
            Text.fontColor(this.msg.role === 'user' ? COLOR_BUBBLE_USER_TEXT : COLOR_BUBBLE_AI_TEXT);
            Text.padding({ left: SPACE_LG, right: SPACE_LG, top: SPACE_MD, bottom: SPACE_MD });
            Text.textAlign(TextAlign.Start);
            Text.lineHeight(20);
        }, Text);
        Text.pop();
        // Message content
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // Streaming indicator
            if (this.msg.isStreaming) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Row.create();
                        Row.debugLine("entry/src/main/ets/pages/ChatPage.ets(64:13)", "entry");
                        Row.margin({ top: SPACE_XS });
                        Row.alignSelf(ItemAlign.Start);
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        LoadingProgress.create();
                        LoadingProgress.debugLine("entry/src/main/ets/pages/ChatPage.ets(65:15)", "entry");
                        LoadingProgress.width(14);
                        LoadingProgress.height(14);
                        LoadingProgress.color(COLOR_ACCENT_BLUE);
                    }, LoadingProgress);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(' Claude is thinking...');
                        Text.debugLine("entry/src/main/ets/pages/ChatPage.ets(68:15)", "entry");
                        Text.fontSize(FONT_CAPTION);
                        Text.fontColor(COLOR_TEXT_MUTED);
                    }, Text);
                    Text.pop();
                    Row.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.msg.role === 'assistant') {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Blank.create();
                        Blank.debugLine("entry/src/main/ets/pages/ChatPage.ets(79:11)", "entry");
                    }, Blank);
                    Blank.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        Row.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
export class ChatPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__inputText = new ObservedPropertySimplePU('', this, "inputText");
        this.__messages = new ObservedPropertyObjectPU([], this, "messages");
        this.__isStreaming = new ObservedPropertySimplePU(false, this, "isStreaming");
        this.__connectionStatus = new ObservedPropertySimplePU(ConnectionStatus.DISCONNECTED, this, "connectionStatus");
        this.socketManager = SocketManager.getInstance();
        this.chatVM = new ChatViewModel();
        this.scroller = new Scroller();
        this.streamingMsgId = '';
        this.onStatusFn = () => { };
        this.onMsgFn = () => { };
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: ChatPage_Params) {
        if (params.inputText !== undefined) {
            this.inputText = params.inputText;
        }
        if (params.messages !== undefined) {
            this.messages = params.messages;
        }
        if (params.isStreaming !== undefined) {
            this.isStreaming = params.isStreaming;
        }
        if (params.connectionStatus !== undefined) {
            this.connectionStatus = params.connectionStatus;
        }
        if (params.socketManager !== undefined) {
            this.socketManager = params.socketManager;
        }
        if (params.chatVM !== undefined) {
            this.chatVM = params.chatVM;
        }
        if (params.scroller !== undefined) {
            this.scroller = params.scroller;
        }
        if (params.streamingMsgId !== undefined) {
            this.streamingMsgId = params.streamingMsgId;
        }
        if (params.onStatusFn !== undefined) {
            this.onStatusFn = params.onStatusFn;
        }
        if (params.onMsgFn !== undefined) {
            this.onMsgFn = params.onMsgFn;
        }
    }
    updateStateVars(params: ChatPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__inputText.purgeDependencyOnElmtId(rmElmtId);
        this.__messages.purgeDependencyOnElmtId(rmElmtId);
        this.__isStreaming.purgeDependencyOnElmtId(rmElmtId);
        this.__connectionStatus.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__inputText.aboutToBeDeleted();
        this.__messages.aboutToBeDeleted();
        this.__isStreaming.aboutToBeDeleted();
        this.__connectionStatus.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __inputText: ObservedPropertySimplePU<string>;
    get inputText() {
        return this.__inputText.get();
    }
    set inputText(newValue: string) {
        this.__inputText.set(newValue);
    }
    private __messages: ObservedPropertyObjectPU<ChatMessage[]>;
    get messages() {
        return this.__messages.get();
    }
    set messages(newValue: ChatMessage[]) {
        this.__messages.set(newValue);
    }
    private __isStreaming: ObservedPropertySimplePU<boolean>;
    get isStreaming() {
        return this.__isStreaming.get();
    }
    set isStreaming(newValue: boolean) {
        this.__isStreaming.set(newValue);
    }
    private __connectionStatus: ObservedPropertySimplePU<ConnectionStatus>;
    get connectionStatus() {
        return this.__connectionStatus.get();
    }
    set connectionStatus(newValue: ConnectionStatus) {
        this.__connectionStatus.set(newValue);
    }
    private socketManager: SocketManager;
    private chatVM: ChatViewModel;
    private scroller: Scroller;
    private streamingMsgId: string;
    private onStatusFn: (status: ConnectionStatus) => void;
    private onMsgFn: (msg: WsMessage) => void;
    aboutToAppear(): void {
        this.connectionStatus = this.socketManager.getStatus();
        this.onStatusFn = (status: ConnectionStatus) => { this.connectionStatus = status; };
        this.onMsgFn = (msg: WsMessage) => { this.handleMessage(msg); };
        this.socketManager.onStatusChange(this.onStatusFn);
        this.socketManager.onMessage(this.onMsgFn);
    }
    aboutToDisappear(): void {
        this.socketManager.offStatusChange(this.onStatusFn);
        this.socketManager.offMessage(this.onMsgFn);
    }
    handleMessage(msg: WsMessage): void {
        if (msg.type === EVENT_CHAT_STREAM) {
            const chunk = msg.payload['chunk'] as string;
            this.chatVM.appendToMessage(this.streamingMsgId, chunk, undefined);
            this.messages = [...this.chatVM.messages];
            this.scrollToBottom();
        }
        else if (msg.type === EVENT_CHAT_DONE) {
            this.chatVM.finishMessage(this.streamingMsgId);
            this.isStreaming = false;
            this.messages = [...this.chatVM.messages];
            this.streamingMsgId = '';
            this.scrollToBottom();
        }
        else if (msg.type === EVENT_CHAT_ERROR) {
            this.chatVM.finishMessage(this.streamingMsgId);
            this.isStreaming = false;
            this.messages = [...this.chatVM.messages];
            this.streamingMsgId = '';
        }
    }
    sendMessage(text?: string): void {
        const msgText = (text || this.inputText).trim();
        if (!msgText || this.isStreaming)
            return;
        if (this.connectionStatus !== ConnectionStatus.CONNECTED)
            return;
        this.chatVM.addUserMessage(msgText);
        this.streamingMsgId = this.chatVM.startAssistantMessage();
        this.messages = [...this.chatVM.messages];
        this.inputText = '';
        this.isStreaming = true;
        let payload = this.makePayload();
        payload['message'] = msgText;
        this.socketManager.send(EVENT_CHAT_SEND, payload);
        this.scrollToBottom();
    }
    sendQuickCommand(cmd: QuickCommand): void {
        this.sendMessage(cmd.prompt);
    }
    makePayload(): Record<string, Object> {
        let obj = new Object();
        return obj as Record<string, Object>;
    }
    scrollToBottom(): void {
        setTimeout(() => {
            this.scroller.scrollEdge(Edge.Bottom);
        }, 80);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/ChatPage.ets(169:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor(COLOR_BG_PRIMARY);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // ── Status bar ──
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/ChatPage.ets(171:7)", "entry");
            // ── Status bar ──
            Row.width('100%');
            // ── Status bar ──
            Row.padding({ left: SPACE_LG, right: SPACE_LG, top: SPACE_SM, bottom: SPACE_SM });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Circle.create({ width: 8, height: 8 });
            Circle.debugLine("entry/src/main/ets/pages/ChatPage.ets(172:9)", "entry");
            Circle.fill(this.statusColor());
        }, Circle);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.statusLabel());
            Text.debugLine("entry/src/main/ets/pages/ChatPage.ets(175:9)", "entry");
            Text.fontSize(FONT_BODY_SM);
            Text.fontColor(COLOR_TEXT_MUTED);
            Text.margin({ left: SPACE_SM });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
            Blank.debugLine("entry/src/main/ets/pages/ChatPage.ets(180:9)", "entry");
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Clear');
            Text.debugLine("entry/src/main/ets/pages/ChatPage.ets(182:9)", "entry");
            Text.fontSize(FONT_BODY_SM);
            Text.fontColor(COLOR_TEXT_SECONDARY);
            Text.padding({ left: SPACE_MD, right: SPACE_MD, top: SPACE_XS, bottom: SPACE_XS });
            Text.borderRadius(RADIUS_SM);
            Text.backgroundColor(COLOR_BG_SECONDARY);
            Text.onClick(() => {
                this.chatVM.clearMessages();
                this.messages = [];
            });
        }, Text);
        Text.pop();
        // ── Status bar ──
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Divider.create();
            Divider.debugLine("entry/src/main/ets/pages/ChatPage.ets(196:7)", "entry");
            Divider.color(COLOR_BORDER);
            Divider.width('100%');
        }, Divider);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // ── Quick commands ──
            if (this.messages.length === 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.debugLine("entry/src/main/ets/pages/ChatPage.ets(200:9)", "entry");
                        Column.width('100%');
                        Column.padding({ left: SPACE_LG, right: SPACE_LG, top: SPACE_LG });
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('Quick Commands');
                        Text.debugLine("entry/src/main/ets/pages/ChatPage.ets(201:11)", "entry");
                        Text.fontSize(FONT_BODY_SM);
                        Text.fontColor(COLOR_TEXT_MUTED);
                        Text.margin({ bottom: SPACE_MD });
                        Text.width('100%');
                        Text.textAlign(TextAlign.Start);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Grid.create();
                        Grid.debugLine("entry/src/main/ets/pages/ChatPage.ets(208:11)", "entry");
                        Grid.columnsTemplate('1fr 1fr 1fr 1fr');
                        Grid.columnsGap(SPACE_SM);
                        Grid.rowsGap(SPACE_SM);
                        Grid.width('100%');
                    }, Grid);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        ForEach.create();
                        const forEachItemGenFunction = _item => {
                            const cmd = _item;
                            {
                                const itemCreation2 = (elmtId, isInitialRender) => {
                                    GridItem.create(() => { }, false);
                                    GridItem.debugLine("entry/src/main/ets/pages/ChatPage.ets(210:15)", "entry");
                                };
                                const observedDeepRender = () => {
                                    this.observeComponentCreation2(itemCreation2, GridItem);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Column.create();
                                        Column.debugLine("entry/src/main/ets/pages/ChatPage.ets(211:17)", "entry");
                                        Column.width('100%');
                                        Column.padding({ top: SPACE_MD, bottom: SPACE_MD });
                                        Column.justifyContent(FlexAlign.Center);
                                        Column.backgroundColor(COLOR_BG_SECONDARY);
                                        Column.borderRadius(RADIUS_MD);
                                        Column.borderWidth(1);
                                        Column.borderColor(COLOR_BORDER);
                                        Column.onClick(() => {
                                            this.sendQuickCommand(cmd);
                                        });
                                    }, Column);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(cmd.icon);
                                        Text.debugLine("entry/src/main/ets/pages/ChatPage.ets(212:19)", "entry");
                                        Text.fontSize(24);
                                        Text.margin({ bottom: SPACE_XS });
                                    }, Text);
                                    Text.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(cmd.label);
                                        Text.debugLine("entry/src/main/ets/pages/ChatPage.ets(215:19)", "entry");
                                        Text.fontSize(FONT_CAPTION);
                                        Text.fontColor(COLOR_TEXT_SECONDARY);
                                    }, Text);
                                    Text.pop();
                                    Column.pop();
                                    GridItem.pop();
                                };
                                observedDeepRender();
                            }
                        };
                        this.forEachUpdateFunction(elmtId, QUICK_COMMANDS, forEachItemGenFunction, (cmd: QuickCommand) => cmd.label, false, false);
                    }, ForEach);
                    ForEach.pop();
                    Grid.pop();
                    Column.pop();
                });
            }
            // ── Message list ──
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // ── Message list ──
            List.create({ scroller: this.scroller });
            List.debugLine("entry/src/main/ets/pages/ChatPage.ets(242:7)", "entry");
            // ── Message list ──
            List.layoutWeight(1);
            // ── Message list ──
            List.width('100%');
            // ── Message list ──
            List.padding({ left: SPACE_MD, right: SPACE_MD });
        }, List);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = _item => {
                const msg = _item;
                {
                    const itemCreation = (elmtId, isInitialRender) => {
                        ViewStackProcessor.StartGetAccessRecordingFor(elmtId);
                        ListItem.create(deepRenderFunction, true);
                        if (!isInitialRender) {
                            ListItem.pop();
                        }
                        ViewStackProcessor.StopGetAccessRecording();
                    };
                    const itemCreation2 = (elmtId, isInitialRender) => {
                        ListItem.create(deepRenderFunction, true);
                        ListItem.debugLine("entry/src/main/ets/pages/ChatPage.ets(244:11)", "entry");
                    };
                    const deepRenderFunction = (elmtId, isInitialRender) => {
                        itemCreation(elmtId, isInitialRender);
                        {
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                if (isInitialRender) {
                                    let componentCall = new MessageBubble(this, { msg: msg }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/ChatPage.ets", line: 245, col: 13 });
                                    ViewPU.create(componentCall);
                                    let paramsLambda = () => {
                                        return {
                                            msg: msg
                                        };
                                    };
                                    componentCall.paramsGenerator_ = paramsLambda;
                                }
                                else {
                                    this.updateStateVarsOfChildByElmtId(elmtId, {
                                        msg: msg
                                    });
                                }
                            }, { name: "MessageBubble" });
                        }
                        ListItem.pop();
                    };
                    this.observeComponentCreation2(itemCreation2, ListItem);
                    ListItem.pop();
                }
            };
            this.forEachUpdateFunction(elmtId, this.messages, forEachItemGenFunction, (msg: ChatMessage) => msg.id, false, false);
        }, ForEach);
        ForEach.pop();
        // ── Message list ──
        List.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Divider.create();
            Divider.debugLine("entry/src/main/ets/pages/ChatPage.ets(253:7)", "entry");
            Divider.color(COLOR_BORDER);
            Divider.width('100%');
        }, Divider);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // ── Input area ──
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/ChatPage.ets(256:7)", "entry");
            // ── Input area ──
            Row.width('100%');
            // ── Input area ──
            Row.padding({ left: SPACE_MD, right: SPACE_MD, top: SPACE_SM, bottom: SPACE_MD });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({ placeholder: 'Ask Claude...', text: this.inputText });
            TextInput.debugLine("entry/src/main/ets/pages/ChatPage.ets(257:9)", "entry");
            TextInput.placeholderColor(COLOR_TEXT_MUTED);
            TextInput.fontColor(COLOR_TEXT_PRIMARY);
            TextInput.backgroundColor(COLOR_BG_SECONDARY);
            TextInput.borderRadius(RADIUS_XL);
            TextInput.borderWidth(1);
            TextInput.borderColor(COLOR_BORDER);
            TextInput.height(44);
            TextInput.layoutWeight(1);
            TextInput.padding({ left: SPACE_LG, right: SPACE_LG });
            TextInput.onChange((value: string) => { this.inputText = value; });
            TextInput.onSubmit(() => { this.sendMessage(); });
        }, TextInput);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithChild({ type: ButtonType.Circle });
            Button.debugLine("entry/src/main/ets/pages/ChatPage.ets(270:9)", "entry");
            Button.width(40);
            Button.height(40);
            Button.backgroundColor(this.inputText.trim().length > 0 && !this.isStreaming ?
                COLOR_ACCENT_BLUE : COLOR_BG_SECONDARY);
            Button.margin({ left: SPACE_SM });
            Button.enabled(this.inputText.trim().length > 0 && !this.isStreaming);
            Button.onClick(() => { this.sendMessage(); });
        }, Button);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('↑');
            Text.debugLine("entry/src/main/ets/pages/ChatPage.ets(271:11)", "entry");
            Text.fontSize(18);
            Text.fontColor('#FFFFFF');
        }, Text);
        Text.pop();
        Button.pop();
        // ── Input area ──
        Row.pop();
        Column.pop();
    }
    statusColor(): ResourceColor {
        switch (this.connectionStatus) {
            case ConnectionStatus.CONNECTED: return COLOR_STATUS_ONLINE;
            case ConnectionStatus.CONNECTING:
            case ConnectionStatus.RECONNECTING: return COLOR_STATUS_WARNING;
            default: return COLOR_STATUS_OFFLINE;
        }
    }
    statusLabel(): string {
        switch (this.connectionStatus) {
            case ConnectionStatus.CONNECTED: return 'Connected';
            case ConnectionStatus.CONNECTING: return 'Connecting...';
            case ConnectionStatus.RECONNECTING: return 'Reconnecting...';
            case ConnectionStatus.ERROR: return 'Connection Error';
            default: return 'Disconnected';
        }
    }
    rerender() {
        this.updateDirtyElements();
    }
}
