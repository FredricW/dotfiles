""" PLUGINS
call plug#begin('~/.vim/plugged')

" ======== SESSION ========
" Plug 'xolox/vim-misc' " Dependency for vim-session
" Plug 'xolox/vim-session' " Session management
" Plug 'gcmt/taboo.vim' " Tab management
" Plug 'mhinz/vim-startify' " Start screen

" ========= VISUAL =========
Plug 'sainnhe/sonokai'
Plug 'dracula/vim', { 'as': 'dracula' } " colorscheme
Plug 'sheerun/vim-polyglot' " Syntax highlighting 
Plug 'vim-airline/vim-airline' " bottom toolbar
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter' " Git line status next to line number
Plug 'kshenoy/vim-signature' " Visualizing marks
Plug 'luochen1990/rainbow'
" Plug 'rafi/awesome-vim-colorschemes'
" Plug 'jparise/vim-graphql' " graphql syntax support

" ========= EDITOR =========
Plug 'neoclide/coc.nvim', {'branch': 'release'} " Autocomplete
Plug 'tpope/vim-surround'
" Plug 'mattn/emmet-vim' " Emmet completion / snippets
Plug 'scrooloose/nerdcommenter' " Auto comment
" Plug 'raimondi/delimitmate' " Autoclose brackets and quotes
" Plug 'preservim/tagbar' " ctags viewer
" Plug 'bitterjug/vim-tagbar-ctags-elm' " elm support in tagbar
" Plug 'terryma/vim-multiple-cursors'
" Plug 'dhruvasagar/vim-table-mode' " Create tables in vim

" ========= UTILITY ========
Plug 'tpope/vim-fugitive' " Git support
Plug 'scrooloose/nerdtree' " File browser
" Plug 'Xuyuanp/nerdtree-git-plugin' " Show git status in file browser
" Plug 'vimwiki/vimwiki' " Notetaking

if isdirectory('/usr/local/opt/fzf')
 Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim'
else
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
Plug 'junegunn/fzf.vim'
endif
Plug 'stsewd/fzf-checkout.vim'

" Plug 'prettier/vim-prettier', {
  " \ 'do': 'yarn install',
  " \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }

call plug#end()

""" Session
set sessionoptions+=tabpages,globals
nnoremap <F2> :OpenSession<CR>

""" GLOBAL
let mapleader = " "
map ø :
syntax on
filetype plugin on
" VimWiki thing (disables vi backwards compatibility):
set nocompatible
" open splits on the right
set splitright
let g:rainbow_active = 1
let g:rainbow_conf = {
  \ 'guifgs': ['#c058c0','#B1B695', '#ffffff']
  \ }
" ({[({[({[]})]})]})
" monokai-pro adaptaion theme 'sonokai'
if has('termguicolors')
  set termguicolors
endif
" The configuration options should be placed before `colorscheme sonokai`.
" let g:sonokai_style = 'andromeda'
" let g:sonokai_enable_italic = 1
" let g:sonokai_disable_italic_comment = 1
colorscheme dracula

" nnoremap <leader>s :w<CR>
nnoremap <leader>? :source ~/.vimrc<CR>
nnoremap <leader>bb :Buffers<CR>
function s:list_buffers()
  redir => list
  silent ls
  redir END
  return split(list, "\n")
endfunction

function! s:delete_buffers(lines)
  execute 'bwipeout' join(map(a:lines, {_, line -> split(line)[0]}))
endfunction

command! BD call fzf#run(fzf#wrap({
  \ 'source': s:list_buffers(),
  \ 'sink*': { lines -> s:delete_buffers(lines) },
  \ 'options': '--multi --reverse --bind ctrl-a:select-all+accept'
\ }))
nnoremap <leader>bd :BD<CR>


""" Tagbar
nnoremap <leader>ta :Tags<CR>
nnoremap <leader>tt :BTags<CR>
nnoremap <leader>tb :TagbarOpen<CR>
let g:tagbar_autoclose = 1


""" PRETTIER
" let g:prettier#autoformat = 0
" autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html PrettierAsync

" adding a comment

""" Coc
set updatetime=300
set shortmess+=c
set completeopt-=preview
let g:coc_global_extensions = ['coc-tsserver']
"Add CoC Prettier if prettier is installed
if isdirectory('./node_modules') && isdirectory('./node_modules/prettier')
  let g:coc_global_extensions += ['coc-prettier']
endif
"Add CoC ESLint if ESLint is installed
if isdirectory('./node_modules') && isdirectory('./node_modules/eslint')
  let g:coc_global_extensions += ['coc-eslint']
