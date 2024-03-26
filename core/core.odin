package core

import "core:fmt"
import "core:c/libc"


rebuild :: proc() -> (success: bool) {
  cmd :cstring
  #partial switch ODIN_OS {
    case .Linux: 
      cmd = "sudo nixos-rebuild switch --flake $CONFIG_DIR/.#$FLAKE"
    case .Darwin:
      cmd = "darwin-rebuild switch --flake $CONFIG_DIR/.#FLAKE"
    case .Windows:
      fmt.println("Windows not supported")
      return false
    case:
      fmt.println("Can't tune something that ain't a banjo")
      return false
  }

  return run_cmd(cmd)
}

sleep :: proc() -> (success:bool){
  cmd: cstring
 #partial switch ODIN_OS {
  case .Linux:
    cmd = "systemctl hibernate"
  case: 
    fmt.println("Command not supported on current system")
    return false
 }
 return run_cmd(cmd)
}

@(private)
run_cmd :: proc(cmd: cstring) -> (success: bool) {
  return libc.system(cmd) == 0
}
