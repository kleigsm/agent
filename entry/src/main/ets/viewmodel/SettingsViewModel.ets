import { preferences } from '@kit.ArkData'; import { ConnectionHistory } from '../common/Models';
import { DEFAULT_SERVER_URL } from '../common/Constants';

const PREF_NAME = 'coderemote_settings'

export class SettingsViewModel {
  serverUrl: string = DEFAULT_SERVER_URL
  authToken: string = ''
  connectionHistory: ConnectionHistory[] = []
  private dataPrefs: preferences.Preferences | null = null

  async init(context: Context): Promise<void> {
    try {
      this.dataPrefs = await preferences.getPreferences(context, PREF_NAME)
      this.serverUrl = await this.dataPrefs.get('server_url', DEFAULT_SERVER_URL) as string
      this.authToken = await this.dataPrefs.get('auth_token', '') as string
      let histStr = await this.dataPrefs.get('conn_history', '[]') as string
      this.connectionHistory = JSON.parse(histStr) as ConnectionHistory[]
    } catch (e) { console.error('Failed to init preferences:', JSON.stringify(e)) }
  }

  async saveServerUrl(url: string, token: string): Promise<void> {
    this.serverUrl = url; this.authToken = token
    if (this.dataPrefs) {
      try { await this.dataPrefs.put('server_url', url); await this.dataPrefs.put('auth_token', token); await this.dataPrefs.flush() }
      catch (e) { console.error('Failed to save settings:', JSON.stringify(e)) }
    }
  }

  async addConnectionHistory(url: string): Promise<void> {
    let h = new ConnectionHistory()
    h.id = 'h_' + Date.now(); h.url = url; h.time = Date.now()
    // Keep max 10 entries
    this.connectionHistory.unshift(h)
    if (this.connectionHistory.length > 10) this.connectionHistory = this.connectionHistory.slice(0, 10)
    if (this.dataPrefs) {
      try { await this.dataPrefs.put('conn_history', JSON.stringify(this.connectionHistory)); await this.dataPrefs.flush() }
      catch (e) { console.error('Failed to save history:', JSON.stringify(e)) }
    }
  }
}
