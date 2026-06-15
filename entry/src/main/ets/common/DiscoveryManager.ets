import socket from '@ohos.net.socket';
import { BusinessError } from '@kit.BasicServicesKit';
import { DiscoveredServer } from './Models';
import { DISCOVERY_PORT, DISCOVERY_MAGIC, DISCOVERY_TIMEOUT_MS } from './Constants';

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

  /**
   * Scan the local network for CodeRemote bridge servers.
   * Sends a UDP broadcast and collects responses.
   */
  async scanNetwork(onFound: DiscoveryCallback): Promise<DiscoveredServer[]> {
    if (this.isScanning) {
      return this.foundServers
    }

    this.isScanning = true
    this.foundServers = []

    try {
      this.udp = socket.constructUDPSocketInstance()

      // Bind to any port to receive responses
      const bindOpt: socket.UDPBindOptions = {
        address: '0.0.0.0',
        port: 0, // OS picks a free port
        family: 1  // IPv4
      }
      await this.udp.bind(bindOpt)

      // Listen for responses
      this.udp.on('message', (data: socket.SocketMessageInfo) => {
        try {
          const text = this.arrayBufferToString(data.message)
          const server = JSON.parse(text) as DiscoveredServer
          if (server.type === 'CODEREMOTE_RESPONSE') {
            // A server may have multiple IPs; use the first IPv4 one
            const host = Array.isArray(server.host) ? server.host[0] : server.host
            if (host && !this.foundServers.find(s => s.host === host && s.port === server.port)) {
              server.host = host
              this.foundServers.push(server)
              onFound(server)
            }
          }
        } catch (e) {
          // Ignore non-JSON or non-server responses
        }
      })

      this.udp.on('error', (err: BusinessError) => {
        console.error('[discovery] UDP error:', err.message)
      })

      // Send broadcast probe
      const probeData = DISCOVERY_MAGIC
      const sendOpt: socket.UDPSendOptions = {
        data: probeData,
        address: '255.255.255.255',
        port: DISCOVERY_PORT
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

  private arrayBufferToString(buffer: ArrayBuffer): string {
    const decoder = new TextDecoder('utf-8')
    const view = new Uint8Array(buffer)
    return decoder.decode(view)
  }

  private sleep(ms: number): Promise<void> {
    return new Promise<void>((resolve) => {
      setTimeout(() => { resolve() }, ms)
    })
  }
}
