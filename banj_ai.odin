package banj


import client "vendor/odin-http/client"
import http "vendor/odin-http"
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

Interaction :: struct {
  role: string, 
  content: string
}

Post_Body :: struct {
  model: string, 
  max_tokens: u32,
  messages: [dynamic]Interaction
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

  curl.easy_init()



  req := client.Request {}
  set_request_headers(&req)
  client.request_init(&req)

  defer client.request_destroy(&req)

  pbody := Post_Body{}
  set_request_body(&req, &pbody, prompt)
  

  res, err := client.request(&req, "https://api.anthropic.com/v1/messages") 
  if err != nil {
		fmt.printf("Request failed: %s", err)
		return
  }
  defer client.response_destroy(&res)


	body, allocation, berr := client.response_body(&res)
  if berr != nil {
		fmt.printf("Error retrieving response body: %s", berr)
		return
  }
	defer client.body_destroy(body, allocation)

	fmt.println(body)

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
set_request_headers :: proc(req: ^client.Request) -> (ok:bool = false) {
  api_key := os.get_env("ANTHROPIC_API_KEY")
  if api_key == ""  {
    return 
  }

  headers := http.Headers{}
  kv := make(map[string]string)
  kv["content-type"]= "application/json"
  kv["anthropic-version"] = "2023-06-01"
  kv["x-api-key"] = api_key
  defer delete(kv)

  headers._kv=kv

  
  req^.method = .Post
  req^.headers = headers
  fmt.println(req^)
  return true
}

@(private="file")
set_request_body :: proc(req: ^client.Request, pbody: ^Post_Body, prompt: ^string) {
  content := Interaction{}
  content.role = "user"
  content.content = prompt^

  messages : [dynamic]Interaction 
  append(&messages, content)
  pbody.model = "claude-3-opus-20240229"
  pbody.max_tokens = 1024
  pbody.messages = messages 

  body, err := json.marshal(pbody)
  fmt.println("JSON: %S", body)
  return 
  //return body, nil
 //  if err := client.with_json(req, pbody^); err != nil {
 //    fmt.printf("JSON error: %s", err)
 //		return
 //  }
}
