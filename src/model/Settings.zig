const std = @import("std");
const Allocator = std.mem.Allocator;
const log = std.log;

const c = @import("../c.zig").sqlite3;

const Conn = @import("db/Conn.zig");
const columnSlice = Conn.columnSlice;

const Settings = @This();

log_file: [:0]const u8,
push_ip: [:0]const u8,
push_port: u16,
push_freq_s: u32,
timeout_s: u32,

pub fn destroy(self: *Settings, a: Allocator) void {
    a.free(self.log_file);
    a.free(self.push_ip);
    a.destroy(self);
}

pub const ReadFromConnError = error{ OutOfMemory, PrepareFailed, NoRows, ValueOutOfRange };

pub fn readFromConn(a: Allocator, conn: Conn) ReadFromConnError!*Settings {
    const sql = "SELECT log_file, push_ip, push_port, push_freq_s, timeout_s FROM settings";

    var stmt: ?*c.sqlite3_stmt = null;

    // Prepare
    if (c.SQLITE_OK != c.sqlite3_prepare_v2(conn.p_db, sql, -1, &stmt, null)) {
        log.err("sqlite3_prepare_v2: {s}", .{c.sqlite3_errmsg(conn.p_db)});
        return error.PrepareFailed;
    }
    defer _ = c.sqlite3_finalize(stmt);

    // Step
    if (c.SQLITE_ROW != c.sqlite3_step(stmt)) {
        log.err("sqlite3_step: no rows", .{});
        return error.NoRows;
    }

    // Copy String
    const log_file: [:0]const u8 = try a.dupeZ(u8, columnSlice(stmt, 0));
    errdefer a.free(log_file);

    // Copy String
    const push_ip: [:0]const u8 = try a.dupeZ(u8, columnSlice(stmt, 1));
    errdefer a.free(push_ip);

    // Read Ints
    const push_port: u16 = std.math.cast(u16, c.sqlite3_column_int(stmt, 2)) orelse
        return error.ValueOutOfRange;
    const push_freq_s: u32 = std.math.cast(u32, c.sqlite3_column_int(stmt, 3)) orelse
        return error.ValueOutOfRange;
    const timeout_s: u32 = std.math.cast(u32, c.sqlite3_column_int(stmt, 4)) orelse
        return error.ValueOutOfRange;

    // Alloc
    const settings: *Settings = try a.create(Settings);
    errdefer a.destroy(settings);

    // Write
    settings.* = Settings{
        .log_file = log_file,
        .push_ip = push_ip,
        .push_port = push_port,
        .push_freq_s = push_freq_s,
        .timeout_s = timeout_s,
    };

    return settings;
}

pub const WriteToConnError = error{ PrepareFailed, BindFailed, StepFailed };

pub fn writeToConn(self: Settings, conn: Conn) WriteToConnError!void {
    const sql =
        \\UPDATE settings 
        \\SET log_file=?, push_ip=?, push_port=?, push_freq_s=?, timeout_s=? 
        \\WHERE id = 1;
    ;

    var stmt: ?*c.sqlite3_stmt = null;

    // Prepare
    if (c.SQLITE_OK != c.sqlite3_prepare_v2(conn.p_db, sql, -1, &stmt, null)) {
        log.err("sqlite3_prepare_v2: {s}", .{c.sqlite3_errmsg(conn.p_db)});
        return error.PrepareFailed;
    }
    defer _ = c.sqlite3_finalize(stmt);

    // Bind
    if (c.SQLITE_OK != c.sqlite3_bind_text(stmt, 1, self.log_file.ptr, -1, c.SQLITE_STATIC) or
        c.SQLITE_OK != c.sqlite3_bind_text(stmt, 2, self.push_ip.ptr, -1, c.SQLITE_STATIC) or
        c.SQLITE_OK != c.sqlite3_bind_int(stmt, 3, @intCast(self.push_port)) or
        c.SQLITE_OK != c.sqlite3_bind_int(stmt, 4, @intCast(self.push_freq_s)) or
        c.SQLITE_OK != c.sqlite3_bind_int(stmt, 5, @intCast(self.timeout_s)))
    {
        log.err("sqlite3_bind: {s}", .{c.sqlite3_errmsg(conn.p_db)});
        return error.BindFailed;
    }

    // Step
    if (c.SQLITE_DONE != c.sqlite3_step(stmt)) {
        log.err("sqlite3_step: {s}", .{c.sqlite3_errmsg(conn.p_db)});
        return error.StepFailed;
    }
}
