const std = @import("std");
const log = std.log;

const mem = @import("mem.zig");
const Config = @import("Config.zig");
const Conn = @import("model/db/Conn.zig");
const App = @import("gui/gtk/App.zig");

pub fn main() (Config.ReadFromDiskError || Conn.OpenError || Conn.ExecSchemaError || App.CreateError)!void {
    defer mem.a_deinit();

    const cfg: Config = try Config.readFromDisk();
    defer cfg.deinit();

    const conn: Conn = try Conn.open(cfg.db_filename);
    defer conn.close();

    try conn.execSchema();

    const app: *const App = try App.create(cfg, conn);
    defer app.destroy();

    _ = app.run();
}
