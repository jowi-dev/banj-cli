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
  output: Output,
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

insert_record :: proc(statement: Statement($I, $O), allocator: mem.Allocator) { 
  field_names := reflect.struct_field_names(I)
  statement := statement

  record_type := typeid_of(I)
  info := type_info_of(record_type)
  table_name := strings.to_lower(info.variant.(runtime.Type_Info_Named).name, allocator)

  bldr := strings.builder_make()
  write(&bldr, "INSERT INTO ")
  write(&bldr, table_name)
  write(&bldr, "s")
  write(&bldr, " (")
  for col_name, index in field_names {
    prepend := index == 0 ? "'" : ", '"
    write(&bldr, prepend)
    write(&bldr, col_name)
    write(&bldr, "'")
  }
  write(&bldr, ") VALUES (")

  for col_name, index in field_names {
    prepend := index == 0 ?  "'" : ", '"
    write(&bldr, prepend)
    fuggin_output, fuggin_err := reflect.struct_field_value_by_name(statement.record, col_name).(string)
    fuggin_output, fuggin_err = strings.remove_all(fuggin_output, "'")
    write(&bldr, fuggin_output)
    write(&bldr, "'")
  }
  write(&bldr, ")")

  cmd := strings.to_string(bldr)

  c_stmt := strings.clone_to_cstring(cmd)
  fmt.println(c_stmt)

  statement.status = exec(statement.connection, c_stmt, print_results, &statement.output, statement.error)

  if statement.status != nil {
    fmt.eprintf("Error: %s | insert_record/2 | '%s'(%v): %s", statement.error, DB_FILE, statement.status, errstr(statement.status))
    os.exit(1)
  }

}

query :: proc(sql : string, db: ^Sqlite3, allocator: mem.Allocator){
  c_sql := strings.clone_to_cstring(sql)
  ctx : rawptr
  err : ^cstring
  fmt.println(c_sql)
  status := exec(db, c_sql, print_results, ctx, err)
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
  reflected_name := strings.to_lower(info.variant.(runtime.Type_Info_Named).name, allocator)

  bldr := strings.builder_make()
  write(&bldr, "SELECT * from odin_logs;")
//  write(&bldr, reflected_name)
//  write(&bldr, "s;")
  sql := strings.to_string(bldr)
  fmt.println(sql)

  statement.status = exec(statement.connection, strings.clone_to_cstring(sql), print_results, statement.output, statement.error)

  if statement.status != nil {
    fmt.eprintf("Error: %s | read_rows/2 | '%s'(%v): %s", statement.error, DB_FILE, statement.status, errstr(statement.status))
    os.exit(1)
  }
  
  close(statement.connection)
}

//assign_list_results :: proc "c" (ctx: $T, n_columns: c.int, col_values: [^]cstring, col_names: [^]cstring) -> c.int {
//  context = runtime.default_context()
//  columns := col_names[:3]
//  defer free(ctx)
//
//  for c_name, index in columns {
//    fmt.println(c_name, col_values[index] )
//  }
//  return 0
//}

print_results :: proc "c" (ctx: rawptr, n_columns: c.int, col_values: [^]cstring, col_names: [^]cstring) -> c.int {
  context = runtime.default_context()
  fmt.println("hello from print_results")
  columns := col_names[:3]
  defer free(ctx)

  for c_name, index in columns {
    fmt.println(c_name, col_values[index] )
  }
  return 0
}
