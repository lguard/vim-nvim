set encoding=utf-8
set fileencoding=utf-8

try
call plug#begin('~/.vim/plugged')

	Plug 'https://github.com/kien/ctrlp.vim'
	Plug 'https://github.com/scrooloose/syntastic'
	Plug 'https://github.com/morhetz/gruvbox'
	Plug 'https://github.com/scrooloose/nerdtree'
	Plug 'https://github.com/bling/vim-airline'
	Plug 'https://github.com/luochen1990/rainbow'

call plug#end()
catch
endtry

let g:syntastic_cpp_compiler = 'c++'
let g:syntastic_cpp_compiler_options = ' -std=c++11 -stdlib=libc++ -Wall -Werror -Wextra'
let g:syntastic_cpp_include_dirs = ['../../../include', '../../include','../include','./include']

let g:syntastic_c_compiler = 'gcc'
let g:syntastic_c_compiler_options = ' -Wall -Werror -Wextra'
let g:syntastic_c_include_dirs = ['../../../include', '../../include','../include','./include']

syntax on
try
	colorscheme gruvbox
catch
endtry
set background=dark

set nu
set cc=80
set ts=4
set t_Co=256
set shiftwidth=4
set cursorline
set ai
set si
set whichwrap+=<,>,h,l,[,]
set list listchars=tab:»·,trail:·,eol:¶
set wildmenu
set wildmode=longest:full,list:full
set foldnestmax=1
set hlsearch
set autoread
set laststatus=2
set backspace=indent,eol,start

let mapleader = ","
let g:mapleader = ","

nmap <leader>t :term<cr>

inoremap {<CR>	{<CR>}<Esc>O<Tab>

noremap <Space><Space>		:tabedit ~/.nvimrc<CR>
noremap <S-Tab>				:tabprevious<CR>
noremap <Tab>				:tabnext<CR>

noremap <C-g>				:NERDTreeToggle<CR>
noremap <S-z>				:set foldmethod=indent<CR>
noremap <S-z>				:set fdm=indent
noremap <CR>				:nohlsearch<CR>
vnoremap <Tab>				>
vnoremap <S-Tab>			<

noremap <S-Right>			<C-w><Right>
noremap <S-Left>			<C-w><Left>
noremap <S-Up>				<C-w><Up>
noremap <S-Down>			<C-w><Down>

inoremap <C-u>				<Esc><C-r>i
noremap <C-u>				<C-r>

noremap <silent>			<C-s>	:w!<CR>
noremap <silent>			<C-s>	:q<CR>

if has('nvim')
	tnoremap <S-Up> <C-\><C-n><S-w>Up
	tnoremap <S-Down> <C-\><C-n><S-w>Down
	tnoremap <S-Left> <C-\><C-n><S-w>Left
	tnoremap <S-Right> <C-\><C-n><S-w>Right
endif

set autochdir