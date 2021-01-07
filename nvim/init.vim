set nocompatible
set nowrap
set encoding=utf8

call plug#begin('~/.vim/plugged')

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}

Plug 'rking/ag.vim'
Plug 'mattn/emmet-vim'
Plug 'cohama/lexima.vim'
Plug 'qpkorr/vim-bufkill'
Plug 'tpope/vim-surround'
Plug 'Yggdroot/indentLine'
Plug 'christoomey/vim-system-copy'
Plug 'terryma/vim-multiple-cursors'

Plug 'mhinz/vim-signify'
Plug 'tpope/vim-fugitive'
Plug 'APZelos/blamer.nvim'

Plug 'mhinz/vim-startify'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'Xuyuanp/nerdtree-git-plugin'

Plug 'neomake/neomake'

Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'ianks/vim-tsx'
Plug 'leafgarland/typescript-vim'
Plug 'jelera/vim-javascript-syntax'

Plug 'tpope/vim-rails'
Plug 'vim-ruby/vim-ruby'
Plug 'slim-template/vim-slim'

Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

Plug 'rafalbromirski/vim-aurora'
Plug 'liuchengxu/space-vim-theme'
Plug 'srcery-colors/srcery-vim'
Plug 'ryanoasis/vim-devicons'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

call plug#end()

" Configurations
"-------------------------------------------------------------------------------
syntax on

set nocompatible
set nowrap
scriptencoding utf-8
set encoding=utf-8

" vim hardcodes background color erase even if the terminfo file does
" not contain bce (not to mention that libvte based terminals
" incorrectly contain bce in their terminfo files). This causes
" incorrect background rendering when using a color theme with a
" background color.
let &t_ut=''

let g:python_host_prog = "/usr/bin/python"
let g:python3_host_prog = "/usr/bin/python3.8"

" Text Wrapper
set wrap
set linebreak

" Show linenumbers
set ruler
set number relativenumber
set numberwidth=3

" Always display the status line
set laststatus=2

" Enable Elite mode
let g:elite_mode=1

" Enable highlighting of the current line
set cursorline

" Enable mouse
set mouse=a

" Enable history and fix bug backspace
set backspace=indent,eol,start

" Turn off swapfile
set noswapfile
set nobackup
set nowb

" Change buffer without save
set hidden

" Set Proper Tabs
set list
set smartindent
set autoindent
set tabstop=2
set softtabstop=2
set shiftwidth=2
set smarttab
set expandtab
set listchars=eol:¬,tab:»-,space:.,trail:~

autocmd BufRead,BufWritePre *.go setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
autocmd BufRead,BufWritePre *.py setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab

set so=7
set title
set shortmess+=c

set clipboard=unnamedplus
set pastetoggle=<F12>

" Copy text from current cursor to end
nnoremap <Leader>y "*y
nnoremap <Leader>p "*p
nnoremap <Leader>Y "+y
nnoremap <Leader>P "+p


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

noremap <c-s> :w<CR>
inoremap <c-s> <Esc>:w<CR>l
vnoremap <c-s> <Esc>:w<CR>

" Command
" Relative number
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

" Remove trailing whitespace
autocmd BufWritePre * :%s/\s\+$//e

" Auto create non existing director
augroup Mkdir
  autocmd!
  autocmd BufWritePre *
        \ if !isdirectory(expand("%:p:h")) |
        \ call mkdir(expand("%:p:h"), "p") |
        \ endif
augroup END

autocmd FileType *.slim setlocal filetype=slim
autocmd FileType *.ts setlocal filetype=typescript
autocmd FileType *.tsx setlocal filetype=typescript.tsx
autocmd FileType typescript setlocal formatprg=prettier\ --parser\ typescript

autocmd BufNewFile, BufRead *.py
      \ set tabstop=4
      \ set softtabstop=4
      \ set shiftwidth=4

command! -nargs=0 Prettier :CocCommand prettier.formatFile

" Colorscheme
if (has("nvim"))
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif

if (has("termguicolors"))
  set termguicolors
endif

set t_Co=256
set background=dark

colorscheme aurora
" colorscheme space_vim_theme

" let g:srcery_bold=1
" let g:srcery_italic=1
" let g:srcery_dim_lisp_paren=1
" let g:srcery_inverse_matches=1
" let g:srcery_inverse_match_paren=1
" colorscheme srcery

"Airline Theme
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline_theme = 'simple'

"DevIcons
let g:webdevicons_enable = 1
let g:webdevicons_enable_ctrlp = 1
let g:webdevicons_enable_nerdtree = 1
let g:WebDevIconsUnicodeDecorateFolderNodes = 1
let g:DevIconsEnableFoldersOpenClose = 1

" CoC extensions
let g:coc_global_extensions = ['coc-tsserver',  'coc-css', 'coc-html', 'coc-json', 'coc-yaml', 'coc-prettier', 'coc-solargraph', 'coc-eslint', 'coc-python', 'coc-go', 'coc-snippets']

"Git-Blame
let g:blamer_enabled = 1

"NERDTree
map <C-n> :NERDTreeToggle<CR>
map <C-f> :NERDTreeFind<CR>
let g:NERDTreeShowHidden=1
let g:NERDTreeCaseSensitiveSort = 1
let g:NERDTreeGitStatusNodeColorization = 1
let g:NERDTreeDirArrowExpandable = '+'
let g:NERDTreeDirArrowCollapsible = '-'
let g:NERDTreeWinSize=45

"Nerdcommenter
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDDefaultAlign = 'left'
let g:NERDTrimTrailingWhitespace = 1
let g:NERDToggleCheckAllLines = 1

"CoC
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>":
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

autocmd BufWritePre *.go :call CocAction('runCommand', 'editor.action.organizeImport')

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

"Ag
let g:ag_working_path_mode="r"

"IndentLine
let g:indentLine_enabled = 1
let g:indentLine_char = '┆'
let g:indentLine_setColors = 1

"Multiple Cursor
let g:multi_cursor_use_default_mapping=0

let g:multi_cursor_start_word_key      = '<C-c>'
let g:multi_cursor_select_all_word_key = '<A-c>'
let g:multi_cursor_start_key           = 'g<C-c>'
let g:multi_cursor_select_all_key      = 'g<A-c>'
let g:multi_cursor_next_key            = '<C-c>'
let g:multi_cursor_prev_key            = '<C-p>'
let g:multi_cursor_skip_key            = '<C-x>'
let g:multi_cursor_quit_key            = '<Esc>'

"Emmet
let g:user_emmet_expandabbr_key = '<c-e>'
let g:use_emmet_complete_tag = 1

"Autoformat nad Prettier
autocmd FileType ruby :call Rubocop()
autocmd FileType javascript :call Prettier()

function! Rubocop()
  noremap <F5> :! rubocop --auto-correct % &>/dev/null<CR>
endfunction

function! Prettier()
  noremap <F5> :Prettier<CR>
endfunction

"Neomake
call neomake#configure#automake('rw')

" Disable inherited syntastic
let g:syntastic_mode_map = {
  \ "mode": "passive",
  \ "active_filetypes": [],
  \ "passive_filetypes": [] }

let g:neomake_serialize = 1
let g:neomake_serialize_abort_on_error = 1


if system("uname -r") =~ "microsoft"
  augroup Yank
    autocmd!
    autocmd TextYankPost * :call system('clip.exe ',@")
  augroup END
endif
