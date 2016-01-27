# let
#   system = "x86_64-linux";
#   pkgs = import <nixpkgs> {inherit system;};
# in
# with pkgs;
{ stdenv, bash, writeShellScriptBin, ffmpeg, yad, gnused, xterm, gnugrep }:
let
  byad = "${yad}/bin/yad";
  bffmpeg = "${ffmpeg}/bin/ffmpeg";
  bsed = "${gnused}/bin/sed";
in
stdenv.mkDerivation {

  name = "videoconvert-1.0";

  buildCommand = ''
    cp -r -v ${writeShellScriptBin "videoconvert" ''
        echo "ffmpeg is ${ffmpeg}"
        echo "yad is ${yad}"

        set -e -x

        S="$1"
        EXT=`echo "$S" | ${bsed} 's/\(.*\)\.//'`
        test -f "$S"
        D=`${byad} --file --save --confirm-overwrite="Переписать файл?"`
        T=`mktemp`

        ${xterm}/bin/xterm -e "${bffmpeg} -i '$S' -r 25 -strict -2  '$T.$EXT' && cp -v '$T.$EXT' '$D' ; echo Done ; read"
        rm "$T" "$T.$EXT"

      ''} $out
  '';

  meta = {
    maintainers = with stdenv.lib.maintainers; [ smironov ];
    platforms = with stdenv.lib.platforms; linux;
  };
}

