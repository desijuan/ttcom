const std = @import("std");
const Allocator = std.mem.Allocator;
const log = std.log;

const c = @cImport(@cInclude("sqlite3.h"));

const utils = @import("../../utils.zig");

const path_db_schema = "src/model/db/schema.sql";

pub const sqlite3 = c.sqlite3;

pub const Config = struct {
    log_file: [:0]const u8,
    push_ip: [:0]const u8,
    push_port: u16,
    push_freq_s: u32,
    timeout_s: u32,

    pub fn destroy(cfg: *Config, a: Allocator) void {
        a.free(cfg.log_file);
        a.free(cfg.push_ip);
        a.destroy(cfg);
    }
};

const Conn = @This();

p_db: ?*c.sqlite3,

const OpenError = utils.ReadFileZError || error{ OpenFailed, SchemaExecFailed };

pub fn open(a: Allocator, file_name: [:0]const u8) OpenError!Conn {
    const schema_str: [:0]const u8 = try utils.readFileZ(a, path_db_schema);
    defer a.free(schema_str);

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

    var err_msg: [*c]u8 = null;
    const rc = c.sqlite3_exec(p_db, schema_str, null, null, &err_msg);
    if (rc != c.SQLITE_OK) {
        defer c.sqlite3_free(err_msg);
        log.err("failed to apply schema: {s}", .{err_msg});
        return error.SchemaExecFailed;
    }

    return Conn{ .p_db = p_db };
}

pub fn close(self: Conn) error{CloseFailed}!void {
    if (c.sqlite3_close(self.p_db) != c.SQLITE_OK) {
        log.err(
            "Error closing the database: {s}",
            .{c.sqlite3_errmsg(self.p_db)},
        );
        return error.CloseFailed;
    }

    log.info("Closed the database", .{});
}

pub const ReadConfigError = error{ OutOfMemory, PrepareFailed, NoRows, ValueOutOfRange };

pub fn readConfig(self: Conn, a: Allocator) ReadConfigError!*Config {
    const sql = "SELECT log_file, push_ip, push_port, push_freq_s, timeout_s FROM config";

    var stmt: ?*c.sqlite3_stmt = null;
    const rc_prep = c.sqlite3_prepare_v2(self.p_db, sql, -1, &stmt, null);
    if (rc_prep != c.SQLITE_OK) {
        log.err("sqlite3_prepare_v2: {s}", .{c.sqlite3_errmsg(self.p_db)});
        return error.PrepareFailed;
    }
    defer _ = c.sqlite3_finalize(stmt);

    const rc_step = c.sqlite3_step(stmt);
    if (rc_step != c.SQLITE_ROW) {
        log.err("sqlite3_step: no rows", .{});
        return error.NoRows;
    }

    const log_file: [:0]const u8 = try a.dupeZ(u8, columnSlice(stmt, 0));
    errdefer a.free(log_file);

    const push_ip: [:0]const u8 = try a.dupeZ(u8, columnSlice(stmt, 1));
    errdefer a.free(push_ip);

    const push_port: u16 = std.math.cast(u16, c.sqlite3_column_int(stmt, 2)) orelse
        return error.ValueOutOfRange;

    const push_freq_s: u32 = std.math.cast(u32, c.sqlite3_column_int(stmt, 3)) orelse
        return error.ValueOutOfRange;

    const timeout_s: u32 = std.math.cast(u32, c.sqlite3_column_int(stmt, 4)) orelse
        return error.ValueOutOfRange;

    const cfg = try a.create(Config);
    errdefer a.destroy(cfg);

    cfg.* = Config{
        .log_file = log_file,
        .push_ip = push_ip,
        .push_port = push_port,
        .push_freq_s = push_freq_s,
        .timeout_s = timeout_s,
    };

    return cfg;
}

pub const WriteConfigError = error{ PrepareFailed, BindFailed, StepFailed };

pub fn writeConfig(self: Conn, cfg: *const Config) WriteConfigError!void {
    const sql =
        \\UPDATE config 
        \\SET log_file=?, push_ip=?, push_port=?, push_freq_s=?, timeout_s=? 
        \\WHERE id = 1;
    ;

    var stmt: ?*c.sqlite3_stmt = null;
    const rc_prep = c.sqlite3_prepare_v2(self.p_db, sql, -1, &stmt, null);
    if (rc_prep != c.SQLITE_OK) {
        log.err("sqlite3_prepare_v2: {s}", .{c.sqlite3_errmsg(self.p_db)});
        return error.PrepareFailed;
    }
    defer _ = c.sqlite3_finalize(stmt);

    if (c.sqlite3_bind_text(stmt, 1, cfg.log_file.ptr, -1, c.SQLITE_STATIC) != c.SQLITE_OK or
        c.sqlite3_bind_text(stmt, 2, cfg.push_ip.ptr, -1, c.SQLITE_STATIC) != c.SQLITE_OK or
        c.sqlite3_bind_int(stmt, 3, @intCast(cfg.push_port)) != c.SQLITE_OK or
        c.sqlite3_bind_int(stmt, 4, @intCast(cfg.push_freq_s)) != c.SQLITE_OK or
        c.sqlite3_bind_int(stmt, 5, @intCast(cfg.timeout_s)) != c.SQLITE_OK)
    {
        log.err("sqlite3_bind: {s}", .{c.sqlite3_errmsg(self.p_db)});
        return error.BindFailed;
    }

    const rc_step = c.sqlite3_step(stmt);
    if (rc_step != c.SQLITE_DONE) {
        log.err("sqlite3_step: {s}", .{c.sqlite3_errmsg(self.p_db)});
        return error.StepFailed;
    }
}

fn columnSlice(stmt: ?*c.sqlite3_stmt, col: c_int) [:0]const u8 {
    const ptr = c.sqlite3_column_text(stmt, col) orelse return "";
    const len: usize = @intCast(c.sqlite3_column_bytes(stmt, col));
    return ptr[0..len :0];
}
