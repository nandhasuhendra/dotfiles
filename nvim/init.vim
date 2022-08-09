set nocompatible
set nowrap
set encoding=utf8

call plug#begin('~/.vim/plugged')

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'rking/ag.vim'
Plug 'mattn/emmet-vim'
Plug 'cohama/lexima.vim'
Plug 'qpkorr/vim-bufkill'
Plug 'tpope/vim-surround'
Plug 'hsanson/vim-openapi'
Plug 'liuchengxu/vista.vim'
Plug 'christoomey/vim-system-copy'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
Plug 'SergioRibera/vim-screenshot', { 'do': 'npm install --prefix Renderizer' }

Plug 'mhinz/vim-signify'
Plug 'tpope/vim-fugitive'
Plug 'APZelos/blamer.nvim'

Plug 'mhinz/vim-startify'
Plug 'scrooloose/nerdcommenter'
Plug 'francoiscabrol/ranger.vim'
Plug 'rbgrouleff/bclose.vim'

Plug 'neomake/neomake'

Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'ianks/vim-tsx'
Plug 'jelera/vim-javascript-syntax'

Plug 'tpope/vim-rails'
Plug 'vim-ruby/vim-ruby'
Plug 'slim-template/vim-slim'

Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

Plug 'nandhasuhendra/vim-aurora'
Plug 'tanvirtin/monokai.nvim'
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

let g:python_host_prog = "/usr/bin/python2.7"
let g:python3_host_prog = "/usr/local/bin/python3.9"

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
inoremap <C-BS> <C-\><C-o>dB

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

set so=7
set title
set shortmess+=c

set clipboard=unnamedplus
set guicursor=a:Cursor-blinkwait700-blinkon400-blinkoff250
set rtp+=/usr/local/opt/fzf

" Folding
autocmd FileType * setlocal foldmethod=indent
set foldlevel=99
set fillchars=fold:\ "The backslash escapes a space
set foldtext=CustomFoldText()
function! CustomFoldText()
  let indentation = indent(v:foldstart - 1)
  let foldSize = 1 + v:foldend - v:foldstart
  let foldSizeStr = " " . foldSize . " lines "
  let foldLevelStr = repeat("+--", v:foldlevel)
  let expansionString = repeat(" ", indentation)
  return expansionString . foldLevelStr . foldSizeStr
endfunction

highlight Folded ctermfg=14 ctermbg=242 guifg=Cyan guibg=DarkGrey

" Copy text from current cursor to end
nnoremap <Leader>y "*y
nnoremap <Leader>p "*p
nnoremap <Leader>Y "+y
nnoremap <Leader>P "+p

" Switch buffer
map <PageUp> :bp<cr>
map <PageDown> :bn<cr>
map <C-x> :BD<cr>

" Ranger
let g:ranger_replace_netrw = 1
let g:ranger_map_keys = 0
map <C-e> :Ranger<CR>

" Find files using fzf
let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.5, 'highlight': 'Comment' } }
nnoremap <silent> <C-p> :Files<CR>
nnoremap <silent> <C-f> :BLines<CR>
nnoremap <silent> <Leader>b :Buffers<CR>
nnoremap <silent> <Leader>c :Commits<CR>

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

" Remap CTRL-S for saving file instead
noremap <C-S> :w<CR>
inoremap <C-S> <Esc>:w<CR>
vnoremap <C-S> <Esc>:w<CR>

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
autocmd BufNewFile,BufRead *.py setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
autocmd BufNewFile,BufRead *.go setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
autocmd BufRead,BufWritePre *.go :silent call CocAction('runCommand', 'editor.action.organizeImport')
autocmd BufNewFile,BufRead *.rb nnoremap <buffer> <F5> :! rubocop --auto-correct % &>/dev/null<CR>
autocmd BufNewFile,BufRead *.ts,*.tsx,*js,*.jsx,*.css,*.scss nnoremap <buffer> <F5> :Prettier<CR>

command! -nargs=0 Prettier :CocCommand prettier.formatFile

" Colorscheme
if (has("termguicolors"))
  set termguicolors
endif

if (has("nvim"))
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif

set t_Co=256
set background=dark

" colorscheme aurora
colorscheme monokai_soda
" let g:airline_theme = 'dark'

"Airline Theme
let g:airline_symbols_ascii = 1
let g:airline_stl_path_style = 'long'
" let g:airline_powerline_fonts = 1
" let g:airline#extensions#tabline#enabled = 1
" let g:airline#extensions#tabline#formatter = 'unique_tail'

" CoC extensions
let g:coc_global_extensions = [
      \ 'coc-tsserver',
      \ 'coc-css',
      \ 'coc-html',
      \ 'coc-json',
      \ 'coc-yaml',
      \ 'coc-prettier',
      \ 'coc-solargraph',
      \ 'coc-python',
      \ 'coc-go',
      \ 'coc-snippets',
      \ 'coc-vetur',
      \ 'coc-swagger']

" Git-Blame
let g:blamer_enabled = 1

"Nerdcommenter
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDDefaultAlign = 'left'
let g:NERDTrimTrailingWhitespace = 1
let g:NERDToggleCheckAllLines = 1
nmap <C-_> <leader>c<Space>
vmap <C-_> <leader>c<Space>

"CoC
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Vista toggle
nmap <F12> :Vista!!<CR>
let g:vista_icon_indent = ["╰─▸ ", "├─▸ "]
let g:vista_default_executive = 'coc'
let g:vista_fzf_preview = ['right:50%']
let g:vista#renderer#enable_icon = 1
let g:vista#renderer#icons = {
\   "function": "\uf794",
\   "variable": "\uf71b",
\  }

"Ag
let g:ag_working_path_mode="r"

"Indent Blankline
let g:indent_blankline_use_treesitter = v:true
" let g:indent_blankline_char_highlight_list = ['Special', 'PreProc', 'Structure', 'Function', 'Statement']

"Emmet
let g:user_emmet_expandabbr_key = '<c-e>'
let g:use_emmet_complete_tag = 1

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
