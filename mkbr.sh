#!/bin/sh

ME=mkbr.sh
die() { echo $ME: $@ >&2 ; exit 1; }

echo $@ | grep -qwE -e '-h|--help' && {
  echo "$ME <commits> - Cherry pick the commits specified to a new branch derived directly from the master" >&2
  return 1
}

echo $@ | grep -qwE -e '-f|--force' && {
  FORCE=y
}

args=`echo "$@" | grep -v -e '-.*'`

set -e

if test -z "$args" ; then
  # cmts=`git rev-parse HEAD`
  crev=`git merge-base HEAD origin/master`
  cmts=`git log --reverse --oneline $crev..HEAD | awk '{print $1}'`
else
  cmts=`git rev-parse "$args"`
fi

cwd=`pwd`
cd $NIX_DEV_ROOT/nixpkgs

echo -n "Enter name for the git branch: "
read bname

(
set -x
cb=`git branch --list | grep '*' | awk '{print $2}'`
base=`git merge-base "$cb" origin/master`
{ git branch $bname $base || {
    if test "$FORCE" = "y" ; then
      git branch -D "$bname"
      git branch "$bname" "$base"
    else
      echo "$ME: branch $bname exists? Well, OK" ;
    fi
  }
}
git checkout "$bname"
git cherry-pick $cmts
git rebase -i $base
git checkout "$cb"
) >&2

if [ "$?" != "0" ] ; then {
  echo "$ME: Cherry-picking failed. Do some git magic to fix it."
  } >&2
  return 1
fi

cd $cwd
