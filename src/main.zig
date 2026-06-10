const std = @import("std");
const log = std.log;

const cfg = @import("config.zig");
const Model = @import("model/Model.zig");
const Conn = @import("model/db/Conn.zig");
const App = @import("gui/gtk/App.zig");

pub fn main() !void {
    var a_inst = std.heap.DebugAllocator(.{ .safety = true }){};
    defer log.debug("gpa: {}", .{a_inst.deinit()});

    const a = a_inst.allocator();

    const conn = try Conn.open(a, cfg.db_name);
    defer conn.close() catch {};

    const model: *Model = try Model.create(
        a,
        conn,
        .Ready,
    );
    defer model.destroy(a);

    _ = App.run(model);
}
