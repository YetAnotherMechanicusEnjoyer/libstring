const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const test_step = b.step("test", "Run tests");
    const docs_step = b.step("docs", "Generate documentation");

    const libstring_mod = b.addModule("string", .{
        .root_source_file = b.path("src/lib/string.zig"),
        .target = target,
        .optimize = optimize,
    });

    if (optimize != .Debug) {
        libstring_mod.strip = true;
        libstring_mod.error_tracing = false;
        libstring_mod.omit_frame_pointer = true;
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
    test_step.dependOn(&run_tests.step);

    const install_docs = b.addInstallDirectory(.{
        .source_dir = libstring.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "docs",
    });
    docs_step.dependOn(&install_docs.step);

    b.installArtifact(libstring);
}
