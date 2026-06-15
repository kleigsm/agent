import { ChatMessage } from "@normalized:N&&&entry/src/main/ets/common/Models&";
export class ChatViewModel {
    messages: ChatMessage[] = [];
    isStreaming: boolean = false;
    addUserMessage(content: string): void {
        const msg = new ChatMessage('msg_' + Date.now() + '_' + Math.random().toString(36).substring(2, 11), 'user', content);
        this.messages.push(msg);
    }
    startAssistantMessage(): string {
        const msgId = 'msg_' + Date.now() + '_' + Math.random().toString(36).substring(2, 11);
        const msg = new ChatMessage(msgId, 'assistant', '');
        msg.isStreaming = true;
        this.messages.push(msg);
        this.isStreaming = true;
        return msgId;
    }
    appendToMessage(msgId: string, chunk: string, lastMessage?: string): void {
        const msg = this.messages.find(m => m.id === msgId);
        if (msg) {
            if (lastMessage) {
                msg.content = lastMessage;
            }
            else {
                msg.content += chunk;
            }
        }
    }
    finishMessage(msgId: string): void {
        const msg = this.messages.find(m => m.id === msgId);
        if (msg) {
            msg.isStreaming = false;
        }
        this.isStreaming = false;
    }
    clearMessages(): void {
        this.messages = [];
        this.isStreaming = false;
    }
}
