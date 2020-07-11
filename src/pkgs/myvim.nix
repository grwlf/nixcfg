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

  # lastplace = vimUtils.buildVimPluginFrom2Nix {
  #   name = "lastplace";
  #   src = fetchurl {
  #     url = "https://github.com/farmergreg/vim-lastplace/archive/v3.1.1.tar.gz";
  #     sha256 = "0vvp6nvq53yqbmnsqlgn0x3ci46vp8grrm7wqnd1cvclzf0n4359";
  #   };
  #   dependencies = [];
  # };


  # bufexplorer = vimUtils.buildVimPluginFrom2Nix {
  #   name = "bufexplorer";
  #   src = fetchurl {
  #     url = "https://github.com/jlanzarotta/bufexplorer/archive/v7.4.18.tar.gz";
  #     sha256 = "10421mspkpkaayawzxdyrv83g95b450d9fskkk52r0yq6qyixwkc";
  #   };
  #   dependencies = [];
  # };

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
      rev = "e6417f261ce86ce44bcb14c36aaa87e5e900b6d8";
      sha256 = "sha256:0nf9p12490phvinl8iarfcqw39zz94dhmh23isw51k9d3ay8cpa6";
    };
  };

  grepper = vimUtils.buildVimPluginFrom2Nix {
    name = "grepper-1.4";
    # src = /home/grwlf/proj/vim-grepper;
    src = fetchFromGitHub {
      owner = "grwlf";
      repo = "vim-grepper";
      rev = "dde595334d2fc0e25eaa67ed39c1043820959d85";
      sha256 = "sha256:1ipvnkj4gcvr6c29qzhd80h6h9kfprp09h7j1lyj2qhzcn259b9v";
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

  # eprecated in favor of Coqtail
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

  coqtail = vimUtils.buildVimPluginFrom2Nix {
    name = "coqtail-999";
    # src = /home/grwlf/proj/coqtail;
    src = fetchgit {
      url = "https://github.com/whonore/Coqtail";
      rev = "ce11c6f241a834c4ea4a80079196c046a6f963c2";
      sha256 = "sha256:1i5l240xhy638lyd1gws7aaiql7bcw9152cb8lak0na3nwmphqaa";
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

  ident-highlight = vimUtils.buildVimPluginFrom2Nix {
    name = "ident-highlight";
    src = fetchFromGitHub {
      owner = "grwlf";
      repo = "indent-highlight.vim";
      rev = "07c465c";
      sha256 = "1vqdbhnpwlsh854d9jr4p6gl0d58bj4vx63gfmbx3zmql1gd9zdx";
    };
  };

  LanguageClient-neovim = let
    version = "0.1.155";
    LanguageClient-neovim-src = fetchurl {
      url = "https://github.com/autozimu/LanguageClient-neovim/archive/${version}.tar.gz";
      sha256 = "sha256:0v9n450iwgvm1d4qwv742bjam3p747cvyrkapkgxy7n1ar8rz50i";
    };
    LanguageClient-neovim-bin = rustPlatform.buildRustPackage {
      name = "LanguageClient-neovim-bin";
      src = LanguageClient-neovim-src;

      cargoSha256 = "sha256:139sj1aq0kr4r4qzhgcn2hb4dyvp5wxjz7bxbm0bbh9bv2pr98jq";
      buildInputs = stdenv.lib.optionals stdenv.isDarwin [ CoreServices ];

      # FIXME: Use impure version of CoreFoundation because of missing symbols.
      #   Undefined symbols for architecture x86_64: "_CFURLResourceIsReachable"
      preConfigure = stdenv.lib.optionalString stdenv.isDarwin ''
        export NIX_LDFLAGS="-F${CoreFoundation}/Library/Frameworks -framework CoreFoundation $NIX_LDFLAGS"
      '';
    };
  in vimUtils.buildVimPluginFrom2Nix {
    pname = "LanguageClient-neovim";
    inherit version;
    src = LanguageClient-neovim-src;

    propagatedBuildInputs = [ LanguageClient-neovim-bin ];

    preFixup = ''
      substituteInPlace "$out"/share/vim-plugins/LanguageClient-neovim/autoload/LanguageClient.vim \
        --replace "let l:path = s:root . '/bin/'" "let l:path = '${LanguageClient-neovim-bin}' . '/bin/'"
    '';
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
      vim-lastplace
      grepper
      supertab
      # ctrlp
      fzf-pure
      # fzfWrapper
      fzf-vim
      vimbufsync
      # coquille
      coqtail
      LanguageClient-neovim
      ident-highlight
      vim-gitgutter
      vim-markdown
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
    set nostartofline
    set updatetime=100  " GitGutter
    set signcolumn=yes
    set colorcolumn=81
    highlight ColorColumn ctermbg=236
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
    au BufEnter *pmd set filetype=markdown
    au BufEnter Dockerfile* set filetype=dockerfile
    au BufEnter *docker set filetype=dockerfile

    au FileType nix set commentstring=#\ %s
    au FileType python syn region Comment start=/"""/ end=/"""/
    au FileType python let &omnifunc=""
    au FileType python set comments+=b:#:
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

    " Terminal
    nnoremap <C-w>t :terminal<CR>
    nnoremap <C-w>е :terminal<CR>

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
        \ 'tools':     ['sgit', 'git', 'grep'],
        \ 'open':      1,
        \ 'jump':      0,
        \ 'sgit':      { 'grepprg':    'git grep --recurse-submodules -nI',
        \                'grepformat': '%f:%l:%m',
        \                'escape':     '\^$.*[]"; '
        \              },
        \ }
    function _run_grepper(args)
      exec "Grepper -noqf -prompt -query '" . a:args . "'"
    endfunction
    function! _get_visual_selection()
        " Why is this not a built-in Vim script function?!
        let [line_start, column_start] = getpos("'<")[1:2]
        let [line_end, column_end] = getpos("'>")[1:2]
        let lines = getline(line_start, line_end)
        if len(lines) == 0
            return ""
        endif
        let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
        let lines[0] = lines[0][column_start - 1:]
        return join(lines, "\n")
    endfunction
    command! -nargs=* G :call _run_grepper(<q-args>)
    nnoremap <C-G> :call _run_grepper(expand('<cword>'))<CR>
    vnoremap <C-G> :call _run_grepper(_get_visual_selection())<CR>

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
    let g:NERDTreeMouseMode=3
    noremap <F4> <ESC>:NERDTreeFind<CR>
    autocmd FileType nerdtree noremap <buffer> <F4> :NERDTreeClose<CR>
    autocmd FileType nerdtree map <buffer> O o:NERDTreeClose<CR>
    command -nargs=0 NF :NERDTreeFind

    function! VimOpenTerm(d)
      let oldcwd = getcwd()
      exec "cd " . a:d
      exec '!tmux new-window'
      exec "cd " . oldcwd
    endfunction

    function! VimOpenTermWindow(d)
      let d =
      exec '!STY="" urxvt -cd ' . fnameescape(a:d) . ' &'
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

    function! _run_grepper_nerd(node)
      let oldcwd = getcwd()
      let newcwd = a:node.path.getDir().str()
      exec "wincmd w"
      exec "cd " . fnameescape(newcwd)
      exec "Grepper -noqf -prompt"
      exec "cd " . fnameescape(oldcwd)
    endfunction

    function! _run_term(node)
      let oldcwd = getcwd()
      let newcwd = a:node.path.getDir().str()
      exec "wincmd w"
      exec "cd " . fnameescape(newcwd)
      exec "terminal"
      exec "cd " . fnameescape(oldcwd)
    endfunction

    function! NERDTree_G(node)
      call _run_grepper_nerd(a:node)
    endfunction

    function! NERDTree_C_G(node)
      call _run_grepper_nerd(a:node)
    endfunction

    function! NERDTree_t(node)
      call _run_term(a:node)
    endfunction

    function! NERDTree_C_T(node)
      call _run_term(a:node)
    endfunction
    " }}}

    " SuperTab
    let g:SuperTabDefaultCompletionType = "context"
    let g:SuperTabContextDefaultCompletionType = "<c-n>"
    let g:SuperTabCompleteCase = "match"
    let g:SuperTabLongestEnhanced = 1

    " Surround
    xmap s S

    " Window resizing
    nnoremap <silent> + :exe "resize " . (max([winheight(0) * 3/2, 2]))<CR>
    nnoremap <silent> - :exe "resize " . (max([winheight(0) * 2/3, 1]))<CR>

    " Mouse
    nmap <RightMouse> <C-o>

    " LanguageClient & tagging
    "let g:LanguageClient_loggingFile = "pyls.log"
    "let g:LanguageClient_loggingLevel = "DEBUG"
    let g:LanguageClient_serverCommands = {
      \ 'python': ['pyls'],
      \ 'cpp': ['ccls'],
      \ 'c': ['ccls']
      \ }
    nnoremap <F5> :call LanguageClient_contextMenu()<CR>
    nnoremap <silent> gh :call LanguageClient_textDocument_hover()<CR>
    nnoremap <silent> gd :call LanguageClient_textDocument_definition()<CR>
    nnoremap <silent> gr :call LanguageClient_textDocument_references()<CR>
    nnoremap <silent> gs :call LanguageClient_textDocument_documentSymbol()<CR>
    " nnoremap <silent> <F2> :call LanguageClient_textDocument_rename()<CR>
    nnoremap <silent> gf :call LanguageClient_textDocument_formatting()<CR>
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

    " IndentHighlight
    let g:indent_highlight_disabled = 0       " Disables the plugin, default 0
    let g:indent_highlight_bg_color = 233     " Color to be used for highlighting, default 233
    let g:indent_highlight_start_disabled = 0 " Disable indent-highlight, enable by explicitly toggling, default 1

    " gitgutter
    highlight GitGutterAdd    guifg=#009900 guibg=#073642 ctermfg=2
    highlight GitGutterChange guifg=#bbbb00 guibg=#073642 ctermfg=3
    highlight GitGutterDelete guifg=#ff2222 guibg=#073642 ctermfg=1

    " Markdown
    let g:vim_markdown_folding_disabled = 1
    let g:vim_markdown_new_list_item_indent = 2
    let g:vim_markdown_auto_insert_bullets = 0


    " Reload the highlighting
    noremap <F12> <Esc>:syntax sync fromstart<CR>
    inoremap <F12> <C-o>:syntax sync fromstart<CR>
  '';
}
