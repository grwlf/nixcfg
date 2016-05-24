{ pkgs, extra ? null} :

with pkgs ;
let

  git = gitAndTools.gitFull;

  gitbin = "${git}/bin/git";

in pkgs.writeText "myprofile.sh" ''
  export EDITOR=${vimHugeX}/bin/vim
  export VERSION_CONTROL=numbered
  export SVN_EDITOR=$EDITOR
  export GIT_EDITOR=$EDITOR
  export LANG="ru_RU.UTF-8"
  export OOO_FORCE_DESKTOP=gnome
  export LC_COLLATE=C
  export HISTCONTROL=ignorespace:erasedups
  export PATH="$HOME/.cabal/bin:$PATH"
  export PATH="$HOME/local/bin:$PATH"

  cal()     { `which cal` -m "$@" ; }
  df()      { `which df` -h "$@" ; }
  du()      { `which du` -h "$@" ; }
  man()     { LANG=C ${man}/bin/man "$@" ; }
  feh()     { ${feh}/bin/feh -. "$@" ; }

  q() 		  { exit ; }
  s() 		  { ${screen}/bin/screen ; }
  e() 		  { thunar . 2>/dev/null & }

  log() 		{ ${vimHugeX}/bin/vim /var/log/messages + ; }
  logx() 		{ ${vimHugeX}/bin/vim /var/log/X.0.log + ; }

  cdt() 		{ cd $HOME/tmp ; }
  cdd()     { cd $HOME/dwnl; }
  gitk() 		{ LANG=C ${git}/bin/gitk "$@" & }
  gitka() 		{ LANG=C ${git}/bin/gitk --all "$@" & }
  mcd() 		{ mkdir "$1" && cd "$1" ; }
  vimless() { ${vimHugeX}/bin/vim -R "$@" - ; }
  pfind() 	{ ${findutils}/bin/find -iname "*$1*" ; }
  d() 	    { if test -z "$1" ; then
                load-env-dev
              else
                load-env-dev-$1
              fi
            }
  manconf() { ${man}/bin/man configuration.nix ; }
  gf()      { ${git}/bin/git fetch github || ${git}/bin/git fetch origin ; }
  beep()    { aplay ~/proj/dotfiles/beep.wav ; }

  alias nb='nix-build --option use-binary-caches false'
  alias ns='nix-shell --option use-binary-caches false'

  alias ga='${gitbin} add'
  alias gai='${gitbin} add -i'
  alias gb='${gitbin} branch'
  alias gc='${gitbin} commit'
  alias gco='${gitbin} checkout'
  alias gcp='${gitbin} cherry-pick'
  alias gd='${gitbin} diff'
  alias gg='${gitbin} grep'
  alias gl='${gitbin} log'
  alias gm='${gitbin} merge'
  alias gp='${gitbin} push'
  alias gpff='${gitbin} pull --ff'
  alias gpr='${gitbin} pull --rebase'
  alias gr='${gitbin} reset'
  alias grh='${gitbin} reset --hard'
  alias grm='${gitbin} remote'
  alias grv='${gitbin} remote -v'
  alias grma='${gitbin} remote add'
  alias gs='${gitbin} status'
  alias gsta='${gitbin} stash pop'
  alias gstl='${gitbin} stash list'
  alias gsts='${gitbin} stash save'
  alias gsu='${gitbin} submodule update'

  vim()     {
    case "$1" in
      "") ${vimHugeX}/bin/vim . ;;
      *) ${vimHugeX}/bin/vim "$@" ;;
    esac
  }

  # Set window name
  wn() { ${wmctrl}/bin/wmctrl -r :ACTIVE: -T "$@";  }

  # Set screen window name
  sn() {
    PID=$(echo $STY | awk -F"." '{ print $1}')
    if test -n "$PID" ; then
      ${screen}/bin/screen -D -r "$PID" -X title "$@"
    else
      echo "Failed to get PID. Do you have GNU/Screen running?" >&2
    fi
  }

  if env | grep -q SSH_CONNECTION= ; then
    if env | grep -q DISPLAY= ; then
      echo DISPLAY is $DISPLAY >/dev/null
      echo "export DISPLAY=$DISPLAY" > $HOME/.display
    else
      echo No DISPLAY was set >/dev/null
    fi
  fi

  make() {
    if test -f "Makefile.dev" ; then
      ${gnumake}/bin/make -f Makefile.dev "$@"
    else
      ${gnumake}/bin/make "$@"
    fi
  }

  my_ghc_cmd() {(
    cmd=$1
    shift
    export LANG=en_US.UTF8
    if [ -d .cabal-sandbox ] ; then
      echo "Using cabal sandbox configs" .cabal-sandbox/*-packages.conf.d >&2
      exec "$cmd" -no-user-package-db -package-db .cabal-sandbox/*-packages.conf.d "$@"
    else
      exec "$cmd" "$@"
    fi
  )}

  ghc() { my_ghc_cmd ghc "$@"; }
  ghci() { my_ghc_cmd ghci "$@"; }

  nix_unpack() { nix-build '<nixpkgs>' -A $1.src --no-out-link | grep /nix/store | xargs ${atool}/bin/aunpack ; }
  alias nix-unpack='nix_unpack'

  encfs() { `which encfs` -i 60 "$@" ; }

  ${if extra != null then extra else ""}
''

