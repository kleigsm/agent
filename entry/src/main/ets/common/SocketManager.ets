import webSocket from '@ohos.net.webSocket';
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { WsMessage } from './Models';
import {
  RECONNECT_DELAY_MS, MAX_RECONNECT_ATTEMPTS,
  PING_INTERVAL_MS, MESSAGE_TIMEOUT_MS
} from './Constants';

type MessageCallback = (msg: WsMessage) => void;
type StatusCallback = (status: ConnectionStatus) => void;
type ErrorCallback = (error: string) => void;

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
  private authToken: string = ''
  private status: ConnectionStatus = ConnectionStatus.DISCONNECTED
  private messageCallbacks: MessageCallback[] = []
  private statusCallbacks: StatusCallback[] = []
  private errorCallbacks: ErrorCallback[] = []
  private reconnectAttempts: number = 0
  private reconnectTimer: number | null = null
  private pendingMessages: string[] = []
  private pingTimer: number | null = null
  private lastPongTime: number = 0

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

  setAuthToken(token: string): void {
    this.authToken = token
  }

  getAuthToken(): string {
    return this.authToken
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

  onError(callback: ErrorCallback): void {
    this.errorCallbacks.push(callback)
  }

  offError(callback: ErrorCallback): void {
    const index = this.errorCallbacks.indexOf(callback)
    if (index > -1) {
      this.errorCallbacks.splice(index, 1)
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

  private notifyError(error: string): void {
    for (const cb of this.errorCallbacks) {
      cb(error)
    }
  }

  connect(url: string, token?: string): void {
    if (this.ws) {
      this.disconnect()
    }

    this.serverUrl = url
    if (token) {
      this.authToken = token
    }

    // Build connection URL with auth token
    let connectUrl = this.serverUrl
    if (this.authToken) {
      const sep = connectUrl.includes('?') ? '&' : '?'
      connectUrl = connectUrl + sep + 'token=' + this.authToken
    }

    this.reconnectAttempts = 0
    this.setStatus(ConnectionStatus.CONNECTING)
    this.doConnect(connectUrl)
  }

  private doConnect(url: string): void {
    try {
      this.ws = webSocket.createWebSocket()

      this.ws.on('open', (err: BusinessError, value: Object) => {
        if (err) {
          console.error('WebSocket open error:', err.message)
          this.setStatus(ConnectionStatus.ERROR)
          this.notifyError('Connection failed: ' + err.message)
          this.tryReconnect()
          return
        }
        console.info('WebSocket connected to', url)
        this.setStatus(ConnectionStatus.CONNECTED)
        this.reconnectAttempts = 0
        this.flushPendingMessages()
        this.startPing()
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
            if (msg.type === 'pong') {
              this.lastPongTime = Date.now()
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
        this.stopPing()

        // 4001 = auth rejected
        if (value.code === 4001) {
          this.setStatus(ConnectionStatus.ERROR)
          this.notifyError('Auth failed: invalid token')
          return // don't reconnect
        }

        if (this.status === ConnectionStatus.CONNECTED) {
          this.tryReconnect()
        } else {
          this.setStatus(ConnectionStatus.DISCONNECTED)
        }
      })

      this.ws.on('error', (err: BusinessError) => {
        console.error('WebSocket error:', err.message)
        if (this.status === ConnectionStatus.CONNECTING) {
          this.setStatus(ConnectionStatus.ERROR)
          this.notifyError('Connection error: ' + err.message)
          this.tryReconnect()
        }
      })

      this.ws.connect(url, (err: BusinessError, value: boolean) => {
        if (err) {
          console.error('WebSocket connect failed:', err.message)
          this.setStatus(ConnectionStatus.ERROR)
          this.notifyError('Connect failed: ' + err.message)
          this.tryReconnect()
        }
      })
    } catch (e) {
      console.error('Failed to create WebSocket:', e)
      this.setStatus(ConnectionStatus.ERROR)
      this.notifyError('Socket creation failed')
      this.tryReconnect()
    }
  }

  private startPing(): void {
    this.lastPongTime = Date.now()
    this.pingTimer = setInterval(() => {
      if (this.ws && this.status === ConnectionStatus.CONNECTED) {
        let pingMsg = new WsMessage()
            pingMsg.type = 'ping'
            pingMsg.payload = {}
            this.sendRaw(JSON.stringify(pingMsg))
        // Check for ping timeout
        if (Date.now() - this.lastPongTime > PING_INTERVAL_MS * 2) {
          console.warn('Ping timeout, reconnecting...')
          this.disconnect()
          this.tryReconnect()
        }
      }
    }, PING_INTERVAL_MS)
  }

  private stopPing(): void {
    if (this.pingTimer) {
      clearInterval(this.pingTimer)
      this.pingTimer = null
    }
  }

  private tryReconnect(): void {
    if (this.reconnectAttempts >= MAX_RECONNECT_ATTEMPTS) {
      console.error('Max reconnect attempts reached')
      this.setStatus(ConnectionStatus.DISCONNECTED)
      this.notifyError('Unable to connect after ' + MAX_RECONNECT_ATTEMPTS + ' attempts')
      return
    }
    this.reconnectAttempts++
    this.setStatus(ConnectionStatus.RECONNECTING)
    const delay = RECONNECT_DELAY_MS * Math.min(this.reconnectAttempts, 5)
    console.info('Reconnecting in', delay, 'ms, attempt', this.reconnectAttempts)

    // Build URL with token again
    let connectUrl = this.serverUrl
    if (this.authToken) {
      const sep = connectUrl.includes('?') ? '&' : '?'
      connectUrl = connectUrl + sep + 'token=' + this.authToken
    }

    this.reconnectTimer = setTimeout(() => {
      this.doConnect(connectUrl)
    }, delay)
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
    this.stopPing()
    this.reconnectAttempts = MAX_RECONNECT_ATTEMPTS
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
