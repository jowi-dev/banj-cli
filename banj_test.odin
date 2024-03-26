package banj
import "core:testing"

@(test)
get_arg_ignores_flags :: proc(_: ^testing.T) {
  _, ok := get_arg("--flag")
  assert(!ok)
}

@(test)
get_arg_ignores_paths :: proc(_: ^testing.T) {
  _, ok := get_arg("shouldnt/work")
  assert(!ok)
}

@(test)
get_arg_returns_arg :: proc(_: ^testing.T) {
  arg, ok := get_arg("totes_arg")
  assert(ok)
  assert(arg == "totes_arg")
}
