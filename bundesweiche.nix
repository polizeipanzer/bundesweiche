{ pkgs, ... }:
let
  bundesweiche-src = pkgs.fetchFromGitHub {
    owner = "codemonauts";
    repo = "bundesedit";
    rev = "master";
    sha256 = "sha256-VjmnuSPFikd20LgH1+wbKlIUw11pZkaHoWaTCIRzZdY";
  };
in
  pkgs.runCommand "bundesweiche-nginx" {} ''
    for category in bundesedit euroedit landesedit; do
      echo "# $category.json"
      cat ${bundesweiche-src}/$category.json |
        ${pkgs.jq}/bin/jq -r 'map(.ranges[])' |
        sed -r 's/  "//;s/"//;s/,//;s/\]//;s/\[//;s/\.0\//\.\*\//;s_/[0-9]+$__' |
        grep -v -E '^$' |
        sed 's/$/ 1\;/' |
        ${pkgs.util-linux}/bin/column -t
    done > $out
  ''
