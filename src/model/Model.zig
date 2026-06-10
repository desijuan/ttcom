const std = @import("std");
const Allocator = std.mem.Allocator;
const log = std.log;

const TabLog = struct {};

const TabClocks = struct {};

const TabSettings = struct {
    push_ip: [:0]const u8,
    push_freq: [:0]const u8,
    log_file: [:0]const u8,
    timeout: [:0]const u8,
};

const Tabs = struct {
    t_log: TabLog,
    t_clocks: TabClocks,
    t_settings: TabSettings,
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
    push_ip: [:0]const u8,
    push_freq: [:0]const u8,
    log_file: [:0]const u8,
    timeout: [:0]const u8,
    status: Status,
) error{OutOfMemory}!*Model {
    const model: *Model = try a.create(Model);
    errdefer a.destroy(model);

    model.* = Model{
        .tabs = Tabs{
            .t_log = TabLog{},
            .t_clocks = TabClocks{},
            .t_settings = TabSettings{
                .push_ip = push_ip,
                .push_freq = push_freq,
                .log_file = log_file,
                .timeout = timeout,
            },
        },
        .status = status,
    };

    return model;
}

pub fn destroy(model: *Model, a: Allocator) void {
    a.destroy(model);
}
