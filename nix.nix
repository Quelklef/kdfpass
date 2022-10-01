let

system = builtins.currentSystem;

pkgs =
  let
    rev = "02b279323f3b5b031cd8aeb6440d76f0b735855e";
    fetched = builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
  in import fetched { inherit system; };

npmlock2nix =
  let fetched = builtins.fetchGit {
        url = "https://github.com/tweag/npmlock2nix.git";
        rev = "dd2897c3a6e404446704a63f40b9a29fa0acf752";
      };
  in import fetched { inherit pkgs; };

gitignoreSource =
  let fetched = builtins.fetchGit {
        url = "https://github.com/hercules-ci/gitignore.nix";
        rev = "80463148cd97eebacf80ba68cf0043598f0d7438";
      };
  in (import fetched { inherit (pkgs) lib; }).gitignoreSource;

src = gitignoreSource ./.;

shell =
  pkgs.mkShell {
    buildInputs = with pkgs; [ nwjs nodejs-14_x entr ];
    shellHook = ''
      function devt {
        ls ./*.{html,json,js} | entr -cr bash -c 'KDFPASS_ARG=$(realpath ./kdfpass.json) nw .'
      }
    '';
  };

deriv =
  pkgs.stdenv.mkDerivation {
    name = "kdfpass";
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/bin
      cp ${src}/{index.html,package.json} $out
      cp -r ${npmlock2nix.node_modules { inherit src; }}/node_modules $out
      cat <<EOF > $out/bin/kdfpass
      KDFPASS_ARG="\$1" ${pkgs.nwjs}/bin/nw $out
      EOF
      chmod +x $out/bin/kdfpass
    '';
  };

in { inherit shell deriv; }
