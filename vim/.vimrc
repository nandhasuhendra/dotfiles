" .Vimrc Script
"-------------------------------------------------------------------------------
" default
set nocompatible
set nowrap
set encoding=utf8

syntax on
filetype off

"-------------------------------------------------------------------------------
" Vundle Plugin
"-------------------------------------------------------------------------------
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

"-------------------------------------------------------------------------------
" List
"-------------------------------------------------------------------------------
" Plugin Vundle (required)
Plugin 'VundleVim/Vundle.vim'

" Utilities --------------------------------------------------------------------
set rtp+=/usr/bin/fzf
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'

Plugin 'w0rp/ale'
Plugin 'rking/ag.vim'
Plugin 'mattn/emmet-vim'
Plugin 'majutsushi/tagbar'
Plugin 'ervandew/supertab'
Plugin 'cohama/lexima.vim'
Plugin 'qpkorr/vim-bufkill'
Plugin 'tpope/vim-surround'
Plugin 'Yggdroot/indentLine'
Plugin 'scrooloose/nerdtree'
Plugin 'sheerun/vim-polyglot'
Plugin 'Shougo/neocomplete.vim'
Plugin 'christoomey/vim-system-copy'
Plugin 'terryma/vim-multiple-cursors'

" Git --------------------------------------------------------------------------
Plugin 'mhinz/vim-signify'
Plugin 'tpope/vim-fugitive'
Plugin 'zivyangll/git-blame.vim'
Plugin 'Xuyuanp/nerdtree-git-plugin'

" YAML -------------------------------------------------------------------------
Plugin 'chase/vim-ansible-yaml'

" Ruby -------------------------------------------------------------------------
Plugin 'tpope/vim-rails'
Plugin 'vim-ruby/vim-ruby'
Plugin 'slim-template/vim-slim'
Plugin 'mustache/vim-mustache-handlebars'

" Javascript -------------------------------------------------------------------
Plugin 'pangloss/vim-javascript'

" Themes / Interfaces ----------------------------------------------------------
Plugin 'mhartington/oceanic-next'
Plugin 'srcery-colors/srcery-vim'
Plugin 'ryanoasis/vim-devicons'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

call vundle#end()
filetype plugin indent on 

"-------------------------------------------------------------------------------
" Configurations
"-------------------------------------------------------------------------------
syntax on

" Text Wrapper -----------------------------------------------------------------
set wrap
set linebreak

" Show linenumbers -------------------------------------------------------------
set ruler
set number relativenumber
set numberwidth=3

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

" Set Proper Tabs -------------------------------------------------------------
set list
set smartindent
set autoindent
set tabstop=2
set shiftwidth=2
set smarttab
set expandtab
set listchars=eol:¬,tab:--

" Always display the status line -----------------------------------------------
set laststatus=2

" Enable Elite mode ------------------------------------------------------------
let g:elite_mode=1

" Enable highlighting of the current line --------------------------------------
set cursorline

" Enable mouse -----------------------------------------------------------------
set mouse=a

" Enable history and fix bug backspace -----------------------------------------
set backspace=indent,eol,start

" Turn off swapfile ------------------------------------------------------------
set noswapfile
set nobackup
set nowb

" Change buffer without save ---------------------------------------------------
set hidden

"------------ Theme
set termguicolors
set t_Co=256
set background=dark
let g:srcery_italic = 1
colorscheme srcery

"------------ Airline Theme
let g:airline_theme = 'simple'
let g:airline_highlighting_cache = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#tabline#left_alt_sep = '|'

"------------ DevIcons
let g:webdevicons_enable = 1
let g:webdevicons_enable_ctrlp = 1
let g:webdevicons_enable_nerdtree = 1
let g:WebDevIconsUnicodeDecorateFolderNodes = 1
let g:DevIconsEnableFoldersOpenClose = 1

"------------- ALE
let g:ale_sign_error = '=>'
let g:ale_sign_warning = '->'
let g:ale_echo_msg_error_str = 'ERROR'
let g:ale_echo_msg_warning_str = 'WARNING'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let b:ale_fixers = { 'javascript': ['prettier', 'eslint'], 'ruby': ['rubocop'], 'python': ['pylint'] }

"------------- IndentLine
let g:indentLine_enabled = 1
let g:indentLine_char = '|'

"------------- Ag
let g:ag_working_path_mode="r"

"------------- Emmet
let g:user_emmet_expandabbr_key = '<c-e>'
let g:use_emmet_complete_tag = 1

"------------- SuperTab
let g:SuperTabDefaultCompletionType = "<c-n>"

" ---------- Git-Blame
nnoremap <Leader>s :<C-u>call gitblame#echo()<CR>

"-----------  NERDTree
map <C-n> :NERDTreeToggle<CR>
map <C-f> :NERDTreeFind<CR>
let g:NERDTreeShowHidden=1
let g:NERDTreeCaseSensitiveSort = 1
let g:NERDTreeGitStatusNodeColorization = 1
let g:NERDTreeDirArrowExpandable = '+'
let g:NERDTreeDirArrowCollapsible = '-'
let g:NERDTreeWinSize=45

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif

"------------ Neocomplete Settings
let g:acp_enableAtStartup = 1
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1
let g:neocomplete#sources#syntax#min_keyword_length = 3

" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
  let g:neocomplete#keyword_patterns = {}
endif

if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif

let g:neocomplete#keyword_patterns['default'] = '\h\w*'

autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab indentkeys-=0# indentkeys-=<:>

autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete
autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
autocmd FileType ruby,eruby let g:rubycomplete_rails = 1
autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
autocmd FileType *.slim setlocal filetype=slim

"------------ Multiple Cursor
let g:multi_cursor_use_default_mapping=0

" Default mapping
let g:multi_cursor_start_word_key      = '<C-c>'
let g:multi_cursor_select_all_word_key = '<A-c>'
let g:multi_cursor_start_key           = 'g<C-c>'
let g:multi_cursor_select_all_key      = 'g<A-c>'
let g:multi_cursor_next_key            = '<C-c>'
let g:multi_cursor_prev_key            = '<C-p>'
let g:multi_cursor_skip_key            = '<C-x>'
let g:multi_cursor_quit_key            = '<Esc>'

" Key Mapping --------------------------------------------------------------------
" Copy text from current cursor to end
nnoremap Y y$

" Open TagBar
nmap <F12> :TagbarToggle<CR>

" Jump to start and end of text and file
nnoremap { ^
nnoremap + 0
nnoremap } $
nnoremap - gg
nnoremap _ G

" Switch buffer
map <F1> :bp<cr>
map <F2> :bn<cr>
map <F3> :BD<cr>

" Switch buffer with specific buffer
nnoremap <F4> :buffers<CR>:buffer<Space>

" Find files using fzf
nnoremap <C-p> :Files<CR>

" Disable Arrow
inoremap <left> <nop>
inoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>

" Disable arrow movement, resize splits instead.
if get(g:, 'elite_mode')
  nnoremap <Up>    :resize -2<CR>
  nnoremap <Down>  :resize +2<CR>
  nnoremap <Left>  :vertical resize -2<CR>
  nnoremap <Right> :vertical resize +2<CR>
endif
