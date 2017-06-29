{ pkgs ? import <nixpkgs> {} } :
with pkgs;
let

  bufexplorer = vimUtils.buildVimPluginFrom2Nix {
    name = "bufexplorer";
    src = fetchurl {
      url = "https://github.com/jlanzarotta/bufexplorer/archive/v7.4.18.tar.gz";
      sha256 = "10421mspkpkaayawzxdyrv83g95b450d9fskkk52r0yq6qyixwkc";
    };
    dependencies = [];
  };

  cyrvim = vimUtils.buildVimPluginFrom2Nix {
    name = "cyrvim";
    src = fetchgit {
      url = "https://github.com/grwlf/cyrvim";
      rev = "01720eaeb066acfd599772f20461bcb62abe4718";
      sha256 = "0vs2kisb6r39jg6nn0q3vs7xfxban2nism3rn8g02l3bzpvh3zc9";
    };
  };

  mynerdtree = vimUtils.buildVimPluginFrom2Nix {
    name = "nerdtree";
    src = fetchgit {
      url = "https://github.com/grwlf/nerdtree";
      rev = "7bbace5bbb3cd234ebfa30061b35c29350105053";
      sha256 = "0i201jrszb12adkbv9djd41fc0ri2xp5qv1vqc2gqmrl7vvagjh8";
    };
  };