endif
" format on save
command! -nargs=0 Prettier :call CocAction('runCommand', 'prettier.formatFile')

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

"Remap keys for gotos
nmap <silent> <leader>dr <Plug>(coc-references)
nmap <silent> <leader>dR <Plug>(coc-refactor)
nmap <silent> <leader>dd <Plug>(coc-implementation)
nmap <silent> <leader>dy <Plug>(coc-type-definition)
nmap <silent> <leader>dn <Plug>(coc-rename)
nmap <silent> <leader>dl <Plug>(coc-codelens-action)
nmap <silent> <leader>da <Plug>(coc-codeaction)
nmap <silent> <leader>e <Plug>(coc-diagnostic-next)
nmap <silent> <leader>E <Plug>(coc-diagnostic-prev)
nmap <silent> <leader>p :Prettier<cr>
inoremap <silent><expr> <Tab> coc#refresh()
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
command! -nargs=0 Prettier :CocCommand prettier.formatFile
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
      \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
" documentation popup
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if &filetype == 'vim'
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

""" AUTOCOMPLETE
"<TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

" trigger autocomplete
inoremap <silent><expr> <c-space> coc#refresh()


" popup menu background
hi Pmenu ctermbg=234 ctermfg=007 guibg=#191B24 guifg=#B1B695
hi PmenuSel ctermbg=000 ctermfg=045 guibg=#212430 guifg=#C2D3CD
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | silent! pclose | endif

hi Background cterm=NONE guifg=NONE guibg=NONE


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
" let g:airline_section_c=''
let g:airline_section_y=''
let g:airline_section_z='%L'


""" EDITOR

" " Cursor (iTerm overrides this though)
hi Cursor ctermbg=125

" " Visual mode selection
hi Visual ctermbg=050 guibg=#241F26
" " Background color
hi Normal ctermbg=None

" " Toggle comment
let g:NERDSpaceDelims = 1
let g:NERDToggleCheckAllLines = 1
map <leader><leader> <plug>NERDCommenterToggle


" " Mouse scrolling
set mouse=a
set scrolloff=5

" " LineNumbers
set number
set relativenumber
set numberwidth=3
hi VertSplit ctermfg=234 ctermbg=NONE guifg=bg guibg=#191B24
set encoding=utf8

" Remove border character (not working atm)
" set fillchars+=vert:\|
" hi VertSplit ctermfg=234 cterm=NONE

highlight LineNr term=bold cterm=NONE ctermfg=060 ctermbg=NONE guifg=#594970 guibg=NONE
highlight CursorLineNR ctermbg=NONE ctermfg=045 guifg=Turquoise2
highlight EndOfBuffer ctermfg=125 ctermbg=NONE guifg=#594970

" Sign column
hi SignColumn ctermbg=NONE guibg=NONE
" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
" Recently vim can merge signcolumn and number column into one
 set signcolumn=number
else
 set signcolumn=yes
endif

" Tabbing and spacing
set tabstop=2
set expandtab
retab
set softtabstop=0
set shiftwidth=2
set list
set listchars=tab:>-

" Windows/panes navigation ctrl + hjkl
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

"""" Search highlighting
" Press Space to turn off highlighting and clear any message already displayed.
set hlsearch
" :map <silent> <Space> :nohlsearch<Bar>:echo<CR>
"
" Clear highlighting on escape in normal mode
" nnoremap <esc> :noh<return><esc>
" nnoremap <esc>^[ <esc>^[
nnoremap <CR> :noh<CR>

""" Typescript
" nnoremap <leader>d :TSDef<CR>

""" GIT
:nnoremap <leader>a :diffput<CR>
:nmap <Leader>hv <Plug>GitGutterPreviewHunk
:map <Leader>g :Gstatus<CR>

" " Gdiff
hi DiffAdd ctermfg=NONE ctermbg=234 cterm=NONE guibg=#192116
hi DiffText ctermfg=220 ctermbg=234 cterm=NONE guibg=#130D00
hi DiffChange ctermbg=060 guibg=NONE
hi DiffDelete ctermfg=089 ctermbg=234 guibg=NONE guifg=#211717

" " GitGutter symbols
hi GitGutterAdd ctermfg=070
hi GitGutterChange ctermfg=220
hi GitGutterDelete ctermfg=125 cterm=bold
hi GitGutterChangeDelete ctermfg=220 cterm=bold

""" TABS
set showtabline=2
hi TabLineFill cterm=NONE guifg=#212430
" hi TabLine ctermfg=062 ctermbg=234 cterm=NONE guifg=#5f5fd7 guibg=#1c1c1c
hi TabLine ctermfg=062 ctermbg=234 cterm=NONE guifg=#847E89 guibg=#847E89
hi TabLineSel ctermfg=White ctermbg=125 guifg=#c2d3cd guibg=#191B24
hi Title ctermfg=LightBlue ctermbg=NONE guifg=#B1B695

