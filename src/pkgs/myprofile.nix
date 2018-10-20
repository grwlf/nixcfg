{ pkgs ? import <nixpkgs> {} } :

with pkgs;
let

  git = gitAndTools.gitFull;

  myvim = import ./myvim.nix { inherit pkgs; };

  vimbin = "${myvim}/bin/vim";

  aplay = "${alsaUtils}/bin/aplay";

in
pkgs.writeText "myprofile.sh" ''
  export EDITOR=${vimbin}
  export VERSION_CONTROL=numbered
  export SVN_EDITOR=$EDITOR
  export GIT_EDITOR=$EDITOR
  export LANG="ru_RU.UTF-8"
  export OOO_FORCE_DESKTOP=gnome
  export LC_COLLATE=C
  export HISTCONTROL=ignorespace:erasedups
  export PATH="$HOME/.cabal/bin:$PATH"
  export PATH="$HOME/local/bin:$PATH"

  if env | grep -q SSH_CONNECTION= ; then
    if env | grep -q DISPLAY= ; then
      echo DISPLAY is $DISPLAY >/dev/null
      echo "export DISPLAY=$DISPLAY" > $HOME/.display
    else
      echo No DISPLAY was set >/dev/null
    fi
  fi

  cal()     { `which cal` -m "$@" ; }
  df()      { `which df` -h "$@" ; }
  duh()     { `which du` -hsx * .[^.]* "$@" | sort -h ; }
  man()     { LANG=C ${man}/bin/man "$@" ; }
  feh()     { ${feh}/bin/feh -. "$@" ; }

  q()       { exit ; }
  s() 		  {
              if test -z "$TMUX" ; then
                case `pwd` in
                  *proj/*) ${tmux}/bin/tmux new -s `pwd | xargs basename` "$@" ;;
                  *) ${tmux}/bin/tmux "$@" ;;
                esac
              else
                ${tmux}/bin/tmux new-window "$@"
              fi
            }
  e() 		  { thunar . 2>/dev/null & }
  lt() 		  { ls -lhrt "$@"; }

  log() 		{ ${vimbin} /var/log/messages + ; }
  logx() 		{ ${vimbin} /var/log/X.0.log + ; }

  cdt() 		{ cd $HOME/tmp ; }
  cdd()     { cd $HOME/dwnl; }
  cdnix()   { cd $HOME/proj/nixcfg ; }
  gitk() 		{ ${git}/bin/gitk "$@" & }
  gitka() 	{ ${git}/bin/gitk --all "$@" & }
  tiga()    { ${tig}/bin/tig --all "$@" ; }
  mcd() 		{ mkdir "$1" && cd "$1" ; }
  vimless() { ${vimbin} -R "$@" - ; }
  pfind() 	{ ${findutils}/bin/find -iname "*$1*" ; }

  manconf() { ${man}/bin/man configuration.nix ; }
  ding()    { ${aplay} ${../data/ding.wav} 2>/dev/null; }
  vim()     { if test -d "$1"; then
                ( dir="$1"; shift; exec ${vimbin} -c "NERDTreeToggle $dir" "$@" ; )
              elif test -z "$1" ; then
                ${vimbin} -c "NERDTreeToggle"
              else
                ${vimbin} "$@"
              fi
            }
  wn()      { ${wmctrl}/bin/wmctrl -r :ACTIVE: -T "$@";  }
  encfs()   { `which encfs` -i 60 "$@" ; }

  #
  # GIT Aliases
  #

  gf()      { git fetch github || ${git}/bin/git fetch origin ; }
  alias ga='git add'
  alias gai='git add -i'
  alias gap='git add -p'
  alias gb='git branch'
  alias gc='git commit'
  alias gca='git commit --amend --no-edit'
  alias gco='git checkout'
  alias gcp='git cherry-pick'
  alias gd='git diff'
  alias gg='git grep'
  alias gl='git log'
  alias gm='git merge'
  alias gp='git push'
  alias gpff='git pull --ff'
  alias gpr='git pull --rebase'
  alias gr='git reset'
  alias grh='git reset --hard'
  alias gri='git rebase -i'
  alias grm='git remote'
  alias grma='git remote add'
  alias grv='git remote -v'
  alias gs='git status'
  alias gsta='git stash pop'
  alias gstl='git stash list'
  alias gsts='git stash save'
  alias gsu='git submodule update'
  alias gsui='git submodule update --init'
  alias gsuir='git submodule update --init --recursive'
  alias gss='git submodule status'

  #
  # Custom aliases
  #

  # Set screen window name
  # sn() {
  #   PID=$(echo $STY | awk -F"." '{ print $1}')
  #   if test -n "$PID" ; then
  #     ${screen}/bin/screen -D -r "$PID" -X title "$@"
  #   else
  #     echo "Failed to get PID. Do you have GNU/Screen running?" >&2
  #   fi
  # }


''
