{ pkgs ? import <nixpkgs> {} } :
with pkgs;
let

  cacert = stdenv.mkDerivation rec {
    name = "ca-certificates-ex";
    syscrt = ../certs/huawei.crt;
    buildCommand =  ''
      mkdir -pv $out/etc/ssl/certs/
      cat ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt ${syscrt} > $out/etc/ssl/certs/ca-bundle.crt
    '';
  };

  inherit (pkgs) fetchgitLocal;
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
      rev = "95621b8fb4a2f101e3bebec54d15cc31a2b389ad";
      sha256 = "1r3m95kb7n91vyfmyjsbjz9y78lr1h0wyr2hnxy7gwa7c2hpv7cv";
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

  vimbufsync = vimUtils.buildVimPluginFrom2Nix {
    name = "vimbufsync";
    src = fetchgit {
      url = "https://github.com/let-def/vimbufsync";
      rev = "15de54fec24efa8a78f1ea8231fa53a9a969ce04";
      sha256 = "1zk0ccifdznd9j9cmigm9jlwflr641mx7v0vr8mhfjz27wbajdap";
    };
  };

  coquille = vimUtils.buildVimPluginFrom2Nix {
    name = "coquille-8.4";
    # src = /home/grwlf/proj/coquille;
    src = fetchgit {
      url = "https://github.com/grwlf/coquille";
      rev = "eb06e85";
      sha256 = "0sj3wg47znm81ffplr9ywbppis3nklrk1a9f2bbi9h0rj5ns4w9w";
    };
    dependencies = [ "vimbufsync" ];
  };


  fzf-pure = vimUtils.buildVimPluginFrom2Nix {
    name = "fzf-pure";
    src = pkgs.stdenv.mkDerivation {
      name="fzf-pure";
      buildCommand = ''
        mkdir -pv $out
        cp -r ${pkgs.fzf.out}/share/vim-plugins/*/* $out/
        chmod +w -R $out
        sed -i "s@base_dir = expand(.*)@base_dir = '${pkgs.fzf}'@g" $out/plugin/fzf.vim
      '';
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
      # ctrlp
      fzf-pure
      # fzfWrapper
      fzf-vim
      vimbufsync
      coquille
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

    function! Ident(ident_spaces)
      let &expandtab=1
      let &shiftwidth=a:ident_spaces
      let &tabstop=a:ident_spaces
      let &cinoptions="'g0,(".a:ident_spaces
      let &softtabstop=a:ident_spaces
    endfunction

    set guioptions-=m
    set guioptions-=T
    set scrolloff=0
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
    set hlsearch
    set mouse=nirv
    set laststatus=2
    set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
    set tags=tags;
    set encoding=utf-8
    set fileencodings=utf8,cp1251
    set t_Co=256
    set modeline
    set textwidth=0
    set timeoutlen=500
    set directory=/tmp,/var/tmp,.
    set hidden
    set nowrap
    set completeopt=longest,menu
    set smartindent
    set number
    set wildignore=*/.git/*,*/.hg/*,*/.svn/*
    call Ident(2)

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

    au FileType nix set commentstring=#\ %s
    au FileType python syn region Comment start=/"""/ end=/"""/
    au FileType python let &omnifunc=""
    au FileType asciidoc set comments+=fb:*
    au FileType asciidoc set comments+=fb:.
    au FileType markdown set textwidth=80
    au FileType markdown set comments+=fb:*
    au FileType markdown set comments+=fb:-
    au FileType markdown set comments+=fb:#.
    au FileType ur set commentstring=(*%s*)
    au FileType c set commentstring=//\ %s

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
    nnoremap <F2> <ESC>:noh<CR>:w!<CR>:lclose<CR>
    inoremap <F2> <ESC>:noh<CR>:w!<CR>:lclose<CR>

    " Reformat
    nnoremap <F3> gqap
    inoremap <F3> <C-o>gqap
    vnoremap <F3> gq

    " Visual $
    vnoremap $ $h

    " Fast command line
    nnoremap ! :!

    " Fzf
    nnoremap <C-p> :Files<CR>
    vnoremap <C-p> "ay:call fzf#vim#files(fnamemodify(getcwd(),':p'),{'options':'--query ' .  shellescape('<C-r>a')})<CR>

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

    function! QFToggle()
      let found=0
      for winnr in range(1, winnr('$'))
        if getwinvar(winnr, '&syntax') == 'qf'
          let found=1
        endif
      endfor
      if found==1
        exe "lclose"
      else
        exe "lopen"
      endif
    endfunction

    QFmap o <cr>
    QFmap <C-o> :lolder<cr>
    QFmap <C-i> :lnewer<cr>
    QFmap q :q<cr>

    nmap <C-j> :lnext<CR>
    nmap <C-k> :lprev<CR>
    nmap <C-l> :call QFToggle()<CR>
    nnoremap <Esc>l :call QFToggle()<CR>

    " Readline-style insert-mode bindings
    " FIXME: Works ok for console version of vim only. They actually maps
    " <Esc><key>. That causes problems in normal mode.
    imap <Esc>f <C-o>e<C-o>a
    cmap <Esc>f <S-Right>
    imap <Esc>b <C-o>b
    cmap <Esc>b <S-Left>
    imap <Esc>d <C-o>ved
    imap <Esc>e <C-o>A
    cmap <Esc>e <C-o>A

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
    function! Mosh_Flip_Ext()
      " Switch editing between .c* and .h* files (and more).
      " Since .h file can be in a different dir, call find.
      if match(expand("%"),'\.cc') > 0
        let s:flipname = substitute(expand("%:t"),'\.cc','.h',"")
      elseif match(expand("%"),'\.c') > 0
        let s:flipname = substitute(expand("%:t"),'\.c\(.*\)','.h\1',"")
      elseif match(expand("%"),"\\.h") > 0
        let s:flipname = substitute(expand("%:t"),'\.h\(.*\)','.c\1',"")
      endif
      call fzf#vim#files(fnamemodify(getcwd(),':p'),{'options':'--query /' .  s:flipname })
    endfun
    command! -nargs=0 A :call Mosh_Flip_Ext()

    " BufferExplorer
    let g:bufExplorerShowTabBuffer = 1
    nnoremap <Leader>e <Esc>:BufExplorer<CR>
    inoremap <Leader>e <Esc>:BufExplorer<CR>
    noremap <Space> <Esc>:BufExplorer<CR>

    " Commentary
    map <C-C> gc
    nmap <C-C> gccj

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
        \ 'tools':     ['sgit', 'git', 'ag', 'grep'],
        \ 'open':      1,
        \ 'jump':      0,
        \ 'sgit':      { 'grepprg':    'git grep --recurse-submodules -nI',
        \                'grepformat': '%f:%l:%m',
        \                'escape':     '\^$.*[]'
        \              },
        \ }
    command! -nargs=* G :Grepper -noqf -query <q-args>

    " Local vimrc
    let g:localvimrc_name = ['.lvimrc', '.vimrc_local.vim', 'localrc.vim', 'lvimrc.vim']
    let g:localvimrc_event = [ "BufWinEnter" ]
    let g:localvimrc_ask = 0
    let g:localvimrc_sandbox = 0
    let g:localvimrc_debug = 0

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
      call fzf#vim#files(fnamemodify(a:node.path.getDir().str(),':p'))
    endfunction

    let g:nerd_oldcwd = ""
    function! NERDTree_G_term()
      if g:nerd_oldcwd != ""
        exec "cd " . g:nerd_oldcwd
        let g:nerd_oldcwd = ""
      endif
    endfunction
    exec "augroup ungrep | au! FileType qf call NERDTree_G_term() | augroup END"

    function! NERDTree_G(node)
      let g:nerd_oldcwd = getcwd()
      let newcwd = a:node.path.getDir().str()
      exec "wincmd w"
      exec "cd " . newcwd
      exec "Grepper -noqf"
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
    function! RT(tab)
        let cw = expand('<cword>')
        try
            if a:tab == 1
              execute 'tabnew'
            endif
            if cw != g:rt_cw
                execute 'ltag ' . cw
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
    " map <C-]> :call RT(0)<CR>
    " map <C-\> :call RT(1)<CR>

    function! _run_ltag(tab)
      if a:tab == 1
        execute 'tabnew'
      endif
      let cw = expand('<cword>')
      execute 'ltag ' . cw
      execute 'lopen'
    endfunction
    map <C-]> :call _run_ltag(0)<CR>
    map <C-/> :call _run_ltag(1)<CR>

    " Mouse
    nmap <RightMouse> <C-o>
  '';
}
