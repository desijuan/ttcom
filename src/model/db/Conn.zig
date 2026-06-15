const std = @import("std");
const log = std.log;

const c = @import("../../c.zig").sqlite3;

const mem = @import("../../mem.zig");
const utils = @import("../../utils.zig");

const path_db_schema = "src/model/db/schema.sql";

const Conn = @This();

p_db: ?*c.sqlite3,

pub const OpenError = utils.ReadFileZError || error{ OpenFailed, SchemaExecFailed };

pub fn open(file_name: [:0]const u8) OpenError!Conn {
    const schema_str: [:0]const u8 = try utils.readFileZ(mem.a, path_db_schema);
    defer mem.a.free(schema_str);

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

    var err_msg: [*c]u8 = null;
    if (c.SQLITE_OK != c.sqlite3_exec(p_db, schema_str, null, null, &err_msg)) {
        defer c.sqlite3_free(err_msg);
        log.err("failed to apply schema: {s}", .{err_msg});
        return error.SchemaExecFailed;
    }

    return Conn{ .p_db = p_db };
}

pub const CloseError = error{CloseFailed};

// Q: Do I have to free the err_msg here?
pub fn close(self: Conn) void {
    if (c.SQLITE_OK != c.sqlite3_close(self.p_db)) {
        log.err(
            "Error closing the database: {s}",
            .{c.sqlite3_errmsg(self.p_db)},
        );
    }

    log.info("Closed the database", .{});
}

pub fn columnSlice(stmt: ?*c.sqlite3_stmt, col: c_int) [:0]const u8 {
    const ptr = c.sqlite3_column_text(stmt, col) orelse return "null";
    const len: usize = @intCast(c.sqlite3_column_bytes(stmt, col));
    return ptr[0..len :0];
}
