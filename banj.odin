package banj

import "core:fmt"
import "core:c/libc"
import "core:os"
import "core:strings"
import "tune"
import "help"

Error :: enum {
  Invalid_Format, 
  Unknown
}

main :: proc() {
  args, error := process_args()
  // If the result really is false
  if error != nil {
    help.print("help.md")
    return
  }

  for i:=0; i < len(args); i+=1{
    fmt.println(args[i])
  }

  switch args[0] {
    case "tune":
      // send args to tune
      //ordered_remove(&args, 0)
      tune.tune(args)
      return
    case: 
      help.print("help.md")
  }
  fmt.println("Done")
}

process_args :: proc() -> (args: [dynamic]string, error: Error) {
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
