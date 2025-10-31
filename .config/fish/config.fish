if status is-interactive
    # Commands to run in interactive sessions can go here
    pokemon-colorscripts -r -s --no-title 2>/dev/null; or true
end

# 取消欢迎语句
set -U fish_greeting ""

# 环境变量
set -Ux GIT_CONFIG_GLOBAL "$HOME/.config/git/config"
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
if command -q nvim && test -f "$HOME/.config/self/script/nvim-nopadding.sh"
    # Fish 使用 command -q 来检查命令是否存在
    # && 用于逻辑与操作
    set NVIM_CMD "$HOME/.config/self/script/nvim-nopadding.sh"
else if command -q nvim
    set NVIM_CMD "nvim"
else
    set NVIM_CMD "vim"
end

alias nvim="$NVIM_CMD"
alias vim="$NVIM_CMD"
alias nv="$NVIM_CMD"

alias grep='grep --color=auto'
alias gdd='cd ~/Downloads'
alias ddd='cd $DOTFILES'
alias ccc='cd $HOME/.config'

alias gi="git init"
alias gs="git status"
alias syy="sudo pacman -Syy"
alias syu="sudo pacman -Syu"

alias y="yazi"
alias h="Hyprland > .hypr.log"
alias o="xdg-open"
alias q="sudo pacman -Rns (pacman -Qdtq)"

# 重新加载 Fish 配置
function rsf
    source "$HOME/.config/fish/config.fish"
end

# 激活虚拟环境
function active
    bash -c "source $HOME/.venv/bin/activate; exec fish"
end
