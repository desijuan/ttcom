const std = @import("std");
const log = std.log;

const cfg = @import("config.zig");
const Model = @import("model/Model.zig");
const Conn = @import("model/db/Conn.zig");
const App = @import("gui/gtk/App.zig");

pub fn main() !void {
    var da_inst = std.heap.DebugAllocator(.{ .safety = true }){};
    defer log.debug("gpa: {}", .{da_inst.deinit()});

    const da = da_inst.allocator();

    const conn = try Conn.open(da, cfg.db_name);
    defer conn.close() catch {};

    const model: *Model = try Model.create(da, conn);
    defer model.destroy(da);

    const app = try App.create(da, model, conn);
    defer app.destroy(da);

    _ = app.run();
}
