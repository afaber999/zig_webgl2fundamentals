const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const EXAMPLES = [_][]const u8{ "fund_01", "fund_02", "fund_03", "less_01" };

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{ .cpu_arch = .wasm32, .os_tag = .freestanding });
    const optimize = b.standardOptimizeOption(.{});

    for (EXAMPLES) |example| {
        const fname = std.fmt.allocPrint(allocator, "src/{s}/main.zig", .{example}) catch unreachable;
        defer allocator.free(fname);

        const webgl_module = b.createModule(.{ .root_source_file = b.path("src/lib/webgl.zig") });
        //const ziglm_module = b.createModule(.{ .root_source_file = b.path("src/lib/ziglm/ziglm.zig") });

        const wasm = b.addExecutable(.{
            .name = "main",
            .root_source_file = b.path(fname),
            .target = target,
            .optimize = optimize,
        });
        //wasm.root_module.addImport("ziglm", ziglm_module);
        wasm.root_module.addImport("webgl", webgl_module);
        wasm.rdynamic = true;
        wasm.entry = .disabled;

        const install_html = b.addInstallDirectory(.{
            .source_dir = b.path("html"),
            .install_dir = .{ .custom = example },
            .install_subdir = "",
        });

        // copy web assets to output (wasm)directory
        const target_output = b.addInstallArtifact(wasm, .{
            .dest_dir = .{
                .override = .{
                    .custom = example,
                },
            },
        });

        b.getInstallStep().dependOn(&install_html.step);
        b.getInstallStep().dependOn(&target_output.step);
    }
}
