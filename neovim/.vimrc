""" PLUGINS
call plug#begin('~/.vim/plugged')

" ======== SESSION ========
Plug 'mhinz/vim-startify' " Start screen
Plug 'rmagatti/auto-session'
Plug 'rmagatti/session-lens'

" ========= VISUAL =========
Plug 'sainnhe/sonokai'
Plug 'dracula/vim', { 'as': 'dracula' } " colorscheme
Plug 'itchyny/lightline.vim' " Status bar
" Plug 'feline-nvim/feline.nvim' " Status bar
Plug 'lewis6991/gitsigns.nvim'
Plug 'kshenoy/vim-signature' " Visualizing marks
Plug 'luochen1990/rainbow'
Plug 'ObserverOfTime/coloresque.vim' " color preview

" ========= EDITOR =========
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer'
Plug 'neovim/nvim-lspconfig'

" Autocomplete plugins
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
" For vsnip users.
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

Plug 'tpope/vim-surround'
Plug 'mattn/emmet-vim' " Emmet completion / snippets
Plug 'numToStr/Comment.nvim' " Comment toggle
Plug 'windwp/nvim-autopairs'
" Plug 'preservim/tagbar' " ctags viewer
" Plug 'bitterjug/vim-tagbar-ctags-elm' " elm support in tagbar
" Plug 'dhruvasagar/vim-table-mode' " Create tables in vim
Plug 'kyazdani42/nvim-web-devicons'
Plug 'folke/trouble.nvim'

" ========= UTILITY ========
Plug 'tpope/vim-fugitive' " Git support
Plug 'scrooloose/nerdtree' " File browser
Plug 'PhilRunninger/nerdtree-visual-selection' " operate on multiple files
Plug 'christoomey/vim-tmux-navigator' " tmux navigation
Plug 'Xuyuanp/nerdtree-git-plugin' " Show git status in file browser
" Plug 'vimwiki/vimwiki' " Notetaking
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

Plug 'prettier/vim-prettier', {
  \ 'do': 'yarn install',
  \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }

call plug#end()

" Init Lua Plugins
lua << EOF
require('nvim-autopairs').setup{}
require('auto-session').setup{}
require('telescope').load_extension('session-lens')
require('Comment').setup{}
EOF

""" Session
set sessionoptions+=tabpages,globals
" nnoremap <F2> :OpenSession<CR>
nnoremap <leader>fs :Telescope session-lens search_session<CR>

""" GLOBAL
let mapleader = " "
map ø :
syntax on
filetype plugin on
" VimWiki thing (disables vi backwards compatibility):
set nocompatible
" open splits on the right
set splitright
let g:rainbow_active = 0
let g:rainbow_conf = {
  \ 'guifgs': ['#c058c0','#B1B695', '#ffffff']
  \ }

let g:rainbow_load_separately = [
    \ [ '*.{html,htm}' , [] ],
\ ]

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

" command! BD call fzf#run(fzf#wrap({
  " \ 'source': s:list_buffers(),
  " \ 'sink*': { lines -> s:delete_buffers(lines) },
  " \ 'options': '--multi --reverse --bind ctrl-a:select-all+accept'
" \ }))
nnoremap <leader>bd :BD<CR>

lua << EOF
require'nvim-web-devicons'.setup {
 -- your personnal icons can go here (to override)
 -- you can specify color or cterm_color instead of specifying both of them
 -- DevIcon will be appended to `name`

 override = {
  zsh = {
    icon = "?",
    color = "#428850",
    cterm_color = "65",
    name = "Zsh"
  }
 };
 -- globally enable default icons (default to false)
 -- will get overriden by `get_icons` option
 default = true;
}

-- require('feline').setup()
-- require('feline').add_theme('6cdh', 6cdh)
-- require('feline').use_theme('6cdh')

EOF


""" TERMINAL
" map esc to escape the builtin terminal
" tnoremap  <C-\><C-n>
nnoremap <leader>tt :term<CR>

""" Tagbar
nnoremap <leader>ta :Tags<CR>
nnoremap <leader>tb :BTags<CR>
nnoremap <leader>to :TagbarOpen<CR>
let g:tagbar_autoclose = 1


""" PRETTIER
let g:prettier#autoformat = 1
let g:prettier#autoformat_require_pragma = 0
" autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html PrettierAsync

" adding a comment

