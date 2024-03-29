package banj

import "core:fmt"
import "core:c/libc"
import "base:runtime"

SupportedOS :: enum {
  Darwin, 
  Linux,
}

rebuild :: proc(os: SupportedOS) -> (cmd:cstring = "", ok:bool = true) {
  #partial switch os {
    case .Linux: 
      cmd = "sudo nixos-rebuild switch --flake $CONFIG_DIR/.#$FLAKE"
    case .Darwin:
      cmd = "darwin-rebuild switch --flake $CONFIG_DIR/.#FLAKE"
    case:
      fmt.println("Can't tune something that ain't a banjo")
      return cmd, !ok
  }
  return
}


sleep :: proc(os: SupportedOS) -> (cmd:cstring = "", ok:bool = true){
  fmt.println(ODIN_OS)
  #partial switch os {
    case .Linux:
      return "systemctl hibernate", true
    case: 
      fmt.println("Command not supported on current system")
  }
  return cmd, !ok
}
