dbuild:
	odin build . -debug

build:
	odin build .

test:
	odin test .

debug: 
	odin build . -debug && lldb ./banj-cli $1
