# MacTVBox 架构与设计规范

## 项目概览
MacTVBox 是专为 macOS 设计的家庭电视盒子软件（10-foot UI），旨在让 Mac mini 或连接到客厅电视的 Mac 变身为沉浸式电视盒子。
界面全面参考 **Apple TV (tvOS)** 设计语言，支持**自动识别电脑中已安装的 macOS 软件**，并提供全功能 **Xbox 手柄**无键鼠交互体验。

## 目录结构
```
MacTVBox/
├── CLAUDE.md                      # 架构规范与说明
├── Package.swift                  # Swift Package Manager 工程定义
├── README.md                      # 使用说明与手柄配对指南
├── Sources/
│   └── MacTVBox/
│       ├── App/
│       │   ├── MacTVBoxApp.swift          # 应用主入口与根状态路由
│       │   └── WindowController.swift     # 全屏窗口控制与防止系统息屏休眠
│       ├── Core/
│       │   ├── Input/
│       │   │   ├── GamepadManager.swift   # Xbox 手柄连接监听与按键映射
│       │   │   └── FocusAction.swift      # 手柄虚拟按键动作抽象
│       │   ├── Focus/
│       │   │   └── FocusCoordinator.swift # 二维空间网格焦点与状态机
│       │   ├── Discovery/
│       │   │   └── AppScanner.swift       # 电脑本地 macOS 安装应用智能发现引擎
│       │   └── Media/
│       │       ├── Channel.swift          # 预置在线流媒体渠道 (B站、腾讯、抖音等)
│       │       └── LauncherItem.swift     # 统一启动项抽象 (流媒体 vs 本地应用)
│       ├── WebAdapters/
│       │   ├── WebAdapter.swift           # 网页适配注入协议
│       │   ├── AdapterFactory.swift       # 适配器工厂
│       │   ├── BilibiliAdapter.swift      # B站大屏CSS与快捷键拦截注入
│       │   ├── TencentVideoAdapter.swift  # 腾讯视频全屏与控制注入
│       │   └── DouyinAdapter.swift        # 抖音手柄刷短视频注入
│       └── Views/
│           ├── LauncherView.swift         # Apple TV 风格主屏 (Top Shelf + Grid)
│           ├── TopShelfView.swift         # tvOS 标志性顶部展架沉浸式视差海报
│           ├── AppCardView.swift          # tvOS 3D 呼吸焦点卡片组件
│           ├── WebContainerView.swift     # WebKit 播放器容器
│           └── OverlayHUDView.swift       # Xbox 手柄键位指引 HUD
```

## 核心设计原则
1. **Apple TV 沉浸式视差质感 (tvOS Aesthetics)**：
   - **Top Shelf**：随手柄焦点动态切换背景海报、剧集标签与功能简介。
   - **Focus Ring**：卡片在获得 Xbox 焦点时光晕缩放、加粗白色轮廓光并投射深层阴影。
2. **本地与在线双模生态**：
   - **在线流媒体**：内置 Bilibili、腾讯视频、抖音等专属适配器与按键接管。
   - **本地 macOS 软件**：通过 `AppScanner` 自动发现 `/Applications` 中的本地 App（如 IINA, VLC, 网易云, Steam），原生无缝拉起。
3. **纯焦点驱动（Focus-Driven 2D Navigation）**：
   - 摇杆/十字键支持行与列（上下左右）平滑移动。
   - `A 键`：确认启动/播放暂停；`B 键`：退出返回；`Y 键`：唤起键位 HUD。
4. **硬件与电源保障**：
   - IOKit 断言防止看剧休眠，全屏启动并自动隐匿鼠标光标。
