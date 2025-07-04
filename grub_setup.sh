#!/bin/bash

# 简易版 Grub 主题安装脚本
ORIGIN_NAME="grub"
# 装在grub下面的主题名字
THEME_NAME="simple"
# 主题文件放在grub的哪里？
THEME_DIR="/boot/grub/themes"
# 默认的grub文件
GRUB_CONFIG="/etc/default/grub"

# 检查是否以root运行
if [ "$(id -u)" -ne 0 ]; then
    echo "请使用 sudo 或以 root 用户运行此脚本"
    exit 1
fi

# 检查主题文件是否存在
if [ ! -d "$ORIGIN_NAME" ]; then
    echo "错误: 在当前目录找不到主题文件夹: $ORIGIN_NAME"
    exit 1
fi

# 创建主题目录
echo "[-] 创建主题目录: $THEME_DIR/$THEME_NAME"
mkdir -p "$THEME_DIR/$THEME_NAME"

# 复制主题文件
echo "[-] 安装 $THEME_NAME 主题..."
cp -r "$ORIGIN_NAME"/* "$THEME_DIR/$THEME_NAME/"

# 备份原始配置
echo "[-] 备份 Grub 配置..."
cp "$GRUB_CONFIG" "${GRUB_CONFIG}.bak"

# 更新 Grub 配置
echo "[-] 设置 $THEME_NAME 为默认主题..."
sed -i '/GRUB_THEME=/d' "$GRUB_CONFIG"
echo "GRUB_THEME=\"$THEME_DIR/$THEME_NAME/theme.txt\"" >> "$GRUB_CONFIG"

# 更新 Grub
echo "[-] 更新 Grub 配置..."
if command -v update-grub >/dev/null; then
    update-grub
elif command -v grub-mkconfig >/dev/null; then
    grub-mkconfig -o /boot/grub/grub.cfg
else
    echo "警告: 找不到 update-grub 或 grub-mkconfig 命令"
    echo "请手动运行 grub-mkconfig 更新配置"
fi

echo "[-] 安装完成! 请重启查看效果"
