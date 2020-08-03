#!/bin/sh

if test "$USER" != "grwlf" ; then
  SUFFIX="-$USER"
else
  SUFFIX=""
fi

/var/run/current-system/sw/bin/nix-build src/pkgs/myenv${SUFFIX}.nix \
  --argstr me $USER \
  -o /tmp/result-env  \
  -K && \
/var/run/current-system/sw/bin/nix-env -i /tmp/result-env
