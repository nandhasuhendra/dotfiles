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
Plug 'liuchengxu/vista.vim'
Plug 'christoomey/vim-system-copy'
Plug 'terryma/vim-multiple-cursors'
Plug 'lukas-reineke/indent-blankline.nvim'

Plug 'mhinz/vim-signify'
Plug 'tpope/vim-fugitive'
Plug 'APZelos/blamer.nvim'

Plug 'glepnir/dashboard-nvim'
Plug 'scrooloose/nerdcommenter'
Plug 'kyazdani42/nvim-tree.lua'

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
Plug 'vim-airline/vim-airline'
Plug 'kyazdani42/nvim-web-devicons'
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
let g:python3_host_prog = "/usr/bin/python3.9"

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

" Copy text from current cursor to end
nnoremap <Leader>y "*y
nnoremap <Leader>p "*p
nnoremap <Leader>Y "+y
nnoremap <Leader>P "+p

" Switch buffer
map <PageUp> :bp<cr>
map <PageDown> :bn<cr>
map <C-x> :BD<cr>

" Find files using fzf
let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.5, 'highlight': 'Comment' } }
nnoremap <silent> <C-p> :Files<CR>
nnoremap <silent> <leader>b :Buffers<CR>
nnoremap <silent> <Leader>f :Rg<CR>
nnoremap <silent> <Leader>/ :BLines<CR>
nnoremap <silent> <Leader>' :Marks<CR>
nnoremap <silent> <Leader>g :Commits<CR>

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
autocmd BufRead,BufWritePre *.go :call CocAction('runCommand', 'editor.action.organizeImport')
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

colorscheme aurora

"Airline Theme
let g:airline_theme = 'simple'
let g:airline_symbols_ascii = 1
let g:airline_stl_path_style = 'long'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'

" CoC extensions
let g:coc_global_extensions = ['coc-tsserver',  'coc-css', 'coc-html', 'coc-json', 'coc-yaml', 'coc-prettier', 'coc-solargraph', 'coc-python', 'coc-go', 'coc-snippets']

" Git-Blame
let g:blamer_enabled = 1

" Dashboard
let g:dashboard_default_executive = 'fzf'

" NvimTree
let g:nvim_tree_width = 40
let g:nvim_tree_ignore = [ '.git', 'node_modules', '.cache' ]
let g:nvim_tree_gitignore = 1
let g:nvim_tree_auto_open = 1
let g:nvim_tree_auto_ignore_ft = [ 'startify', 'dashboard' ]
let g:nvim_tree_indent_markers = 1
let g:nvim_tree_git_hl = 1
let g:nvim_tree_highlight_opened_files = 1
let g:nvim_tree_root_folder_modifier = ':~'
let g:nvim_tree_tab_open = 1
let g:nvim_tree_add_trailing = 1
let g:nvim_tree_group_empty = 1
let g:nvim_tree_disable_window_picker = 1
let g:nvim_tree_hijack_cursor = 0
let g:nvim_tree_icon_padding = ' '
let g:nvim_tree_update_cwd = 1
let g:nvim_tree_icons = {
    \ 'default': '',
    \ 'symlink': '',
    \ 'git': {
    \   'unstaged': "✗",
    \   'staged': "✓",
    \   'unmerged': "",
    \   'renamed': "➜",
    \   'untracked': "★",
    \   'deleted': "",
    \   'ignored': "◌"
    \   },
    \ 'folder': {
    \   'arrow_open': "",
    \   'arrow_closed': "",
    \   'default': "",
    \   'open': "",
    \   'empty': "",
    \   'empty_open': "",
    \   'symlink': "",
    \   'symlink_open': "",
    \   },
    \   'lsp': {
    \     'hint': "",
    \     'info': "",
    \     'warning': "",
    \     'error': "",
    \   }
    \ }

nnoremap <C-n> :NvimTreeToggle<CR>
nnoremap <C-f> :NvimTreeFindFile<CR>

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
let g:vista#renderer#enable_icon = 1
let g:vista#renderer#icons = {
\   "function": "\uf794",
\   "variable": "\uf71b",
\  }

"Ag
let g:ag_working_path_mode="r"

"Indent Blankline
let g:indent_blankline_use_treesitter = v:true
let g:indent_blankline_char_highlight_list = ['Special', 'PreProc', 'Structure', 'Function', 'Statement']

"Multiple Cursor
let g:multi_cursor_use_default_mapping = 0
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
