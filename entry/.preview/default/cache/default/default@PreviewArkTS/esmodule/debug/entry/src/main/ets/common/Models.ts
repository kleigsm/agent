@Observed
export class ChatMessage {
    id: string = '';
    role: string = 'user'; // 'user' | 'assistant' | 'system' | 'tool'
    content: string = '';
    isStreaming: boolean = false;
    timestamp: number = Date.now();
    isError: boolean = false;
    toolName: string = '';
    constructor(id: string, role: string, content: string) {
        this.id = id;
        this.role = role;
        this.content = content;
        this.timestamp = Date.now();
    }
}
@Observed
export class ChatSession {
    id: string = '';
    title: string = 'New Chat';
    messages: ChatMessage[] = [];
    createdAt: number = Date.now();
    updatedAt: number = Date.now();
}
export class FileNode {
    name: string = '';
    type: string = 'file'; // 'file' | 'directory'
    path: string = '';
    size: number = 0;
    modified: string = '';
}
export class TerminalOutput {
    data: string = '';
    isStderr: boolean = false;
}
export class WsMessage {
    type: string = '';
    payload: Record<string, Object> = {};
}
@Observed
export class DiscoveredServer {
    host: string = '';
    port: number = 3000;
    token: string = '';
    version: string = '';
}
