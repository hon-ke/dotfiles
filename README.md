
# 简介


> 个人一直使用的hyprland配置文件,及相关脚本

写`install.sh`的目的是为了从刚安装好archlinux的终端界面开始一键配置好日常使用的配置



个人有很强的强迫症,绝对不多安一个额外的软件,删除也必须是彻彻底底


过去用过很多的窗口管理器,bspwm,i3,awesome,dwm,使用时间最长的是awesomewm,其次是dwm,最后尝试了一周左右的Hyprland之后就决定以后就是他了,


我对Hyprland的评价是: **Hyprland,满足你对窗口管理器的所有期待**


**预览**

github的图片显示一直都有点问题, preview下就是预览的图片


**目录结构**





```bash
## 完整目录结构说明
.
├── .config/                  # 用户应用程序配置
│   ├── alacritty             # 终端模拟器配置
│   ├── cava                  # 音频频谱可视化配置
│   ├── dunst                 # 桌面通知系统配置
│   ├── fcitx5                # 输入法框架配置
│   ├── hypr                  # Hyprland 窗口管理器配置
│   ├── nicoulaj.zsh-theme    # Zsh 主题文件
│   ├── nvim                  # Neovim 编辑器配置
│   ├── rofi                  # 应用启动器配置
│   ├── waybar                # 状态栏工具配置
│   └── yazi                  # 终端文件管理器配置
├── etc/                      # 系统级配置文件
│   ├── environment           # 全局环境变量设置
│   ├── fonts/                # 系统字体配置
│   ├── pacman.conf           # pacman 包管理器优化配置
│   ├── usr/                  # 用户级系统配置
│   └── vconsole.conf         # 虚拟控制台配置
├── grub/                     # GRUB 启动管理器主题
│   ├── dejavu_32.pf2         # 32px DejaVu 字体
│   ├── dejavu_sans_12.pf2    # 12px DejaVu Sans 字体
│   ├── dejavu_sans_14.pf2    # 14px DejaVu Sans 字体
│   ├── dejavu_sans_16.pf2    # 16px DejaVu Sans 字体
│   ├── dejavu_sans_24.pf2    # 24px DejaVu Sans 字体
│   ├── dejavu_sans_48.pf2    # 48px DejaVu Sans 字体
│   ├── moon.jpg              # GRUB 背景星空图
│   ├── selected_item_c.png   # 选中项指示器图标
│   ├── terminus-12.pf2       # 12px Terminus 终端字体
│   ├── terminus-14.pf2       # 14px Terminus 终端字体
│   ├── terminus-16.pf2       # 16px Terminus 终端字体
│   ├── terminus-18.pf2       # 18px Terminus 终端字体
│   └── theme.txt             # GRUB 主题配置文件
├── .zshrc                    # Zsh 配置文件
├── archinstall.json          # Archinstall 自动安装配置文件
├── pkgs.conf                 # 软件包列表配置文件
├── setup.sh                  # 主安装脚本
├── actions.sh                # 系统动作脚本
├── grub_setup.sh             # GRUB 主题安装脚本
├── zsh_setup.sh              # Zsh 配置安装脚本      
└── README.md                 # 项目说明文档

```

**.config 目录配置说明**

以下是用户配置文件目录的详细说明：

```bash
.config/
├── hypr/               # Hyprland 窗口管理器配置
│   ├── bg/             # 壁纸存储目录
│   ├── scripts/        # 自定义脚本目录
│   │   ├── bg_mp4.sh               # mpvpaper动态壁纸随机切换的脚本
│   │   ├── bg.sh                   # hyprpaper 随机切换壁纸
│   │   ├── ip.sh                   # 复制ip地址和IP的C段到剪切板工具
│   │   ├── reload.sh               # 重新加载hypeland配置
│   │   ├── screenshot.sh           # 几个工具组合实现的截屏标注
│   │   ├── starthypr.sh            # 启动hyprland的脚本（内涵很多环境变量）
│   │   ├── start-vmware.sh         # 启动vmware的脚本
│   │   ├── toggle-waybar.sh        # waybar动态显示/隐藏
│   │   └── update_dotfiles.sh      # 更新配置文件到指定文件（可以修改）
│   ├── exec.conf       # 自启动应用配置
│   ├── hypridle.conf   # 空闲行为配置
│   ├── hyprland.conf   # 核心配置文件
│   ├── hyprlock.conf   # 锁屏界面配置
│   ├── hyprpaper.conf  # 壁纸管理配置
│   ├── keybinds.conf   # 快捷键绑定
│   ├── plugins.conf    # 插件配置
│   └── rules.conf      # 窗口规则配置
├── rofi/               # 应用启动器配置
├── waybar/             # 状态栏配置
├── alacritty/          # 终端模拟器配置
├── cava/               # 音频可视化配置
├── dunst/              # 通知系统配置
├── fcitx5/             # 输入法配置
├── yazi/               # 文件管理器配置
├── nvim/               # Neovim 编辑器配置
└── nicoulaj.zsh-theme  # Zsh 自定义主题文件
```


# Usage

