package banj

// Odin Core
import "core:fmt"
import "core:c/libc"
import "core:os"
import "core:strings"

import banjos "os"
import ai "ai"
import help "help"

import "vendor/sqlite3"
import http "vendor/curl"

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
  defer delete(args)

  cmd:cstring = ``
  if error != nil || len(os.args) == 1 do cmd = help.print(.Banj)
  else {
    switch args[0] {
      case "tune", "rebuild":
        cmd = banjos.rebuild(cast_os()) or_else help.print(.Rebuild)
      case "sleep":
        cmd = banjos.sleep(cast_os()) or_else help.print(.Sleep)
      case "ai":
        cmd = ai.prompt(cast_os(), &args[1]) or_else help.print(.AI)
      // this command is mostly for creating new commands or testing out functionality for easy integration
      case "dbg":

        ai.print_logs(context.temp_allocator)
      case: 
        cmd = help.print(.Banj)
    }
  }
  if cmd != `` {
    status := libc.system(cmd)
    fmt.println(status)
  }
  return 
}

cast_os :: proc() -> banjos.SupportedOS {
  if ODIN_OS == .Darwin do return .Darwin
  return .Linux
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

