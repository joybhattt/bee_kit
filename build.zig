const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // 1. Determine OS and Arch for the path
    const os_tag = target.result.os.tag;
    const os_name = @tagName(os_tag);
    const arch_name = @tagName(target.result.cpu.arch);
    const custom_path = b.fmt("bin/{s}/{s}", .{ os_name, arch_name });

    var install_options: std.Build.Step.InstallArtifact.Options = undefined;
    if (os_tag == .windows) {
        install_options = .{
            .dest_dir = .{ .override = .{ .custom = custom_path } },
            .pdb_dir = .{ .override = .{ .custom = custom_path } },
        };
    } else {
        install_options = .{ .dest_dir = .{ .override = .{ .custom = custom_path } } };
    }

    const zio_dep = b.dependency("zio", .{
        .target = target,
        .optimize = optimize,
    });

    // --- Client Setup ---
    const main_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const root_module = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    root_module.addImport("zio", zio_dep.module("zio"));
    main_module.addImport("deps", root_module);

    const exe = b.addExecutable(.{
        .name = "bee_engine",
        .root_module = main_module,
    });
    exe.linkLibC();

    const install_exe = b.addInstallArtifact(exe, .{
        .dest_dir = .{ .override = .{ .custom = custom_path } },
        .pdb_dir = if (os_tag == .windows) .{ .override = .{ .custom = custom_path } } else .default,
    });

    // This is the critical part: tell the main 'install' step to wait for YOUR step
    b.getInstallStep().dependOn(&install_exe.step);
}
