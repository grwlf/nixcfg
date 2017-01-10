#! /usr/bin/env nix-shell
#! nix-shell --show-trace -i bash -p stack findutils haskell.packages.lts-6_17.ghc cabal2nix


CWD=`pwd`

# Base compiler used to generate Nix expressions
COMPILER=ghc7103
# Stack project to unstack
TGT="$CWD/nk"
# Working directory to place resulting expressions
WD="$CWD/.unstack-work"


mkdir "$WD"
cd "$WD"

#
# 1. Downloading dependencies, as specified by the stack
#

# Contents of the stack project, there may be more than one .yamls
contents=`cd $TGT ; find . -name "package.yaml"  | xargs cat | grep 'name:'`

(cd "$TGT" ; stack --system-ghc --no-install-ghc list-dependencies) | while read pkg ver ; do

    printf "%-15s " "$pkg"

    if echo $contents | grep -q -w "$pkg" ; then
        echo "package is included in stack project, skipping"
        continue
    fi


    if ! test -d $pkg-$ver ; then
        echo "new, downloaded"
        stack unpack $pkg-$ver
    else
        echo "directory already exists, skipping"
    fi

done



#
# 2. Generating Nix expressions
#

case $COMPILER in
    *ghc710*) CABAL2NIX_COMPILER="--compiler=ghc-7.10";;
    *) CABAL2NIX_COMPILER="" ;;
esac

for pkg in `find . -maxdepth 1 -mindepth 1 -type d`  ; do
    cabal2nix $CABAL2NIX_COMPILER --no-check --no-haddock $pkg > $pkg.nix
done



#
# 3. Building master expression all.nix
#

# Stoplist contains packages that are listed in the dependencies but at the same
# time are already included in GHC base packakge
STOPLIST=`ghc-pkg list | tail -n +2`

{

cat <<EOF
{ nixpkgs ? import <nixpkgs> {}, compiler ? "$COMPILER" }:

let

lib = nixpkgs.lib;

stdenv = nixpkgs.stdenv;

all = rec {

    ghcenv = nixpkgs.pkgs.haskell.packages.\${compiler};

    ghcpkgs = with ghcenv ; [];

    ghc = ghcenv.ghcWithPackages (x : ghcpkgs);

    callPackage = ghcenv.callPackageWithScope (ghcenv // pkgs // {
        inherit stdenv;
    } );

    pkgs = rec {

EOF

pkgs=`cd "$WD" ; find . -maxdepth 1 -mindepth 1 -type d`

for pkg in $pkgs  ; do
    spkg=`echo $pkg | sed 's@^\./@@' | sed 's@[-.0-9]*$@@' | sed 's@[.]@_@g' `
    if test "$spkg" = "base" ; then
        continue
    fi
    if cat GHCLIST | grep -q -w "$spkg" ; then
        echo "Skipping "$spkg" due to entry in STOPLIST" >&2
        continue
    fi
    echo "        $spkg = callPackage $pkg.nix {};"
done

cat <<"EOF"
    };
};
in all.pkgs
EOF

} >all.nix

