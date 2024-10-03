pub const std = @import("std");
pub const glm = @import("ziglm/ziglm.zig");

pub const Vec2f = glm.Vec2(f32);
pub const Vec3f = glm.Vec3(f32);
pub const Vec4f = glm.Vec4(f32);

pub const ARRAY_BUFFER = 0x8892;
pub const COLOR_BUFFER_BIT = 0x00004000;
pub const FLOAT = 0x1406;
pub const STATIC_DRAW = 0x88E4;
pub const TRIANGLES = 0x0004;

pub extern fn bindBuffer(target: u32, vbo: u32) void;
pub extern fn bindVertexArray(vao: u32) void;
pub extern fn bufferData(target: u32, data: *const anyopaque, length: usize, usage: u32) void;
pub extern fn clear(mask: u32) void;
pub extern fn clearColor(r: f32, g: f32, b: f32, a: f32) void;
pub extern fn createBuffer() u32;
pub extern fn createProgram(vertCode: [*]const u8, vertCodeLength: usize, fragCode: [*]const u8, fragCodeLength: usize) u32;
pub extern fn createVertexArray() u32;
pub extern fn drawArrays(mode: u32, first: i32, count: i32) void;
pub extern fn enableVertexAttribArray(index: u32) void;
pub extern fn getAttribLocation(program: u32, name: [*]const u8, nameLength: usize) u32;
pub extern fn getUniformLocation(program: u32, name: [*]const u8, nameLength: usize) u32;
pub extern fn useProgram(program: u32) void;
pub extern fn vertexAttribPointer(index: u32, size: i32, @"type": u32, normalized: bool, stride: i32, offset: i32) void;

pub extern fn uniform1f(location: u32, u1: f32) void;
pub extern fn uniform2f(location: u32, u1: f32, u2: f32) void;
pub extern fn uniform3f(location: u32, u1: f32, u2: f32, u3: f32) void;
pub extern fn uniform4f(location: u32, u1: f32, u2: f32, u3: f32, u4: f32) void;

pub extern fn uniform1fv(location: u32, value: *const [1]f32) void;
pub extern fn uniform2fv(location: u32, value: *const [2]f32) void;
pub extern fn uniform3fv(location: u32, value: *const [3]f32) void;
pub extern fn uniform4fv(location: u32, value: *const [4]f32) void;

pub extern fn logWasm(s: [*]const u8, len: usize) void;

pub fn print(comptime fmt: []const u8, args: anytype) void {
    var buf: [4096]u8 = undefined;
    const slice = std.fmt.bufPrint(&buf, fmt, args) catch unreachable;
    logWasm(slice.ptr, slice.len);
}

pub fn print_vec(comptime fmt: []const u8, args: anytype) void {
    var buf: [4096]u8 = undefined;
    const slice = std.fmt.bufPrint(&buf, fmt, args) catch unreachable;
    logWasm(slice.ptr, slice.len);
}

pub fn setUniformByLoc(location: u32, item: anytype) void {
    //print("Setting uniformG {s}\n", .{@typeName(@TypeOf(item))});

    switch (@TypeOf(item)) {
        Vec2f => uniform2f(location, item.x, item.y),
        Vec3f => uniform3f(location, item.x, item.y, item.z),
        Vec4f => uniform4f(location, item.x, item.y, item.z, item.w),

        [1]f32 => uniform1f(location, item[0]),
        [2]f32 => uniform2f(location, item[0], item[1]),
        [3]f32 => uniform3f(location, item[0], item[1], item[2]),
        [4]f32 => uniform4f(location, item[0], item[1], item[2], item[3]),
        else => {
            @compileError("Type no supported\n");
        },
    }
    // const fields = @typeInfo(@TypeOf(item)).Struct.fields;
    // inline for (fields) |field| {
    //     if (field.type != void) {
    //         print(" {s} -> {s}\n", .{ field.name, @typeName(field.type) });
    //     }
    // }
}

pub fn setUniformByName(program: u32, name: []const u8, item: anytype) void {
    const location = getUniformLocation(program, name.ptr, name.len);
    setUniformByLoc(location, item);
}

pub fn setStructUniforms(program: u32, items: anytype) void {
    inline for (std.meta.fields(@TypeOf(items))) |item| {
        //print("Item: {s}", item.name);
        //@compileLog(item.name);
        //@compileLog(@typeInfo(@TypeOf(item)));
        const v = @field(items, item.name);
        //@compileLog(v);

        //@compileLog(item.name);
        //@compileLog(item.type);
        //@compileLog(std.meta.fields(@TypeOf(item)));
        setUniformByName(program, item.name, v);
    }
}

// for (@typeInfo(cam_pos).Struct.fields) |field| {
//     gl.print("Name is : {any}", field.name);
//     // if (@typeInfo(field.type) == .Fn) {
//     //     count += 1;
//     // }
// }

// inline for (std.meta.fields(@TypeOf(cam_pos))) |f| {
//     gl.print("Name is : {any}", f.name);
// }
// //     std.log.debug(f.name ++ " {any}", .{@as(f.type, @field(x, f.name))});
