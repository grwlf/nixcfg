{pkgs, xscreensaver-run, rss-glx}:
pkgs.writeShellScriptBin "xflock4" ''
  #!/bin/sh

  echo 1 >/var/run/autolykos_enabled
  echo 0 >/var/run/autolykos_delay

  # ${xscreensaver-run}/bin/xscreensaver-run ${rss-glx}/bin/biof --lightmap
  ${xscreensaver-run}/bin/xscreensaver-run glslideshow -root -delay 15000 -zoom 94 -pan 20

  # echo 0 > /var/run/autolykos_enabled
  echo 30 >/var/run/autolykos_delay
  ''
