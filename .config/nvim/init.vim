" 基础配置
set nu
set encoding=UTF-8
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

" 加载所有子配置文件
source $HOME/.config/nvim/plugins.vim
source $HOME/.config/nvim/keymaps.vim

" 加载插件的配置文件
source $HOME/.config/nvim/conf/nerdtree.vim

"autocmd VimEnter * NERDTree " 自动打开NERDTree
let g:dracula_transparent_bg = 0.5  " 启用透明背景
colorscheme dracula
