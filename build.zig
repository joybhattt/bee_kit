const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const root_module = b.addModule("bee_engine",.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    root_module.addImport("bee_engine", root_module);

    const lib = b.addLibrary(.{
        .name = "bee_engine",
        .root_module = root_module,
        .linkage = .static,
    });
    b.installArtifact(lib);
}
