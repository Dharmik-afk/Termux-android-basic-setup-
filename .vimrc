" ---------------- Basic Editor Settings ----------------
syntax on
set number
set relativenumber
set tabstop=2
set shiftwidth=2
set expandtab
set smartindent
set cursorline
set termguicolors
set background=dark
set encoding=utf-8
set clipboard=unnamedplus
set mouse=a
set ruler
set showcmd
set updatetime=300       " faster update time for plugins
filetype plugin indent on

" ---------------- Plugin Manager (vim-plug) ----------------
" Install vim-plug first:
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
"     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

call plug#begin('~/.vim/plugged')

" File Explorer
Plug 'preservim/nerdtree'

Plug 'junegunn/fzf.vim'

" Autocompletion & Language Support
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Status Line
Plug 'itchyny/lightline.vim'

" Syntax Highlighting, Languages
Plug 'sheerun/vim-polyglot'

" Colorscheme
Plug 'arcticicestudio/nord-vim'

" Additional niceties
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'nvim-lua/plenary.nvim'     " often required for newer plugins
" … you can add more later …

call plug#end()

" ---------------- Keymaps & Tweaks ----------------
" Toggle NERDTree
nmap <C-n> :NERDTreeToggle<CR>

" FZF file search
nmap <C-p> :Files<CR>

" CoC keymaps for autocomplete/navigation
inoremap <silent><expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"
nmap gd <Plug>(coc-definition)
nmap gr <Plug>(coc-references)
nmap gi <Plug>(coc-implementation)
" ==== CoC mappings ====
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Rename symbol
nmap <leader>rn <Plug>(coc-rename)

" Show docs in preview
nnoremap <silent> K :call CocActionAsync('doHover')<CR>

" Format file
nmap <leader>f :call CocAction('format')<CR>

" Set colorscheme
colorscheme nord

" Some additional settings for Vim in Termux
set clipboard+=unnamed        " ensure using system clipboard
" just extra for python 
autocmd FileType python setlocal expandtab shiftwidth=4 softtabstop=4
autocmd FileType cpp,c setlocal expandtab shiftwidth=2 softtabstop=2
