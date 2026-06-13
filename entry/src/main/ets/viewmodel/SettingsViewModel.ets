import { preferences } from '@kit.ArkData';
import { SocketManager, ConnectionStatus } from '../common/SocketManager';
import { DEFAULT_SERVER_URL } from '../common/Constants';

const PREF_NAME = 'coderemote_settings'

export class SettingsViewModel {
  serverUrl: string = DEFAULT_SERVER_URL
  connectionStatus: ConnectionStatus = ConnectionStatus.DISCONNECTED
  private dataPrefs: preferences.Preferences | null = null

  async init(context: Context): Promise<void> {
    try {
      this.dataPrefs = await preferences.getPreferences(context, PREF_NAME)
      this.serverUrl = await this.dataPrefs.get('server_url', DEFAULT_SERVER_URL) as string
    } catch (e) {
      console.error('Failed to init preferences:', JSON.stringify(e))
    }
  }

  async saveServerUrl(url: string): Promise<void> {
    this.serverUrl = url
    if (this.dataPrefs) {
      try {
        await this.dataPrefs.put('server_url', url)
        await this.dataPrefs.flush()
      } catch (e) {
        console.error('Failed to save server URL:', JSON.stringify(e))
      }
    }
  }
}
