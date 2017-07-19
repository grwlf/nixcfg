{ config, pkgs, ... } :

{

  environment.etc."myprofile".source =
    with pkgs;
    let

      git = gitAndTools.gitFull;

      gitbin = "${git}/bin/git";

      vimbin = "${myvim}/bin/vim-with-plugins";

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

      q() 		  { exit ; }
      s() 		  { ${screen}/bin/screen ; }
      e() 		  { thunar . 2>/dev/null & }
      lt() 		  { ls -lhrt "$@"; }

      log() 		{ ${vimbin} /var/log/messages + ; }
      logx() 		{ ${vimbin} /var/log/X.0.log + ; }

      cdt() 		{ cd $HOME/tmp ; }
      cdd()     { cd $HOME/dwnl; }
      gitk() 		{ LANG=C ${git}/bin/gitk "$@" & }
      gitka() 		{ LANG=C ${git}/bin/gitk --all "$@" & }
      mcd() 		{ mkdir "$1" && cd "$1" ; }
      vimless() { ${vimbin} -R "$@" - ; }
      pfind() 	{ ${findutils}/bin/find -iname "*$1*" ; }
      d() 	    { if test -z "$1" ; then
                    load-env-dev
                  else
                    load-env-dev-$1
                  fi
                }
      manconf() { ${man}/bin/man configuration.nix ; }
      ding()    { ${aplay} ${../data/ding.wav} 2>/dev/null; }

      #
      # GIT Aliases
      #

      gf()      { ${git}/bin/git fetch github || ${git}/bin/git fetch origin ; }
      alias ga='${gitbin} add'
      alias gai='${gitbin} add -i'
      alias gap='${gitbin} add -p'
      alias gb='${gitbin} branch'
      alias gc='${gitbin} commit'
      alias gca='${gitbin} commit --amend --no-edit'
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

      #
      # NIX aliases
      #

      nix_dev() { (
        N=$1; shift ;
        NIXPKGS_CONFIG=$NIX_DEV_ROOT/ideas/nixpkgs-config.nix \
          nix-shell '<nixpkgs>' -A "$N" "$@" ;
      ) }

      nix_env() { (
        NIXPKGS_CONFIG=$NIX_DEV_ROOT/ideas/nixpkgs-config.nix \
          nix-env -f '<nixpkgs>' "$@"
      ) }

      nix_unpack() { (
        NIXPKGS_CONFIG=$NIX_DEV_ROOT/ideas/nixpkgs-config.nix \
          nix-build '<nixpkgs>' -A $1.src --no-out-link | \
            grep /nix/store | xargs ${atool}/bin/aunpack
      ) }

      alias ne="nix_env"
      alias nu="nix_unpack"
      alias nd="nix_dev"


      #
      # Custom aliases
      #

      vim() {
        case "$1" in
          "") ${vimbin} .    ;;
           *) ${vimbin} "$@" ;;
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

      encfs() { `which encfs` -i 60 "$@" ; }

    '';
}

