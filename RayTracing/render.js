var gl;
var program;
var image;
function render() {
  var canvas = document.getElementById("canvas");
  gl = canvas.getContext("webgl");
  if (!gl) {
    alert("你的浏览器, 操作系统或硬件等可能不支持WebGL. ");
    return;
  }
  program = webglUtils.createProgramFromScripts(gl, ["vertexShader", "fragmentShader"]);
  gl.useProgram(program);

  var anchorPoint = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, anchorPoint);
  var positions = [
    0, 0,
    0, canvas.height,
    canvas.width, 0,
    canvas.width, canvas.height,
  ];
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW);
  console.log(new Float32Array(positions));

  /* 以下是渲染部分 */

  gl.viewport(0, 0, canvas.width, canvas.height);
  gl.clearColor(0, 0, 0, 1);
  gl.clear(gl.COLOR_BUFFER_BIT);

  // 设置顶点着色器全局变量
  var uRes = gl.getUniformLocation(program, "uResolution");
  gl.uniform2f(uRes, gl.canvas.width, gl.canvas.height);

  // 设置顶点着色器属性读取方式
  var aPos = gl.getAttribLocation(program, "aPosition");
  gl.enableVertexAttribArray(aPos);
  var size = 2; // 每次迭代运行提取两个单位数据
  var type = gl.FLOAT; // 每个单位的数据类型是32位浮点型
  var normalize = false; // 不需要归一化数据
  var stride = 0; // 0 = 移动单位数量 * 每个单位占用内存（sizeof(type)）
  var offset = 0; // 从缓冲起始位置开始读取
  gl.vertexAttribPointer(aPos, size, type, normalize, stride, offset);

  // 读取图片
  image = new Image();
  image.src = "image.png";

  // 绘制
  requestAnimationFrame(draw);
}

function draw() {
  gl.uniform1f(
    gl.getUniformLocation(program, 'x1'),
    parseFloat(document.getElementById('x1').value),
  );
  gl.uniform1f(
    gl.getUniformLocation(program, 'y1'),
    parseFloat(document.getElementById('y1').value),
  );
  gl.uniform1f(
    gl.getUniformLocation(program, 'z1'),
    parseFloat(document.getElementById('z1').value),
  );
  gl.uniform1f(
    gl.getUniformLocation(program, 's1'),
    parseFloat(document.getElementById('s1').value),
  );
  gl.uniform1f(
    gl.getUniformLocation(program, 'x2'),
    parseFloat(document.getElementById('x2').value),
  );
  gl.uniform1f(
    gl.getUniformLocation(program, 'y2'),
    parseFloat(document.getElementById('y2').value),
  );
  gl.uniform1f(
    gl.getUniformLocation(program, 'z2'),
    parseFloat(document.getElementById('z2').value),
  );
  gl.uniform1f(
    gl.getUniformLocation(program, 's2'),
    parseFloat(document.getElementById('s2').value),
  );
  gl.uniform1f(
    gl.getUniformLocation(program, 'x3'),
    parseFloat(document.getElementById('x3').value),
  );
  gl.uniform1f(
    gl.getUniformLocation(program, 'y3'),
    parseFloat(document.getElementById('y3').value),
  );
  gl.uniform1f(
    gl.getUniformLocation(program, 'z3'),
    parseFloat(document.getElementById('z3').value),
  );
  gl.uniform1f(
    gl.getUniformLocation(program, 's3'),
    parseFloat(document.getElementById('s3').value),
  );
  gl.uniform1f(
    gl.getUniformLocation(program, 'x4'),
    parseFloat(document.getElementById('x4').value),
  );
  gl.uniform1f(
    gl.getUniformLocation(program, 'y4'),
    parseFloat(document.getElementById('y4').value),
  );
  gl.uniform1f(
    gl.getUniformLocation(program, 'z4'),
    parseFloat(document.getElementById('z4').value),
  );
  gl.uniform1f(
    gl.getUniformLocation(program, 's4'),
    parseFloat(document.getElementById('s4').value),
  );
  gl.uniform1f(
    gl.getUniformLocation(program, 'c1'),
    parseFloat(document.getElementById('c1').value),
  );
  gl.uniform1f(
    gl.getUniformLocation(program, 'c2'),
    parseFloat(document.getElementById('c2').value),
  );
  gl.uniform1f(
    gl.getUniformLocation(program, 'c3'),
    parseFloat(document.getElementById('c3').value),
  );
  gl.uniform1f(
    gl.getUniformLocation(program, 'c4'),
    parseFloat(document.getElementById('c4').value),
  );


  // 创建纹理
  var texture = gl.createTexture();
  gl.bindTexture(gl.TEXTURE_2D, texture);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
  // 上传图片
  gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image);
  
  gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
  requestAnimationFrame(draw);
}

