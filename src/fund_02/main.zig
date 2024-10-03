const std = @import("std");
const gl = @import("webgl");

const vertCode =
    \\#version 300 es
    \\// an attribute is an input (in) to a vertex shader.
    \\// It will receive data from a buffer
    \\in vec2 a_position;
    \\
    \\// Used to pass in the resolution of the canvas
    \\uniform vec2 u_resolution;
    \\
    \\// all shaders have a main function
    \\void main() {
    \\
    \\  // convert the position from pixels to 0.0 to 1.0
    \\  vec2 zeroToOne = a_position / u_resolution;
    \\
    \\  // convert from 0->1 to 0->2
    \\  vec2 zeroToTwo = zeroToOne * 2.0;
    \\
    \\  // convert from 0->2 to -1->+1 (clipspace)
    \\  vec2 clipSpace = zeroToTwo - 1.0;
    \\
    \\  gl_Position = vec4(clipSpace * vec2(1, -1), 0, 1);
    \\}
;

const fragCode =
    \\#version 300 es
    \\// fragment shaders don't have a default precision so we need
    \\// to pick one. highp is a good default. It means "high precision"
    \\precision highp float;
    \\
    \\uniform vec4 u_color;
    \\// we need to declare an output for the fragment shader
    \\out vec4 outColor;
    \\
    \\void main() {
    \\  // Just set the output to a constant redish-purple
    \\  outColor = u_color;
    \\}
;

pub export fn init(width: u32, height: u32) void {
    // Link the two shaders into a program
    const program = gl.createProgram(vertCode, vertCode.len, fragCode, fragCode.len);

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

    const positions = [_]f32{
        10, 20,
        80, 20,
        10, 30,
        10, 30,
        80, 20,
        80, 30,
    };

    gl.bufferData(gl.ARRAY_BUFFER, &positions, @sizeOf(@TypeOf(positions)), gl.STATIC_DRAW);

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
    const color = [_]f32{ 1.0, 0.8, 0.7, 1.0 };
    gl.uniform4fv(color_loc, &color);

    //gl.uniform2f(resolutionUniformLocation
    // draw
    const primitiveType = gl.TRIANGLES;
    const offset = 0;
    const count = 6;
    gl.drawArrays(primitiveType, offset, count);

    gl.bufferData(gl.ARRAY_BUFFER, &positions, @sizeOf(@TypeOf(positions)), gl.STATIC_DRAW);
}

pub export fn update(timestamp: i32) void {
    _ = timestamp;
}
