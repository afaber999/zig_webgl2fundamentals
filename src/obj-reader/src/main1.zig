const std = @import("std");
const lineIterator = @import("utils.zig").lineIterator;

fn parse_obj(allocator: std.mem.Allocator, reader: anytype) !void {
    _ = allocator;
    var buffer: [128]u8 = undefined;
    var lines = lineIterator(reader, &buffer);

    while (try lines.next()) |line| {
        std.debug.print("Line os: {s}\n", .{line});
    }

    // var buf_reader = std.io.bufferedReader(reader);
    // var in_stream = buf_reader.reader();

    // const buf = try allocator.alloc(u8, 1024);
    // defer allocator.free(buf);

    // while (try in_stream.readUntilDelimiterOrEof(buf, '\n')) |line| {
    //     std.debug.print("{s}", .{line});
    // }
}

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    // const file = try std.fs.cwd().openFile("cube.obj", .{});
    // defer file.close();
    // //const reader = buffered.reader();
    // try parse_obj(gpa.allocator(), file.reader());

    const obj_data: []const u8 = "# Blender v2.80 (sub 75) OBJ File";
    const obj_stream = std.io.fixedBufferStream(obj_data);
    try parse_obj(gpa.allocator(), obj_stream);
}

test "simple test" {
    const fh = try std.fs.cwd().openFile("cube.obj", .{});
    defer fh.close();
    const buffered = std.io.bufferedReader(fh);
    const reader = buffered.reader();
    try parse_obj(std.testing.allocator, reader);
}
