#!/bin/bash

# 定义颜色代码
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # 重置颜色

# 全局变量
interrupted=0                  # 用于跟踪是否被中断
DEFAULT_TIMEOUT=200            # 默认超时时间（秒）
MANAGER="paru"                 # 默认包管理器 (paru/pacman/yay)
RUN_AS_ROOT=0                  # 是否以 root 运行

# 处理Ctrl+C信号
handle_interrupt() {
    echo -e "\n${RED}[!] 检测到中断信号 (Ctrl+C)，正在退出...${NC}"
    interrupted=1
    exit 1
}

# 注册中断处理
trap handle_interrupt SIGINT

# 带超时的命令执行函数
run_with_timeout() {
    local cmd="$1"
    local timeout="$2"
    local error_file="$3"
    
    # 使用timeout命令执行，并捕获退出状态
    if timeout "$timeout" bash -c "$cmd" > /dev/null 2>"$error_file"; then
        return 0
    else
        local exit_code=$?
        if [ $exit_code -eq 124 ]; then
            # 超时退出状态码
            echo "命令执行超时 ($timeout秒)" > "$error_file"
        fi
        return $exit_code
    fi
}

# 检查包是否已安装
is_package_installed() {
    local pkg_name="$1"
    pacman -Q "$pkg_name" &>/dev/null
    return $?
}

# 构建安装命令
build_install_cmd() {
    local pkg_name="$1"
    
    # 特殊处理 archlinuxcn-keyring
    if [ "$pkg_name" == "archlinuxcn-keyring" ]; then
        if [ "$RUN_AS_ROOT" -eq 1 ]; then
            echo "pacman -Sy --noconfirm archlinuxcn-keyring"
        else
            echo "sudo pacman -Sy --noconfirm archlinuxcn-keyring"
        fi
        return
    fi
    
    if [ "$MANAGER" = "pacman" ]; then
        if [ "$RUN_AS_ROOT" -eq 1 ]; then
            echo "pacman -S --noconfirm $pkg_name"
        else
            echo "sudo pacman -S --noconfirm $pkg_name"
        fi
    elif [ "$MANAGER" = "yay" ]; then
        echo "yay -S --noconfirm $pkg_name"
    else  # 默认使用paru
        echo "paru -S --noconfirm --skipreview $pkg_name"
    fi
}

