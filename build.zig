const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const root_module = b.addModule("bee_kit",.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const lib = b.addLibrary(.{
        .name = "bee_kit",
        .root_module = root_module,
        .linkage = .static,
    });

    @import("zgpu").addLibraryPathsTo(lib);
    const zgpu = b.dependency("zgpu", .{
        .target = target,
        .optimize = optimize,
    });
    lib.root_module.addImport("zgpu", zgpu.module("root"));
    lib.root_module.linkLibrary(zgpu.artifact("zdawn"));


    const zglfw = b.dependency("zglfw", .{
        .target = target,
        .optimize = optimize,
    });
    lib.root_module.addImport("zglfw", zglfw.module("root"));
    lib.root_module.linkLibrary(zglfw.artifact("glfw"));

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

    const tatfi = b.dependency("tatfi", .{
        .optimize = optimize,
        .target = target,
    });
    lib.root_module.addImport("tatfi", tatfi.module("tatfi"));

    b.installArtifact(lib);
}
