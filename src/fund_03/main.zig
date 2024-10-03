const std = @import("std");
const gl = @import("webgl");

const RndGen = std.rand.DefaultPrng;
var rnd: std.rand.DefaultPrng = RndGen.init(0);

// include embedded shader files, easier to edit and have sytax highlighting
const vert_src = @embedFile("vert.glsl");
const frag_src = @embedFile("frag.glsl");

fn draw_rect() void {}

pub export fn init(width: u32, height: u32) void {
    // Link the two shaders into a program
    const program = gl.createProgram(vert_src, vert_src.len, frag_src, frag_src.len);

    // look up where the vertex data needs to go.
    const attrib_name = "a_position";
    const position_attribute = gl.getAttribLocation(program, attrib_name.ptr, attrib_name.len);

    // look up uniform locations
    const resolution_name = "u_resolution";
    const resolution_loc = gl.getUniformLocation(program, resolution_name.ptr, resolution_name.len);

    const color_name = "u_color";
    const color_loc = gl.getUniformLocation(program, color_name.ptr, color_name.len);

    // Create a buffer and put three 2d clip space points in it
    const position_buf = gl.createBuffer();

    // Bind it to ARRAY_BUFFER (think of it as ARRAY_BUFFER = positionBuffer)
    gl.bindBuffer(gl.ARRAY_BUFFER, position_buf);

    // Create a vertex array object (attribute state)
    const vao = gl.createVertexArray();

    // and make it the one we're currently working with
    gl.bindVertexArray(vao);

    // Turn on the attribute
    gl.enableVertexAttribArray(position_attribute);

    // Tell the attribute how to get data out of positionBuffer (ARRAY_BUFFER)
    gl.vertexAttribPointer(position_attribute, 2, gl.FLOAT, false, 0, 0);

    // Clear the canvas
    gl.clearColor(0.1, 0.1, 0.1, 1.0);
    gl.clear(gl.COLOR_BUFFER_BIT);

    // Tell it to use our program (pair of shaders)
    gl.useProgram(program);

    // Bind the attribute/buffer set we want.
    gl.bindVertexArray(vao);

    // pixels to clipspace in the shader
    gl.uniform2f(resolution_loc, @floatFromInt(width), @floatFromInt(height));

    for (0..50) |_| {
        const color = [_]f32{ rnd.random().float(f32), rnd.random().float(f32), rnd.random().float(f32), 1.0 };
        gl.uniform4fv(color_loc, &color);

        const xs = rnd.random().float(f32) * 300;
        const ys = rnd.random().float(f32) * 300;
        const xe = xs + rnd.random().float(f32) * 300;
        const ye = ys + rnd.random().float(f32) * 300;

        const positions = [_]f32{
            xs, ys,
            xe, ys,
            xs, ye,
            xs, ye,
            xe, ys,
            xe, ye,
        };

        gl.bufferData(gl.ARRAY_BUFFER, &positions, @sizeOf(@TypeOf(positions)), gl.STATIC_DRAW);

        const primitiveType = gl.TRIANGLES;
        const offset = 0;
        const count = 6;
        gl.drawArrays(primitiveType, offset, count);
    }
}

pub export fn update(timestamp: i32) void {
    _ = timestamp;
}
