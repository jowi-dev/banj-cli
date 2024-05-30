package banj_help

import "core:testing"

@(test)
outputs_path_to_md_file :: proc(_: ^testing.T) {
  cmd :string = auto_cast print(.Banj)

  assert(cmd == "bat /etc/profiles/per-user/$USER/share/doc/banj-cli/md/help.md --style=plain -f --theme=Dracula")
}
