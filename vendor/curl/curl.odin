package curl

import "core:runtime"
import "core:fmt"
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

//  struct memory {
//  char *response;
//  size_t size;
//};

Memory :: struct {
  response: []u8, 
  size: u8
}
post :: proc(url :cstring, body: map[string]string, headers: any) {
  handle := easy_init()
  //json_body, err := json.marshal(body, {}, context.temp_allocator)

  json_body : cstring = `{"hello": "world"}`
  //slist := slist{}
//  defer slist_free_all(slist)

//  for key, value in headers^._kv {
//    bldr :=  strings.builder_make()
//    strings.write_string(&bldr, key)
//    strings.write_string(&bldr, ": ")
//    strings.write_string(&bldr, value)
//    blt  := strings.to_string(bldr)
//    slist_append(&slist, strings.clone_to_cstring(blt))
//  }

//static size_t cb(void *data, size_t size, size_t nmemb, void *clientp)

//  struct memory {
//  char *response;
//  size_t size;
//};
 
//{
//  size_t realsize = size * nmemb;
//  struct memory *mem = (struct memory *)clientp;


  headers := slist_append(nil, `content-type: application/json`)
  data := new(map[string]string)
  easy_setopt(handle, OPT_HTTPHEADER, headers)
  easy_setopt(handle, OPT_POSTFIELDS, json_body)
  easy_setopt(handle, OPT_WRITEFUNCTION, writer)
  easy_setopt(handle, OPT_WRITEDATA, &data)
  easy_setopt(handle, OPT_POST, 1)
  easy_setopt(handle, OPT_URL, url)
  easy_perform(handle)
}

writer :: proc "c" (data : rawptr, size: u64, mem: u64, client: rawptr) {
  context = runtime.default_context()
  c_data := cast(cstring)data
  fmt.println(c_data)
  s_data := string(c_data)
  u_data := transmute([]u8)s_data


  parser := json.make_parser(u_data, json.Specification.JSON, true, context.allocator)
  fmt.println(parser)

  //str := raw_data(casted^.response)
//  for index, value in casted {
//    fmt.println("index ", casted)
//    fmt.println("value ", casted^.response[value])
//  }
  //fmt.println(str^)
//  res := strings.string_from_ptr(str, len)
//  fmt.println(res)
//  json.unmarshal_string(res, str, json.Specification.JSON, context.temp_allocator)
//  fmt.println("%s", res)
}
