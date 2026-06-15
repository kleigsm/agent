if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface FilesPage_Params {
    currentPath?: string;
    entries?: FileNode[];
    viewingFile?: string;
    fileContent?: string;
    isLoading?: boolean;
    parentPath?: string;
    breadcrumbs?: string[];
    socketManager?: SocketManager;
    filesVM?: FilesViewModel;
    onMsgFn?: (msg: WsMessage) => void;
}
import { SocketManager } from "@normalized:N&&&entry/src/main/ets/common/SocketManager&";
import { FilesViewModel } from "@normalized:N&&&entry/src/main/ets/viewmodel/FilesViewModel&";
import { EVENT_FILES_LIST, EVENT_FILES_READ, EVENT_FILES_RESULT, COLOR_BG_PRIMARY, COLOR_BG_SECONDARY, COLOR_BG_INPUT, COLOR_TEXT_PRIMARY, COLOR_TEXT_SECONDARY, COLOR_TEXT_MUTED, COLOR_ACCENT_BLUE, COLOR_BORDER, COLOR_DIVIDER, SPACE_XS, SPACE_SM, SPACE_MD, SPACE_LG, RADIUS_MD, RADIUS_FULL, FONT_CAPTION, FONT_BODY_SM, FONT_BODY, FONT_BODY_LG } from "@normalized:N&&&entry/src/main/ets/common/Constants&";
import type { WsMessage, FileNode } from '../common/Models';
export class FilesPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__currentPath = new ObservedPropertySimplePU('/', this, "currentPath");
        this.__entries = new ObservedPropertyObjectPU([], this, "entries");
        this.__viewingFile = new ObservedPropertySimplePU('', this, "viewingFile");
        this.__fileContent = new ObservedPropertySimplePU('', this, "fileContent");
        this.__isLoading = new ObservedPropertySimplePU(false, this, "isLoading");
        this.__parentPath = new ObservedPropertySimplePU('/', this, "parentPath");
        this.__breadcrumbs = new ObservedPropertyObjectPU(['/'], this, "breadcrumbs");
        this.socketManager = SocketManager.getInstance();
        this.filesVM = new FilesViewModel();
        this.onMsgFn = () => { };
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: FilesPage_Params) {
        if (params.currentPath !== undefined) {
            this.currentPath = params.currentPath;
        }
        if (params.entries !== undefined) {
            this.entries = params.entries;
        }
        if (params.viewingFile !== undefined) {
            this.viewingFile = params.viewingFile;
        }
        if (params.fileContent !== undefined) {
            this.fileContent = params.fileContent;
        }
        if (params.isLoading !== undefined) {
            this.isLoading = params.isLoading;
        }
        if (params.parentPath !== undefined) {
            this.parentPath = params.parentPath;
        }
        if (params.breadcrumbs !== undefined) {
            this.breadcrumbs = params.breadcrumbs;
        }
        if (params.socketManager !== undefined) {
            this.socketManager = params.socketManager;
        }
        if (params.filesVM !== undefined) {
            this.filesVM = params.filesVM;
        }
        if (params.onMsgFn !== undefined) {
            this.onMsgFn = params.onMsgFn;
        }
    }
    updateStateVars(params: FilesPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__currentPath.purgeDependencyOnElmtId(rmElmtId);
        this.__entries.purgeDependencyOnElmtId(rmElmtId);
        this.__viewingFile.purgeDependencyOnElmtId(rmElmtId);
        this.__fileContent.purgeDependencyOnElmtId(rmElmtId);
        this.__isLoading.purgeDependencyOnElmtId(rmElmtId);
        this.__parentPath.purgeDependencyOnElmtId(rmElmtId);
        this.__breadcrumbs.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__currentPath.aboutToBeDeleted();
        this.__entries.aboutToBeDeleted();
        this.__viewingFile.aboutToBeDeleted();
        this.__fileContent.aboutToBeDeleted();
        this.__isLoading.aboutToBeDeleted();
        this.__parentPath.aboutToBeDeleted();
        this.__breadcrumbs.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __currentPath: ObservedPropertySimplePU<string>;
    get currentPath() {
        return this.__currentPath.get();
    }
    set currentPath(newValue: string) {
        this.__currentPath.set(newValue);
    }
    private __entries: ObservedPropertyObjectPU<FileNode[]>;
    get entries() {
        return this.__entries.get();
    }
    set entries(newValue: FileNode[]) {
        this.__entries.set(newValue);
    }
    private __viewingFile: ObservedPropertySimplePU<string>;
    get viewingFile() {
        return this.__viewingFile.get();
    }
    set viewingFile(newValue: string) {
        this.__viewingFile.set(newValue);
    }
    private __fileContent: ObservedPropertySimplePU<string>;
    get fileContent() {
        return this.__fileContent.get();
    }
    set fileContent(newValue: string) {
        this.__fileContent.set(newValue);
    }
    private __isLoading: ObservedPropertySimplePU<boolean>;
    get isLoading() {
        return this.__isLoading.get();
    }
    set isLoading(newValue: boolean) {
        this.__isLoading.set(newValue);
    }
    private __parentPath: ObservedPropertySimplePU<string>;
    get parentPath() {
        return this.__parentPath.get();
    }
    set parentPath(newValue: string) {
        this.__parentPath.set(newValue);
    }
    private __breadcrumbs: ObservedPropertyObjectPU<string[]>;
    get breadcrumbs() {
        return this.__breadcrumbs.get();
    }
    set breadcrumbs(newValue: string[]) {
        this.__breadcrumbs.set(newValue);
    }
    private socketManager: SocketManager;
    private filesVM: FilesViewModel;
    private onMsgFn: (msg: WsMessage) => void;
    aboutToAppear(): void {
        this.onMsgFn = (msg: WsMessage) => { this.handleMessage(msg); };
        this.socketManager.onMessage(this.onMsgFn);
        this.loadDirectory('/');
    }
    aboutToDisappear(): void {
        this.socketManager.offMessage(this.onMsgFn);
    }
    handleMessage(msg: WsMessage): void {
        if (msg.type === EVENT_FILES_RESULT) {
            const success = msg.payload['success'] as boolean;
            if (!success)
                return;
            const path = msg.payload['path'] as string;
            const data = msg.payload['data'];
            if (Array.isArray(data)) {
                this.filesVM.setEntries(path, data as FileNode[]);
                this.breadcrumbs = this.buildBreadcrumbs(path);
                this.refreshState();
            }
            else if (typeof data === 'string' && msg.payload['operation'] === 'read') {
                this.filesVM.setFileContent(path, data);
                this.refreshState();
            }
        }
    }
    buildBreadcrumbs(path: string): string[] {
        const parts = path.split('/').filter(p => p);
        const crumbs = ['/'];
        let current = '';
        for (const part of parts) {
            current += '/' + part;
            crumbs.push(current);
        }
        return crumbs;
    }
    refreshState(): void {
        this.currentPath = this.filesVM.currentPath;
        this.entries = [...this.filesVM.entries];
        this.parentPath = this.filesVM.parentPath;
        this.viewingFile = this.filesVM.viewingFile;
        this.fileContent = this.filesVM.fileContent;
        this.isLoading = false;
    }
    loadDirectory(path: string): void {
        this.isLoading = true;
        this.filesVM.clearFileView();
        let payload = this.makePayload();
        payload['path'] = path;
        this.socketManager.send(EVENT_FILES_LIST, payload);
    }
    loadFile(path: string): void {
        this.isLoading = true;
        let payload = this.makePayload();
        payload['path'] = path;
        this.socketManager.send(EVENT_FILES_READ, payload);
    }
    makePayload(): Record<string, Object> {
        let obj = new Object();
        return obj as Record<string, Object>;
    }
    navigateUp(): void {
        if (this.currentPath !== '/') {
            this.loadDirectory(this.parentPath);
        }
    }
    formatSize(bytes: number): string {
        if (bytes < 1024)
            return bytes + ' B';
        if (bytes < 1048576)
            return (bytes / 1024).toFixed(1) + ' KB';
        return (bytes / 1048576).toFixed(1) + ' MB';
    }
    fileIcon(item: FileNode): string {
        if (item.type === 'directory')
            return '📁';
        const ext = item.name.split('.').pop()?.toLowerCase();
        switch (ext) {
            case 'ets': return '🔷';
            case 'ts': return '🔵';
            case 'js': return '🟨';
            case 'json':
            case 'json5': return '📋';
            case 'md': return '📝';
            case 'png':
            case 'jpg':
            case 'jpeg':
            case 'gif': return '🖼';
            case 'svg': return '🎨';
            case 'hsp':
            case 'hap': return '📦';
            default: return '📄';
        }
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/FilesPage.ets(127:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor(COLOR_BG_PRIMARY);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // ── Navigation bar ──
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/FilesPage.ets(129:7)", "entry");
            // ── Navigation bar ──
            Row.width('100%');
            // ── Navigation bar ──
            Row.padding({ left: SPACE_MD, right: SPACE_MD, top: SPACE_SM, bottom: SPACE_SM });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithChild({ type: ButtonType.Circle });
            Button.debugLine("entry/src/main/ets/pages/FilesPage.ets(130:9)", "entry");
            Button.width(36);
            Button.height(36);
            Button.backgroundColor(COLOR_BG_SECONDARY);
            Button.enabled(this.currentPath !== '/');
            Button.onClick(() => this.navigateUp());
        }, Button);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('↑');
            Text.debugLine("entry/src/main/ets/pages/FilesPage.ets(131:11)", "entry");
            Text.fontSize(16);
            Text.fontColor(COLOR_TEXT_PRIMARY);
        }, Text);
        Text.pop();
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // Breadcrumbs
            Scroll.create();
            Scroll.debugLine("entry/src/main/ets/pages/FilesPage.ets(139:9)", "entry");
            // Breadcrumbs
            Scroll.layoutWeight(1);
            // Breadcrumbs
            Scroll.scrollable(ScrollDirection.Horizontal);
            // Breadcrumbs
            Scroll.scrollBar(BarState.Off);
            // Breadcrumbs
            Scroll.margin({ left: SPACE_SM });
        }, Scroll);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/FilesPage.ets(140:11)", "entry");
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = (_item, index: number) => {
                const crumb = _item;
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Row.create();
                    Row.debugLine("entry/src/main/ets/pages/FilesPage.ets(142:15)", "entry");
                }, Row);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    If.create();
                    if (index > 0) {
                        this.ifElseBranchUpdateFunction(0, () => {
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                Text.create('/');
                                Text.debugLine("entry/src/main/ets/pages/FilesPage.ets(144:19)", "entry");
                                Text.fontSize(FONT_BODY_SM);
                                Text.fontColor(COLOR_TEXT_MUTED);
                                Text.margin({ left: SPACE_XS, right: SPACE_XS });
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
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create(index === 0 ? '/' : crumb.split('/').pop() || '');
                    Text.debugLine("entry/src/main/ets/pages/FilesPage.ets(147:17)", "entry");
                    Text.fontSize(FONT_BODY_SM);
                    Text.fontColor(index === this.breadcrumbs.length - 1 ? COLOR_TEXT_PRIMARY : COLOR_ACCENT_BLUE);
                    Text.fontFamily('monospace');
                    Text.maxLines(1);
                    Text.onClick(() => { this.loadDirectory(crumb); });
                }, Text);
                Text.pop();
                Row.pop();
            };
            this.forEachUpdateFunction(elmtId, this.breadcrumbs, forEachItemGenFunction, (crumb: string, idx: number) => idx.toString(), true, true);
        }, ForEach);
        ForEach.pop();
        Row.pop();
        // Breadcrumbs
        Scroll.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('⟳');
            Button.debugLine("entry/src/main/ets/pages/FilesPage.ets(162:9)", "entry");
            Button.fontSize(FONT_BODY_LG);
            Button.fontColor(COLOR_ACCENT_BLUE);
            Button.backgroundColor(COLOR_BG_SECONDARY);
            Button.width(34);
            Button.height(34);
            Button.borderRadius(RADIUS_FULL);
            Button.onClick(() => this.loadDirectory(this.currentPath));
        }, Button);
        Button.pop();
        // ── Navigation bar ──
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Divider.create();
            Divider.debugLine("entry/src/main/ets/pages/FilesPage.ets(173:7)", "entry");
            Divider.color(COLOR_BORDER);
            Divider.width('100%');
        }, Divider);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // ── File viewer (when a file is open) ──
            if (this.viewingFile) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.debugLine("entry/src/main/ets/pages/FilesPage.ets(177:9)", "entry");
                        Column.layoutWeight(1);
                        Column.width('100%');
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Row.create();
                        Row.debugLine("entry/src/main/ets/pages/FilesPage.ets(178:11)", "entry");
                        Row.width('100%');
                        Row.padding({ left: SPACE_LG, right: SPACE_SM, top: SPACE_SM, bottom: SPACE_SM });
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('📄 ' + this.viewingFile.split('/').pop());
                        Text.debugLine("entry/src/main/ets/pages/FilesPage.ets(179:13)", "entry");
                        Text.fontSize(FONT_BODY);
                        Text.fontColor(COLOR_ACCENT_BLUE);
                        Text.fontFamily('monospace');
                        Text.layoutWeight(1);
                        Text.maxLines(1);
                        Text.textOverflow({ overflow: TextOverflow.Ellipsis });
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithChild({ type: ButtonType.Circle });
                        Button.debugLine("entry/src/main/ets/pages/FilesPage.ets(187:13)", "entry");
                        Button.width(32);
                        Button.height(32);
                        Button.backgroundColor(Color.Transparent);
                        Button.onClick(() => {
                            this.filesVM.clearFileView();
                            this.viewingFile = '';
                            this.fileContent = '';
                        });
                    }, Button);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('✕');
                        Text.debugLine("entry/src/main/ets/pages/FilesPage.ets(188:15)", "entry");
                        Text.fontSize(14);
                        Text.fontColor(COLOR_TEXT_SECONDARY);
                    }, Text);
                    Text.pop();
                    Button.pop();
                    Row.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Scroll.create();
                        Scroll.debugLine("entry/src/main/ets/pages/FilesPage.ets(201:11)", "entry");
                        Scroll.layoutWeight(1);
                        Scroll.width('100%');
                        Scroll.backgroundColor(COLOR_BG_INPUT);
                        Scroll.borderRadius(RADIUS_MD);
                        Scroll.margin({ left: SPACE_SM, right: SPACE_SM, bottom: SPACE_SM });
                    }, Scroll);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.fileContent || 'Empty file');
                        Text.debugLine("entry/src/main/ets/pages/FilesPage.ets(202:13)", "entry");
                        Text.fontSize(FONT_BODY_SM);
                        Text.fontColor(COLOR_TEXT_PRIMARY);
                        Text.fontFamily('monospace');
                        Text.padding(SPACE_LG);
                        Text.width('100%');
                        Text.textAlign(TextAlign.Start);
                        Text.lineHeight(18);
                    }, Text);
                    Text.pop();
                    Scroll.pop();
                    Column.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        If.create();
                        // ── File list ──
                        if (this.isLoading && this.entries.length === 0) {
                            this.ifElseBranchUpdateFunction(0, () => {
                                this.observeComponentCreation2((elmtId, isInitialRender) => {
                                    Column.create();
                                    Column.debugLine("entry/src/main/ets/pages/FilesPage.ets(222:11)", "entry");
                                    Column.width('100%');
                                    Column.layoutWeight(1);
                                    Column.justifyContent(FlexAlign.Center);
                                }, Column);
                                this.observeComponentCreation2((elmtId, isInitialRender) => {
                                    LoadingProgress.create();
                                    LoadingProgress.debugLine("entry/src/main/ets/pages/FilesPage.ets(223:13)", "entry");
                                    LoadingProgress.width(32);
                                    LoadingProgress.height(32);
                                    LoadingProgress.color(COLOR_ACCENT_BLUE);
                                }, LoadingProgress);
                                this.observeComponentCreation2((elmtId, isInitialRender) => {
                                    Text.create('Loading...');
                                    Text.debugLine("entry/src/main/ets/pages/FilesPage.ets(224:13)", "entry");
                                    Text.fontSize(FONT_BODY_SM);
                                    Text.fontColor(COLOR_TEXT_MUTED);
                                    Text.margin({ top: SPACE_MD });
                                }, Text);
                                Text.pop();
                                Column.pop();
                            });
                        }
                        else {
                            this.ifElseBranchUpdateFunction(1, () => {
                            });
                        }
                    }, If);
                    If.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        List.create();
                        List.debugLine("entry/src/main/ets/pages/FilesPage.ets(234:9)", "entry");
                        List.layoutWeight(1);
                        List.width('100%');
                        List.divider({ strokeWidth: 0.5, color: COLOR_DIVIDER });
                    }, List);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        ForEach.create();
                        const forEachItemGenFunction = _item => {
                            const item = _item;
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
                                    ListItem.debugLine("entry/src/main/ets/pages/FilesPage.ets(236:13)", "entry");
                                };
                                const deepRenderFunction = (elmtId, isInitialRender) => {
                                    itemCreation(elmtId, isInitialRender);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Row.create();
                                        Row.debugLine("entry/src/main/ets/pages/FilesPage.ets(237:15)", "entry");
                                        Row.width('100%');
                                        Row.height(52);
                                        Row.padding({ left: SPACE_LG, right: SPACE_LG });
                                        Row.alignItems(VerticalAlign.Center);
                                        Row.onClick(() => {
                                            if (item.type === 'directory') {
                                                this.loadDirectory(item.path);
                                            }
                                            else {
                                                this.loadFile(item.path);
                                            }
                                        });
                                    }, Row);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(this.fileIcon(item));
                                        Text.debugLine("entry/src/main/ets/pages/FilesPage.ets(238:17)", "entry");
                                        Text.fontSize(22);
                                    }, Text);
                                    Text.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Column.create();
                                        Column.debugLine("entry/src/main/ets/pages/FilesPage.ets(241:17)", "entry");
                                        Column.layoutWeight(1);
                                        Column.margin({ left: SPACE_MD });
                                        Column.alignItems(HorizontalAlign.Start);
                                    }, Column);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(item.name);
                                        Text.debugLine("entry/src/main/ets/pages/FilesPage.ets(242:19)", "entry");
                                        Text.fontSize(FONT_BODY);
                                        Text.fontColor(COLOR_TEXT_PRIMARY);
                                        Text.maxLines(1);
                                        Text.textOverflow({ overflow: TextOverflow.Ellipsis });
                                        Text.fontWeight(FontWeight.Medium);
                                    }, Text);
                                    Text.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Row.create();
                                        Row.debugLine("entry/src/main/ets/pages/FilesPage.ets(249:19)", "entry");
                                        Row.margin({ top: 2 });
                                    }, Row);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        If.create();
                                        if (item.type === 'file') {
                                            this.ifElseBranchUpdateFunction(0, () => {
                                                this.observeComponentCreation2((elmtId, isInitialRender) => {
                                                    Text.create(this.formatSize(item.size));
                                                    Text.debugLine("entry/src/main/ets/pages/FilesPage.ets(251:23)", "entry");
                                                    Text.fontSize(FONT_CAPTION);
                                                    Text.fontColor(COLOR_TEXT_MUTED);
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
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        If.create();
                                        if (item.modified) {
                                            this.ifElseBranchUpdateFunction(0, () => {
                                                this.observeComponentCreation2((elmtId, isInitialRender) => {
                                                    Text.create(item.modified.substring(0, 10));
                                                    Text.debugLine("entry/src/main/ets/pages/FilesPage.ets(256:23)", "entry");
                                                    Text.fontSize(FONT_CAPTION);
                                                    Text.fontColor(COLOR_TEXT_MUTED);
                                                    Text.margin({ left: SPACE_SM });
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
                                    Row.pop();
                                    Column.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Image.create({ "id": 125832664, "type": 40000, params: [], "bundleName": "com.coderemote.harmonyos", "moduleName": "entry" });
                                        Image.debugLine("entry/src/main/ets/pages/FilesPage.ets(268:17)", "entry");
                                        Image.width(16);
                                        Image.height(16);
                                        Image.fillColor(COLOR_TEXT_MUTED);
                                    }, Image);
                                    Row.pop();
                                    ListItem.pop();
                                };
                                this.observeComponentCreation2(itemCreation2, ListItem);
                                ListItem.pop();
                            }
                        };
                        this.forEachUpdateFunction(elmtId, this.entries, forEachItemGenFunction, (item: FileNode) => item.path, false, false);
                    }, ForEach);
                    ForEach.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        If.create();
                        if (this.entries.length === 0 && !this.isLoading) {
                            this.ifElseBranchUpdateFunction(0, () => {
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
                                        ListItem.debugLine("entry/src/main/ets/pages/FilesPage.ets(287:13)", "entry");
                                    };
                                    const deepRenderFunction = (elmtId, isInitialRender) => {
                                        itemCreation(elmtId, isInitialRender);
                                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                                            Text.create('Empty directory');
                                            Text.debugLine("entry/src/main/ets/pages/FilesPage.ets(288:15)", "entry");
                                            Text.fontSize(FONT_BODY);
                                            Text.fontColor(COLOR_TEXT_MUTED);
                                            Text.width('100%');
                                            Text.textAlign(TextAlign.Center);
                                            Text.padding(32);
                                        }, Text);
                                        Text.pop();
                                        ListItem.pop();
                                    };
                                    this.observeComponentCreation2(itemCreation2, ListItem);
                                    ListItem.pop();
                                }
                            });
                        }
                        else {
                            this.ifElseBranchUpdateFunction(1, () => {
                            });
                        }
                    }, If);
                    If.pop();
                    List.pop();
                });
            }
        }, If);
        If.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
