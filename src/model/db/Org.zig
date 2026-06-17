const std = @import("std");
const log = std.log;
const ArrayList = std.ArrayList;

const c = @import("c.zig").sqlite3;

const mem = @import("../../mem.zig");

const Conn = @import("Conn.zig");
const columnSlice = Conn.columnSlice;

const Org = @This();

id: i32,
name: [:0]const u8,

pub fn free(self: *const Org) void {
    mem.a.free(self.name);
}

pub const GetAllError = error{ OutOfMemory, PrepareFailed, StepFailed };

pub fn getAll(conn: Conn) GetAllError![]const Org {
    const sql = "SELECT id, name FROM orgs";

    var stmt: ?*c.sqlite3_stmt = null;

    // Prepare
    if (c.SQLITE_OK != c.sqlite3_prepare_v2(conn.p_db, sql, -1, &stmt, null)) {
        log.err("sqlite3_prepare_v2: {s}", .{c.sqlite3_errmsg(conn.p_db)});
        return error.PrepareFailed;
    }
    defer _ = c.sqlite3_finalize(stmt);

    // Init ArrayList
    var list: ArrayList(Org) = try .initCapacity(mem.a, 16);
    errdefer list.deinit(mem.a);

    // Step
    var rc: c_int = c.sqlite3_step(stmt);
    while (rc == c.SQLITE_ROW) : (rc = c.sqlite3_step(stmt)) {
        const id: i32 = c.sqlite3_column_int(stmt, 0);

        const name: [:0]const u8 = try mem.a.dupeZ(u8, columnSlice(stmt, 1));
        errdefer mem.a.free(name);

        try list.append(mem.a, Org{
            .id = id,
            .name = name,
        });
    } else if (rc != c.SQLITE_DONE) {
        std.log.err("Error stepping statement\n{s}\n{s}", .{ sql, c.sqlite3_errmsg(conn.p_db) });
        return error.StepFailed;
    }

    return list.toOwnedSlice(mem.a);
}
