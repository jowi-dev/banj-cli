package banj

// Odin Core
import "core:fmt"
import "core:c/libc"
import "core:os"
import "core:strings"

import "./help"
import "./banj_os"

Error :: enum {
  Invalid_Format, 
  Invalid_Args,
  Unknown
}


main :: proc() {
  args, error := process_args()
  if len(os.args) == 1 do return
  // If the result really is false
  if error != nil {
    help.print("help.md")
    return
  }

  cmd:cstring
  switch args[0] {
    case "tune", "rebuild":
      cmd = banj_os.rebuild(auto_cast ODIN_OS) or_else banj_os.help()
    case "sleep":
      cmd = banj_os.sleep(auto_cast ODIN_OS) or_else banj_os.help()
    case: 
      help.print("help.md")
      return 
  }
  libc.system(cmd)
  return 
}

process_args :: proc() -> (args: [dynamic]string, error: Error) {
  if len(os.args) <= 1 do return args, Error.Invalid_Args

  error = Error.Invalid_Format
  for i := 0; i < len(os.args); i +=1{
    arg, ok := get_arg(os.args[i])
    if ok {
      error = nil
      append(&args, arg)
    }
  }
  // Either tell the user we didn't get any args, or return them
  return args, error
}

get_arg :: proc(arg: string) -> (found_arg: string = "", ok: bool = false) {
  // Naked returns will send the default found ^
  if strings.has_prefix(arg, "--") do return
  if strings.contains(arg, "/") do return

  return arg, true
}
