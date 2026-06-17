// ── Server defaults ──
export const DEFAULT_SERVER_URL = 'ws://192.168.1.100:3000'
export const RECONNECT_DELAY_MS = 3000
export const MAX_RECONNECT_ATTEMPTS = 10
export const PING_INTERVAL_MS = 30000
export const MESSAGE_TIMEOUT_MS = 60000

// ── WebSocket event names ──
export const EVENT_CHAT_SEND = 'chat:send'
export const EVENT_CHAT_STREAM = 'chat:stream'
export const EVENT_CHAT_DONE = 'chat:done'
export const EVENT_CHAT_ERROR = 'chat:error'
export const EVENT_FILES_LIST = 'files:list'
export const EVENT_FILES_READ = 'files:read'
export const EVENT_FILES_WRITE = 'files:write'
export const EVENT_FILES_RESULT = 'files:result'
export const EVENT_TERM_EXEC = 'term:exec'
export const EVENT_TERM_OUTPUT = 'term:output'
export const EVENT_TERM_EXIT = 'term:exit'
export const EVENT_AUTH_TOKEN = 'auth:token'

// ── Discovery ──
export const DISCOVERY_PORT = 3001
export const DISCOVERY_MAGIC = 'CODEREMOTE_DISCOVER'
export const DISCOVERY_TIMEOUT_MS = 3000

// ── Quick commands ──
export const QUICK_COMMANDS: QuickCommand[] = [
  { icon: '🏗️', label: '构建', prompt: 'Build the project and report any errors' },
  { icon: '🚀', label: '运行', prompt: 'Run the project on the simulator' },
  { icon: '🧪', label: '测试', prompt: 'Run all tests for this project' },
  { icon: '📜', label: '日志', prompt: 'Show recent build or runtime logs' },
  { icon: '🔎', label: '检查', prompt: 'Check the code for linting issues' },
  { icon: '🗂️', label: '结构', prompt: 'Show the project file structure' },
  { icon: '🪄', label: '修复', prompt: 'Analyze and fix any code issues you find' },
  { icon: '💡', label: '解释', prompt: 'Explain the architecture of the currently open file' },
]

export interface QuickCommand {
  icon: string
  label: string
  prompt: string
}

// ── Color palette (Light theme) ──
// Backgrounds
export const COLOR_BG_PRIMARY = '#F5F5F7'
export const COLOR_BG_SECONDARY = '#FFFFFF'
export const COLOR_BG_TERTIARY = '#EBEBED'
export const COLOR_BG_INPUT = '#F0F0F2'
export const COLOR_BG_HOVER = '#E8E8EC'

// Text
export const COLOR_TEXT_PRIMARY = '#1D1D1F'
export const COLOR_TEXT_SECONDARY = '#6E6E73'
export const COLOR_TEXT_MUTED = '#AEAEB2'
export const COLOR_TEXT_INVERSE = '#FFFFFF'

// Accents
export const COLOR_ACCENT_BLUE = '#007AFF'
export const COLOR_ACCENT_PURPLE = '#AF52DE'
export const COLOR_ACCENT_GREEN = '#34C759'
export const COLOR_ACCENT_RED = '#FF3B30'
export const COLOR_ACCENT_ORANGE = '#FF9500'
export const COLOR_ACCENT_CYAN = '#5AC8FA'
export const COLOR_ACCENT_PINK = '#FF2D55'

// Bubbles
export const COLOR_USER_BUBBLE = '#007AFF'
export const COLOR_AI_BUBBLE = '#F0F0F2'
export const COLOR_BUBBLE_USER_TEXT = '#FFFFFF'
export const COLOR_BUBBLE_AI_TEXT = '#1D1D1F'

// Borders & dividers
export const COLOR_BORDER = '#D1D1D6'
export const COLOR_BORDER_FOCUS = '#007AFF'
export const COLOR_DIVIDER = '#E5E5EA'

// Status
export const COLOR_STATUS_ONLINE = '#34C759'
export const COLOR_STATUS_OFFLINE = '#FF3B30'
export const COLOR_STATUS_WARNING = '#FF9500'

// Gradients (start, end)
export const GRADIENT_ACCENT: [string, string] = ['#58A6FF', '#7C72FF']

