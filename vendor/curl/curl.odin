package curl

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
  headers := slist_append(nil, `content-type: application/json`)
  easy_setopt(handle, OPT_HTTPHEADER, headers)
  easy_setopt(handle, OPT_POSTFIELDS, json_body)
  easy_setopt(handle, OPT_POST, 1)
  easy_setopt(handle, OPT_URL, url)
  easy_perform(handle)
}
