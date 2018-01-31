#!/bin/sh

ME=mkbr.sh
die() { echo $ME: $@ >&2 ; exit 1; }

FORCE=n
args=""
bname=""
while test -n "$1" ; do
  case "$1" in
    -h|--help)
      echo "$ME [-f] branch-name [commits] - Cherry pick the commits specified to a new branch derived directly from the master" >&2
      exit 1
      ;;
    -f|--force)
      FORCE=y
      ;;
    *)
      if test -z "$bname" ; then
        bname="$1"
      else
        if test -n "$args" ; then
          args="$args $1";
        else
          args="$1"
        fi
      fi
      ;;
  esac
  shift
done

set -e

if test -z "$bname" ; then
  die "Invalid branch name, see -h|--help"
fi

# basebranch=`git for-each-ref --format='%(upstream:short)' $(git symbolic-ref -q HEAD)`
basebranch=origin/master
if test -z "$basebranch" ; then
  die "Remote-tracing branch is not set"
fi

if test -z "$args" ; then
  # cmts=`git rev-parse HEAD`
  crev=`git merge-base HEAD $basebranch`
  cmts=`git log --reverse --oneline $crev..HEAD | awk '{print $1}'`
else
  cmts=`git rev-parse "$args"`
fi

(
set -x
cb=`git branch --list | grep '*' | awk '{print $2}'`
base=`git merge-base "$cb" $basebranch`
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
