# Nix buildPhase
default:
	odin build . -out:banj

# Nix installPhase
install:
	cp banj $out/bin/banj && chmod +x $out/bin/banj

# Nix checkPhase
check:
	odin test .


dbuild:
	odin build . -debug

build:
	odin build .

test:
	odin test .

debug: 
	odin build . -debug && lldb ./banj-cli $1
