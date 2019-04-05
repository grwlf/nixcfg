#!/bin/sh

config="$1"
if ! test -f "$config" ; then
  echo "Usage: $0 <config_rel_path>" >&2
  exit 1
fi

set -e -x

CWD=`dirname $0`
export NIX_DEV_ROOT=`cd $CWD; pwd`
export NIX_PATH="nixpkgs=$NIX_DEV_ROOT/nixpkgs:nixos=$NIX_DEV_ROOT/nixpkgs/nixos:nixos-config=$NIX_DEV_ROOT/$config:passwords=$NIX_DEV_ROOT/pass"

nixos-rebuild switch
