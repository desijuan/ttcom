const std = @import("std");
const log = std.log;

const c = @cImport(@cInclude("sqlite3.h"));

pub const sqlite3 = c.sqlite3;

p_db: ?*c.sqlite3,

const Self = @This();

inline fn columnSlice(stmt: ?*c.sqlite3_stmt, iCol: comptime_int) []const u8 {
    return c.sqlite3_column_text(stmt, iCol)[0..@as(usize, @intCast(c.sqlite3_column_bytes(stmt, iCol)))];
}

pub fn open(file_name: [:0]const u8) error{OpenFailed}!Self {
    log.info("SQLite v{s}", .{c.sqlite3_libversion()});

    var p_db: ?*c.sqlite3 = null;

    if (c.sqlite3_open_v2(
        file_name,
        &p_db,
        c.SQLITE_OPEN_READWRITE | c.SQLITE_OPEN_CREATE,
        null,
    ) != c.SQLITE_OK) {
        log.err(
            "Error opening the database: {s}\n{s}",
            .{ file_name, c.sqlite3_errmsg(p_db) },
        );
        _ = c.sqlite3_close(p_db);
        return error.OpenFailed;
    }

    log.info("Connected to database: {s}", .{file_name});

    return Self{ .p_db = p_db };
}

pub fn close(self: *const Self) error{CloseFailed}!void {
    if (c.sqlite3_close(self.p_db) != c.SQLITE_OK) {
        log.err(
            "Error closing the database: {s}",
            .{c.sqlite3_errmsg(self.p_db)},
        );
        return error.CloseFailed;
    }

    log.info("Closed the database", .{});
}