// ── Spacing (8px grid) ──
export const SPACE_XS = 4
export const SPACE_SM = 8
export const SPACE_MD = 12
export const SPACE_LG = 16
export const SPACE_XL = 20
export const SPACE_2XL = 24
export const SPACE_3XL = 32

// ── Border radius ──
export const RADIUS_SM = 8
export const RADIUS_MD = 12
export const RADIUS_LG = 16
export const RADIUS_XL = 20
export const RADIUS_FULL = 9999

// ── Font sizes ──
export const FONT_CAPTION = 10
export const FONT_BODY_SM = 12
export const FONT_BODY = 14
export const FONT_BODY_LG = 16
export const FONT_HEADING_SM = 18
export const FONT_HEADING = 20
export const FONT_HEADING_LG = 24

// ── Animation ──
export const ANIM_DURATION_FAST = 150
export const ANIM_DURATION_NORMAL = 250
export const ANIM_DURATION_SLOW = 350

// ── Shadows (elevation) ──
export interface ShadowConfig {
  radius: number
  color: string
  offsetY: number
}
export const SHADOW_CARD: ShadowConfig = { radius: 8, color: '#00000040', offsetY: 2 }
export const SHADOW_MODAL: ShadowConfig = { radius: 24, color: '#00000060', offsetY: 8 }

// ── Glass morphism ──
export const COLOR_GLASS_BG = 'rgba(255, 255, 255, 0.82)'
export const COLOR_GLASS_BORDER = 'rgba(0, 0, 0, 0.08)'
export const COLOR_GLASS_HIGHLIGHT = 'rgba(0, 0, 0, 0.02)'

// ── Gradients ──
export interface GradientStop { color: string; offset: number }
export const GRADIENT_BLUE_PURPLE: string[] = [COLOR_ACCENT_BLUE, COLOR_ACCENT_PURPLE]

// ── Breathing dot ──
export const BREATH_DURATION = 2000 // ms per cycle

// ── App Info ──
export const APP_VERSION = '1.0.0'
export const APP_NAME = 'CodeRemote'

// ── Theme ──
export interface ThemeColors {
  bgPrimary: string
  bgSecondary: string
  bgInput: string
  textPrimary: string
  textSecondary: string
  textMuted: string
  accentBlue: string
  accentGreen: string
  accentRed: string
  accentOrange: string
  userBubble: string
  aiBubble: string
  userText: string
  aiText: string
  border: string
  glassBg: string
  glassBorder: string
  terminalBg: string
  terminalText: string
}

export const LIGHT_THEME: ThemeColors = {
  bgPrimary: '#F5F5F7', bgSecondary: '#FFFFFF', bgInput: '#F0F0F2',
  textPrimary: '#1D1D1F', textSecondary: '#6E6E73', textMuted: '#AEAEB2',
  accentBlue: '#007AFF', accentGreen: '#34C759', accentRed: '#FF3B30', accentOrange: '#FF9500',
  userBubble: '#007AFF', aiBubble: '#F0F0F2', userText: '#FFFFFF', aiText: '#1D1D1F',
  border: '#D1D1D6', glassBg: 'rgba(255,255,255,0.82)', glassBorder: 'rgba(0,0,0,0.08)',
  terminalBg: '#1D1D1F', terminalText: '#E5E5EA'
}

export const DARK_THEME: ThemeColors = {
  bgPrimary: '#0D1117', bgSecondary: '#161B22', bgInput: '#0D1117',
  textPrimary: '#E6EDF3', textSecondary: '#8B949E', textMuted: '#484F58',
  accentBlue: '#58A6FF', accentGreen: '#3FB950', accentRed: '#F85149', accentOrange: '#D29922',
  userBubble: '#1F6FEB', aiBubble: '#21262D', userText: '#FFFFFF', aiText: '#E6EDF3',
  border: '#30363D', glassBg: 'rgba(22,27,34,0.85)', glassBorder: 'rgba(48,54,61,0.6)',
  terminalBg: '#0D1117', terminalText: '#E6EDF3'
}

export function getTheme(isDark: boolean): ThemeColors {
  return isDark ? DARK_THEME : LIGHT_THEME
}
