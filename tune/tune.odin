package tune

import "core:fmt"
import "core:c/libc"


tune :: proc(args: [dynamic]string) -> (success: bool) {
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

  result : int = auto_cast libc.system(cmd)
  return result == 0
}


