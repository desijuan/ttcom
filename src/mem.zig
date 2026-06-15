const std = @import("std");
const Allocator = std.mem.Allocator;

pub const AllocInst: type = switch (@import("builtin").mode) {
    .ReleaseSmall, .ReleaseFast => c_allocator,
    .Debug, .ReleaseSafe => DebugAllocator,
};

pub const a: Allocator = AllocInst.allocator();

pub fn a_deinit() void {
    if (comptime @hasDecl(AllocInst, "deinit")) AllocInst.deinit();
}

const c_allocator = struct {
    pub fn allocator() Allocator {
        return std.heap.c_allocator;
    }
};

const DebugAllocator = struct {
    var da_inst = std.heap.DebugAllocator(.{ .safety = true }){};

    pub fn allocator() Allocator {
        return da_inst.allocator();
    }

    pub fn deinit() void {
        std.log.debug("gpa: {}", .{da_inst.deinit()});
    }
};
