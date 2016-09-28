#!/bin/sh

me=`basename $0`

nix-channel --update
rev=`nix-instantiate --eval -E "(import ~/.nix-defexpr/channels/nixpkgs/default.nix {}).lib.nixpkgsVersion" |
  sed -n 's/.*pre.*\.\([a-z0-9]\+\).*/\1/g p' | tail -n 1`

if test -z "$rev" ; then
  echo "$me: Error obtaining channel info from nixos.org" >&2
  exit 1
fi
echo $rev

(
set -e
cd `dirname $0`/nixpkgs
b=`git rev-parse --abbrev-ref HEAD`
crev=`git merge-base $b origin/master`

gitlog() {
  git log --oneline $crev..$rev
}
ncomm=`{ gitlog || { git fetch ; gitlog ; }  }  | wc -l`
echo "$ncomm commits between the current merge-base `echo $crev | cut -c 1-7` and $rev" >&2
)