in
vim_configurable.customize {
  name = "vim-with-plugins";

  # store your plugins in Vim packages
  vimrcConfig.packages.myVimPackage = with pkgs.vimPlugins; {
    # loaded on launch
    start = [
      cyrvim
      bufexplorer
      youcompleteme
      surround
      vim-airline
      vim-airline-themes
      mynerdtree
      vim-trailing-whitespace
      vim-localvimrc
      commentary
      vim-trailing-whitespace
      vim-colorschemes
    ];
    # manually loadable by calling `:packadd $plugin-name`
    # opt = [ phpCompletion elm-vim ];
    # To automatically load a plugin when opening a filetype, add vimrc lines like:
    # autocmd FileType php :packadd phpCompletion
  };

  # add custom .vimrc lines like this:
  vimrcConfig.customRC = ''
    if (hostname() == "ww2")
      colorscheme default
    else
      colorscheme Tomorrow-Night
    endif

    " colorscheme zellner


    runtime macros/matchit.vim

    let mapleader = "~"
    let maplocalleader = "~"

    set guioptions-=m
    set guioptions-=T
    set scrolloff=10
    set tabstop=4
    set nobackup
    set shiftwidth=4
    set noshowmatch
    set showcmd
    set autowrite
    set foldmethod=marker
    set foldcolumn=0
    set backspace=indent,eol,start
    set incsearch
    set ignorecase
    set formatoptions+=roj
    set cinoptions+=g0,(4
    set hlsearch
    set mouse=nirv
    set laststatus=2
    set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
    set tags=tags;
    set encoding=utf-8
    set fileencodings=utf8,cp1251
    set t_Co=256
    set modeline
    set textwidth=80
    set timeoutlen=500
    set directory=/tmp,/var/tmp,.
    set hidden
    set nowrap
    set completeopt=longest,menu
    set smartindent
    set number

    " Softwrapping
    " set columns=80
    " au VimResized * if (&columns > 80) | set columns=80 | endif
    " set wrap
    " set linebreak
    " set showbreak=>

    au BufEnter * syntax sync minlines=50
    au BufEnter * syntax sync fromstart
    au BufEnter .vimperatorrc set filetype=vim
    au BufEnter *urs set filetype=ur
    au BufEnter *grm set filetype=ur

    au BufEnter nixos-config set filetype=nix
    au FileType nix set expandtab shiftwidth=2 tabstop=2
    au FileType nix set commentstring=#\ %s
    au FileType sh set expandtab shiftwidth=2 tabstop=2 textwidth=0
    au FileType haskell set expandtab shiftwidth=2 tabstop=2
    au FileType cabal set expandtab
    au FileType python set expandtab shiftwidth=2 tabstop=2 cinoptions=g0,(2 softtabstop=2 nosmartindent
    au FileType *asciidoc set expandtab shiftwidth=2 tabstop=2
    au FileType *asciidoc set comments+=fb:*
    au FileType *asciidoc set comments+=fb:.

    au FileType *markdown set expandtab shiftwidth=2 tabstop=2
    au FileType *markdown set comments+=fb:*
    au FileType *markdown set comments+=fb:-
    au FileType *markdown set comments+=fb:#.

    au FileType ur set commentstring=(*%s*)
    au FileType ur set expandtab shiftwidth=2 tabstop=2

    au FileType c set expandtab shiftwidth=2 tabstop=2
    au FileType c set commentstring=//\ %s
    au FileType cpp set expandtab shiftwidth=2 tabstop=2

    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid or when inside an event handler
    " (happens when dropping a file on gvim).
    au BufReadPost *
      \ if line("'\"") > 0 && line("'\"") <= line("$") |
      \   exe "normal g`\"" |
      \ endif

    " General bindings
    inoremap <Leader><Leader> <Leader>
    inoremap <Esc><Esc> <Esc>

    " Save
    nnoremap <F2> <ESC>:noh<CR>:w!<CR>
    inoremap <F2> <ESC>:noh<CR>:w!<CR>

    " Reformat
    nnoremap <F3> gqap
    inoremap <F3> <C-o>gqap
    vnoremap <F3> gq

    " Visual $
    vnoremap $ $h

    " Fast command line
    nnoremap ! :!

    " Help on word
    map <F1> :exec ":help " . expand('<cword>')<CR>

    " Display lines scrolling
    nnoremap j gj
    nnoremap k gk
    nnoremap Y y$

    " Quick quit
    map q :quit<CR>

    " Paste 1-line visual selection into the command line
    function! SmartColon() range
      if (a:firstline == a:lastline)
        call feedkeys("gvy:\<Space>\<C-r>\"\<C-b>",'n')
      else
        call feedkeys(":")
      endif
    endfunction
    vnoremap : :call SmartColon()<CR>

    " Easy paste
    nnoremap <Leader>i :set paste<CR>i

    " Open quickfix window
    nnoremap <Leader>f :cope<CR>

    " Tab key cycles through windows
    " noremap <Tab> <C-w>w
    noremap ` <C-w>w

    " noremap <C-p> <C-i>

    " Tabs
    map gr gT
    map tn :tabnew<CR>
    map th :tabnew $HOME<CR>

    " Clear hlsearch
    nnoremap <CR> :nohlsearch<CR><CR>

    " Clipboard helpers
    if has("x11")
      vnoremap "a "ay
      vnoremap "b "by
      vnoremap "c "cy
      vnoremap "d "dy
      vnoremap "e "yy

      nnoremap "a "ap
      nnoremap "b "bp
      nnoremap "c "cp
      nnoremap "d "dp
      nnoremap "e "ep

      nnoremap "A "aP
      nnoremap "B "bP
      nnoremap "C "cP
      nnoremap "D "dP
      nnoremap "E "eP

      vnoremap y "+y
      vnoremap d "+d
      vnoremap c "+c
      vnoremap p "+p
      nnoremap Y "+y$
      nnoremap D "+D
      nnoremap yy "+yy
      nnoremap yw "+yw
      nnoremap dd "+dd
      nnoremap p "+p
      nnoremap P "+P
    endif

    " Quicfix bindings
    function! QFmap(a,b)
      exe "au BufWinEnter quickfix map <buffer> " . a:a . " " . a:b
    endfunction
    command! -nargs=+ QFmap :call QFmap(<f-args>)

    QFmap o <cr>
    QFmap J :cnext<cr>:copen<cr>
    QFmap K :cprevious<cr>:copen<cr>
    QFmap <C-o> :cold<cr>
    QFmap <C-i> :cnew<cr>
    QFmap <Leader>f <C-w>q
    QFmap q :q<cr>

    " Readline-style bindings
    " FIXME: Works ok for console version of vim only. They actually maps
    " <Esc><key>. That causes problems in normal mode.
    imap <Esc>f <C-o>e<C-o>a
    cmap <Esc>f <S-Right>
    imap <Esc>b <C-o>b
    cmap <Esc>b <S-Left>
    imap <Esc>d <C-o>ved

    " Screen - like bindings
    nmap <Esc>q :tabprev<CR>
    nmap <Esc>й :tabprev<CR>
    imap <Esc>q <C-o>:tabprev<CR>
    imap <Esc>й <C-o>:tabprev<CR>
    nmap <Esc>w :tabnext<CR>
    nmap <Esc>ц :tabnext<CR>
    imap <Esc>w <C-o>:tabnext<CR>
    imap <Esc>ц <C-o>:tabnext<CR>
    nmap <C-a>c :tabnew<CR>

    " Wrap encodings on F8
    let g:enc_index = 0
    function! ChangeFileencoding()
      let encodings = ['cp1251', 'cp866', 'utf-8']
      execute 'e ++enc='.encodings[g:enc_index].' %:p'
      echo encodings[g:enc_index]
      if g:enc_index >= len(encodings)-1
        let g:enc_index = 0
      else
        let g:enc_index = g:enc_index + 1
      endif
    endf
    nmap <F8> :call ChangeFileencoding()<CR>

    " Figlet
    command! -nargs=+ Figlet :r! figlet <args> | sed 's/[ \t]*$//'

    " Cyrvim
    let g:cyrvim_map_esc = 1
    let g:cyrvim_map_cmd = 1
    let g:cyrvim_map_cmd_esc = 1

    " NERDTree settings
    let g:NERDChristmasTree=1
    let g:NERDTreeChDirMode=2
    let g:NERDTreeMinimalUI=1
    let g:NERDTreeWinSize=35
    let g:NERDTreeIgnore=['\.o', '\.ko', '^cscope', '\.hi']
    let g:NERDTreeCasadeOpenSingleChildDir=1
    let g:NERDTreeMapQuit='h'
    noremap <F4> <ESC>:NERDTreeFind<CR>
    command -nargs=0 NF :NERDTreeFind

    function! VimOpenTerm(d)
      let oldcwd = getcwd()
      exec "cd " . a:d
      exec '!screen'
      exec "cd " . oldcwd
    endfunction

    function! VimOpenTermWindow(d)
      let d =
      exec '!STY="" urxvt -cd ' . a:d . ' &'
    endfunction

    function! NERDTreeOpenTerm(node)
      call VimOpenTerm(a:node.path.getDir().str())
    endfunction

    function! NERDTreeOpenTermWindow(node)
      call VimOpenTermWindow(a:node.path.getDir().str())
    endfunctio

    " Screen
    nnoremap s :call VimOpenTerm(expand("%:h"))<CR>
    nnoremap S :call VimOpenTermWindow(expand("%:p:h"))<CR>


    " Airline
    let g:airline_theme="badwolf"

    " BufferExplorer
    nnoremap <Leader>e <Esc>:BufExplorer<CR>
    inoremap <Leader>e <Esc>:BufExplorer<CR>
    noremap <Space> <Esc>:BufExplorer<CR>

    " EasyGrep
    let g:EasyGrepRecursive = 1
    let g:EasyGrepMode = 2

    " Local vimrc
    let g:localvimrc_name = ['.lvimrc', '.vimrc_local.vim', 'localrc.vim']
    let g:localvimrc_event = [ "BufWinEnter" ]
    let g:localvimrc_ask = 0
    let g:localvimrc_sandbox = 0

    " SuperTab
    let g:SuperTabDefaultCompletionType = "context"
    let g:SuperTabContextDefaultCompletionType = "<c-n>"

    " Surround
    xmap s S

    " Commentary
    map <C-C> gc
    nmap <C-C> gccj

    " Alternate
    let g:alternateExtensions_ur = "urs"
    let g:alternateExtensions_urs = "ur"

    " Window resizing
    nnoremap <silent> + :exe "resize " . (max([winheight(0) * 3/2, 2]))<CR>
    nnoremap <silent> - :exe "resize " . (max([winheight(0) * 2/3, 1]))<CR>

    " G[rep] (requires tpope's vim-fugitive plugin)
    function! GitGrepInDir(args)
      let cwd = getcwd()
      exec "Ggrep '" . a:args . "' '" . cwd . "'"
      echo  "Ggrep '" . a:args . "' '" . cwd . "'"
    endfunction
    command! -nargs=+ G :call GitGrepInDir("<args>")
    autocmd QuickFixCmdPost *grep* cwindow

    " let g:hscoptions = "wA𝐒𝐓𝐓𝐌CIT𝔻"
    " :au BufReadPost * if b:current_syntax == "haskell"
    " :au BufReadPost *   highlight Comment ctermfg=Red guifg=Red
    " :au BufReadPost *   let g:aaa = "AAA"
    " :au BufReadPost * endif

    " Cyclic tag navigation
    let g:rt_cw = ""
    function! RT()
        let cw = expand('<cword>')
        try
            if cw != g:rt_cw
                execute 'tag ' . cw
                call search(cw,'c',line('.'))
            else
                try
                    execute 'tnext'
                catch /.*/
                    execute 'trewind'
                endtry
                call search(cw,'c',line('.'))
            endif
            let g:rt_cw = cw
        catch /.*/
            echo "no tags on " . cw
        endtry
    endfunction
    map <C-]> :call RT()<CR>
  '';

  # plugins can also be managed by VAM
  # vimrcConfig.vam.knownPlugins = pkgs.vimPlugins + [plg1]; # optional
  # vimrcConfig.vam.pluginDictionaries = [
  #   # load always
  #   # { name = "youcompleteme"; }
  #   # { name = "youcompleteme"; }
  #   {
  #     names = [
  #       "youcompleteme" "surround" "vim-airline"
  #       "nerdtree"
  #       "vim-trailing-whitespace"
  #       "vim-localvimrc"
  #     ];
  #   }

  #   # only load when opening a .php file
  #   # { name = "phpCompletion"; ft_regex = "^php\$"; }
  #   # { name = "phpCompletion"; filename_regex = "^.php\$"; }

  #   # provide plugin which can be loaded manually:
  #   # { name = "phpCompletion"; tag = "lazy"; }

  #   # full documentation at github.com/MarcWeber/vim-addon-manager
  # ];

  # there is a pathogen implementation as well, but its startup is slower and [VAM] has more feature
  # vimrcConfig.pathogen.knownPlugins = vimPlugins; # optional
  # vimrcConfig.pathogen.pluginNames = ["vim-addon-nix"];
}

