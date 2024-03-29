package help 

import "core:c/libc"
import "core:strings"


// Takes a context and prints a formatted help string
print :: proc(cont: string){
  cmd_bldr := strings.builder_make()
  strings.write_string(&cmd_bldr, "bat $BANJ_CLI_DIR/help/")
  strings.write_string(&cmd_bldr, cont)
  strings.write_string(&cmd_bldr, " --style=plain -f --theme=Dracula")

  cmd := strings.to_string(cmd_bldr)
  cmdc := strings.clone_to_cstring(cmd)
  libc.system(cmdc)
}
