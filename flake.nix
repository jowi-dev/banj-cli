{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };
  
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
      
      # System-specific dependencies
      additionalInputs = if system == "x86_64-linux" then 
        [pkgs.btop pkgs.wavemon] 
      else [];
      
      # Common build inputs for both platforms
      commonBuildInputs = with pkgs; [
        # Build tools
        cmake
        gcc
        pkg-config
        
        # Core dependencies
        openssl
        sqlite
        curl
        catch2_3
        
        # Development tools
        gdb
        lldb # Especially useful for Darwin
        
        # Library dependencies
        boost
        fmt
      ];
      
      # Platform-specific compiler settings
      stdenv = if system == "x86_64-darwin" then
        pkgs.darwin.apple_sdk.stdenv
      else
        pkgs.stdenv;
        
      docPath = "doc/banj-cli/md";
      
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = commonBuildInputs ++ additionalInputs;
        
        # Platform-specific shell settings
        shellHook = ''
          export CPATH=${pkgs.catch2_3}/include:$CPATH
          export LIBRARY_PATH=${pkgs.catch2_3}/lib:$LIBRARY_PATH
          ${if system == "x86_64-darwin" then ''
            export SDKROOT=${pkgs.darwin.apple_sdk.sdk}
          '' else ""}
        '';
      };
      
      packages.default = stdenv.mkDerivation {
        pname = "banj-cli";
        version = "0.0.1";
        src = ./.;
        
        # Build dependencies
        nativeBuildInputs = with pkgs; [
          cmake
          pkg-config
        ];
        
        buildInputs = commonBuildInputs ++ additionalInputs;
        
        # Enable tests with Catch2
        doCheck = true;
        checkPhase = ''
          ctest --output-on-failure
        '';
        
        # CMake configuration flags
        cmakeFlags = [
          "-DCMAKE_BUILD_TYPE=Release"
          "-DBUILD_TESTING=ON"
          "-DUSE_CATCH2=ON"
        ] ++ (if system == "x86_64-darwin" then [
          "-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15"
        ] else []);
        
        installPhase = ''
          mkdir -p $out/bin
          mkdir -p $out/${docPath}
          
          # Install binary
          install -Dm755 banj $out/bin/banj
          
          # Install documentation
          if [ -d docs ]; then
            cp -r docs/* $out/${docPath}/
          fi
          
          # Install CMake configuration files
          mkdir -p $out/lib/cmake/banj-cli
          install -Dm644 cmake/banj-cli-config.cmake $out/lib/cmake/banj-cli/
          
          # Create pkg-config file
          mkdir -p $out/lib/pkgconfig
          cat > $out/lib/pkgconfig/banj-cli.pc << EOF
          prefix=$out
          exec_prefix=\''${prefix}
          libdir=\''${prefix}/lib
          includedir=\''${prefix}/include
          
          Name: banj-cli
          Description: C++ CLI tool for system management
          Version: 0.0.1
          Libs: -L\''${libdir} -lbanj-cli
          Cflags: -I\''${includedir}
          EOF
        '';
        
        meta = with pkgs.lib; {
          description = "C++ CLI tool for system management";
          homepage = "https://github.com/yourusername/banj-cli";
          license = licenses.mit;
          platforms = platforms.unix;
          maintainers = with maintainers; [ /* your maintainer name */ ];
        };
      };
    });
}
