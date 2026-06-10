const std = @import("std");
const Allocator = std.mem.Allocator;
const log = std.log;

const Conn = @import("db/Conn.zig");

const TabLog = struct {};

const TabClocks = struct {};

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

const Tabs = struct {
    t_log: TabLog,
    t_clocks: TabClocks,
    t_settings: Config,
};

pub const Status = enum {
    Idle,
    Ready,
    Error,

    pub fn tagName(self: Status) [:0]const u8 {
        return @tagName(self);
    }
};

const Model = @This();

tabs: Tabs,
status: Status,

pub fn create(
    a: Allocator,
    conn: Conn,
    status: Status,
) (Conn.GetConfigError || error{OutOfMemory})!*Model {
    const model: *Model = try a.create(Model);
    errdefer a.destroy(model);

    const cfg: *Config = try conn.getConfig(a);
    defer a.destroy(cfg);

    model.* = Model{
        .tabs = Tabs{
            .t_log = TabLog{},
            .t_clocks = TabClocks{},
            .t_settings = cfg.*,
        },
        .status = status,
    };

    return model;
}

pub fn destroy(model: *Model, a: Allocator) void {
    a.free(model.tabs.t_settings.log_file);
    a.free(model.tabs.t_settings.push_ip);
    a.destroy(model);
}
