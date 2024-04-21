package sqlite3

import "core:c"
import "core:c/libc"

when ODIN_OS == .Windows {
    foreign import sqlite3 "bin/sqlite3.lib"
} else when ODIN_OS ==.Linux {
    foreign import sqlite3 {
        "system:sqlite3",
        "system:pthread",
        "system:dl",
        "system:m",
    }
}

// Database connection handle.
Sqlite3 :: struct {}


@(link_prefix="sqlite3_", default_calling_convention="c")
foreign sqlite3 {
    // One-step query execution interface.
    @(private)
    exec :: proc (
        conn: ^Sqlite3,
        sql: cstring,
        callback: proc "c" (rawptr, c.int, [^]cstring, [^]cstring) -> c.int,        
        ctx: rawptr,
        errmsg: ^cstring,
    ) -> Status ---

    @(private)
    close :: proc (conn: ^Sqlite3) -> Status ---

    @(private)
    open :: proc (filename: cstring, out_conn: ^^Sqlite3) -> Status ---

    @(private)
    errstr :: proc (status: Status) -> cstring ---
}


Status :: enum i32 {
    // Successfull result.
    Ok         = 0,
    // Generic error.
    Error      = 1,
    // Internal logic error in SQLite.
    Internal   = 2,
    // Access permission defined.
    Perm       = 3,
    // Callback routine requested an abort.
    Abort      = 4,
    // Database file is locked.
    Busy       = 5,
    // A table in the database is locked.
    Locked     = 6,
    // malloc() failed.
    No_Mem     = 7,
    // Attempt to write a read only database.
    Read_Only  = 8,
    // Operation terminated by `interrupt()`
    Interrupt  = 9,
    // Some kind of disk I/O error occurred.
    IO_Err     = 10,
    // The database disk image is malformed.
    Corrupt    = 11,
    // Unknown optocde in `file_control()`.
    Not_Found  = 12,
    // Insertion failed because database is full.
    Full       = 13,
    // Unable to open the database file.
    Cant_Open  = 14,
    // Database lock protocol error.
    Protocol   = 15,
    // <internal use only>
    Empty      = 16,
    // The database schema changed.
    Schema     = 17,
    // String or BLOB exceeds size limit.
    Too_Big    = 18,
    // Abort due to constraint violation.
    Constraint = 19,
    // Data type mismatch.
    Mismatch   = 20,
    // Library used incorrectly.
    Misuse     = 21,
    // Uses OS features not supported on a host.
    No_LFS     = 22,
    // Authorization denied.
    Auth       = 23,
    // <not used>
    Format     = 24,
    // Second parameter to `bind()` is out of range.
    Range      = 25,
    // File opened but wasn't an SQLite database file.
    Not_A_DB   = 26,
    // Notifications from `log()`.
    Notice     = 27,
    // Warnings from `log()`.
    Warning    = 28,
    // `step()` has another row ready.
    Row        = 100,
    // `step()` has finished execution.
    Done       = 101,
}
