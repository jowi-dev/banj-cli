package banj_os

import "core:fmt"

display :: proc(os: SupportedOS, display_type: ^string) -> (cstring, bool) {
  switch display_type^ {
    case "duplicate":
      return display_duplicate(os)
    case "extend":
      return display_extended(os)
    case "laptop":
      return display_single_laptop(os)
    case "desktop":
      return display_single_desktop(os)
  }
  return ``, false
}

@(private="file")
display_duplicate :: proc(os: SupportedOS) -> (cmd:cstring = "", ok:bool = true){
  #partial switch os {
    case .Linux:
      return "xrandr --auto", true
    case: 
      fmt.println("Command not supported on current system")
  }
  return cmd, !ok
}

@(private="file")
display_extended :: proc(os: SupportedOS) -> (cmd:cstring = "", ok:bool = true){
  #partial switch os {
    case .Linux:
      return "xrandr --auto && xrandr --output eDP-1 --right-of HDMI-2", true
    case: 
      fmt.println("Command not supported on current system")
  }
  return cmd, !ok
}

@(private="file")
display_single_laptop :: proc(os: SupportedOS) -> (cmd:cstring = "", ok:bool = true){
  #partial switch os {
    case .Linux:
      return "xrandr --auto && xrandr --output HDMI-2 --off", true
    case: 
      fmt.println("Command not supported on current system")
  }
  return cmd, !ok
}

@(private="file")
display_single_desktop :: proc(os: SupportedOS) -> (cmd:cstring = "", ok:bool = true){
  #partial switch os {
    case .Linux:
      return "xrandr --auto && xrandr --output eDP-1 --off", true
    case: 
      fmt.println("Command not supported on current system")
  }
  return cmd, !ok
}
