const std = @import("std");
const apeiron_logger = @import("apeiron_logger");
//const apeiron_logger_build = @import("./apeiron-logger/build.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const fw = b.addModule("apeiron-framework", .{
        .root_source_file = b.path("src/frame.zig"),
        .target = target,
        .optimize = optimize,
    });

    const apeiron_logger_dep = b.dependency("apeiron_logger", .{
        .target = target,
        .optimize = optimize,
    });

    var apeiron_logger_mod = apeiron_logger_dep.module("apeiron-logger");

    const apeiron_logger_common_mod = apeiron_logger_dep.module("commond");
    apeiron_logger_mod.addImport("common", apeiron_logger_common_mod);

    const apeiron_logger_user_config_mod: *std.Build.Module = apeiron_logger.generate_config_module(b, target, optimize, "./logger_config.json") catch |err| {
        std.debug.print("compilation error: {}\n", .{err});
        return;
    };
    apeiron_logger_user_config_mod.addImport("common", apeiron_logger_common_mod);
    apeiron_logger_mod.addImport("user_config", apeiron_logger_user_config_mod);

    const exe = b.addExecutable(.{
        .name = "demo",
        .root_source_file = b.path("src/demo/demo.zig"),
        .target = target,
        .optimize = optimize,
    });

    fw.addImport("apeiron-logger", apeiron_logger_dep.module("apeiron-logger"));
    exe.root_module.addImport("apeiron-framework", fw);
    exe.linkLibC();
    exe.root_module.addImport("apeiron-logger", apeiron_logger_dep.module("apeiron-logger"));

    if (b.option(bool, "enable-demo", "install the demo too") orelse false) {
        b.installArtifact(exe);
    }
}
