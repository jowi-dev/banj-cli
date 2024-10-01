package banj

// Odin Core
import "core:fmt"
import "core:c/libc"
import "core:os"
import "core:strings"

import banjos "os"
import ai "ai"
import help "help"

import sqlite "vendor/sqlite3"
import http "vendor/curl"

Error :: enum {
  Invalid_Format, 
  Invalid_Args,
  Unknown
}

/*
* TODO 
* - AI Commands - for sure new project - MVP DONE - /ai/banj_ai.odin
* - Garbage collect both generations and derivations - banj_os.odin
* - GC Home manager? - put in banj_os.odin
* - Project CLI. Maybe seperate project
* - Monitoring commands - DONE - /os/monitor.odin
* - Display commands - DONE - /os/display.odin
*/
main :: proc() {
  args, error := process_args()
  defer delete(args)

  cmd:cstring = ``
  if error != nil || len(os.args) == 1 do cmd = help.print(.Banj)
  else {
    switch args[0] {
      case "tune", "rebuild":
        // This will eventually need docs on profile switching
        cmd = banjos.rebuild(cast_os()) or_else help.print(.Rebuild)
      case "sleep":
        cmd, _ = banjos.sleep(cast_os()) 
      case "monitor":
        cmd = banjos.monitor(cast_os(), &args[1]) or_else help.print(.Monitor) // needs to be monitor
      case "display":
        cmd = banjos.display(cast_os(), &args[1]) or_else help.print(.Display) // needs to be display
      case "ai":
        db_name := os.get_env("BANJ_DB")
        cmd = ai.prompt(cast_os(), &args[1], db_name) or_else help.print(.AI)
      case "dbg":
        // this command is mostly for creating new commands or testing out functionality for easy integration
        ai.print_logs(context.temp_allocator)
      case "query":
        db_name := os.get_env("BANJ_DB")
        // useful for ad-hoc querying of our local db
        db : ^sqlite.Sqlite3 = sqlite.connect_db(db_name, context.temp_allocator)
        sqlite.query(args[1], db, context.temp_allocator)
        defer free_all(context.temp_allocator)
      case "init":
        db_name := os.get_env("BANJ_DB")
        // useful to setup DB tables
        if os.exists(db_name) do return
        db : ^sqlite.Sqlite3 = sqlite.connect_db(db_name, context.temp_allocator)
        defer free_all(context.temp_allocator)
        sqlite.create_table(ai.CREATE_STATEMENT, db)
      case: 
        cmd = help.print(.Banj)
    }
  }
  if cmd != `` {
    status := libc.system(cmd)
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
  for i := 1; i < len(os.args); i +=1{
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

