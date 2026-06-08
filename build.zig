const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const root_mod: *std.Build.Module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const exe = b.addExecutable(.{
        .name = "ttcom",
        .root_module = root_mod,
        .use_llvm = true,
    });

    // - SQLite3 -
    //
    switch (optimize) {
        .Debug => root_mod.linkSystemLibrary("sqlite3", .{}),
        else => {
            root_mod.addIncludePath(b.path("sqlite3"));
            root_mod.addCSourceFile(.{
                .file = b.path("sqlite3/sqlite3.c"),
                .flags = &.{},
            });
        },
    }

    //
    // - GTK 3 -
    //
    root_mod.linkSystemLibrary("c", .{});
    root_mod.linkSystemLibrary("gtk+-3.0", .{ .use_pkg_config = .force });

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_exe_tests.step);
}