nnoremap <leader>tc :tabclose<CR>

""" KEYBINDINGS
" Global Copy Paste
" nnoremap Y "+y
" nnoremap P "+p
" vnoremap Y "+y
" vnoremap P "+p

" Search for word
" nnoremap <leader>n yiw/<C-r>"<CR>
" search, highlight and replace
nnoremap <leader>* yiw/<C-r>"<CR>:%s/<C-r>"/

" NERDTree
" nnoremap <S-Tab> :NERDTreeFind<CR>
nnoremap <leader>n :NERDTreeToggle<CR>

let g:NERDTreeHijackNetrw=0 " Prevent auto open when vim starts
let g:NERDTreeMapActivateNode = "l"
let g:NERDTreeMapPreview = "<space>"
let g:NERDTreeMapCloseDir = "h"

" Git / fugitive
""" Fugitive / fugitive
" command GdiffInTab tabedit %|Gdiff
function GStatusTabDiff()
  if has('multi_byte_encoding')
    let colon = '\%(:\|\%uff1a\)'
  else
    let colon = ':'
  endif
  let filename = matchstr(matchstr(getline(line('.')),'^#\t\zs.\{-\}\ze\%( ([^()[:digit:]]\+)\)\=$'), colon.' *\zs.*')
  tabedit %
  execute ':Gedit ' . filename
  Gvdiff
endfunction
" command GStatusTabDiff call GStatusTabDiff()
" autocmd FileType gitcommit noremap <buffer> dt :GStatusTabDiff<CR>

" pick right side diff
nmap <leader>gl :diffget //3<CR>
" pick left side diff
nmap <leader>gh :diffget //2<CR>
" show git status
nmap <leader>gs :G<CR>
" open diff in tab
" nmap <leader>gd :GdiffInTab<CR>
nmap <leader>gd :tabedit %<CR>:Gvdiffsplit!<CR>


" Resize windows / panes
nnoremap > :vertical resize -5<CR>
nnoremap < :vertical resize +5<CR>
nnoremap + :resize -5<CR>
nnoremap - :resize +5<CR>

" Save with cmd+s // Not working atm?
" map <D-s> :w<CR>

" Move lines up and down: alt + j / alt + k
nnoremap √ ddp
nnoremap ª ddkP

" indent with alt + h/l
nnoremap ﬁ ><space>
nnoremap ˛ <<space>

" Navigate windows
" map <leader>h <C-w>h
" map <leader>j <C-w>j
" map <leader>k <C-w>k
" map <leader>l <C-w>l

" nnoremap <leader>w :q<CR>


""" LINTING
" let g:ale_linters = {
" \  'javascript': ['eslint', 'flow'],
" \  'css': ['stylelint'],
" \  'ruby': ['rubocop'],
" \}
" let g:ale_fixers = {
" \  'javascript': ['eslint', 'prettier'],
" \  'typescript': ['eslint', 'prettier'],
" \}
" let g:ale_fix_on_save = 1
" let g:ale_lint_on_save = 1
" let g:ale_lint_on_text_changed = 1
" let g:ale_sign_column_always = 1

" hi ALEWarning ctermbg=234 ctermfg=220 cterm=underline,bold
" hi ALEWarningSign ctermfg=220 cterm=bold
" hi ALEWarningLine ctermbg=234
" hi ALEError ctermfg=white ctermbg=204
" hi ALEErrorSign ctermbg=204
" hi ALEErrorLine ctermbg=234

" nmap <silent> <leader>j :ALENext<CR>
" nmap <silent> <leader>k :ALEPrevious<CR>


"""" JSX linting
" augroup FiletypeGroup
    " autocmd!
    " au BufNewFile,BufRead *.jsx set filetype=javascript.jsx
" augroup END

" Autoreload vimrc
" augroup reload_vimrc " {
    " autocmd!
    " autocmd BufWritePost $MYVIMRC source $MYVIMRC
    " autocmd BufWritePost ~/.vimrc source ~/.vimrc
" augroup END " }

