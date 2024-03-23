package banj

import "core:fmt"
import "core:c/libc"
import "core:os"
import "core:strings"
import "tune"

main :: proc() {
  args := process_args()
  _, ok := args.(bool)
  // If the result really is false
  if ok {
    help_message()
    return
  }
  args_vec := args.([dynamic]string)
  switch args_vec[0] {
    case "tune":
      tune.tune()
    case: 
      help_message()
  }
  fmt.println("done parsing args!")
  flags := process_flags()
  fmt.println("done parsing flags!")
  libc.system("echo 'fuck yes'")
}

help_message :: proc() {
  fmt.println("TODO - help the user")
}

process_args :: proc() -> union #no_nil {bool, [dynamic]string} {
  args: [dynamic]string
  has_args := false
  for i := 0; i < len(os.args); i +=1{
    arg := get_arg(os.args[i])
    if arg != false {
      has_args = true
      fmt.println(arg.(string))
      append(&args, arg.(string))
    }
  }
  // Either tell the user we didn't get any args, or return them
  if !has_args do return false
  return args
}

// I currently have no use for flags, but this
// was an easy way to get started
process_flags :: proc() -> [dynamic]string{
  flags: [dynamic]string
  for i := 0; i < len(os.args); i += 1{
    flag := get_flag(os.args[i])
    if flag != false {
      //Get the flag as a string
      flag_name:string = flag.(string)
      append(&flags, flag_name)
      fmt.println(flag)
    }
  }
  return flags
}

// Args are described as any alphanumeric input following the base command
// itself
get_arg :: proc(arg: string) -> union{string, bool} {
  if strings.has_prefix(arg, "--") do return false
  if strings.contains(arg, "/") do return false

  return arg
}

get_flag :: proc(arg: string) -> union{string, bool} {
  head, match, tail := strings.partition(arg, "--")

  if match == "--" && head == "" do return tail
  return false
}
