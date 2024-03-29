package banj

import "core:testing"

/*
* rebuild tests 
*/
@(test)
rebuild_works_on_linux :: proc(_: ^testing.T) {
  cmd, ok := rebuild(.Linux)
  assert(ok)
}

@(test)
rebuild_works_on_darwin :: proc(_: ^testing.T) {
  cmd, ok := rebuild(.Darwin)
  assert(ok)
}

/*
* sleep tests
*/
@(test)
sleep_works_on_linux :: proc(_: ^testing.T) {
  _, ok := sleep(.Linux)
  assert(ok)
}

@(test)
sleep_fails_on_darwin :: proc(_: ^testing.T) {
  _, ok := sleep(.Darwin)
  assert(!ok)
}
