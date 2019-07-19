{pkgs, xscreensaver-run, rss-glx}:
pkgs.writeShellScriptBin "mylock.sh" ''
  #!/bin/sh

  echo 1 >/var/run/autolykos_enabled
  echo 0 >/var/run/autolykos_delay

  ${xscreensaver-run}/bin/xscreensaver-run ${rss-glx}/bin/biof --lightmap

  # echo 0 > /var/run/autolykos_enabled
  echo 30 >/var/run/autolykos_delay
  ''
