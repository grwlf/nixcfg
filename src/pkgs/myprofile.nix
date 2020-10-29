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

  for p in "/home/${me}/.cabal/bin" \
           "/home/${me}/.local/bin" \
           "/home/${me}/local/bin" \
           ; do
    if ! echo $PATH | grep -q "$p" ; then
      export PATH="$p:$PATH"
    fi
  done

  if env | grep -q SSH_CONNECTION= ; then
    if env | grep -q DISPLAY= ; then
      echo DISPLAY is $DISPLAY >/dev/null
      echo "$DISPLAY" > /home/${me}/.lastdisplay
      echo 'export DISPLAY=$(cat /home/${me}/.lastdisplay)' > /home/${me}/.display
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
                  *proj/*) ${tmux}/bin/tmux new -s `pwd | xargs basename` -A "$@" ;;
                  *) ${tmux}/bin/tmux "$@" ;;
                esac
              else
                ${tmux}/bin/tmux new-window "$@"
              fi
            }
  e() 		  { thunar . 2>/dev/null & }
  lt() 		  { ls -lhrt "$@"; }

  cdt() 		{ cd $HOME/tmp ; }
  cdd()     { cd $HOME/dwnl; }
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
  vimpriv() { if ! mount | grep -q ~/priv ; then
                `which encfs` -i 60 ~/.priv ~/priv "$@"
              fi
              vim ~/priv ;
            }
  p()       { myipython "$@" ; }
  ydla()    { ${youtube-dl}/bin/youtube-dl --extract-audio --audio-format=mp3 "$@" ; }

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

  ${xdg-user-dirs}/bin/xdg-user-dirs-update --set DOWNLOAD "$HOME/dwnl"
  ${xdg-user-dirs}/bin/xdg-user-dirs-update --set MUSIC "$HOME/music"
  ${xdg-user-dirs}/bin/xdg-user-dirs-update --set DOCUMENTS "$HOME/pers"
  ${xdg-user-dirs}/bin/xdg-user-dirs-update --set PICTURES "$HOME/photo"
  ${xdg-user-dirs}/bin/xdg-user-dirs-update --set TEMPLATES "$HOME/templ"
  ${xdg-user-dirs}/bin/xdg-user-dirs-update --set PUBLICSHARE "$HOME/pub"
  ${xdg-user-dirs}/bin/xdg-user-dirs-update --set VIDEOS "$HOME/video"

''
