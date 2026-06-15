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
  { icon: '📦', label: 'Build', prompt: 'Build the project and report any errors' },
  { icon: '▶', label: 'Run', prompt: 'Run the project on the simulator' },
  { icon: '🧪', label: 'Test', prompt: 'Run all tests for this project' },
  { icon: '📋', label: 'Logs', prompt: 'Show recent build or runtime logs' },
  { icon: '🔍', label: 'Lint', prompt: 'Check the code for linting issues' },
  { icon: '📂', label: 'Tree', prompt: 'Show the project file structure' },
  { icon: '🔧', label: 'Fix', prompt: 'Analyze and fix any code issues you find' },
  { icon: '📝', label: 'Explain', prompt: 'Explain the architecture of the currently open file' },
]

export interface QuickCommand {
  icon: string
  label: string
  prompt: string
}

// ── Color palette (GitHub-dark inspired) ──
// Backgrounds
export const COLOR_BG_PRIMARY = '#0D1117'
export const COLOR_BG_SECONDARY = '#161B22'
export const COLOR_BG_TERTIARY = '#21262D'
export const COLOR_BG_INPUT = '#0D1117'
export const COLOR_BG_HOVER = '#1C2128'

// Text
export const COLOR_TEXT_PRIMARY = '#E6EDF3'
export const COLOR_TEXT_SECONDARY = '#8B949E'
export const COLOR_TEXT_MUTED = '#484F58'
export const COLOR_TEXT_INVERSE = '#0D1117'

// Accents
export const COLOR_ACCENT_BLUE = '#58A6FF'
export const COLOR_ACCENT_PURPLE = '#7C72FF'
export const COLOR_ACCENT_GREEN = '#3FB950'
export const COLOR_ACCENT_RED = '#F85149'
export const COLOR_ACCENT_ORANGE = '#D29922'
export const COLOR_ACCENT_CYAN = '#39D2C0'
export const COLOR_ACCENT_PINK = '#DB61A2'

// Bubbles
export const COLOR_USER_BUBBLE = '#1F6FEB'
export const COLOR_AI_BUBBLE = '#21262D'
export const COLOR_BUBBLE_USER_TEXT = '#FFFFFF'
export const COLOR_BUBBLE_AI_TEXT = '#E6EDF3'

// Borders & dividers
export const COLOR_BORDER = '#30363D'
export const COLOR_BORDER_FOCUS = '#58A6FF'
export const COLOR_DIVIDER = '#21262D'

// Status
export const COLOR_STATUS_ONLINE = '#3FB950'
export const COLOR_STATUS_OFFLINE = '#F85149'
export const COLOR_STATUS_WARNING = '#D29922'

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
export const SHADOW_CARD = { radius: 8, color: '#00000040', offsetY: 2 }
export const SHADOW_MODAL = { radius: 24, color: '#00000060', offsetY: 8 }
