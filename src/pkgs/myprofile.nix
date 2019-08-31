{ pkgs ? import <nixpkgs> {}, myvim, me } :

with pkgs;
let
  vimbin = "${myvim}/bin/vim";

  aplay = "${alsaUtils}/bin/aplay";
in
pkgs.writeText "myprofile.sh" ''
  export EDITOR=${vimbin}
  export VERSION_CONTROL=numbered
  export SVN_EDITOR=$EDITOR
  export GIT_EDITOR=$EDITOR
  export OOO_FORCE_DESKTOP=gnome
  export LC_COLLATE=C
  export HISTCONTROL=ignorespace:erasedups
  export PATH="/home/${me}/.cabal/bin:$PATH"
  export PATH="/home/${me}/local/bin:$PATH"

  if env | grep -q SSH_CONNECTION= ; then
    if env | grep -q DISPLAY= ; then
      echo DISPLAY is $DISPLAY >/dev/null
      echo "export DISPLAY=$DISPLAY" > /home/${me}/.display
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
  gitk() 		{ `which gitk` "$@" & }
  gitka() 	{ `which gitk` --all "$@" & }
  tiga()    { tig --all "$@" ; }
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
  encpriv() { `which encfs` -i 60  ~/.priv ~/priv "$@" ; }
  p()       { nix-shell -p pkgs.python3Packages.ipython \
                           pkgs.python3Packages.pandas \
                           pkgs.python3Packages.matplotlib \
                     --run ipython ; }

  ydla()    { ${youtube-dl}/bin/youtube-dl --extract-audio --audio-format=vorbis "$@" ; }

  #
  # GIT Aliases
  #

  gf() { git fetch ; }
  gfp() { git fetch "$1" "pull/$2/head:$3" ; }
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
  alias gl1='git log --oneline'
  alias glc='git log --reverse --color | cat ; git commit -F -'
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

''
