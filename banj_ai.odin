package banj


import client "vendor/odin-http/client"
import http "vendor/odin-http"
import sqlite "vendor/sqlite3"
import "core:fmt"
import "core:os"
import "core:strings"

DB_FILE :: "dev.db"

Interaction :: struct {
  role: string, 
  content: string
}

Post_Body :: struct {
  model: string, 
  max_tokens: u32,
  messages: [dynamic]Interaction
}

ai :: proc(OS: SupportedOS) -> (cmd:cstring = "", ok:bool = true) {
  db : sqlite.Sqlite3
  status := sqlite.open( DB_FILE, &db)
  if status != nil {
    fmt.eprintf("Unable to open database '%s'(%v): %s", DB_FILE, status, sqlite.errstr(status))
    os.exit(1)
  }
  req := client.Request {}
  set_request_headers(&req)
  client.request_init(&req)

  defer client.request_destroy(&req)

  pbody := Post_Body{}
  set_request_body(&req, &pbody)

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

  sqlite.close(&db)
  return "", true
}

@(private)
print_debug :: proc(res: ^client.Response){
	fmt.printf("Status: %s\n", res.status)
	fmt.printf("Headers: %v\n", res.headers)
	fmt.printf("Cookies: %v\n", res.cookies)
}

@(private)
create_table :: proc(db: ^sqlite.Sqlite3) {
  // Do things with database
  ptr := new(int)
  err : cstring = `failed to create table!`
  sqlite.exec(db, `
    CREATE TABLE IF NOT EXISTS ai_logs (
        id INTEGER PRIMARY KEY
        , role VARCHAR(64) NOT NULL
        , content TEXT NOT NULL
    );
  `, nil, &ptr, &err)
}

@(private)
create_record :: proc(db: ^sqlite.Sqlite3, role: string, content: string) {
  ptr := new(int)
  err : cstring = `failed to insert record!`
  statement := "INSERT INTO ai_logs (role, content) VALUES ('guy', 'this is real');"
  sqlite.exec(db, strings.clone_to_cstring(statement), nil, &ptr, &err)
}


@(private)
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

@(private)
set_request_body :: proc(req: ^client.Request, pbody: ^Post_Body) {
  content := Interaction{}
  content.role = "user"
  content.content = "Hello. Tell me about yourself? How can I use you best? I am a software engineer who needs to increase my productivity. I work in application development in Elixir by trade, but moonlight as a systems engineer in Nix, Rust, and Odin"

  messages : [dynamic]Interaction 
  append(&messages, content)
  pbody.model = "claude-3-opus-20240229"
  pbody.max_tokens = 1024
  pbody.messages = messages 
  if err := client.with_json(req, pbody^); err != nil {
    fmt.printf("JSON error: %s", err)
		return
  }
}
