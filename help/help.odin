package banj_help

import "core:c/libc"
import "core:strings"

Context :: enum {
  Banj,
  Rebuild,
  Sleep,
  AI
}

// Takes a context and prints a formatted help string
print :: proc(cont: Context) -> cstring{
  cmd_bldr := strings.builder_make()
  // TODO - this should not be hardcoded
  strings.write_string(&cmd_bldr, "bat $BANJ_CLI_DIR/docs/")
  strings.write_string(&cmd_bldr, get_help(cont))
  strings.write_string(&cmd_bldr, " --style=plain -f --theme=Dracula")

  cmd := strings.to_string(cmd_bldr)
  return strings.clone_to_cstring(cmd)
}

@(private)
get_help :: proc(cont: Context) -> string {
  switch cont {
    case .Banj:
      return "help.md"
    case .Rebuild:
      return "rebuild.md"
    case .Sleep:
      return "sleep.md"
    case .AI: 
      return "ai.md"
    case: 
      return "help.md"
  }
}
