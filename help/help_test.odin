package banj

import "core:testing"

@(test)
outputs_path_to_md_file :: proc(_: ^testing.T) {
  cmd :string = auto_cast help(.Banj)

  assert(cmd == "bat $BANJ_CLI_DIR/docs/help.md --style=plain -f --theme=Dracula")
}

