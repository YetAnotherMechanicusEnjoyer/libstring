const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.option(std.builtin.OptimizeMode, "mode", "") orelse .Debug;

    const libstring_mod = b.createModule(.{
        .root_source_file = b.path("src/lib/string.zig"),
        .target = target,
        .optimize = optimize,
    });

    if (optimize != .Debug) {
        libstring_mod.stack_protector = true;
    }

    const libstring = b.addLibrary(.{
        .linkage = .static,
        .name = "string",
        .root_module = libstring_mod,
    });

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe_mod.addImport("string", libstring_mod);

    if (optimize != .Debug) {
        exe_mod.stack_protector = true;
    }

    const exe = b.addExecutable(.{
        .name = "string_test",
        .root_module = exe_mod,
    });

    b.installArtifact(libstring);
    b.installArtifact(exe);
}
