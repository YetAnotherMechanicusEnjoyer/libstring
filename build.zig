const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.option(std.builtin.OptimizeMode, "mode", "") orelse .Debug;

    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/lib/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    if (optimize != .Debug) {
        lib_mod.stack_protector = true;
    }

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "string",
        .root_module = lib_mod,
    });

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe_mod.addImport("string", lib_mod);

    if (optimize != .Debug) {
        exe_mod.stack_protector = true;
    }

    const exe = b.addExecutable(.{
        .name = "string_test",
        .root_module = exe_mod,
    });

    b.installArtifact(lib);
    b.installArtifact(exe);
}
