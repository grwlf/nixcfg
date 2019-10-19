{ lib, xfce }:

lib.overrideDerivation (xfce4-14.xfce4_xkb_plugin) (o:{
  name = o.name + "-patched";
});
