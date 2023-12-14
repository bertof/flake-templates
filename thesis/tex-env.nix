# Generated with tex2nix 0.0.0
{ texlive, extraTexPackages ? { } }:
(texlive.combine ({
  inherit (texlive) scheme-small;
  # "subfigure" = texlive."subfigure";
  # "xfor" = texlive."xfor";
  # "cite" = texlive."cite";
  # "supertabular" = texlive."supertabular";
  # "amsmath" = texlive."amsmath";
  # "url" = texlive."url";
  # "listings" = texlive."listings";
  # "enumitem" = texlive."enumitem";
  # "textcase" = texlive."textcase";
  # "xkeyval" = texlive."xkeyval";
  # "glossaries" = texlive."glossaries";
  # "mfirstuc" = texlive."mfirstuc";
  # "mathtools" = texlive."mathtools";
  # "makecell" = texlive."makecell";
  # "tracklang" = texlive."tracklang";
  # "xcolor" = texlive."xcolor";
  # "etoolbox" = texlive."etoolbox";
  # "soul" = texlive."soul";
  # "psfrag" = texlive."psfrag";
  # "booktabs" = texlive."booktabs";
  # "arydshln" = texlive."arydshln";
  # "graphics" = texlive."graphics";
  # "multirow" = texlive."multirow";
} // extraTexPackages))
