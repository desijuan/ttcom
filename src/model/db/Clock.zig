const std = @import("std");
const log = std.log;
const ArrayList = std.ArrayList;

const c = @import("c.zig").sqlite3;

const mem = @import("../../mem.zig");

const Conn = @import("Conn.zig");

const Clock = @This();

building_id: i32,
id: i32,
name: [:0]const u8,
ip: [:0]const u8, // TODO: Store ip as [4]u8 ?
port: u16,

pub fn deinit(self: *const Clock) void {
    mem.a.free(self.name);
    mem.a.free(self.ip);
}

pub const GetAllError = error{ OutOfMemory, PrepareFailed, StepFailed };

pub fn getAll(conn: Conn) GetAllError![]const Clock {
    const sql = "SELECT id, name, ip, port, building_id FROM clocks";

    var stmt: ?*c.sqlite3_stmt = null;

    // Prepare
    if (c.SQLITE_OK != c.sqlite3_prepare_v2(conn.p_db, sql, -1, &stmt, null)) {
        log.err("sqlite3_prepare_v2: {s}", .{c.sqlite3_errmsg(conn.p_db)});
        return error.PrepareFailed;
    }
    defer _ = c.sqlite3_finalize(stmt);

    // Init ArrayList
    var list: ArrayList(Clock) = try .initCapacity(mem.a, 16);
    errdefer list.deinit(mem.a);

    // Step
    var rc: c_int = c.sqlite3_step(stmt);
    while (rc == c.SQLITE_ROW) : (rc = c.sqlite3_step(stmt)) {
        const id: c_int = c.sqlite3_column_int(stmt, 0);

        const name: [:0]const u8 = try mem.a.dupeZ(u8, Conn.getColumnSlice(stmt, 1));
        errdefer mem.a.free(name);

        const ip: [:0]const u8 = try mem.a.dupeZ(u8, Conn.getColumnSlice(stmt, 2));
        errdefer mem.a.free(ip);

        const port: c_int = c.sqlite3_column_int(stmt, 3);
        const building_id: c_int = c.sqlite3_column_int(stmt, 4);

        try list.append(mem.a, Clock{
            .building_id = building_id,
            .id = id,
            .name = name,
            .ip = ip,
            .port = @intCast(port),
        });
    } else if (rc != c.SQLITE_DONE) {
        std.log.err("Error stepping statement\n{s}\n{s}", .{ sql, c.sqlite3_errmsg(conn.p_db) });
        return error.StepFailed;
    }

    return list.toOwnedSlice(mem.a);
}

pub const FindByBuildingIdError = error{ OutOfMemory, PrepareFailed, StepFailed, CastFailed };

pub fn findByBuildingId(building_id: c_int, conn: Conn) ![]const Clock {
    const sql = "SELECT id, name, ip, port FROM clocks WHERE building_id  = ?";

    var stmt: ?*c.sqlite3_stmt = null;

    // Prepare
    if (c.SQLITE_OK != c.sqlite3_prepare_v2(conn.p_db, sql, -1, &stmt, null)) {
        log.err("sqlite3_prepare_v2: {s}", .{c.sqlite3_errmsg(conn.p_db)});
        return error.PrepareFailed;
    }
    defer _ = c.sqlite3_finalize(stmt);

    // Bind
    if (c.SQLITE_OK != c.sqlite3_bind_int(stmt, 1, building_id)) {
        log.err("sqlite3_bind_int: {s}", .{c.sqlite3_errmsg(conn.p_db)});
        return error.BindFailed;
    }

    // Init ArrayList
    var list: ArrayList(Clock) = try .initCapacity(mem.a, 16);
    errdefer list.deinit(mem.a);

    // Step
    var rc: c_int = c.sqlite3_step(stmt);
    while (rc == c.SQLITE_ROW) : (rc = c.sqlite3_step(stmt)) {
        const id: c_int = c.sqlite3_column_int(stmt, 0);

        const name: [:0]const u8 = try mem.a.dupeZ(u8, Conn.getColumnSlice(stmt, 1));
        errdefer mem.a.free(name);

        const ip: [:0]const u8 = try mem.a.dupeZ(u8, Conn.getColumnSlice(stmt, 2));
        errdefer mem.a.free(ip);

        const port: u16 = std.math.cast(u16, c.sqlite3_column_int(stmt, 3)) orelse
            return error.CastFailed;

        try list.append(mem.a, Clock{
            .building_id = building_id,
            .id = id,
            .name = name,
            .ip = ip,
            .port = port,
        });
    } else if (rc != c.SQLITE_DONE) {
        std.log.err("Error stepping statement\n{s}\n{s}", .{ sql, c.sqlite3_errmsg(conn.p_db) });
        return error.StepFailed;
    }

    return list.toOwnedSlice(mem.a);
}
