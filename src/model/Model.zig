const std = @import("std");
const Allocator = std.mem.Allocator;
const log = std.log;

const Conn = @import("db/Conn.zig");

pub const Config = struct {
    log_file: [:0]const u8,
    push_ip: [:0]const u8,
    push_port: u16,
    push_freq_s: u32,
    timeout_s: u32,

    pub fn destroy(cfg: *Config, a: Allocator) void {
        a.free(cfg.log_file);
        a.free(cfg.push_ip);
        a.destroy(cfg);
    }
};

const Model = @This();

config: Config,

pub fn create(
    a: Allocator,
    conn: Conn,
) (Conn.ReadConfigError || error{OutOfMemory})!*Model {
    const model: *Model = try a.create(Model);
    errdefer a.destroy(model);

    const config: *Config = try conn.readConfig(a);
    defer a.destroy(config);

    model.* = Model{
        .config = config.*,
    };

    return model;
}

pub fn destroy(model: *Model, a: Allocator) void {
    a.free(model.config.log_file);
    a.free(model.config.push_ip);
    a.destroy(model);
}
