package curl

import "core:fmt"
import "core:strings"

get :: proc() {
  handle := init()
  fmt.println("handle, %s", handle)
  if handle == nil {
  url : cstring = "https://google.com"

 // memory leak here 
  setopt(handle, Curl_Opt.CURLOPT_URL, url)
  result := perform(handle^)
  if result != Curl_Code.CURLE_OK {
    fmt.println("Failed to request, %s", result)
  }
  cleanup(handle)
  }
  else {
    fmt.println("Failed to get handle")
  }

}
