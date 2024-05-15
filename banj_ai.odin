package banj


import "vendor/curl"
import sqlite "vendor/sqlite3"
import "core:fmt"
import "core:os"
import "core:c"
import json "core:encoding/json"
import "core:strings"
import "base:runtime"
import "core:mem"

write :: strings.write_string


@(private="file")
Interaction :: struct {
  role: string, 
  content: string
}


@(private="file")
Headers :: struct {
  x_api_key: string `json:"x-api-key"`,
  content_type: string `json:"content-type"`, 
  anthropic_version: string `json:"anthropic-version"`,
}

@(private="file")
Payload :: struct {
  model: string, 
  max_tokens: u32,
  messages: [dynamic]Interaction
}

@(private="file")
Response :: struct {
  ok: bool, 
  response: string,
}

Filter :: struct {
  clauses : string,
  limit : u8
}

CREATE_STATEMENT : cstring : `
    CREATE TABLE IF NOT EXISTS odin_logs (
        id INTEGER PRIMARY KEY
        , user VARCHAR(64) NOT NULL
        , message TEXT NOT NULL
    );
  `


ai :: proc(OS: SupportedOS, prompt: ^string) -> (cmd:cstring = "", ok:bool = true) {

  db : ^sqlite.Sqlite3 = sqlite.connect_db(context.temp_allocator)
  defer free_all(context.temp_allocator)
  sqlite.create_table(CREATE_STATEMENT, db)

  headers, headers_ok := set_request_headers()
  payload := create_request_body(prompt)
  output := new(Response)


  post_context := curl.Post_Context(Headers, Payload, ^Response) {
    `https://api.anthropic.com/v1/messages`,
    headers,
    payload,
    output, 
    callback,
    context.allocator,
  }

  res := curl.post(post_context)

  sqlite.close(db)
  return "", true
}


@(private="file")
query_records :: proc(filter: Filter, allocator: mem.Allocator) {
  // FIlters should likely be part of a query dsl
  cmd_bldr := strings.builder_make(allocator)
  write(&cmd_bldr, "SELECT * from odin_logs ")
  // todo - conditionally filter
  write(&cmd_bldr, filter.clauses)
  write(&cmd_bldr, ";")
  built_cmd := strings.to_string(cmd_bldr)
  cmd :cstring = strings.clone_to_cstring(built_cmd, allocator)
  // TODO - What should we do with the rows?
  sqlite.read_rows(cmd, allocator)
}

@(private="file")
insert_record :: proc(content: Interaction, db: ^sqlite.Sqlite3, allocator: mem.Allocator) -> (output: Interaction, ok: bool) {
  cmd_bldr := strings.builder_make(allocator)
  write(&cmd_bldr, "INSERT INTO odin_logs (user, message) VALUES (")
  write(&cmd_bldr, content.role)
  write(&cmd_bldr, ", ")
  write(&cmd_bldr, content.content)
  write(&cmd_bldr, ");")
  built_cmd := strings.to_string(cmd_bldr)
  cmd :cstring = strings.clone_to_cstring(built_cmd, allocator)
  // TODO - Should we do anyhting with this record?
  sqlite.insert_record(cmd, db)

  return content, true
}



@(private="file")
set_request_headers :: proc() -> (headers: Headers, ok:bool = false) {
  api_key := os.get_env("ANTHROPIC_API_KEY")
  if api_key == ""  {
    fmt.println("no api key found")
    return headers, false
  }

  headers.content_type = "application/json"
  headers.anthropic_version = "2023-06-01"
  headers.x_api_key = api_key


  return headers, true
}

@(private="file")
create_request_body :: proc(prompt: ^string) -> (result: Payload) {
  content := Interaction{}
  content.role = "user"
  content.content = prompt^

  messages : [dynamic]Interaction 
  append(&messages, content)
  result.model = "claude-3-opus-20240229"
  result.max_tokens = 1024
  result.messages = messages 

  return result
}

@(private)
callback :: proc "c" (data : rawptr, size: u64, mem: u64, output: ^Response) {
  context = runtime.default_context()
  c_data := cast(cstring)data
  s_data := string(c_data)
  u_data := transmute([]u8)s_data

  value, err := json.parse(u_data, json.Specification.JSON, true, context.temp_allocator)
  if err != .None {
    fmt.println("Error is %s |", err)
    return
  }
  resp := value.(json.Object)
  fmt.println(value)
  fmt.println(resp["content"])
  fmt.println(resp["content"].(json.Array))
  arr_item := resp["content"].(json.Array)[0]
  fmt.println(arr_item.(json.Object)["text"])
  result := arr_item.(json.Object)["text"]

  // TODO - figure out how to convert result to a string and you win
  output.response = result

  return
}
