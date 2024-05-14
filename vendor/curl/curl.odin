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

  c_headers := marshal_to_cstring(ctx.headers, ctx.allocator)
  libcurl_headers := slist_append(nil, c_headers)
  //defer slist_free_all(libcurl_headers)

  json_body := marshal_to_cstring(ctx.body, ctx.allocator) // clean this in the outer scope

  //set options
  // TODO - c_headers needs to have \" removed from it, then be split on { || , || } - from there it can be pushed through slist_append and sent as a properly formatted header
  easy_setopt(handle, OPT_HTTPHEADER, &c_headers)
  easy_setopt(handle, OPT_POSTFIELDS, json_body)
  easy_setopt(handle, OPT_WRITEFUNCTION, ctx.callback_fn)
  easy_setopt(handle, OPT_WRITEDATA, ctx.output)
  easy_setopt(handle, OPT_POST, 1)
  easy_setopt(handle, OPT_URL, ctx.url)

  code := easy_perform(handle) // do the cha cha
  if code != E_OK{
    return false
  }

  return true
}

@(private)
marshal_to_cstring :: proc (m: any, ctx: mem.Allocator) -> cstring {
  marsh, err := json.marshal(m, {}, ctx)
  str := transmute(string)marsh

  return strings.clone_to_cstring(str, ctx)
}

//@(private)
//encode_headers :: proc(headers: cstring, ctx: mem.Allocator) -> ^slist {
////  libcurl_headers : ^slist = nil
////  for key, value in headers {
////    bldr := strings.builder_make(ctx)
////    strings.write_string(&bldr, key)
////    strings.write_string(&bldr, ": ")
////    strings.write_string(&bldr, value)
////    str := strings.to_string(bldr)
////    c_str := strings.clone_to_cstring(str, ctx)
////
////    libcurl_headers = slist_append(libcurl_headers, c_str)
////  }
//  //return libcurl_headers
//  //return slist_append(nil, headers)
//}


