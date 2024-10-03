let memory;

function readCharStr(ptr, len) {
    const bytes = new Uint8Array(memory.buffer, ptr, len);
    return new TextDecoder('utf-8').decode(bytes);
}

/** @type{HTMLCanvasElement} */
const canvas = document.getElementById('canvas');
/** @type{WebGL2RenderingContext} */
const gl = canvas.getContext('webgl2');
gl.viewport(0, 0, canvas.width, canvas.height);


async function fetchAndInstantiate(url, importObject) {
    const response = await fetch(url);
    const bytes = await response.arrayBuffer();
    const results = await WebAssembly.instantiate(bytes, importObject); // TODO consider instantiateStreaming
    const instance =  results.instance;

    memory = instance.exports.memory;
    instance.exports.init(canvas.width, canvas.height);
    
    const updateFn = instance.exports.update;
    // TODO callbacks:
    // document.addEventListener('keydown'/'keyup'/'mousedown'/'mouseup'/'mousemove'/'resize', e => instance.exports.onX(...));

    function step(timestamp) {
        updateFn(timestamp);
        window.requestAnimationFrame(step);
    }
    window.requestAnimationFrame(step);
}

const VAOs = [];
const VBOs = [];
const programs = [];
const locations = [];

const env = {
    enable: (cap) => gl.enable(cap),
    disable: (cap) => gl.disable(cap),

    clearColor: (r, g, b, a) => gl.clearColor(r, g, b, a),
    clear: (mask) => gl.clear(mask),

    createVertexArray: function () {
        const vao = gl.createVertexArray();
        VAOs.push(vao);
        return VAOs.length - 1;
    },
    bindVertexArray: (vao) => gl.bindVertexArray(VAOs[vao]),
    enableVertexAttribArray: (index) => gl.enableVertexAttribArray(index),
    vertexAttribPointer: (index, size, type, normalized, stride, offset) => gl.vertexAttribPointer(index, size, type, normalized, stride, offset),

    createBuffer: function() {
        const vbo = gl.createBuffer();
        VBOs.push(vbo);
        return VBOs.length - 1;
    },
    bindBuffer: (target, vbo) => gl.bindBuffer(target, VBOs[vbo]),
    bufferData: function(target, dataPtr, dataLen, usage) {
        const buf = new DataView(memory.buffer, dataPtr, dataLen);
        gl.bufferData(target, buf, usage);
    },

    createProgram: function(vertCodePtr, vertCodeLen, fragCodePtr, fragCodeLen) {
        const vertCode = readCharStr(vertCodePtr, vertCodeLen);
        const fragCode = readCharStr(fragCodePtr, fragCodeLen);

        const vertShader = gl.createShader(gl.VERTEX_SHADER);
        gl.shaderSource(vertShader, vertCode);
        gl.compileShader(vertShader);

        if (!gl.getShaderParameter(vertShader, gl.COMPILE_STATUS)) {
            throw 'Error compiling vertex shader: ' + gl.getShaderInfoLog(vertShader);
        }

        const fragShader = gl.createShader(gl.FRAGMENT_SHADER);
        gl.shaderSource(fragShader, fragCode);
        gl.compileShader(fragShader);

        if (!gl.getShaderParameter(fragShader, gl.COMPILE_STATUS)) {
            throw 'Error compiling fragment shader: ' + gl.getShaderInfoLog(fragShader);
        }

        const program = gl.createProgram();
        gl.attachShader(program, vertShader);
        gl.attachShader(program, fragShader);
        gl.linkProgram(program);

        if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
            throw 'Error linking program: ' + gl.getProgramInfoLog(program);
        }

        programs.push(program);
        return program.length - 1;
    },
    getUniformLocation: function(program, namePtr, nameLen) {
        const name = readCharStr(namePtr, nameLen);
        const location = gl.getUniformLocation(programs[program], name);

        if (location === null) {
            throw 'ERROR: uniform ' + name + ' not found'
        }
        locations.push(location);
        return locations.length - 1;
    },
    getAttribLocation: function(program, namePtr, nameLen) {
        const name = readCharStr(namePtr, nameLen);
        return gl.getAttribLocation(programs[program], name);
    },

    useProgram: (program) => gl.useProgram(programs[program]),
    drawArrays: (mode, first, count) => gl.drawArrays(mode, first, count),
    drawElements: (mode, count, type, indices) => gl.drawElements(mode, count, type, indices),

    uniformMatrix2fv: (location, transpose, valuePtr) => gl.uniformMatrix2fv(locations[location], transpose, new Float32Array(memory.buffer, valuePtr, 2*2)),
    uniformMatrix3fv: (location, transpose, valuePtr) => gl.uniformMatrix3fv(locations[location], transpose, new Float32Array(memory.buffer, valuePtr, 3*3)),
    uniformMatrix4fv: (location, transpose, valuePtr) => gl.uniformMatrix4fv(locations[location], transpose, new Float32Array(memory.buffer, valuePtr, 4*4)),

    uniform2f: (location, u1, u2) => gl.uniform2f(locations[location],u1, u2),
    uniform3f: (location, u1, u2, u3) => gl.uniform3f(locations[location],u1, u2, u3),
    uniform4f: (location, u1, u2, u3, u4) => gl.uniform4f(locations[location],u1, u2, u3, u4),

    uniform2fv: (location,  valuePtr) => gl.uniform2fv(locations[location],new Float32Array(memory.buffer, valuePtr, 2)),
    uniform3fv: (location,  valuePtr) => gl.uniform3fv(locations[location],new Float32Array(memory.buffer, valuePtr, 3)),
    uniform4fv: (location,  valuePtr) => gl.uniform4fv(locations[location],new Float32Array(memory.buffer, valuePtr, 4)),

    logWasm:(s, len ) => {  
        const buf = new Uint8Array(memory.buffer, s, len);
        console.log(new TextDecoder("utf8").decode(buf));
    }
};

fetchAndInstantiate('main.wasm', {env});
