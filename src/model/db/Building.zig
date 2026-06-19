const std = @import("std");
const log = std.log;
const ArrayList = std.ArrayList;

const c = @import("c.zig").sqlite3;

const mem = @import("../../mem.zig");

const Conn = @import("Conn.zig");
const columnSlice = Conn.columnSlice;

const Building = @This();

org_id: i32,
id: i32,
name: [:0]const u8,

pub fn deinit(self: *const Building) void {
    mem.a.free(self.name);
}

pub const GetAllError = error{ OutOfMemory, PrepareFailed, StepFailed };

pub fn getAll(conn: Conn) GetAllError![]const Building {
    const sql = "SELECT id, name, org_id FROM buildings";

    var stmt: ?*c.sqlite3_stmt = null;

    // Prepare
    if (c.SQLITE_OK != c.sqlite3_prepare_v2(conn.p_db, sql, -1, &stmt, null)) {
        log.err("sqlite3_prepare_v2: {s}", .{c.sqlite3_errmsg(conn.p_db)});
        return error.PrepareFailed;
    }
    defer _ = c.sqlite3_finalize(stmt);

    // Init ArrayList
    var list: ArrayList(Building) = try .initCapacity(mem.a, 16);
    errdefer list.deinit(mem.a);

    // Step
    var rc: c_int = c.sqlite3_step(stmt);
    while (rc == c.SQLITE_ROW) : (rc = c.sqlite3_step(stmt)) {
        const id: c_int = c.sqlite3_column_int(stmt, 0);

        const name: [:0]const u8 = try mem.a.dupeZ(u8, columnSlice(stmt, 1));
        errdefer mem.a.free(name);

        const org_id: c_int = c.sqlite3_column_int(stmt, 2);

        try list.append(mem.a, Building{
            .org_id = org_id,
            .id = id,
            .name = name,
        });
    } else if (rc != c.SQLITE_DONE) {
        std.log.err("Error stepping statement\n{s}\n{s}", .{ sql, c.sqlite3_errmsg(conn.p_db) });
        return error.StepFailed;
    }

    return list.toOwnedSlice(mem.a);
}

pub const FindByOrgIdError = error{ OutOfMemory, PrepareFailed, BindFailed, StepFailed };

pub fn findByOrgId(org_id: c_int, conn: Conn) FindByOrgIdError![]const Building {
    const sql = "SELECT id, name FROM buildings WHERE org_id  = ?";

    var stmt: ?*c.sqlite3_stmt = null;

    // Prepare
    if (c.SQLITE_OK != c.sqlite3_prepare_v2(conn.p_db, sql, -1, &stmt, null)) {
        log.err("sqlite3_prepare_v2: {s}", .{c.sqlite3_errmsg(conn.p_db)});
        return error.PrepareFailed;
    }
    defer _ = c.sqlite3_finalize(stmt);

    // Bind
    if (c.SQLITE_OK != c.sqlite3_bind_int(stmt, 1, org_id)) {
        log.err("sqlite3_bind_int: {s}", .{c.sqlite3_errmsg(conn.p_db)});
        return error.BindFailed;
    }

    // Init ArrayList
    var list: ArrayList(Building) = try .initCapacity(mem.a, 16);
    errdefer list.deinit(mem.a);

    // Step
    var rc: c_int = c.sqlite3_step(stmt);
    while (rc == c.SQLITE_ROW) : (rc = c.sqlite3_step(stmt)) {
        const id: c_int = c.sqlite3_column_int(stmt, 0);

        const name: [:0]const u8 = try mem.a.dupeZ(u8, columnSlice(stmt, 1));
        errdefer mem.a.free(name);

        try list.append(mem.a, Building{
            .org_id = org_id,
            .id = id,
            .name = name,
        });
    } else if (rc != c.SQLITE_DONE) {
        std.log.err("Error stepping statement\n{s}\n{s}", .{ sql, c.sqlite3_errmsg(conn.p_db) });
        return error.StepFailed;
    }

    return list.toOwnedSlice(mem.a);
}
