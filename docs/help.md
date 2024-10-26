# banjOS CLI 

## Environment Variables
- `$BANJOS_CONFIG` - fully qualified path to the config directory e.g `home/jowi/.config/nix-config`
- `$FLAKE` - name of the current system e.g. `nixos` or `papa-laptop`. Searchable in `$BANJOS_CONFIG/flake.nix`
- `$BANJ_DB` - path and name of the sqlite db you would like to save history to. e.g. `my-cmds.db`

## Usage Options
- `banj | banj help` - print this help message
- `banj tune | rebuild` - rebuild the environment to reflect any changes
- `banj sleep` - put the computer in a low power mode
- `banj monitor` - commands related to various process monitoring. `banj monitor` will display more information
- `banj display` - commands for dealing with physical outputs. `banj display` will show further options.
- `banj project` - project related commands. `banj project` will display more help
- `banj gc | banj gc-all` - commands for managing nix store size
- `banj ai` - commands for prompting the LLM dejour
- `banj query` - commands for viewing local db records. Performs a sql query as entered. e.g. `banj query "select * from interactions"`

