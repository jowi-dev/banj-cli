package banj_os

import "core:testing"

@(test)
rebuild_works_on_linux :: proc(_: ^testing.T) {
  cmd, ok := rebuild(.Linux)
  assert(ok)
  //assert(cmd == "")
}

//@(test)
//get_arg_ignores_paths :: proc(_: ^testing.T) {
//  _, ok := get_arg("shouldnt/work")
//  assert(!ok)
//}
//
//@(test)
//get_arg_returns_arg :: proc(_: ^testing.T) {
//  arg, ok := get_arg("totes_arg")
//  assert(ok)
//  assert(arg == "totes_arg")
//}
