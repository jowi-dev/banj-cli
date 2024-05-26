package curl

import "core:runtime"
import "core:fmt"
import "core:mem"
import "core:strings"
import json "core:encoding/json"

Post_Context :: struct($Header, $Body, $Output: typeid) {
  url: cstring,
  headers: Header,
  body: Body, 
  output: Output,
  callback_fn: proc "c" (data : rawptr, size: u64, mem: u64, output: Output),
  allocator: mem.Allocator
}

get :: proc(url : cstring) -> (result: cstring = ``, ok: bool = false){
  handle := easy_init()
  // memory leak here 
  easy_setopt(handle, OPT_URL, `https://google.com`)
  libcurl_result := easy_perform(handle)

  // delete this nephew
  fmt.println("%s", libcurl_result)


  if libcurl_result != E_OK {
    fmt.println("Failed to request, %s", libcurl_result)
    easy_cleanup(handle)
    return 
  }

  easy_cleanup(handle)
  return ``, true
}

post :: proc(ctx :Post_Context($H, $B, $O)) -> bool {
  //initialize assets
  handle := easy_init()
  defer easy_cleanup(handle)

  slist_headers : ^slist = encode_headers(ctx.headers, ctx.allocator)
  defer slist_free_all(slist_headers)

  json_body := marshal_to_cstring(ctx.body, ctx.allocator) // clean this in the outer scope

  easy_setopt(handle, OPT_HTTPHEADER, slist_headers)
  easy_setopt(handle, OPT_POSTFIELDS, json_body)
  easy_setopt(handle, OPT_WRITEFUNCTION, ctx.callback_fn)
  easy_setopt(handle, OPT_WRITEDATA, ctx.output)
  easy_setopt(handle, OPT_POST, 1)
  easy_setopt(handle, OPT_URL, ctx.url)

  code := easy_perform(handle) // do the cha cha

  if code != E_OK do return false

  return true
}

@(private)
marshal_to_cstring :: proc (m: any, ctx: mem.Allocator) -> cstring {
  marsh, err := json.marshal(m, {}, ctx)
  str := transmute(string)marsh

  return strings.clone_to_cstring(str, ctx)
}

@(private)
encode_headers :: proc(headers: any, ctx: mem.Allocator) -> ^slist {
  bldr := strings.builder_make()

  opts := json.Marshal_Options{
    json.Specification.JSON, //parser spec
    false, // Use line breaks & tabs/spaces
    false, // Use spaces for indentation instead of tabs
    0, // Given use_spaces true, use this many spaces per indent level. 0 means 4 spaces.
    false, // Output uint as hex in JSON5 & MJSON
    false, //quote key names
    false, //use_equals when MJSON
    false, //sort by key
    false,
    // Internal state
    0,
    false,
    false,
  }

  json.marshal_to_builder(&bldr, headers, &opts)
  str := strings.to_string(bldr)
  err : bool 
  str, err = strings.remove_all(str, "{")
  str, err = strings.remove_all(str, "}")
  str, err = strings.remove_all(str, "\"")
  splits := strings.split(str, ",")

  res : ^slist = nil

  for split, index in splits {
    c_split : cstring = strings.clone_to_cstring(split)
    res = slist_append(res, c_split)
  }

  return res
}


