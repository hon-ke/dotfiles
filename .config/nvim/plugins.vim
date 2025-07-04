call plug#begin()

" file-tree
Plug 'scrooloose/nerdtree'
" icons
Plug 'ryanoasis/vim-devicons'
" background opticty
Plug 'xiyaowong/transparent.nvim'

" markdown
Plug 'plasticboy/vim-markdown'

" 代码补全，需要有nodejs
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'jiangmiao/auto-pairs'	" 括号等成对出现和删除

" themes
Plug 'Mofiqul/dracula.nvim'


call plug#end()
