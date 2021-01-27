{ stdenv, fetchFromGitHub, pkgconfig, deadbeef, gtkmm3, libxmlxx3 }:

stdenv.mkDerivation {
  name = "deadbeef-lyricbar-plugin";

  src = fetchFromGitHub {
    owner = "loskutov";
    repo = "deadbeef-lyricbar";
    rev = "015379a6a209c4b4358a3a13aa21f27f42326a8e";
    sha256 = "1kk1drd3lwkbgg2hdydnsz0v4gyfb7sxw8g60m9g58dj0i2vrssy";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ deadbeef gtkmm3 libxmlxx3 ];

  buildFlags = [ "gtk3" ];
}

