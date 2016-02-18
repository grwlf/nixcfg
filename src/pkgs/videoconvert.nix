# { stdenv, bash, writeShellScriptBin, ffmpeg, yad, gnused, xterm, gnugrep }:
{ pkgs ? import <nixpkgs> {} } :
with pkgs;
let
  byad = "${yad}/bin/yad";
  bffmpeg = "${ffmpeg}/bin/ffmpeg";
  bsed = "${gnused}/bin/sed";
in
stdenv.mkDerivation {

  name = "videoconvert-1.0";

  buildCommand = ''
    cp -r -v ${writeShellScriptBin "videoconvert" ''
        set -e -x

        while test -n "$1" ; do

          S="$1"
          EXT=`echo "$S" | ${bsed} 's/\(.*\)\.//'`
          test -f "$S"
          D=`${byad} --file --save --confirm-overwrite="Переписать файл?" --filename="$S" --geometry=750x500`
          test -n "$D"
          T=`mktemp`

          ${xterm}/bin/xterm -e " { ${bffmpeg} -i '$S' -r 25 -strict -2 '$T.$EXT' ; mv --verbose '$T.$EXT' '$D' ; echo Done ; } || read "

          rm "$T" "$T.$EXT" || true

          shift
        done

      ''} $out
  '';

  meta = {
    maintainers = with stdenv.lib.maintainers; [ smironov ];
    platforms = with stdenv.lib.platforms; linux;
  };
}

