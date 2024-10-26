package project

handler :: proc(project_cmd: ^string) -> (cstring, bool){
  switch project_cmd^ {
    case "develop": 
      return "nix develop --command fish", true
    case "init":
      return "INCOMPLETE -- this is going to be done via C++", false 
    case "flake-hide":
      return "git add --intent-to-add flake.nix flake.lock && git update-index --assume-unchanged flake.nix flake.lock", true
    case "flake-out":
      return "mv flake.nix flake.lock ~/", true
    case "flake-in":
      return "mv ~/flake.nix ~/flake.lock ./", true
  }
  return ``, false
}
