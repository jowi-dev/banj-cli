{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, }:
    flake-utils.lib.eachDefaultSystem (system:
    let 
      pkgs = import nixpkgs { inherit system; }; 
      additionalInputs = if system == "x86_64-linux" then [pkgs.btop pkgs.wavemon] else [];
      buildInputs = with pkgs; [odin openssl sqlite curl] ++ additionalInputs;
      docPath = "doc/banj-cli/md";
    in {
        devShells.default = pkgs.mkShell {
          buildInputs = buildInputs ++  [ pkgs.valgrind ];
        };
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "banj-cli";
          version = "0.0.0";
          src = ./.;
          doCheck=true;
          inherit buildInputs;
          installPhase = ''
#/etc/profiles/per-user/$USER/share/doc/banj-cli/md/
            mkdir -p $out/bin
            mkdir -p $out/${docPath}
            mv banj $out/bin
            mv docs/* $out/${docPath}

            ./$out/bin/banj init
          '';
        };
      });
}
