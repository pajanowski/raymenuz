const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{.preferred_optimize_mode = .Debug});
    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
    });
    const raylib = raylib_dep.module("raylib"); // main raylib module
    const raygui = raylib_dep.module("raygui"); // raygui module
    const raylib_artifact = raylib_dep.artifact("raylib"); // raylib C library

    const mod = b.addModule("raymenuz", .{
        .root_source_file = b.path("src/raymenu.zig"),
        .target = target,
        .optimize = optimize,  // Add this line
    });

    mod.addImport("raylib", raylib);
    mod.addImport("raygui", raygui);

    const raymenu_example_exe = b.addExecutable(.{
        .name = "raymenu example",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/examples/raymenu_example.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "raymenuz", .module = mod },
            },
        })
    });

    raymenu_example_exe.linkLibrary(raylib_artifact);
    raymenu_example_exe.root_module.addImport("raylib", raylib);
    raymenu_example_exe.root_module.addImport("raygui", raygui);

    b.installArtifact(raymenu_example_exe);

    const run_example_step = b.step("run_example", "Run the Raymenu example");
    const run_example_cmd = b.addRunArtifact(raymenu_example_exe);

    run_example_step.dependOn(&run_example_cmd.step);

    run_example_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_example_cmd.addArgs(args);
    }

    const mod_tests = b.addTest(.{
        .root_module = mod,
    });

    const run_mod_tests = b.addRunArtifact(mod_tests);

    const exe_tests = b.addTest(.{
        .root_module = raymenu_example_exe.root_module
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_exe_tests.step);
}
