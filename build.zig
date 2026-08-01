const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const test_option = b.step("test", "Run tests");

    const libstring_mod = b.addModule("string", .{
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

    const tests_mod = b.createModule(.{
        .root_source_file = b.path("tests/string.zig"),
        .target = target,
        .optimize = optimize,
    });

    tests_mod.addImport("string", libstring_mod);

    const tests = b.addTest(.{
        .name = "string_test",
        .root_module = tests_mod,
    });

    const run_tests = b.addRunArtifact(tests);
    test_option.dependOn(&run_tests.step);

    b.installArtifact(libstring);
}