# 处理单个节
process_section() {
    local section_name="$1"
    local -a commands=("${!2}")
    local total_commands="${#commands[@]}"
    local index=1
    
    # 打印节标题
    echo -e "\n${CYAN}[*] 执行 '${section_name}' 命令 (使用 ${YELLOW}$MANAGER${CYAN})${NC}"
    
    for cmd_line in "${commands[@]}"; do
        # 检查是否被中断
        if [ $interrupted -eq 1 ]; then
            echo -e "${YELLOW}[!] 跳过剩余命令（用户中断）${NC}"
            return
        fi
        
        # 分离包名和注释
        local pkg_name="${cmd_line%%#*}"  # 移除注释部分
        local comment="${cmd_line#*#}"    # 提取注释
        
        # 清理空白字符
        pkg_name=$(echo "$pkg_name" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        comment=$(echo "$comment" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        
        # 跳过空行
        if [ -z "$pkg_name" ]; then
            continue
        fi
        
        # 初始显示"执行中"状态
        printf "[%d/%d] [${YELLOW}当前${NC}] %-50s ${GREEN}# %s${NC}" \
            "$index" "$total_commands" "$pkg_name" "$comment"
        # 立即刷新输出缓冲区
        /bin/echo -ne ""
        
        # 检查包是否已安装
        if is_package_installed "$pkg_name"; then
            # 清除当前行
            echo -ne "\r\033[K"
            printf "[%d/%d] [${GREEN}跳过${NC}] %-50s ${GREEN}# %s${NC}\n" \
                "$index" "$total_commands" "$pkg_name" "$comment"
            ((index++))
            continue
        fi
        
        # 更新状态为"安装中"
        echo -ne "\r\033[K"
        printf "[%d/%d] [${YELLOW}当前${NC}] %-50s ${GREEN}# %s${NC}" \
            "$index" "$total_commands" "$pkg_name" "$comment"
        /bin/echo -ne ""
        
        # 创建临时文件捕获错误输出
        local error_file
        error_file=$(mktemp)
        
        # 构建安装命令
        local install_cmd
        install_cmd=$(build_install_cmd "$pkg_name")
        
        # 执行命令并捕获结果
        if run_with_timeout "$install_cmd" "$DEFAULT_TIMEOUT" "$error_file"; then
            status="${GREEN}成功${NC}"
            # 清除当前行
            echo -ne "\r\033[K"
            printf "[%d/%d] [%b] %-50s ${GREEN}# %s${NC}\n" \
                "$index" "$total_commands" "$status" "$pkg_name" "$comment"
            # 删除临时文件
            rm -f "$error_file"
        else
            # 检查是否被中断
            if [ $interrupted -eq 1 ]; then
                echo -e "\n${RED}[!] 命令被中断: $pkg_name${NC}"
                rm -f "$error_file"
                return
            fi
            
            status="${RED}安装失败${NC}"
            # 读取错误信息
            local error_msg
            error_msg=$(<"$error_file")
            rm -f "$error_file"
            
            # 清除当前行
            echo -ne "\r\033[K"
            # 显示失败结果
            printf "[%d/%d] [%b] %-50s ${GREEN}# %s${NC}\n" \
                "$index" "$total_commands" "$status" "$pkg_name" "$comment"
            # 在下一行显示错误原因
            echo -e "${RED}错误信息: ${error_msg}${NC}"
        fi
        
        ((index++))
    done
}

# 主函数
pkginstall() {
    if [[ $# -ne 1 ]]; then
        echo "Usage: $0 <config-file>"
        exit 1
    fi

    local config_file="$1"
    local current_section=""
    local -a section_commands

    # 检查文件是否存在
    if [ ! -f "$config_file" ]; then
        echo -e "${RED}错误: 配置文件 $config_file 不存在${NC}"
        exit 1
    fi

    # 主循环处理配置文件
    while IFS= read -r line || [ -n "$line" ]; do
        # 检查是否被中断
        if [ $interrupted -eq 1 ]; then
            echo -e "${YELLOW}[!] 停止处理配置文件（用户中断）${NC}"
            exit 1
        fi
        
        # 移除行首行尾空白字符
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        
        # 跳过空行和纯注释行
        if [[ -z "$line" || "$line" =~ ^# ]]; then
            continue
        fi
        
        # 检测节标题
        if [[ "$line" =~ ^\[(.+)\]$ ]]; then
            # 处理已收集的节
            if [[ -n "$current_section" && ${#section_commands[@]} -gt 0 ]]; then
                process_section "$current_section" section_commands[@]
            fi
            
            # 检查是否被中断
            if [ $interrupted -eq 1 ]; then
                echo -e "${YELLOW}[!] 停止处理配置文件（用户中断）${NC}"
                exit 1
            fi
            
            # 开始新节
            current_section="${BASH_REMATCH[1]}"
            section_commands=()
        elif [[ -n "$current_section" ]]; then
            # 收集命令 - 跳过被注释掉的命令
            if ! [[ "$line" =~ ^\s*# ]]; then
                section_commands+=("$line")
            fi
        fi
    done < "$config_file"
    
    # 处理最后一个节
    if [[ -n "$current_section" && ${#section_commands[@]} -gt 0 ]]; then
        process_section "$current_section" section_commands[@]
    fi
}


setup(){
    # 设置包管理器 (直接修改变量即可)
    # 可选值: pacman, paru, yay
    MANAGER="paru"
    
    # 检查是否以 root 运行
    if [ "$(id -u)" -eq 0 ]; then
        RUN_AS_ROOT=1
        echo -e "${YELLOW}[!] 警告: 以 root 用户运行脚本${NC}"
        
        # 使用 AUR 助手时不能以 root 运行
        if [ "$MANAGER" != "pacman" ]; then
            echo -e "${RED}错误: 不能以 root 用户使用 $MANAGER${NC}"
            echo -e "${YELLOW}请以普通用户身份运行脚本${NC}"
            exit 1
        fi
    else
        RUN_AS_ROOT=0
    fi
    
    # 显示当前使用的包管理器
    echo -e "${CYAN}[*] ======================================${NC}"
    echo -e "${GREEN}[*] 使用包管理器: ${YELLOW}$MANAGER${NC}"
    # 显示当前用户状态
    if [ "$RUN_AS_ROOT" -eq 1 ]; then
        echo -e "${GREEN}[*] 运行身份: ${YELLOW}root${NC}"
    else
        echo -e "${GREEN}[*] 运行身份: ${YELLOW}$(whoami)${NC}"
    fi
    echo -e "${CYAN}[*] ======================================${NC}"
    
    # 特殊处理 archlinuxcn-keyring
    if ! is_package_installed "archlinuxcn-keyring"; then
        echo -e "${YELLOW}[*] 安装 archlinuxcn-keyring...${NC}"
        sudo pacman -Sy --noconfirm archlinuxcn-keyring
    fi
    

    pkginstall "pkgs.conf"
    sh zsh_setup.sh
    sh grub_setup.sh
    sh actions.sh
}

setup