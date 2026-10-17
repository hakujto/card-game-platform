const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zap_dep = b.dependency("zap", .{ .target = target, .optimize = optimize });

    const sqlite3_tc = b.addTranslateC(.{
        .root_source_file = b.path("sqlite3_stub.h"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    const sqlite3_mod = sqlite3_tc.createModule();
    sqlite3_mod.link_libc = true;
    sqlite3_mod.linkSystemLibrary("sqlite3", .{});

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_mod.addImport("zap", zap_dep.module("zap"));
    exe_mod.addImport("c", sqlite3_mod);
    exe_mod.link_libc = true;

    const exe = b.addExecutable(.{
        .name = "cards_project",
        .root_module = exe_mod,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const test_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    test_mod.addImport("zap", zap_dep.module("zap"));
    test_mod.addImport("c", sqlite3_mod);
    test_mod.link_libc = true;

    const unit_tests = b.addTest(.{
        .root_module = test_mod,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
