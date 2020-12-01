let
  generatePackage = { name, tagLine, commentLines, requireList, code }:
    let
      prelude = generatePrelude { inherit name tagLine commentLines; };
      requires = generateRequires requireList;
      postlude = generatePostlude name;
    in
    ''
      ${prelude}

      ${requires}

      ${code}

      ${postlude}
    '';

  generatePrelude = { name, tagLine, commentLines }:
    let
      generated = "This file is generated! DO NOT CHANGE!";
      comments = builtins.concatStringsSep "\n"
        (builtins.map (l: if l == "" then "" else ";; ${l}") commentLines);
    in
    ''
      ;;; ${name} --- ${tagLine}

      ;;; Commentary:

      ${comments}

      ;;; Code:
    '';

  generatePostlude = name: ''
    (provide '${name})
    ;;; ${name}.el ends here
  '';

  generateRequires = list:
    let
      sorted = builtins.sort (l: r: l < r) list;
      required = builtins.map (r: "(require '${r})") sorted;
    in
    builtins.concatStringsSep "\n" required;

in
{
  emacs.generatePackage = name: tagLine: commentLines: requireList: code:
    generatePackage {
      inherit name code tagLine commentLines requireList;
    };
}