""" LSP
nnoremap <silent> ca <cmd>lua vim.lsp.buf.code_action()<CR>

lua << EOF
local lsp_installer = require("nvim-lsp-installer")

-- Register a handler that will be called for each installed server when it's ready (i.e. when installation is finished
-- or if the server is already installed).
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
lsp_installer.on_server_ready(function(server)
    local opts = {
      capabilities = capabilities
    }

    -- (optional) Customize the options passed to the server
    -- if server.name == "tsserver" then
    --     opts.root_dir = function() ... end
    -- end

    -- This setup() function will take the provided server configuration and decorate it with the necessary properties
    -- before passing it onwards to lspconfig.
    -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
    server:setup(opts)
end)

local nvim_lsp = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  --Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<Space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<Leader>dr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<Leader>da', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<Space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

end

require("trouble").setup { }

local signs = {
    Error = " ",
    Warn = " ",
    Hint = " ",
    Info = " "
}

for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, {text = icon, texthl = hl, numhl = hl})
end

EOF

" popup menu background
hi Pmenu ctermbg=234 ctermfg=007 guibg=#191B24 guifg=#B1B695
hi PmenuSel ctermbg=000 ctermfg=045 guibg=#212430 guifg=#C2D3CD
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | silent! pclose | endif

hi Background cterm=NONE guifg=NONE guibg=NONE


""" AUTOCOMPLETE (nvim-cmp)
set completeopt=menu,menuone,noselect

