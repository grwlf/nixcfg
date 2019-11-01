#!/bin/sh

if test -n "$1" ; then
  SUFFIX="-$1"
else
  SUFFIX=""
fi

nix-build src/pkgs/myenv${SUFFIX}.nix --argstr me $USER && nix-env -i ./result
