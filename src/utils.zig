const std = @import("std");
const Allocator = std.mem.Allocator;
const Io = std.Io;

pub const ReadFileZError = std.fs.File.OpenError || std.fs.File.GetEndPosError ||
    std.Io.Reader.Error || error{OutOfMemory};

pub fn readFileZ(allocator: Allocator, path: []const u8) ReadFileZError![:0]const u8 {
    const file: std.fs.File = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
    defer file.close();

    var buf: [4 * 1024]u8 = undefined;
    var reader: std.fs.File.Reader = file.reader(&buf);

    const size: u64 = try file.getEndPos();

    const bytes: []u8 = try allocator.alloc(u8, size + 1);
    errdefer allocator.free(bytes);

    try reader.interface.readSliceAll(bytes[0..size]);

    bytes[size] = 0;

    return bytes[0..size :0];
}

pub fn getField(comptime T: type, comptime name: []const u8) ?std.builtin.StructField {
    inline for (@typeInfo(T).@"struct".fields) |field| {
        if (std.mem.eql(u8, field.name, name))
            return field;
    }
    return null;
}
