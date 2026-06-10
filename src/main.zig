const std = @import("std");
const log = std.log;

const cfg = @import("config.zig");
const Model = @import("model/Model.zig");
const Conn = @import("model/db/Conn.zig");
const App = @import("gui/gtk/App.zig");

pub fn main() !void {
    var gpa_inst = std.heap.DebugAllocator(.{ .safety = true }){};
    defer log.debug("gpa: {}", .{gpa_inst.deinit()});

    const gpa = gpa_inst.allocator();

    const conn = try Conn.open(cfg.db_name);
    defer conn.close() catch {};

    const model: *Model = try Model.create(
        gpa,
        "192.168.1.100",
        "90",
        "log.txt",
        "30",
        .Ready,
    );
    defer model.destroy(gpa);

    _ = App.run(model);
}
