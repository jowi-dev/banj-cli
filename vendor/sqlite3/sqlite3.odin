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
  db_file : cstring
  db_file, _ = strings.clone_to_cstring(DB_FILE, allocator)
  status := open(db_file, &db)
  if status != nil {
    fmt.eprintf("Error | connect_db/1 | '%s'(%v): %s", DB_FILE, status, errstr(status))
    os.exit(1)
  }

  return 
}

// TODO - can this rawptr in ctx point to a list/vector/etc that is populated with the values?
result_reader :: proc "c" (ctx: rawptr, n_columns: c.int, col_values: [^]cstring, col_names: [^]cstring) -> c.int {
  context = runtime.default_context()
  columns := col_names[:2]
  defer free(ctx)

  for c_name, index in columns {
    fmt.println(c_name, col_values[index] )
  }
  return 0
}

read_rows :: proc(statement:cstring, allocator: mem.Allocator) {
  fmt.println("starting read row function")
  db := connect_db(allocator)

  // probably needs a free
  ptr : rawptr 
  err : ^cstring 
  status := exec(db, statement, result_reader, ptr, err)

  if status != nil {
    fmt.eprintf("Error: %s | read_rows/2 | '%s'(%v): %s", err, DB_FILE, status, errstr(status))
    os.exit(1)
  }
  
  close(db)
}

create_table :: proc(statement:cstring, db: ^Sqlite3) {
  // probably needs a free
  create_ptr : rawptr  
  create_err : ^cstring 
  
  status := exec(db, statement, nil, create_ptr, create_err)

  if status != nil {
    fmt.eprintf("Error: %s | create_table/2 | '%s'(%v): %s ", create_err, DB_FILE, status, errstr(status))
    os.exit(1)
  }
}

insert_record :: proc(statement:cstring, db: ^Sqlite3) {
  // probably needs a free
  ptr : rawptr  
  err : ^cstring 
  status := exec(db, statement, nil, ptr, err)

  if status != nil {
    fmt.eprintf("Error: %s | insert_record/2 | '%s'(%v): %s", err, DB_FILE, status, errstr(status))
    os.exit(1)
  }
}
