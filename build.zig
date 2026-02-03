const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const root_module = b.addModule("bee_kit", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .name = "bee_set",
        .root_module = root_module,
        .linkage = .static,
    });

    const zio = b.dependency("zio",.{
        .target = target,
        .optimize = optimize,
    });
    lib.root_module.addImport("zio", zio.module("zio"));

    const sokol = b.dependency("sokol", .{
        .target = target,
        .optimize = optimize,
    });
    lib.root_module.addImport("sokol", sokol.module("sokol"));

    const zmath = b.dependency("zmath", .{
        .target = target,
        .optimize = optimize,
    });
    lib.root_module.addImport("zmath", zmath.module("root"));

    const zstbi = b.dependency("zstbi", .{
        .target = target,
        .optimize = optimize,
    });
    lib.root_module.addImport("zstbi", zstbi.module("root"));

    const tatfi = b.dependency("tatfi", .{});
    lib.root_module.addImport("tatfi", tatfi.module("tatfi"));

    b.installArtifact(lib);
}