lua << EOF
  -- Setup nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine

      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },
    mapping = {
      ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ['<C-y>'] = cmp.config.disable, --Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
      ['<C-e>'] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    },

    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' },
    }, {
      { name = 'buffer' },
    })
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline('/', {
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  -- Setup lspconfig.
  -- local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
  -- -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
  -- require('lspconfig')['<YOUR_LSP_SERVER>'].setup {
  --   capabilities = capabilities
  -- }
  --
EOF

""" Lightline (statusbar)

let g:lightline = {
  \ 'colorscheme': 'one',
  \ 'active': {
  \   'left': [ [ 'mode', 'paste' ],
  \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
  \ },
  \ 'component_function': {
  \   'gitbranch': 'FugitiveHead'
  \ },
  \ }

command! LightlineReload call LightlineReload()

function! LightlineReload()
  call lightline#init()
  call lightline#colorscheme()
  call lightline#update()
endfunction

autocmd VimEnter * call SetupLightlineColors()
function! SetupLightlineColors() abort
  let l:pallete = lightline#palette()
  let l:pallete.normal.left[1][3] = 'NONE'
  call lightline#colorscheme()
endfunction


""" EDITOR

" " Cursor (iTerm overrides this though)
hi Cursor ctermbg=125

" line height
set linespace=16

" Command line
hi MsgArea guifg=#594970

" " Visual mode selection
hi Visual ctermbg=050 guibg=#241F26
" " Background color
hi Normal ctermbg=None guibg=#282935

" " Toggle comment
" let g:NERDSpaceDelims = 1
" let g:NERDToggleCheckAllLines = 1
map <leader><leader> gcc


" " Mouse scrolling
set mouse=a
set scrolloff=5

" " LineNumbers
set number
set relativenumber
set numberwidth=3
" hi VertSplit ctermfg=234 ctermbg=NONE guifg=NONE guibg=#191B24
set encoding=utf8

" Remove border character (not working atm)
" set fillchars=""
"guifg=#241F26
hi VertSplit ctermfg=045 ctermbg=NONE cterm=NONE guifg=#241F26 guibg=NONE gui=NONE
set fillchars+=vert:\│" with trailing space!

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

" Windows/panes navigation ctrl + hjkl (THIS IS NOW HANDLED BY tmux navigation plugin)
" nnoremap <C-h> <C-w>h
" nnoremap <C-j> <C-w>j
" nnoremap <C-k> <C-w>k
" nnoremap <C-l> <C-w>l

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

lua << EOF
require('gitsigns').setup()
EOF

:nnoremap <leader>a :diffput<CR>
:map <Leader>g :Git<CR>

""" TABS
" set showtabline=2
" hi TabLineFill cterm=NONE guifg=DEFAULT
" hi TabLine ctermfg=062 ctermbg=234 cterm=NONE guifg=#5f5fd7 guibg=#1c1c1c
hi TabLine ctermfg=062 ctermbg=234 cterm=NONE guifg=#847E89 guibg=#847E89
hi TabLineSel ctermfg=White ctermbg=125 guifg=#c2d3cd guibg=#191B24
hi Title ctermfg=LightBlue ctermbg=NONE guifg=#B1B695

nnoremap <leader>tc :tabclose<CR>

""" KEYBINDINGS
" Global Copy Paste
nnoremap <leader>y "+y
nnoremap <leader>p "+p
vnoremap <leader>y "+y
vnoremap <leader>p "+p

" Search for word
" nnoremap <leader>n yiw/<C-r>"<CR>
" search, highlight and replace (case-sensitive)
nnoremap <leader>* yiw/<C-r>"<CR>:%s/\C<C-r>"/
set ignorecase
set smartcase

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
    " au BufNewFile,BufRead *.jsx set filøetype=javascript.jsx
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

""" Telescope

" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>gb <cmd>Telescope git_branches<cr>

" Border highlight groups
" Black #241F26
" Beige #B1B695
highlight TelescopeBorder         guifg=#241F26
highlight TelescopePromptBorder   guifg=#B1B695
highlight TelescopeResultsBorder  guifg=#B1B695
highlight TelescopePreviewBorder  guifg=#B1B695
highlight TelescopeTitle          guifg=#B1B695


lua << EOF
local actions = require('telescope.actions')

require('telescope').setup{
  pickers = {
    find_files = {
      find_command = {'rg', '--files', '--hidden', '-g', '!.git' }
    },
  },
  defaults = {
    mappings = {
      i = {
        ['<C-j>'] = actions.move_selection_next,
        ['<C-k>'] = actions.move_selection_previous,
        ['<esc>'] = actions.close
      },
    },
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case'
    },
    prompt_prefix = "> ",
    selection_caret = "> ",
    entry_prefix = "  ",
    initial_mode = "insert",
    selection_strategy = "reset",
    sorting_strategy = "descending",
    layout_strategy = "horizontal",
    layout_config = {
      horizontal = {
        mirror = false,
      },
      vertical = {
        mirror = false,
      },
    },
    width_padding = 2,
    file_ignore_patterns = {},
    winblend = 0,
    border = {},
    borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    color_devicons = true,
    path_display = {},
    set_env = { ['COLORTERM'] = 'truecolor' }, -- default = nil,
  }
}
EOF

""" FZF
" let g:fzf_layout = {'down': '~40%'}
" nnoremap <leader>f :Files<CR>
" nnoremap <leader>h :History<CR>
" nnoremap <leader>F :call fzf#vim#files('.', {'options':'--query '.expand('<cword>')})<CR>

" " fzf checkout
" nnoremap <leader>gc :GCheckout<CR>

" " fzf.vim
" set grepprg=rg\ --vimgrep\ $*  " Use ripgrep
" set wildmode=list:longest,list:full
" set wildignore+=*.o,*.obj,.git,*.rbc,*.pyc,__pycache__
" let g:rg_command = '
  " \ rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --color "always"
  " \ -g "*.{js,json,php,md,styl,jade,html,config,py,cpp,c,go,hs,rb,conf}"
  " \ -g "!{.git,node_modules,vendor}/*" '
" command! -bang -nargs=* Rg
  " \ call fzf#vim#grep(
  " \   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
  " \   <bang>0 ? fzf#vim#with_preview('up:60%')
  " \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  " \   <bang>0)
" command! -bang -nargs=* F call fzf#vim#grep(g:rg_command .shellescape(<q-args>), 1, <bang>0)

" nnoremap <leader>F :Rg<CR>

" " rg is configured in more detail in ~/.ripgreprc
" let $FZF_DEFAULT_COMMAND='rg --files --column --follow --no-heading --line-number'
" let $FZF_DEFAULT_OPTS=' --layout=reverse --color=border:#241F26 --margin=1,4'
" let g:fzf_layout = { 'window': 'call FloatingFZF()' }

" let g:fzf_colors =
" \ { 'fg':      ['fg', 'Normal'],
  " \ 'bg':      ['fg', 'TabLineFill'],
  " \ 'hl':      ['fg', 'Comment'],
  " \ 'fg+':     ['fg', 'CursorLineNR', 'CursorColumn', 'Normal'],
  " \ 'bg+':     ['fg', 'TabLineFill', 'CursorColumn'],
  " \ 'hl+':     ['fg', 'Statement'],
  " \ 'info':    ['fg', 'TabLineFill'],
  " \ 'border':  ['bg', 'TabLineFill'],
  " \ 'prompt':  ['fg', 'Comment'],
  " \ 'pointer': ['fg', 'CursorLineNR'],
  " \ 'marker':  ['fg', 'Keyword'],
  " \ 'spinner': ['fg', 'Label'],
  " \ 'gutter':  ['fg', 'TabLineFill'],
  " \ 'header':  ['fg', 'Comment'] }

" function! FloatingFZF()
  " let buf = nvim_create_buf(v:false, v:true)
  " call setbufvar(buf, '&signcolumn', 'no')
 
  " let height = float2nr(&lines - 16)
  " let maxHeight = float2nr(20)
  " let width = float2nr(&columns - 32)
  " let maxWidth = float2nr(220)

  " if height > maxHeight
    " let height = maxHeight
  " endif

  " if width > maxWidth
    " let width = maxWidth
  " endif
 
  " let horizontal = float2nr((&columns - width) / 2)
  " let vertical = float2nr((&lines - height) / 2.5)

  " let opts = {
        " \ 'relative': 'editor',
        " \ 'row': vertical,
        " \ 'col': horizontal,
        " \ 'width': width,
        " \ 'height': height,
        " \ 'style': 'minimal'
        " \ }
 
  " call nvim_open_win(buf, v:true, opts)
" endfunction

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
