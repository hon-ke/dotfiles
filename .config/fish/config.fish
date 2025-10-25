if status is-interactive
    # Commands to run in interactive sessions can go here
    pokemon-colorscripts -r -s --no-title 2>/dev/null; or true
end

# 取消欢迎语句
set -U fish_greeting ""

# 环境变量
set -gx EDITOR nvim
set -gx BG_PATH /data/bg/img
set -gx DOTFILES /data/dotfiles

# PATH 设置
fish_add_path $HOME/.config/self/script/
fish_add_path $HOME/.config/self/bin/

# 别名设置
if command -q eza
    alias ls='eza --icons'
    alias la='eza -la --icons'
    alias ll='eza -ll --icons'
    alias lt='eza --tree --icons'
else
    alias ls='ls --color=auto'
    alias la='ls -la --color=auto'
    alias ll='ls -l --color=auto'
end

# 设置编辑器命令
if command -q nvim && test -f "$SELF/script/nvim-nopadding.sh"
    set NVIM_CMD "$SELF/script/nvim-nopadding.sh"
else if command -q nvim
    set NVIM_CMD "nvim"
else
    set NVIM_CMD "vim"
end

alias nvim="$NVIM_CMD"
alias vim="$NVIM_CMD"

alias grep='grep --color=auto'
alias gdd='cd ~/Downloads'
alias ddd='cd $DOTFILES'
alias ccc='cd $HOME/.config'
alias y="yazi"
alias h="Hyprland"
alias o="xdg-open"
alias q="sudo pacman -Rns (pacman -Qdtq)"
alias active="source $HOME/.venv/bin/activate"
alias pyy="sudo pacman -Syy"
alias pyu="sudo pacman -Syu"
# 其他工具
# pokemon-colorscripts -r -s --no-title 2>/dev/null; or true
