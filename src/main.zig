const std = @import("std");
const log = std.log;

const mem = @import("mem.zig");
const cfg = @import("config.zig");
const Conn = @import("model/db/Conn.zig");
const App = @import("gui/gtk/App.zig");

pub fn main() (Conn.OpenError || App.CreateError)!void {
    defer mem.a_deinit();

    const conn = try Conn.open(cfg.db_name);
    defer conn.close();

    const app = try App.create(conn);
    defer app.destroy();

    _ = app.run();
}
