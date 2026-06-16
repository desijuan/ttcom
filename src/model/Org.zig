const std = @import("std");
const log = std.log;

const c = @import("../c.zig").sqlite3;

const mem = @import("../mem.zig");

const Conn = @import("db/Conn.zig");
const columnSlice = Conn.columnSlice;

const Org = @This();

id: i32,
name: [:0]const u8,

pub fn destroy(self: *const Org) void {
    mem.a.free(self.name);
    mem.a.destroy(self);
}

pub const ReadFromConnError = error{ OutOfMemory, PrepareFailed, NoRows, ValueOutOfRange };

pub fn readFromConn(conn: Conn) ReadFromConnError![]const Org {
    _ = conn;
    @panic("TODO");
    // const sql = "SELECT log_file, push_ip, push_port, push_freq_s, timeout_s FROM settings";
    //
    // var stmt: ?*c.sqlite3_stmt = null;
    //
    // // Prepare
    // if (c.SQLITE_OK != c.sqlite3_prepare_v2(conn.p_db, sql, -1, &stmt, null)) {
    //     log.err("sqlite3_prepare_v2: {s}", .{c.sqlite3_errmsg(conn.p_db)});
    //     return error.PrepareFailed;
    // }
    // defer _ = c.sqlite3_finalize(stmt);
    //
    // // Step
    // if (c.SQLITE_ROW != c.sqlite3_step(stmt)) {
    //     log.err("sqlite3_step: no rows", .{});
    //     return error.NoRows;
    // }
    //
    // // Copy String
    // const log_file: [:0]const u8 = try mem.a.dupeZ(u8, columnSlice(stmt, 0));
    // errdefer mem.a.free(log_file);
    //
    // // Copy String
    // const push_ip: [:0]const u8 = try mem.a.dupeZ(u8, columnSlice(stmt, 1));
    // errdefer mem.a.free(push_ip);
    //
    // // Read Ints
    // const push_port: u16 = std.math.cast(u16, c.sqlite3_column_int(stmt, 2)) orelse
    //     return error.ValueOutOfRange;
    // const push_freq_s: u32 = std.math.cast(u32, c.sqlite3_column_int(stmt, 3)) orelse
    //     return error.ValueOutOfRange;
    // const timeout_s: u32 = std.math.cast(u32, c.sqlite3_column_int(stmt, 4)) orelse
    //     return error.ValueOutOfRange;
    //
    // // Alloc
    // const settings: *Settings = try mem.a.create(Settings);
    // errdefer mem.a.destroy(settings);
    //
    // // Write
    // settings.* = Settings{
    //     .log_file = log_file,
    //     .push_ip = push_ip,
    //     .push_port = push_port,
    //     .push_freq_s = push_freq_s,
    //     .timeout_s = timeout_s,
    // };
    //
    // return settings;
}
