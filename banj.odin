package banj

// Odin Core
import "core:fmt"
import "core:c/libc"
import "core:os"
import "core:strings"

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
  if error != nil || len(os.args) == 1 do cmd = help(.Banj)
  else {
    switch args[0] {
      case "tune", "rebuild":
        cmd = rebuild(cast_os()) or_else help(.Rebuild)
      case "sleep":
        cmd = sleep(cast_os()) or_else help(.Sleep)
      case "ai":
        cmd = ai(cast_os(), &args[1]) or_else help(.AI)
      case "dbg_ai":
        // todo - this should be implemented as a flag
        sqlite3.read_rows(``, context.temp_allocator)
        defer free_all(context.temp_allocator)
      case "curl":
        body := make(map[string]string)
        defer delete(body)
        body["hello"] = "world";

        header := make(map[string]string)
        defer delete(header)
        header["Content-Type"] = "application/json"
        //http.post(`http://localhost:3000`, body, &headers)
        resp := http.post(`http://localhost:3000`, body, header, context.temp_allocator)
        fmt.println("resp is")
        fmt.println(resp)
        defer free_all(context.temp_allocator)
        
      case: 
        cmd = help(.Banj)
    }
  }
  if cmd != `` {
    status := libc.system(cmd)
    fmt.println(status)
  }
  return 
}

cast_os :: proc() -> SupportedOS {
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
