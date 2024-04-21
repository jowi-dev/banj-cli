package sqlite3

import "core:mem"
import "core:c"
import "core:fmt"
import "core:os"
import "core:strings"
import "base:runtime"

DB_FILE :: "dev.db"

connect_db :: proc(allocator: mem.Allocator) -> (db : ^Sqlite3) {
  db = new(Sqlite3, allocator)
  
  flag : c.int = 2
  db_file : cstring = strings.clone_to_cstring("dev.db")
  status := open(db_file, &db)
  if status != nil {
    fmt.eprintf("failed to open")
    fmt.eprintf("Unable to open database '%s'(%v): %s", DB_FILE, status, errstr(status))
    os.exit(1)
  }

  return 
}

result_reader :: proc "c" (ctx: rawptr, n_columns: c.int, col_values: [^]cstring, col_names: [^]cstring) -> c.int {
  context = runtime.default_context()
  columns := col_names[:2]
  defer free(ctx)

  for c_name, index in columns {
    fmt.println(c_name, col_values[index] )
  }
  return 0
}

read_rows :: proc(allocator: mem.Allocator) {
  fmt.println("starting read row function")
  db := connect_db(allocator)

  ptr : rawptr 
  err : ^cstring 
  statement: cstring = `SELECT user, message FROM odin_logs;`
  status := exec(db, statement, result_reader, ptr, err)

  if status != nil {
    fmt.eprintf("Unable to search database '%s'(%v): %s", DB_FILE, status, errstr(status))
    os.exit(1)
  }
  
  close(db)
}

create_table :: proc(db: ^Sqlite3) {
  create_ptr : rawptr  
  create_err : ^cstring 
  create_statement : cstring = `
    CREATE TABLE IF NOT EXISTS odin_logs (
        id INTEGER PRIMARY KEY
        , user VARCHAR(64) NOT NULL
        , message TEXT NOT NULL
    );
  `
  
  status := exec(db, create_statement, nil, create_ptr, create_err)

  if status != nil {
    fmt.eprintf("create_err: %s", create_err)
    fmt.eprintf("Unable to create table in database '%s'(%v): %s ", DB_FILE, status, errstr(status))
    os.exit(1)
  }
}

create_record :: proc(db: ^Sqlite3) {
  ptr : rawptr  
  err : ^cstring 
  statement := strings.clone_to_cstring("INSERT INTO odin_logs (user, message) VALUES ('guy', 'this is real');")
  status := exec(db, statement, nil, ptr, err)

  if status != nil {
    fmt.eprintf("Unable to insert record in database '%s'(%v): %s", DB_FILE, status, errstr(status))
    os.exit(1)
  }
}
