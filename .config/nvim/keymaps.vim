" 基础快捷键
imap jk <Esc>
" nmap <SPACE> :
let mapleader = "<>"
nmap wq  :wq!<CR>
nmap ww  :w<CR>
nmap qq  :q!<CR>

" Nerd Tree快捷键
nnoremap <SPACE>n :NERDTreeFocus<CR>
" nnoremap <C-> :NERDTree<CR>
nnoremap <C-e> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>

" coc 代码补全
" 回车键确认第一项补全
inoremap <expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

" Tab 选择补全项
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" 跳转到定义/引用
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-references)

" 格式化代码
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" 重命名变量
nmap <leader>rn <Plug>(coc-rename)
