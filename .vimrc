""" PLUGINS
call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-fugitive' " Git support
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx' " JSX support
Plug 'vim-airline/vim-airline' " bottom toolbar
Plug 'vim-airline/vim-airline-themes'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim' " Fuzzy finder
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-surround'
Plug 'mattn/emmet-vim' " Emmet completion / snippets
Plug 'scrooloose/nerdtree' " File browser
Plug 'Xuyuanp/nerdtree-git-plugin' " Show git status in file browser
Plug 'w0rp/ale' " Async linter
Plug 'airblade/vim-gitgutter' " Git line status next to line number
Plug 'rafi/awesome-vim-colorschemes'
Plug 'scrooloose/nerdcommenter' " Auto comment
Plug 'mhinz/vim-startify' " Start screen
Plug 'vimwiki/vimwiki' " Notetaking
" Plug 'dhruvasagar/vim-table-mode' " Create tables in vim
Plug 'kshenoy/vim-signature' " Visualizing marks

"Typescript stuff
Plug 'HerringtonDarkholme/yats.vim'
Plug 'mhartington/nvim-typescript', {'do': ':!install.sh \| UpdateRemotePlugins'}
Plug 'Shougo/deoplete.nvim' " Autocomplete
Plug 'Shougo/denite.nvim'
Plug 'styled-components/vim-styled-components', { 'branch': 'main' } " and emotion + other css in js libraries
Plug 'jparise/vim-graphql' " graphql syntax support

" Plug 'prettier/vim-prettier', {
  " \ 'do': 'yarn install',
  " \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }

call plug#end()

""" GLOBAL
syntax on
colorscheme dracula
filetype plugin on
" VimWiki thing:
set nocompatible

""" PRETTIER
" let g:prettier#autoformat = 0
" autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html PrettierAsync


""" AUTOCOMPLETE
let g:deoplete#enable_at_startup = 1
call deoplete#custom#option({
\ 'smart_case': v:true,
\ })
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

hi Pmenu ctermbg=125
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | silent! pclose | endif


""" AIRLINE
" Theme
let g:airline_theme='deus'
"let g:airline_solarized_bg='dark'

let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

" Icons
" let g:airline_left_sep="\u25B6"
" let g:airline_right_sep="\u25C0"
" let g:airline_left_sep='⮀'
" let g:airline_right_sep=''
let g:airline_left_sep=''
let g:airline_right_sep=''

" Section config
let g:airline_section_c=''
let g:airline_section_y=''
let g:airline_section_z='%L'


""" EDITOR
" Cursor (iTerm overrides this though)
hi Cursor ctermbg=125

" Visual mode selection
hi Visual ctermbg=060

" Toggle comment
let g:NERDSpaceDelims = 1
let g:NERDToggleCheckAllLines = 1
map <leader><leader> <plug>NERDCommenterToggle


" Mouse scrolling
set mouse=a
set scrolloff=5

" LineNumbers
set number
set relativenumber
set numberwidth=3
highlight VertSplit ctermfg=234 ctermbg=NONE
set encoding=utf8
"set fillchars=vert:
highlight LineNr term=bold cterm=NONE ctermfg=060 ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE
highlight CursorLineNR ctermbg=NONE ctermfg=045
highlight EndOfBuffer ctermfg=125 ctermbg=NONE

" Sign column
hi SignColumn ctermbg=NONE

" Tabbing and spacing
set tabstop=2
set expandtab
retab
set softtabstop=0
set shiftwidth=2
set list
set listchars=tab:>-


"""" Search highlighting
" Press Space to turn off highlighting and clear any message already displayed.
set hlsearch
:map <silent> <Space> :nohlsearch<Bar>:echo<CR>

""" GIT
:nnoremap <leader>a :diffput<CR>
:nmap <Leader>hv <Plug>GitGutterPreviewHunk
:map <Leader>g :Gstatus<CR>

" Gdiff
hi DiffAdd ctermfg=NONE ctermbg=234 cterm=NONE
hi DiffText ctermfg=220 ctermbg=234 cterm=NONE
hi DiffChange ctermfg=061 ctermbg=234
hi DiffDelete ctermfg=225 ctermbg=125

" GitGutter symbols
hi GitGutterAdd ctermfg=070
hi GitGutterChange ctermfg=220
hi GitGutterDelete ctermfg=125 cterm=bold
hi GitGutterChangeDelete ctermfg=220 cterm=bold

