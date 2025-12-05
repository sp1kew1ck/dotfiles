" If you open this file in Vim, it'll be syntax highlighted for you.

" Vim is based on Vi. Setting `nocompatible` switches from the default
" Vi-compatibility mode and enables useful Vim functionality. This
" configuration option turns out not to be necessary for the file named
" '~/.vimrc', because Vim automatically enters nocompatible mode if that file
" is present. But we're including it here just in case this config file is
" loaded some other way (e.g. saved as `foo`, and then Vim started with
" `vim -u foo`).
set nocompatible

" ================ basic config ================

syntax on " Turn on syntax highlighting.
set showmode
set showcmd

" Enable mouse support. You should avoid relying on this too much, but it can
" sometimes be convenient.
set mouse+=a
set encoding=utf-8
set t_Co=256

" Enable file type detection and auto-indentation support. When editing .py files, 
" Vim will look for Python's indentation rules in ~/.vim/indent/python.vim.
filetype plugin indent on 

" Disable the default Vim startup message.
set shortmess+=I

" Supports redrawing to improve performance
set ttyfast
set lazyredraw

" ================ indent ================

" Use spaces instead of tabs
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent

" ================ number, cursor, display ================

" Show line numbers.
set number

" This enables relative line numbering mode. With both number and
" relativenumber enabled, the current line shows the true line number, while
" all other lines (above and below) are numbered relative to the current line.
" This is useful because you can tell, at a glance, what count is needed to
" jump up or down to a particular line, by {count}k to go up or {count}j to go
" down.
set relativenumber

" Insert mode uses absolute line numbers
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END

" Highlight the current row
set cursorline

" Displays automatic line wrapping, without inserting newline characters.
set wrap
" The number of blank characters between the line break and the right edge of the editing window.
set wrapmargin=2
" Do not wrap inside words
set linebreak
" set textwidth=80

" When scrolling vertically, 
" the cursor's position from the top/bottom (in lines).
set scrolloff=5

" Always show the status line at the bottom, even if you only have one window open.
set laststatus=2

" Display the current cursor position (row and column) in the status bar.
set ruler
set rulerformat=%70(%=\:b%n%y[%{&fenc==\#\"\"?&encoding:&fenc},%{&ff}]\ %l,%c%V\ %P%)

set background=dark
colorscheme gruvbox

" ================ search ================

" This setting makes search case-insensitive when all characters in the string
" being searched are lowercase. However, the search becomes case-sensitive if
" it contains any capital letters. This makes searching more convenient.
set ignorecase
set smartcase

" Enable searching as you type, rather than waiting till you press enter.
set incsearch
" highlight
set hlsearch

" When the cursor encounters a parenthesis,
" the corresponding parenthesis is automatically highlighted.
set showmatch

" ================ edit ================

" The backspace key has slightly unintuitive behavior by default. For example,
" by default, you can't backspace before the insertion point set with 'i'.
" This configuration makes backspace behave more reasonably, in that you can
" backspace over anything.
set backspace=indent,eol,start

" By default, Vim doesn't let you hide a buffer (i.e. have a buffer that isn't
" shown in any window) that has unsaved changes. This is to prevent you from "
" forgetting about unsaved changes and then quitting e.g. via `:qa!`. We find
" hidden buffers helpful enough to disable this protection. See `:help hidden`
" for more information on this.
set hidden

" Disable audible bell because it's annoying.
set noerrorbells visualbell t_vb=


" system clipboard
set clipboard=unnamed

" auto change pwd when open new file
set autochdir

set swapfile

" auto reload file when change by others
set autoread

set history=1000

set spell spelllang=en_us

" In command mode, pressing the Tab key will 
" automatically complete the bottom operation commands.
set wildmenu
set wildmode=longest:list,full

" Making the Invisible Visible
set list
set listchars=tab:│\ ,trail:·,nbsp:␣,extends:»,precedes:«

" ================ shortcut ================

" Unbind some useless/annoying default key bindings.
nmap Q <Nop> " 'Q' in normal mode enters Ex mode. You almost never want this.

" Try to prevent bad habits like using the arrow keys for movement. This is
" not the only possible bad habit. For example, holding down the h/j/k/l keys
" for movement, rather than using more efficient movement commands, is also a
" bad habit. The former is enforceable through a .vimrc, while we don't know
" how to prevent the latter.
" Do this in normal mode...
nnoremap <Left>  :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up>    :echoe "Use k"<CR>
nnoremap <Down>  :echoe "Use j"<CR>

" ff to replace <ESC>
inoremap ff <ESC>
vnoremap ff <ESC>
