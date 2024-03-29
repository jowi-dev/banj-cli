package banj

// Odin Core
import "core:fmt"
import "core:c/libc"
import "core:os"
import "core:strings"

Error :: enum {
  Invalid_Format, 
  Invalid_Args,
  Unknown
}

/*
* TODO 
* - AI Commands - for sure new project
* - Garbage collect both generations and derivations
* - GC Home manager?
* - Project CLI. Maybe seperate project
* - Monitoring commands
* - Display commands
*/
main :: proc() {
  args, error := process_args()

  cmd:cstring
  if error != nil || len(os.args) == 1 do cmd = help(.Banj)
  else {
    switch args[0] {
      case "tune", "rebuild":
        cmd = rebuild(auto_cast ODIN_OS) or_else help(.Rebuild)
      case "sleep":
        cmd = sleep(auto_cast ODIN_OS) or_else help(.Sleep)
      case: 
        cmd = help(.Banj)
    }
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

get_arg :: proc(arg: string) -> (result: string, ok: bool = true) {
  if strings.has_prefix(arg, "--") do return "", !ok
  if strings.contains(arg, "/") do return "", !ok

  return arg, ok
}
