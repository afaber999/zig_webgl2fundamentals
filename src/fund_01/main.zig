// example from: https://webgl2fundamentals.org/webgl/lessons/webgl-fundamentals.html
// Copyright (c) 2024 Albert L Faber

const std = @import("std");

const ARRAY_BUFFER = 0x8892;
const COLOR_BUFFER_BIT = 0x00004000;
const FLOAT = 0x1406;
const STATIC_DRAW = 0x88E4;
const TRIANGLES = 0x0004;

extern fn bindBuffer(target: u32, vbo: u32) void;
extern fn bindVertexArray(vao: u32) void;
extern fn bufferData(target: u32, data: *const anyopaque, length: usize, usage: u32) void;
extern fn clear(mask: u32) void;
extern fn clearColor(r: f32, g: f32, b: f32, a: f32) void;
extern fn createBuffer() u32;
extern fn createProgram(vertCode: [*]const u8, vertCodeLength: usize, fragCode: [*]const u8, fragCodeLength: usize) u32;
extern fn createVertexArray() u32;
extern fn drawArrays(mode: u32, first: i32, count: i32) void;
extern fn enableVertexAttribArray(index: u32) void;
extern fn getAttribLocation(program: u32, name: [*]const u8, nameLength: usize) u32;
extern fn useProgram(program: u32) void;
extern fn vertexAttribPointer(index: u32, size: i32, @"type": u32, normalized: bool, stride: i32, offset: i32) void;

const vertCode =
    \\#version 300 es
    \\//an attribute is an input (in) to a vertex shader.
    \\// It will receive data from a buffer
    \\in vec4 a_position;
    \\
    \\// all shaders have a main function
    \\void main() {
    \\
    \\// gl_Position is a special variable a vertex shader
    \\// is responsible for setting
    \\gl_Position = a_position;
    \\}
;

const fragCode =
    \\#version 300 es
    \\// fragment shaders don't have a default precision so we need
    \\// to pick one. highp is a good default. It means "high precision"
    \\precision highp float;
    \\
    \\// we need to declare an output for the fragment shader
    \\out vec4 outColor;
    \\
    \\void main() {
    \\// Just set the output to a constant redish-purple
    \\outColor = vec4(1, 0, 0.5, 1);
    \\}
;

pub export fn init() void {
    // Link the two shaders into a program
    const program = createProgram(vertCode, vertCode.len, fragCode, fragCode.len);

    // look up where the vertex data needs to go.
    const attrib_name = "a_position";
    const positionAttributeLocation = getAttribLocation(program, attrib_name.ptr, attrib_name.len);

    // Create a buffer and put three 2d clip space points in it
    const positionBuffer = createBuffer();

    // Bind it to ARRAY_BUFFER (think of it as ARRAY_BUFFER = positionBuffer)
    bindBuffer(ARRAY_BUFFER, positionBuffer);

    const positions = [_]f32{
        0.0, 0.0,
        0.0, 0.5,
        0.7, 0.0,
    };

    bufferData(ARRAY_BUFFER, &positions, @sizeOf(@TypeOf(positions)), STATIC_DRAW);

    // Create a vertex array object (attribute state)
    const vao = createVertexArray();

    // and make it the one we're currently working with
    bindVertexArray(vao);

    // Turn on the attribute
    enableVertexAttribArray(positionAttributeLocation);

    // Tell the attribute how to get data out of positionBuffer (ARRAY_BUFFER)
    vertexAttribPointer(positionAttributeLocation, 2, FLOAT, false, 0, 0);

    // Clear the canvas
    clearColor(0.1, 0.1, 0.1, 1.0);
    clear(COLOR_BUFFER_BIT);

    // Tell it to use our program (pair of shaders)
    useProgram(program);

    // Bind the attribute/buffer set we want.
    bindVertexArray(vao);

    // draw
    const primitiveType = TRIANGLES;
    const offset = 0;
    const count = 3;
    drawArrays(primitiveType, offset, count);

    bufferData(ARRAY_BUFFER, &positions, @sizeOf(@TypeOf(positions)), STATIC_DRAW);
}

pub export fn update(timestamp: i32) void {
    _ = timestamp;
}
