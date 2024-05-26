{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, }:
    flake-utils.lib.eachDefaultSystem (system:
    let 
      pkgs = import nixpkgs { inherit system; }; 
      buildInputs = with pkgs; [odin openssl sqlite curl];
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
          mkdir -p $out/bin
          mv banj $out/bin
          '';
        };
      });
}
