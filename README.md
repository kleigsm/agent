# VBconnect Agent —— 移动端编程智能体

运行在 HarmonyOS 设备上的 AI 编程助手，通过 WebSocket 连接 PC 端 Bridge 服务，远程操控 Claude CLI 执行代码编写、文件管理、编译构建、终端命令等任务。

---

## 三模块生态

| 模块 | 仓库 | 定位 |
|------|------|------|
| **VBconnect Agent** | 本仓库 | 鸿蒙手机端编程智能体 App |
| **Bridge** | [bridge](https://github.com/kleigsm/bridge) | PC 端 Node.js 桥接服务 |
| **VBDog** | [vbdog](https://github.com/kleigsm/vbdog) | AI Prompt 社交社区 |

数据流：手机输入自然语言 -> Agent WebSocket -> Bridge -> Claude CLI -> 流式返回手机

---

## 功能模块（6 个 Tab）

### 对话 Chat
- 气泡式 UI + WebSocket 流式响应 + Markdown 渲染（代码块深色背景+复制 / 行内代码橙色高亮）
- 多会话管理（新建/切换/重命名/删除，DataStore 持久化）
- 8 个快捷指令：构建 / 运行 / 测试 / 日志 / 检查 / 结构 / 修复 / 解释，4 列网格一键发送

### 文件 Files
- 目录浏览 + 面包屑导航 + Git 状态标记（M 橙色 / A 绿色 / D 红色 / ?? 灰色）
- Git Diff 对比（绿色+行 / 红色-行高亮）+ 行内编辑（<50KB 文件）

### 终端 Terminal
- 命令输入 + 实时输出（仿真终端 #1D1D1F 底色）+ 命令历史回溯（100 条）

### 编译 Build
- 4 个预设 Hvigor 命令 + 进度条 + 彩色日志（红/黄/绿）
- 编译失败一键 AI 修复 + 跨 Tab 完成通知横幅

### 仪表盘 Dashboard
- Git 分支 + 文件变更状态 + 最近 5 次 commit

### 设置 Settings
- 服务器地址/Token 配置 + UDP 设备发现 + 深色模式 Toggle
- 启动自动连接 + 连接延迟显示（ms）

---

## 技术栈

| 层 | 技术 |
|---|------|
| 框架 | HarmonyOS ArkTS / ArkUI |
| 架构 | MVVM（6 ViewModel + 6 Page）|
| 通信 | WebSocket（单例 SocketManager，心跳+重连）|
| 渲染 | 自研 MarkdownRenderer |
| 存储 | DataStore |
| 发现 | UDP 广播（3001 端口）|

---

## 项目结构

`
entry/src/main/ets/
├── common/
│   ├── SocketManager.ets      # WebSocket 连接管理（单例）
│   ├── MarkdownRenderer.ets   # Markdown 解析渲染
│   ├── DiscoveryManager.ets   # UDP 设备发现
│   └── Models.ets / Constants.ets
├── viewmodel/
│   ├── ChatViewModel.ets / FilesViewModel.ets
│   ├── TerminalViewModel.ets / BuildViewModel.ets
│   ├── DashboardViewModel.ets
│   └── SessionManager.ets / SettingsViewModel.ets
└── pages/
    ├── Index.ets（6 Tab）/ ChatPage.ets / FilesPage.ets
    ├── TerminalPage.ets / BuildPage.ets
    └── DashboardPage.ets / SettingsPage.ets
`

---

## 开发日志

- 06.13-15：初始 UI（气泡/流式/Markdown/深色主题/毛玻璃/Tab 导航）
- 06.16-17：快捷指令面板 / 搜索 / 代码复制 / Toast 提示
- 06.24：多会话 / 编译进度 / 仪表盘 / 深色全局适配 / Diff 对比 / 行内编辑
- 06.25：跨 Tab 通知 / 命令历史 / 连接延迟 / Git 标记 / 自动连接
- 06.26：语音输入占位 / 收尾整理

---

> 作者：高晟铭（202421332087）· 软件 2413 · 移动软件开发实践 · 2026.06
