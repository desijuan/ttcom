const std = @import("std");
const log = std.log;

const Conn = @import("model/db/Conn.zig");
const App = @import("gui/gtk/App.zig");

const db_name = "db.sqlite";

pub fn main() !void {
    const conn = try Conn.open(db_name);
    defer conn.close() catch {};

    _ = App.run();
}
