const std = @import("std");

const slice_data =
    \\#comment line1
    \\#
    \\v 4 6 3 
    \\v 1.034 2.033e1 3.8e-1 
    \\line2 onespce   twospaces tabe
;

const ObjKind = enum {
    position,
    normal,
    index,
};
const ObjType = union(ObjKind) {
    position: [3]f32,
    normal: [3]f32,
    index: [9]u32,
};

fn parse_line(line: []const u8) !void {
    var iter = std.mem.tokenizeAny(u8, line, " \t");

    const kind = iter.next() orelse return;

    var tp: ObjType = undefined;

    if (std.mem.eql(u8, kind, "#")) {
        std.debug.print("Comment:{s}:", .{line});
    } else if (std.mem.eql(u8, kind, "v")) {
        const v1 = try std.fmt.parseFloat(f32, iter.next().?);
        const v2 = try std.fmt.parseFloat(f32, iter.next().?);
        const v3 = try std.fmt.parseFloat(f32, iter.next().?);
        tp = ObjType{ .position = .{ v1, v2, v3 } };
    } else if (std.mem.eql(u8, kind, "vn")) {
        const v1 = try std.fmt.parseFloat(f32, iter.next().?);
        const v2 = try std.fmt.parseFloat(f32, iter.next().?);
        const v3 = try std.fmt.parseFloat(f32, iter.next().?);
        tp = ObjType{ .normal = .{ v1, v2, v3 } };
    } else if (std.mem.eql(u8, kind, "vt11")) {
        const v1 = try std.fmt.parseFloat(f32, iter.next().?);
        const v2 = try std.fmt.parseFloat(f32, iter.next().?);
        const v3 = try std.fmt.parseFloat(f32, iter.next().?);
        tp = ObjType{ .position = .{ v1, v2, v3 } };
    } else {
        std.debug.print("UNKOWN:{s}:", .{line});
    }
    // while (iter.next()) |tok| {
    //     std.debug.print(":{s}: ", .{tok});
    // }
    std.debug.print("{any}\n", .{tp});
}

fn parse(reader: anytype) !void {
    var buf: [1024]u8 = undefined;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const tline = std.mem.trimRight(u8, line, "\r");
        try parse_line(tline);
    }
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("cube.obj", .{});
    defer file.close();
    try parse(file.reader());

    // const fb = try std.fs.cwd().openFile("cube.obj", .{});
    // defer fb.close();
    // var buffered = std.io.bufferedReader(fb.reader());
    // try parse(buffered.reader());

    // const buffered = std.io.bufferedReader(fh);
    // const reader = buffered.reader();

    var slice_stream = std.io.fixedBufferStream(slice_data);
    const slice_reader = slice_stream.reader();

    try parse(slice_reader);
    std.debug.print("done\n", .{});
}
