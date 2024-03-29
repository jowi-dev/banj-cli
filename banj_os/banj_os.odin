package banj_os

import "core:fmt"
import "core:c/libc"
import "base:runtime"

SupportedOS :: enum {
  Darwin, 
  Linux,
  Windows
}

rebuild :: proc(os: SupportedOS) -> (cmd:cstring = "", ok:bool = false) {
  #partial switch os {
    case .Linux: 
      cmd = "sudo nixos-rebuild switch --flake $CONFIG_DIR/.#$FLAKE"
    case .Darwin:
      cmd = "darwin-rebuild switch --flake $CONFIG_DIR/.#FLAKE"
    case .Windows:
      fmt.println("Windows not supported")
    case:
      fmt.println("Can't tune something that ain't a banjo")
  }
  return
}

sleep :: proc(os: SupportedOS) -> (cmd:cstring = "", ok:bool = false){
  #partial switch os {
    case .Linux:
      return "systemctl hibernate", true
    case: 
      fmt.println("Command not supported on current system")
  }
  return cmd, ok
}

help :: proc() -> cstring{
  fmt.println("TODO -- help the user")
  return "echo \"TODO -- help the user\""
}

