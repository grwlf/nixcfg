{ stdenv, bash, writeText, coreutils, gnugrep, gnused, findutils, xsel, xvkbd,
 xdotool }:

let
  mkscript = path : text : ''
    mkdir -pv `dirname ${path}`
    cat > ${path} <<"EOF"
    #!${bash}/bin/bash
    ME=`basename ${path}`
    ${text}
    EOF
    sed -i "s@%out@$out@g" ${path}
    chmod +x ${path}
  '';

  binxsel = "${xsel}/bin/xsel";
  binxvkbd = "${xvkbd}/bin/xvkbd";
  binxdotool = "${xdotool}/bin/xdotool";

in
stdenv.mkDerivation {
  name = "handyscripts-1.0";

  builder = writeText "builder.sh" ''
    . $stdenv/setup
    ${mkscript "$out/bin/xpaste" ''
      ${binxdotool} type "`${binxsel}`"
    ''}
    ${mkscript "$out/bin/lockhyb" ''
      i3lock -d && xfce4-session-logout --suspend
    ''}
  '';

  meta = {
    description = "Photofetcher is a tool which fetches photos from a remote media";
    maintainers = with stdenv.lib.maintainers; [ smironov ];
    platforms = with stdenv.lib.platforms; linux;
  };
}

