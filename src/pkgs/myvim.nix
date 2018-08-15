{ pkgs ? import <nixpkgs> {} } :
with pkgs;
let

  cacert = stdenv.mkDerivation rec {
    name = "ca-certificates-ex";
    syscrt = /etc/ssl/certs/ca-certificates.crt;
    buildCommand =  ''
      mkdir -pv $out/etc/ssl/certs/
      cat ${syscrt} > $out/etc/ssl/certs/ca-bundle.crt
    '';
  };

  fetchgit = pkgs.callPackage ./fetchgit.nix {
    git = gitMinimal;
    cacert = cacert;
  };

  lastplace = vimUtils.buildVimPluginFrom2Nix {
    name = "lastplace";
    src = fetchurl {
      url = "https://github.com/farmergreg/vim-lastplace/archive/v3.1.1.tar.gz";
      sha256 = "0vvp6nvq53yqbmnsqlgn0x3ci46vp8grrm7wqnd1cvclzf0n4359";
    };
    dependencies = [];
  };


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
      rev = "d8399f7683a8de4310de47a11a39e90499ecb843";
      sha256 = "017lmh393aybq74hg5j4iq8k8ar8xdfx904yj78w6l3yab9g0qlf";
    };
  };

  grepper = vimUtils.buildVimPluginFrom2Nix {
    name = "grepper-1.4";
    src = fetchgit {
      url = "https://github.com/mhinz/vim-grepper";
      rev = "b146028f70594390bd18e16789d1af29eac55aad";
      sha256 = "0wdxsghadmg6zl608j6j1icihdc62czbsx5lmsq0j1b2rqzb5xj2";
    };
  };


in

vim_configurable.customize {
  name = "vim";

  vimrcConfig.packages.myVimPackage = with pkgs.vimPlugins; {
    start = [
      cyrvim
      bufexplorer
      # youcompleteme
      surround
      vim-airline
      vim-airline-themes
      mynerdtree
      vim-trailing-whitespace
      vim-localvimrc
      commentary
      vim-trailing-whitespace
      vim-colorschemes
      changeColorScheme-vim
      # syntastic
      vim-hdevtools
      lastplace
      grepper
      supertab
      ctrlp
    ];
  };

  vimrcConfig.customRC = ''
    " if (hostname() == "ww2")
    "  colorscheme default
    " else
    " endif

    colorscheme blackboard
    hi Comment guifg=grey35 ctermfg=30


    " colorscheme zellner


    runtime macros/matchit.vim

    let mapleader = "~"
    let maplocalleader = "~"

    set guioptions-=m
    set guioptions-=T
    set scrolloff=0
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
    set wildignore=*/.git/*,*/.hg/*,*/.svn/*

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
    au FileType chaskell set expandtab shiftwidth=2 tabstop=2
    au FileType cabal set expandtab
    au FileType python set expandtab textwidth=0 shiftwidth=2 tabstop=2 cinoptions=g0,(2 softtabstop=2 nosmartindent
    au FileType python syn region Comment start=/"""/ end=/"""/
    au FileType python let &omnifunc=""
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

    " Escape bindings
    " Convert double Escape sent by terminals back to single Escape
    " TODO: find a way not to use <Esc>letter as <A-letter> alternative
    inoremap <Leader><Leader> <Leader>
    inoremap <Esc><Esc> <Esc>
    inoremap <F1> <Esc>
    nnoremap <F1> <Esc>

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
    imap <Esc>x <C-o>x
    imap <Esc>ч <C-o>x
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

    " Screen
    nnoremap s :call VimOpenTerm(expand("%:h"))<CR>
    nnoremap S :call VimOpenTermWindow(expand("%:p:h"))<CR>


    " Airline
    let g:airline_theme="badwolf"

    " Alternate
    let g:alternateExtensions_ur = "urs"
    let g:alternateExtensions_urs = "ur"

    " BufferExplorer
    nnoremap <Leader>e <Esc>:BufExplorer<CR>
    inoremap <Leader>e <Esc>:BufExplorer<CR>
    noremap <Space> <Esc>:BufExplorer<CR>

    " Commentary
    map <C-C> gc
    nmap <C-C> gccj

    " CtrlP
    let g:ctrlp_max_files = 0
    au BufEnter * vmap <C-p> "a:CtrlP<CR><C-\>ra

    " Cycle colorscheme
    " map <F5> :call NextColorScheme()<CR>:colorscheme<CR>
    " map <F6> :call PreviousColorScheme()<CR>:colorscheme<CR>

    " Cyrvim
    let g:cyrvim_map_esc = 1
    let g:cyrvim_map_cmd = 1
    let g:cyrvim_map_cmd_esc = 1

    " EasyGrep
    let g:EasyGrepRecursive = 1
    let g:EasyGrepMode = 2

    " Figlet
    command! -nargs=+ Figlet :r! figlet <args> | sed 's/[ \t]*$//'

    " Grepper
    let g:grepper = {
        \ 'tools':     ['git', 'ag', 'grep'],
        \ 'open':      1,
        \ 'jump':      0,
        \ }
    command! -nargs=* G :Grepper -noqf -query <q-args>

    " Local vimrc
    let g:localvimrc_name = ['.lvimrc', '.vimrc_local.vim', 'localrc.vim']
    let g:localvimrc_event = [ "BufWinEnter" ]
    let g:localvimrc_ask = 0
    let g:localvimrc_sandbox = 0

    " NERDTree settings
    " {{{ NERD
    let g:NERDChristmasTree=1
    let g:NERDTreeChDirMode=2
    let g:NERDTreeMinimalUI=1
    let g:NERDTreeWinSize=35
    let g:NERDTreeWinPos='left'
    let g:NERDTreeIgnore=['\.o', '\.ko', '^cscope', '\.hi']
    let g:NERDTreeCasadeOpenSingleChildDir=1
    let g:NERDTreeQuitOnOpen=0
    let g:NERDTreeMapQuit='<Plug>h'
    noremap <F4> <ESC>:NERDTreeFind<CR>
    command -nargs=0 NF :NERDTreeFind

    function! VimOpenTerm(d)
      let oldcwd = getcwd()
      exec "cd " . a:d
      exec '!tmux new-window'
      exec "cd " . oldcwd
    endfunction

    function! VimOpenTermWindow(d)
      let d =
      exec '!STY="" urxvt -cd ' . a:d . ' &'
    endfunction

    function! NERDTree_s(node)
      call VimOpenTerm(a:node.path.getDir().str())
    endfunction

    function! NERDTree_S(node)
      call VimOpenTermWindow(a:node.path.getDir().str())
    endfunction

    function! NERDTree_C_P(node)
      exec "wincmd w"
      exec "CtrlP " . a:node.path.getDir().str()
    endfunction

    function! NERDTree_G(node)
      let oldcwd = getcwd()
      exec "cd " . a:node.path.getDir().str()
      exec "wincmd w"
      exec "Grepper -noqf"
      exec "augroup ungrep | au! FileType qf cd " . oldcwd . " | augroup END"
    endfunction
    " }}}

    " SuperTab
    let g:SuperTabDefaultCompletionType = "context"
    let g:SuperTabContextDefaultCompletionType = "<c-n>"
    let g:SuperTabCompleteCase = "match"

    " Surround
    xmap s S

    " Window resizing
    nnoremap <silent> + :exe "resize " . (max([winheight(0) * 3/2, 2]))<CR>
    nnoremap <silent> - :exe "resize " . (max([winheight(0) * 2/3, 1]))<CR>

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

    " Mouse
    nmap <RightMouse> <C-o>
  '';
}
