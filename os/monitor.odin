package banj_os

import "core:fmt"

monitor :: proc(os: SupportedOS, monitor_type: ^string) -> (cstring, bool) {
 switch monitor_type^ {
   case "system":
     return monitor_system(os)
   case "wifi":
     return monitor_wifi(os)
   case "containers":
     return monitor_containers(os)
 }
 return ``, false
}

@(private="file")
monitor_system :: proc(os: SupportedOS) -> (cmd:cstring = "", ok:bool = true){
  #partial switch os {
    case .Linux:
      return "btop", true
    case: 
      fmt.println("Command not supported on current system")
  }
  return cmd, !ok
}

@(private="file")
monitor_wifi :: proc(os: SupportedOS) -> (cmd:cstring = "", ok:bool = true){
  #partial switch os {
    case .Linux:
      return "sudo wavemon", true
    case: 
      fmt.println("Command not supported on current system")
  }
  return cmd, !ok
}

@(private="file")
monitor_containers :: proc(os: SupportedOS) -> (cmd:cstring = "", ok:bool = true){
  #partial switch os {
    case .Linux:
      return "lazydocker", true
    case: 
      fmt.println("Command not supported on current system")
  }
  return cmd, !ok
}