### 完整安装
```bash
# 1. 克隆仓库
git clone https://github.com/hon-ke/dotfiles.git
cd dotfiles

# 2. 运行主安装脚本
sudo ./setup.sh
```

#### 分步安装
```bash
# 安装基础软件包
# 需要先把setup.sh下的如下几行注释掉
# sh zsh_setup.sh
# sh grub_setup.sh
# sh actions.sh

sudo ./setup.sh

# 配置 Zsh
sudo ./zsh_setup.sh

# 配置 GRUB 主题
sudo ./grub_setup.sh

# 执行系统动作，最后执行整个
sudo ./actions.sh

```
# Keymap(快捷键绑定)

| 快捷键 | 功能描述 |
|--------|----------|
| SUPER + Enter | 打开终端 (Alacritty) |
| SUPER + SHIFT + Enter | 以 root 权限打开终端 |
| SUPER + Q | 关闭当前活动窗口 |
| SUPER + E | 打开文件管理器 (Yazi) |
| SUPER + Space | 切换窗口浮动状态 |
| SUPER + C | 打开浏览器 (Chrome) |
| SUPER + V | 打开 VSCode |
| SUPER + D | 打开应用启动器 (Rofi) |
| SUPER + T | 打开 Typora |
| SUPER + i | 显示 IP 信息 |
| SUPER + SHIFT + i | 显示 IP 信息并复制 |
| SUPER + F | 全屏当前窗口 |
| SUPER + P | 打开系统监控 (btop) |
| SUPER + SHIFT + P | 屏幕取色并复制到剪贴板 |
| SUPER + B | 切换 Waybar 显示状态 |
| SUPER + SHIFT + B | 切换壁纸 |
| SUPER + CONTROL + SHIFT + B | 切换动态壁纸 |
| SUPER + SHIFT + Q | 退出 Hyprland |
| SUPER + SHIFT + D | 锁屏 |
| SUPER + SHIFT + u | 更新 dotfiles 配置 |
| SUPER + SHIFT + r | 重新加载 Hyprland 配置 |
| SUPER + SHIFT + i | 打开系统监控 (bpytop) |
| SUPER + S | 切换特殊工作区 |
| SUPER + SHIFT + S | 移动窗口到特殊工作区 |
| CONTROL + ALT + A | 截屏 |
| SUPER + CONTROL + SHIFT + S | 关机 |
| SUPER + CONTROL + SHIFT + R | 重启 |
| XF86MonBrightnessUp | 增加屏幕亮度 |
| XF86MonBrightnessDown | 减少屏幕亮度 |
| XF86AudioRaiseVolume | 增加音量 |
| XF86AudioLowerVolume | 减少音量 |
| XF86AudioMicMute | 麦克风静音切换 |
| XF86AudioMute | 系统静音切换 |
| XF86AudioPlay | 播放/暂停媒体 |
| XF86AudioPause | 播放/暂停媒体 |
| XF86AudioNext | 播放下一曲 |
| XF86AudioPrev | 播放上一曲 |
| SUPER + ← | 向左移动焦点 |
| SUPER + → | 向右移动焦点 |
| SUPER + ↑ | 向上移动焦点 |
| SUPER + ↓ | 向下移动焦点 |
| SUPER + 1 | 切换到工作区 1 |
| SUPER + 2 | 切换到工作区 2 |
| SUPER + 3 | 切换到工作区 3 |
| SUPER + 4 | 切换到工作区 4 |
| SUPER + 5 | 切换到工作区 5 |
| SUPER + 6 | 切换到工作区 6 |
| SUPER + 7 | 切换到工作区 7 |
| SUPER + 8 | 切换到工作区 8 |
| SUPER + 9 | 切换到工作区 9 |
| SUPER + 0 | 切换到工作区 10 |
| SUPER + SHIFT + 1 | 移动窗口到工作区 1 |
| SUPER + SHIFT + 2 | 移动窗口到工作区 2 |
| SUPER + SHIFT + 3 | 移动窗口到工作区 3 |
| SUPER + SHIFT + 4 | 移动窗口到工作区 4 |
| SUPER + SHIFT + 5 | 移动窗口到工作区 5 |
| SUPER + SHIFT + 6 | 移动窗口到工作区 6 |
| SUPER + SHIFT + 7 | 移动窗口到工作区 7 |
| SUPER + SHIFT + 8 | 移动窗口到工作区 8 |
| SUPER + SHIFT + 9 | 移动窗口到工作区 9 |
| SUPER + SHIFT + 0 | 移动窗口到工作区 10 |
| SUPER + 鼠标滚轮下 | 切换到下一个工作区 |
| SUPER + 鼠标滚轮上 | 切换到上一个工作区 |
| SUPER + 鼠标左键拖动 | 移动窗口 |
| SUPER + 鼠标右键拖动 | 调整窗口大小 |
| SUPER + SHIFT + → | 增加窗口宽度 |
| SUPER + SHIFT + ← | 减少窗口宽度 |
| SUPER + SHIFT + ↑ | 减少窗口高度 |
| SUPER + SHIFT + ↓ | 增加窗口高度 |