""" NERDTree
" Fix NERDTree '^G' thing
let g:NERDTreeNodeDelimiter = "\u00a0"
let g:NERDTreeWinSize=50
let NERDTreeQuitOnOpen = 1
let NERDTreeMinimalUI = 1
let NERDTreeShowHidden=1

" autocmd bufenter * if (winnr(“$”) == 1 && exists(“b:NERDTreeType”) && b:NERDTreeType == “primary”) | q | endif
" NERDTree git plugin
" let g:NERDTreeIndicatorMapCustom = {
    " \ "Modified"  : "M",
    " \ "Staged"    : "✚",
    " \ "Untracked" : "U",
    " \ "Renamed"   : "➜",
    " \ "Unmerged"  : "═",
    " \ "Deleted"   : "✖",
    " \ "Dirty"     : "✗",
    " \ "Clean"     : "✔︎",
    " \ 'Ignored'   : '☒',
    " \ "Unknown"   : "?"
    " \ }

""" FZF
let g:fzf_layout = {'down': '~40%'}
nnoremap <leader>f :Files<CR>
nnoremap <leader>h :History<CR>
" nnoremap <leader>F :call fzf#vim#files('.', {'options':'--query '.expand('<cword>')})<CR>

" fzf checkout
nnoremap <leader>gc :GCheckout<CR>

" fzf.vim
set grepprg=rg\ --vimgrep\ $*  " Use ripgrep
set wildmode=list:longest,list:full
set wildignore+=*.o,*.obj,.git,*.rbc,*.pyc,__pycache__
" let $FZF_DEFAULT_COMMAND="find * -path '*/\.*' -prune -o -path 'node_modules/**' -prune -o -path 'target/**' -prune -o -path 'dist/**' -prune -o  -type f -print -o -type l -print 2> /dev/null"
let g:rg_command = '
  \ rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --color "always"
  \ -g "*.{js,json,php,md,styl,jade,html,config,py,cpp,c,go,hs,rb,conf}"
  \ -g "!{.git,node_modules,vendor}/*" '
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)
command! -bang -nargs=* F call fzf#vim#grep(g:rg_command .shellescape(<q-args>), 1, <bang>0)

nnoremap <leader>F :Rg<CR>

let $FZF_DEFAULT_COMMAND="rg --files"
let $FZF_DEFAULT_OPTS=' --layout=reverse --color=border:#ffffff --margin=1,4'
let g:fzf_layout = { 'window': 'call FloatingFZF()' }

let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['fg', 'TabLineFill'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLineNR', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['fg', 'TabLineFill', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'TabLineFill'],
  \ 'border':  ['bg', 'TabLineFill'],
  \ 'prompt':  ['fg', 'Comment'],
  \ 'pointer': ['fg', 'CursorLineNR'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'gutter':  ['fg', 'TabLineFill'],
  \ 'header':  ['fg', 'Comment'] }

function! FloatingFZF()
  let buf = nvim_create_buf(v:false, v:true)
  call setbufvar(buf, '&signcolumn', 'no')
 
  let height = float2nr(&lines - 16)
  let maxHeight = float2nr(20)
  let width = float2nr(&columns - 32)
  let maxWidth = float2nr(220)

  if height > maxHeight
    let height = maxHeight
  endif

  if width > maxWidth
    let width = maxWidth
  endif
 
  let horizontal = float2nr((&columns - width) / 2)
  let vertical = float2nr((&lines - height) / 2.5)

  let opts = {
        \ 'relative': 'editor',
        \ 'row': vertical,
        \ 'col': horizontal,
        \ 'width': width,
        \ 'height': height,
        \ 'style': 'minimal'
        \ }
 
  call nvim_open_win(buf, v:true, opts)
endfunction

""" Notes
" let g:vimwiki_list = [{'path': '~/Notes/vimwiki'}]

""" FOLDING
set foldmethod=expr
set foldexpr=getline(v:lnum)=~'^\"\"'?'>'.(matchend(getline(v\:lnum),'\"\"*')-2)\:'='
" set foldexpr=strlen(substitute(substitute(getline(v:lnum),'\\s','',\"g\"),'[^>].*','',''))

" set fillchars+=vert:\ 
" hi foldcolumn ctermbg=NONE ctermfg=LightBlue


""" HISTORY
set undofile
set undodir=~/.vim/undo_files//
set directory=~/.vim/swap_files//
set backupdir=~/.vim/backup_files//

""" VimWiki
" nmap <leader>tt :VimwikiTable 2 2<CR>jli
" nnoremap <leader>bb :Vimwiki
