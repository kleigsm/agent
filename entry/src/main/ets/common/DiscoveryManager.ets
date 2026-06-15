import socket from '@ohos.net.socket';
import { BusinessError } from '@kit.BasicServicesKit';
import { DiscoveredServer } from './Models';
import { DISCOVERY_PORT, DISCOVERY_MAGIC, DISCOVERY_TIMEOUT_MS } from './Constants';
import { util } from '@kit.ArkTS';

type DiscoveryCallback = (server: DiscoveredServer) => void;

export class DiscoveryManager {
  private static instance: DiscoveryManager | null = null
  private udp: socket.UDPSocket | null = null
  private isScanning: boolean = false
  private foundServers: DiscoveredServer[] = []

  static getInstance(): DiscoveryManager {
    if (!DiscoveryManager.instance) {
      DiscoveryManager.instance = new DiscoveryManager()
    }
    return DiscoveryManager.instance
  }

  getServers(): DiscoveredServer[] {
    return [...this.foundServers]
  }

  clearServers(): void {
    this.foundServers = []
  }

  getIsScanning(): boolean {
    return this.isScanning
  }

  async scanNetwork(onFound: DiscoveryCallback): Promise<DiscoveredServer[]> {
    if (this.isScanning) {
      return this.foundServers
    }

    this.isScanning = true
    this.foundServers = []

    try {
      this.udp = socket.constructUDPSocketInstance()

      // Bind to a random port for receiving responses
      let bindAddr: socket.NetAddress = { address: '0.0.0.0', port: 0, family: 1 }
      await this.udp.bind(bindAddr)

      // Listen for responses
      this.udp.on('message', (data: socket.SocketMessageInfo) => {
        try {
          let decoder = new util.TextDecoder('utf-8')
          let view = new Uint8Array(data.message)
          let text = decoder.decodeToString(view)
          let server = JSON.parse(text) as Record<string, Object>
          if (server['type'] === 'CODEREMOTE_RESPONSE') {
            let host = server['host'] as string
            let port = server['port'] as number
            let token = server['token'] as string
            let version = server['version'] as string
            if (host && !this.foundServers.find(s => s.host === host && s.port === port)) {
              let found: DiscoveredServer = new DiscoveredServer()
              found.host = host
              found.port = port
              found.token = token || ''
              found.version = version || ''
              this.foundServers.push(found)
              onFound(found)
            }
          }
        } catch (e) {
          // Ignore non-JSON responses
        }
      })

      this.udp.on('error', (err: BusinessError) => {
        console.error('[discovery] UDP error:', err.message)
      })

      // Send broadcast probe
      let sendOpt: socket.UDPSendOptions = {
        data: DISCOVERY_MAGIC,
        address: { address: '255.255.255.255', port: DISCOVERY_PORT, family: 1 }
      }
      await this.udp.send(sendOpt)

      // Wait for responses
      await this.sleep(DISCOVERY_TIMEOUT_MS)

    } catch (e) {
      console.error('[discovery] Scan error:', JSON.stringify(e))
    } finally {
      this.isScanning = false
      if (this.udp) {
        this.udp.close()
        this.udp = null
      }
    }

    return this.foundServers
  }

  stopScan(): void {
    this.isScanning = false
    if (this.udp) {
      this.udp.close()
      this.udp = null
    }
  }

  private sleep(ms: number): Promise<void> {
    return new Promise<void>((resolve: Function) => {
      setTimeout(() => { resolve() }, ms)
    })
  }
}
