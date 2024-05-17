package sqlite3

import "core:mem"
import "core:c"
import "core:fmt"
import "core:reflect"
import "core:os"
import "core:strings"
import "base:runtime"

write :: strings.write_string

DB_FILE :: "dev.db"

Statement :: struct($Record, $Output: typeid) {
  connection: ^Sqlite3,
  record: Record,
  output: ^Output,
  status: Status,
  error: ^cstring
}

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

insert_record :: proc(statement: Statement($I, $O), db: ^Sqlite3) { 
  field_names :[]string = reflect.struct_field_names(statement.record)
  table_name := reflect.struct_tag_get()
  bldr := strings.builder_make()
  write(&blder, "INSERT INTO ")
  write(&blder, table_name)
  write(&blder, " (")
  for col_name, index in field_names {
    index == 0 ? write(&bldr, "'") : write(&blder, ", '")
    write(&bldr, col_name)
    write(&blder, "'")
  }
  write(&blder, ") VALUES")

  for col_name, index in field_names {
    index == 0 ? write(&bldr, "'") : write(&blder, ", '")
    write(&bldr, reflect.struct_field_value_by_name(statement.record, col_name).(string))
    write(&blder, "'")
  }

  statement := strings.to_string(bldr)

  c_stmt := strings.clone_to_cstring(statement)

  // probably needs a free
  ptr : rawptr  
  err : ^cstring 
  // the nil value represents a callback - write a confirmation function maybe
  status := exec(db, statement, result_reader, &statement.output, err)

  if status != nil {
    fmt.eprintf("Error: %s | insert_record/2 | '%s'(%v): %s", err, DB_FILE, status, errstr(status))
    os.exit(1)
  }

}

update :: proc() {}

get :: proc() {}

all :: proc(statement: Statement($R, $O), allocator: mem.Allocator) {
  fmt.println("starting read row function")
  //shadow the param
  statement := statement
  if statement.connection == nil do statement.connection = connect_db(allocator)

  record_type := typeid_of(type_of(statement.record))
  info := type_info_of(record_type)

  bldr := strings.builder_make()
  write(&bldr, "SELECT * from ")
  write(&bldr, strings.to_lower(info.variant.(runtime.Type_Info_Named).name, allocator))
  write(&bldr, "s;")
  sql := strings.to_string(bldr)
  fmt.println(sql)

  statement.status = exec(statement.connection, strings.clone_to_cstring(sql), result_reader, statement.output, statement.error)

  if statement.status != nil {
    fmt.eprintf("Error: %s | read_rows/2 | '%s'(%v): %s", statement.error, DB_FILE, statement.status, errstr(statement.status))
    os.exit(1)
  }
  
  close(statement.connection)
}

// TODO - can this rawptr in ctx point to a list/vector/etc that is populated with the values?
result_reader :: proc "c" (ctx: rawptr, n_columns: c.int, col_values: [^]cstring, col_names: [^]cstring) -> c.int {
  context = runtime.default_context()
  columns := col_names[:2]
  defer free(ctx)

  for c_name, index in columns {
    //fmt.println(c_name, col_values[index] )
  }
  return 0
}
