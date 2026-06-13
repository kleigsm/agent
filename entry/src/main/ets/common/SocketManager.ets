import webSocket from '@ohos.net.webSocket';
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { WsMessage } from './Models';
import { RECONNECT_DELAY_MS, MAX_RECONNECT_ATTEMPTS } from './Constants';

type MessageCallback = (msg: WsMessage) => void;
type StatusCallback = (status: ConnectionStatus) => void;

export enum ConnectionStatus {
  DISCONNECTED = 'disconnected',
  CONNECTING = 'connecting',
  CONNECTED = 'connected',
  RECONNECTING = 'reconnecting',
  ERROR = 'error'
}

export class SocketManager {
  private static instance: SocketManager | null = null
  private ws: webSocket.WebSocket | null = null
  private serverUrl: string = ''
  private status: ConnectionStatus = ConnectionStatus.DISCONNECTED
  private messageCallbacks: MessageCallback[] = []
  private statusCallbacks: StatusCallback[] = []
  private reconnectAttempts: number = 0
  private reconnectTimer: number | null = null
  private pendingMessages: string[] = []

  static getInstance(): SocketManager {
    if (!SocketManager.instance) {
      SocketManager.instance = new SocketManager()
    }
    return SocketManager.instance
  }

  getStatus(): ConnectionStatus {
    return this.status
  }

  setServerUrl(url: string): void {
    this.serverUrl = url
  }

  getServerUrl(): string {
    return this.serverUrl
  }

  onMessage(callback: MessageCallback): void {
    this.messageCallbacks.push(callback)
  }

  offMessage(callback: MessageCallback): void {
    const index = this.messageCallbacks.indexOf(callback)
    if (index > -1) {
      this.messageCallbacks.splice(index, 1)
    }
  }

  onStatusChange(callback: StatusCallback): void {
    this.statusCallbacks.push(callback)
  }

  offStatusChange(callback: StatusCallback): void {
    const index = this.statusCallbacks.indexOf(callback)
    if (index > -1) {
      this.statusCallbacks.splice(index, 1)
    }
  }

  private setStatus(status: ConnectionStatus): void {
    this.status = status
    for (const cb of this.statusCallbacks) {
      cb(status)
    }
  }

  private notifyMessage(msg: WsMessage): void {
    for (const cb of this.messageCallbacks) {
      cb(msg)
    }
  }

  connect(url: string): void {
    if (this.ws) {
      this.disconnect()
    }

    this.serverUrl = url
    this.reconnectAttempts = 0
    this.setStatus(ConnectionStatus.CONNECTING)
    this.doConnect(url)
  }

  private doConnect(url: string): void {
    try {
      this.ws = webSocket.createWebSocket()

      this.ws.on('open', (err: BusinessError, value: Object) => {
        if (err) {
          console.error('WebSocket open error:', err.message)
          this.setStatus(ConnectionStatus.ERROR)
          this.tryReconnect()
          return
        }
        console.info('WebSocket connected to', url)
        this.setStatus(ConnectionStatus.CONNECTED)
        this.reconnectAttempts = 0
        this.flushPendingMessages()
      })

      this.ws.on('message', (err: BusinessError, value: string | ArrayBuffer) => {
        if (err) {
          console.error('WebSocket message error:', err.message)
          return
        }
        try {
          const msgStr = typeof value === 'string' ? value : ''
          if (msgStr) {
            const msg: WsMessage = JSON.parse(msgStr) as WsMessage
            // Handle pong
            if (msg.type === 'pong') {
              return
            }
            this.notifyMessage(msg)
          }
        } catch (e) {
          console.error('Failed to parse WebSocket message:', e)
        }
      })

      this.ws.on('close', (err: BusinessError, value: webSocket.CloseResult) => {
        console.info('WebSocket closed, code:', value.code, 'reason:', value.reason)
        this.ws = null
        if (this.status === ConnectionStatus.CONNECTED) {
          this.tryReconnect()
        }
      })

      this.ws.on('error', (err: BusinessError) => {
        console.error('WebSocket error:', err.message)
        if (this.status === ConnectionStatus.CONNECTING) {
          this.setStatus(ConnectionStatus.ERROR)
          this.tryReconnect()
        }
      })

      const connectOptions: webSocket.WebSocketRequestOptions = {
        header: { 'User-Agent': 'CodeRemote-HarmonyOS' }
      }
      this.ws.connect(url, connectOptions, (err: BusinessError, value: boolean) => {
        if (err) {
          console.error('WebSocket connect failed:', err.message)
          this.setStatus(ConnectionStatus.ERROR)
          this.tryReconnect()
        }
      })
    } catch (e) {
      console.error('Failed to create WebSocket:', e)
      this.setStatus(ConnectionStatus.ERROR)
      this.tryReconnect()
    }
  }

  private tryReconnect(): void {
    if (this.reconnectAttempts >= MAX_RECONNECT_ATTEMPTS) {
      console.error('Max reconnect attempts reached')
      this.setStatus(ConnectionStatus.DISCONNECTED)
      return
    }
    this.reconnectAttempts++
    this.setStatus(ConnectionStatus.RECONNECTING)
    console.info('Reconnecting in', RECONNECT_DELAY_MS, 'ms, attempt', this.reconnectAttempts)
    this.reconnectTimer = setTimeout(() => {
      this.doConnect(this.serverUrl)
    }, RECONNECT_DELAY_MS)
  }

  private flushPendingMessages(): void {
    while (this.pendingMessages.length > 0) {
      const msg = this.pendingMessages.shift()
      if (msg) {
        this.sendRaw(msg)
      }
    }
  }

  send(type: string, payload: Record<string, Object>): void {
    const msg = new WsMessage()
    msg.type = type
    msg.payload = payload
    const jsonStr = JSON.stringify(msg)
    if (this.ws && this.status === ConnectionStatus.CONNECTED) {
      this.sendRaw(jsonStr)
    } else {
      this.pendingMessages.push(jsonStr)
    }
  }

  private sendRaw(data: string): void {
    if (this.ws) {
      this.ws.send(data, (err: BusinessError) => {
        if (err) {
          console.error('WebSocket send error:', err.message)
        }
      })
    }
  }

  disconnect(): void {
    if (this.reconnectTimer) {
      clearTimeout(this.reconnectTimer)
      this.reconnectTimer = null
    }
    this.reconnectAttempts = MAX_RECONNECT_ATTEMPTS // prevent reconnect
    if (this.ws) {
      this.ws.close({ code: 1000, reason: 'Client disconnect' }, (err: BusinessError) => {
        if (err) {
          console.error('WebSocket close error:', err.message)
        }
      })
      this.ws = null
    }
    this.pendingMessages = []
    this.setStatus(ConnectionStatus.DISCONNECTED)
  }
}
