package curl

import "core:fmt"
import "core:strings"
import json "core:encoding/json"

Header :: struct {
	_kv:      map[string]string,
	readonly: bool,
}

get :: proc(url : cstring) -> (result: cstring = ``, ok: bool = false){
  handle := init()
  // memory leak here 
  //setopt(handle, CurlOption.CURLOPT_URL, url)
  setopt(handle, CurlOption.CURLOPT_URL, `https://google.com`)
  libcurl_result := perform(handle)

  // delete this nephew
  fmt.println("%s", libcurl_result)


  if libcurl_result != CurlCode.CURLE_OK {
    fmt.println("Failed to request, %s", libcurl_result)
    cleanup(handle)
    return 
  }

  cleanup(handle)
  //libcurl_result
  return ``, true
}

post :: proc(url :cstring, body: any, headers: ^Header) {
  handle := init()
  json_body, err := json.marshal(body, {}, context.temp_allocator)

  slist := Curl_SList{}

  for key, value in headers^._kv {
    bldr :=  strings.builder_make()
    strings.write_string(&bldr, key)
    strings.write_string(&bldr, ": ")
    strings.write_string(&bldr, value)
    blt  := strings.to_string(bldr)
    slist_append(&slist, strings.clone_to_cstring(blt))
  }
  setopt(handle, CurlOption.CURLOPT_HTTPHEADER, slist)
  slist_free_all(&slist)

}
