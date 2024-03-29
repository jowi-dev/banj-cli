{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; }; 
      in with pkgs; {
        devShells.default = mkShell {
          shellHook = ''
            #abbr --add joe 'echo "hello joe"';
            echo "TODO - add some build aliases and test commands -- THESE ARE BROKEN";
            alias build='odin build . -debug';
            alias test='odin test .';
            alias debug='lldb ./banj-cli $1';
            alias hello='echo "hello $1"';
            export BANJ_CLI_DIR=.;

            #exec $SHELL && exit;
          '';
#          LD_LIBRARY_PATH = "$LD_LIBRARY_PATH:${
#              with pkgs;
#              pkgs.lib.makeLibraryPath [
#                # for raylib and openGL
#                pkgs.libGL
#                pkgs.xorg.libX11
#                pkgs.xorg.libXi
#
#                # for SDL and SDL2
#                pkgs.SDL2
#                pkgs.SDL2_mixer
#                pkgs.SDL
#
#                # for vulkan and GLFW
#                pkgs.vulkan-loader
#                pkgs.glfw
#              ]
#            }";

          buildInputs = [
            pkgs.odin
            # TODO - I want to get this working
            # https://odin-lang.org/docs/install/#for-macos
#            (odin.overrideAttrs (finalAttr: prevAttr: {
#
#              src = fetchFromGitHub {
#                owner = "odin-lang";
#                repo = "Odin";
#                rev = "dev-2023-11"; # version of the branch
#                hash = "sha256-5plcr+j9aFSaLfLQXbG4WD1GH6rE7D3uhlUbPaDEYf8=";
#                # name = "${finalAttr.pname}-${finalAttr.version}"; # not gona work .
#              };
#
#              preBuild = ''
#
#                echo "# for use of STB libraries"
#                cd vendor/stb/src
#                make
#                cd ../../..
#
#              '';
#
#            }))

#            # SDL
#            pkgs.SDL2
#            pkgs.SDL2_mixer
#            pkgs.SDL
#
#            # GLFW
#            pkgs.glfw
#
#            # vulkan
#            pkgs.vulkan-headers
#            pkgs.vulkan-loader
#            pkgs.vulkan-tools
#
#            # x11 and raylib stuff
#            pkgs.glxinfo
#            pkgs.lld
#            pkgs.gnumake
#            pkgs.xorg.libX11.dev
#            pkgs.xorg.libX11
#            pkgs.xorg.libXft
#            pkgs.xorg.libXi
#            pkgs.xorg.libXinerama
#            pkgs.libGL

            ## not need because of vendor
            # stb
            # lua

            # TODO - set these up so others can contribute
            # debugging stuff and profile
#            pkgs.valgrind
#            pkgs.rr
#            pkgs.gdb
#            pkgs.lldb
#            pkgs.gf
#
#            # Graphics Debugger
#            pkgs.renderdoc
#
#
#            # needed for raylib
#            pkgs.xorg.libXcursor
#            pkgs.xorg.libXrandr
#            pkgs.xorg.libXinerama
          ];
        };
      });
}
