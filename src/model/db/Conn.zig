const std = @import("std");
const log = std.log;

const c = @import("c.zig").sqlite3;

const mem = @import("../../mem.zig");

const Conn = @This();

p_db: ?*c.sqlite3,

pub const OpenError = error{OpenFailed};

pub fn open(file_name: [:0]const u8) OpenError!Conn {
    log.info("SQLite v{s}", .{c.sqlite3_libversion()});

    var p_db: ?*c.sqlite3 = null;

    if (c.SQLITE_OK != c.sqlite3_open_v2(
        file_name,
        &p_db,
        c.SQLITE_OPEN_READWRITE | c.SQLITE_OPEN_CREATE,
        null,
    )) {
        log.err(
            "Error opening the database: {s}\n{s}",
            .{ file_name, c.sqlite3_errmsg(p_db) },
        );
        _ = c.sqlite3_close(p_db);
        return error.OpenFailed;
    }

    log.info("Connected to database: {s}", .{file_name});

    return Conn{ .p_db = p_db };
}

pub fn close(self: Conn) void {
    if (c.SQLITE_OK != c.sqlite3_close(self.p_db)) {
        log.err(
            "Error closing the database: {s}",
            .{c.sqlite3_errmsg(self.p_db)},
        );
        return;
    }

    log.info("Database closed", .{});
}

pub const schema = @embedFile("schema.sql");

pub const ExecSchemaError = error{SchemaExecFailed};

pub fn execSchema(self: Conn) ExecSchemaError!void {
    var err_msg: [*c]u8 = null;
    if (c.SQLITE_OK != c.sqlite3_exec(self.p_db, schema, null, null, &err_msg)) {
        defer c.sqlite3_free(err_msg);
        log.err("failed to apply schema: {s}", .{err_msg});
        return error.SchemaExecFailed;
    }
}

/// The returned slice is valid only while the connection remains open.
/// Memory is owned by SQLite. Do not free it.
pub fn db_filename(self: Conn) [:0]const u8 {
    const path: [*c]const u8 = c.sqlite3_db_filename(self.p_db, "main");
    const len: usize = std.mem.len(path);
    return path[0..len :0];
}

// --- Helpers ---

pub fn getColumnSlice(stmt: ?*c.sqlite3_stmt, col: c_int) [:0]const u8 {
    const ptr = c.sqlite3_column_text(stmt, col) orelse return "null";
    const len: usize = @intCast(c.sqlite3_column_bytes(stmt, col));
    return ptr[0..len :0];
}