""" TABS
set showtabline=2
hi TabLineFill ctermfg=234 ctermbg=NONE
hi TabLine ctermfg=062 ctermbg=234 cterm=NONE
hi TabLineSel ctermfg=White ctermbg=125
hi Title ctermfg=LightBlue ctermbg=NONE

""" KEYBINDINGS
" Global Copy Paste
nnoremap Y "+y
nnoremap P "+p
vnoremap Y "+y
vnoremap P "+p

" Search for word
nnoremap <leader>n yiw/<C-r>"<CR>

" NERDTree
nnoremap <S-Tab> :NERDTreeFind<CR>
nnoremap <Tab> :NERDTreeToggle<CR>

let g:NERDTreeMapActivateNode = "l"
let g:NERDTreeMapPreview = "<space>"
let g:NERDTreeMapCloseDir = "h"

" Resize windows / panes
nnoremap > :vertical resize -5<CR>
nnoremap < :vertical resize +5<CR>
nnoremap + :resize -5<CR>
nnoremap - :resize +5<CR>

" Save with cmd+s // Not working atm?
map <D-s> :w<CR>
let mapleader = " "
map ø :

" Move lines up and down: alt + j / alt + k
nnoremap √ ddp
nnoremap ª ddkP

" indent with alt + h/l
" nnoremap ﬁ ><space>
" nnoremap ˛ <<space>

" Navigate windows
map <leader>h <C-w>h
map <leader>j <C-w>j
map <leader>k <C-w>k
map <leader>l <C-w>l

" nnoremap <leader>w :q<CR>


""" LINTING
let g:ale_linters = {
\  'javascript': ['eslint', 'flow'],
\  'css': ['stylelint'],
\  'ruby': ['rubocop'],
\}
let g:ale_fixers = {
\  'javascript': ['eslint', 'prettier'],
\  'typescript': ['eslint', 'prettier'],
\}
let g:ale_fix_on_save = 1
let g:ale_lint_on_save = 1
let g:ale_lint_on_text_changed = 1
let g:ale_sign_column_always = 1

hi ALEWarning ctermbg=234 ctermfg=220 cterm=underline,bold
hi ALEWarningSign ctermfg=220 cterm=bold
hi ALEWarningLine ctermbg=234
hi ALEError ctermfg=white ctermbg=204
hi ALEErrorSign ctermbg=204
hi ALEErrorLine ctermbg=234

nmap <silent> <leader>j :ALENext<CR>
nmap <silent> <leader>k :ALEPrevious<CR>


"""" JSX linting
augroup FiletypeGroup
    autocmd!
    au BufNewFile,BufRead *.jsx set filetype=javascript.jsx
augroup END

" Autoreload vimrc
augroup reload_vimrc " {
    autocmd!
    autocmd BufWritePost $MYVIMRC source $MYVIMRC
    autocmd BufWritePost ~/.vimrc source ~/.vimrc
augroup END " }

""" NERDTree
" Fix NERDTree '^G' thing
let g:NERDTreeNodeDelimiter = "\u00a0"
let g:NERDTreeWinSize=50
let NERDTreeQuitOnOpen = 1
let NERDTreeMinimalUI = 1
" autocmd bufenter * if (winnr(“$”) == 1 && exists(“b:NERDTreeType”) && b:NERDTreeType == “primary”) | q | endif
" NERDTree git plugin
let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "M",
    \ "Staged"    : "✚",
    \ "Untracked" : "U",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ 'Ignored'   : '☒',
    \ "Unknown"   : "?"
    \ }

""" FZF
let g:fzf_layout = {'down': '~40%'}
nnoremap <leader>f :FZF<CR>
nnoremap <leader>F :call fzf#vim#files('.', {'options':'--query '.expand('<cword>')})<CR>

""" Notes
let g:vimwiki_list = [{'path': '~/Notes/vimwiki'}]

""" FOLDING
set foldmethod=expr
set foldexpr=getline(v:lnum)=~'^\"\"'?'>'.(matchend(getline(v\:lnum),'\"\"*')-2)\:'='
" set foldexpr=strlen(substitute(substitute(getline(v:lnum),'\\s','',\"g\"),'[^>].*','',''))

hi foldcolumn ctermbg=NONE ctermfg=LightBlue

""" HISTORY
set undofile
set undodir=~/.vim/undo_files//
set directory=~/.vim/swap_files//
set backupdir=~/.vim/backup_files//

""" VimWiki
nmap <leader>tt :VimwikiTable 2 2<CR>jli
nnoremap <leader>bb :Vimwiki
