# banjOS CLI 

## Environment Variables
- `$BANJOS_CONFIG` - fully qualified path to the config directory e.g `home/jowi/.config/nix-config`
- `$FLAKE` - name of the current system e.g. `nixos` or `papa-laptop`. Searchable in `$BANJOS_CONFIG/flake.nix`
- `$BANJ_CLI_DIR` - fully qualified path to the config for this CLI. Default: `$HOME/.banj-cli

## Usage Options
- `banj | banj help` - print this help message
- `banj tune` - rebuild the environment to reflect any changes


