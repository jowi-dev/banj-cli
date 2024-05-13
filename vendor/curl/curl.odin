package curl

import "core:runtime"
import "core:fmt"
import "core:mem"
import "core:strings"
import json "core:encoding/json"

Header :: struct {
	_kv:      map[string]string,
	readonly: bool,
}

get :: proc(url : cstring) -> (result: cstring = ``, ok: bool = false){
  handle := easy_init()
  // memory leak here 
  //setopt(handle, CurlOption.CURLOPT_URL, url)
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
  //libcurl_result
  return ``, true
}

post :: proc(url :cstring, body: map[string]string, headers: map[string]string, output: ^map[string]json.Value, ctx: mem.Allocator) -> bool {

  json_body := map_to_cstring(body, ctx)
  fmt.println(json_body)
  headers := slist_append(nil, `content-type: application/json`)
  handle := easy_init()
  easy_setopt(handle, OPT_HTTPHEADER, headers)
  easy_setopt(handle, OPT_POSTFIELDS, json_body)
  easy_setopt(handle, OPT_WRITEFUNCTION, writer)
  easy_setopt(handle, OPT_WRITEDATA, output)
  easy_setopt(handle, OPT_POST, 1)
  easy_setopt(handle, OPT_URL, url)
  code := easy_perform(handle)
  if code != E_OK{
    return false
  }

  return true
}

@(private)
map_to_cstring :: proc (m: map[string]string, ctx: mem.Allocator) -> cstring {
  b := strings.builder_make(ctx)

  marsh, err := json.marshal(m, {}, ctx)
  str := transmute(string)marsh

  strings.write_string(&b, "{ ")
  for key in m {
    strings.write_string(&b, key)
    strings.write_string(&b, ": ")
    strings.write_string(&b, m[key])
  }
  strings.write_string(&b, "}")

  return strings.clone_to_cstring(str)
}


@(private)
writer :: proc "c" (data : rawptr, size: u64, mem: u64, output: ^map[string]json.Value) {
  context = runtime.default_context()
  c_data := cast(cstring)data
  s_data := string(c_data)
  u_data := transmute([]u8)s_data

  value, err := json.parse(u_data, json.Specification.JSON, true, context.temp_allocator)
  if err != .None {return}
  resp := value.(json.Object)

  for key, value in  resp{
    output[key] = value
  }

  return
}
