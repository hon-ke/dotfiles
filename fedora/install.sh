#!/bin/bash
# =============================================
# 安装必要的软件包和配置
# =============================================

# 定义包含备注的关联数组（字典）
declare -A essential_packages
essential_packages["iwlwifi-QuZ-a0-hr-b0-77.ucode"]="iwlwifi firmware"
essential_packages["code"]="Visual Studio Code"
essential_packages["waybar"]="Status bar"
essential_packages["alacritty"]="Terminal emulator"
essential_packages["rofi"]="App Menu"
essential_packages["ibus"]="Input method framework"
essential_packages["wqy-zenhei-fonts"]="Chinese Font"
essential_packages["adobe-source-han-serif-cn-fonts"]="Adobe Source Han Serif Font"
essential_packages["noto-fonts-cjk"]="Noto CJK Font"
essential_packages["swaylock"]="Lock screen"
essential_packages["dunst"]="Notification daemon"
essential_packages["fcitx"]="Input method framework"
essential_packages["fcitx-pinyin"]="Chinese input method"
essential_packages["fcitx5-im"]="Fcitx5 input method"
essential_packages["fcitx5-configtool"]="Configuration tool for Fcitx5"
essential_packages["fcitx5-chinese-addons"]="Chinese add-ons for Fcitx5"
essential_packages["dejavu-fonts-all"]="DejaVu fonts"
essential_packages["git-core"]="Git version control"
essential_packages["zsh"]="Zsh shell"
essential_packages["unzip"]="Unzip utility"
essential_packages["zip"]="Zip utility"
essential_packages["v2ray"]="V2Ray client"
essential_packages["polkit"]="Polkit for permission management"
essential_packages["polkit-kde"]="KDE Polkit agent"
essential_packages["polkit-kde-agent"]="KDE Polkit agent"
essential_packages["lxpolkit"]="LXQt Polkit agent"
essential_packages["xwayland"]="XWayland support"

# 初始化
init_actions=(
    "mkdir -p \$HOME/data"
    "sudo mount /dev/sda1 \$HOME/data"
)

# 颜色输出
success() {
    echo -e "\e[32m[SUCCESS] $1\e[0m"
}

error() {
    echo -e "\e[31m[ERROR] $1\e[0m"
}

# 安装包及执行函数
install() {
    success "Installing '$1' list"
    local -n packages=$2 # 通过引用传递
    for package in "${!packages[@]}"; do
        echo "Installing $package: ${packages[$package]}"
        if [ "$package" == "code" ]; then
            # 特殊处理 Visual Studio Code
            sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
            echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
            sudo dnf install -y "$package"
        else
            # 依赖包安装
            sudo dnf install -y "$package"
        fi
    done
}

# 执行初始化操作
do_actions() {
    success "Executing initialization actions"
    for action in "${!init_actions[@]}"; do
        echo "Executing: ${init_actions[$action]}"
        eval "${init_actions[$action]}"
    done
}

# =============================================
# 执行逻辑
# =============================================
# logo
echo "Starting installation process..."

# 检查网络
if ! ping -c 1 google.com > /dev/null 2>&1; then
    error "Network is unreachable. Please check your connection."
    exit 1
fi

# 执行初始化
do_actions

# 安装各类软件包
install "Essential" essential_packages

# 额外配置
sudo cp "$HOME/data/hypr/etc/fonts/"* /etc/fonts/
sudo dnf install -y zsh-autosuggestions
chsh -s /usr/bin/zsh 
sudo dnf install -y v2ray
sudo dnf copr enable zhullyb/v2raya
curl -Ls https://mirrors.v2raya.org/go.sh | sudo bash
sudo dnf update -y

# 配置 VS Code 启动命令
sudo sed -i 's|Exec=/usr/bin/code|Exec=env GTK_IM_MODULE=fcitx5 QT_IM_MODULE=fcitx5 XMODIFIERS=@im=fcitx5 /usr/bin/code --enable-features=UseOzonePlatform --ozone-platform=wayland|g' /usr/share/applications/code.desktop

# 显示安装完成信息
success "All installations and configurations are complete. Please reboot your system."

# 重启系统
reboot

