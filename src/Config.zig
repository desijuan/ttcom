const std = @import("std");

const mem = @import("mem.zig");
const utils = @import("utils.zig");

const Config = @This();

db_filename: [:0]const u8 = "db.sqlite",

pub const ReadFromDiskError = utils.ReadFileZError || error{ParseZon};

pub fn readFromDisk() ReadFromDiskError!Config {
    const cfg_def = Config{};

    // Copy default values so that we don't crash when freeing the memory
    const def_cp: [:0]const u8 = try mem.a.dupeZ(u8, cfg_def.db_filename);
    errdefer mem.a.free(def_cp);

    const cfg_buffer: [:0]const u8 = utils.readFileZ(mem.a, "config.zon") catch |err| switch (err) {
        error.FileNotFound => return Config{ .db_filename = def_cp },
        else => return err,
    };
    defer mem.a.free(cfg_buffer);
    mem.a.free(def_cp);

    return try std.zon.parse.fromSlice(Config, mem.a, cfg_buffer, null, .{
        .ignore_unknown_fields = false,
        .free_on_error = true,
    });
}

pub fn deinit(self: Config) void {
    mem.a.free(self.db_filename);
}
