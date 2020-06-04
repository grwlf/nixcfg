{ config, pkgs, ... } :
{

  fonts = {
    fontconfig.enable = true;
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs ; [
      corefonts
      liberation_ttf
      ttf_bitstream_vera
      dejavu_fonts
      terminus_font
      terminus_font_ttf
      bakoma_ttf
      bakoma_ttf
      ubuntu_font_family
      vistafonts
      unifont
      freefont_ttf
    ];
  };
}

