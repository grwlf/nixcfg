{pkgs, urxvt}:
pkgs.writeShellScriptBin "urxvtb" ''
  #!/bin/sh

  WP=`ls $HOME/pers/wallpapers/terminal-dark-* | sort -R | head -n 1`
  # WP=`ls $HOME/pers/images/* | sort -R | head -n 1`
  cp "$WP" "/tmp/background-$USER"
  ${urxvt}/bin/urxvt -pe background --background-expr "shade -0.5, cover load \"/tmp/background-$USER\"" "$@"
''
