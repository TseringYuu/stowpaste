(function () {
  "use strict";

  var PAPER_TYPES = [
    { kind: "TEXT", source: "Notes", title: "Meet at 10:30", body: "Bring the revised outline and the new screenshots.", accent: "#655DFF" },
    { kind: "PASSWORD", source: "Login", title: "••••••••••••", body: "account.example.com", accent: "#FF6846" },
    { kind: "IMAGE", source: "Preview", title: "Screenshot 12.42.18", body: "1440 × 900 PNG", accent: "#08B8C5", image: true },
    { kind: "FILE", source: "Finder", title: "Launch-notes.pdf", body: "2.8 MB · Documents", accent: "#EAAF19" },
    { kind: "LINK", source: "Safari", title: "stowpaste.aiware.store", body: "Clipboard history for macOS", accent: "#655DFF" },
    { kind: "CODE", source: "Terminal", title: "npm run build", body: "✓ compiled successfully", accent: "#08B8C5" },
    { kind: "COLOR", source: "Figma", title: "#655DFF", body: "Product violet", accent: "#655DFF", swatches: true },
    { kind: "TEXT", source: "Messages", title: "On my way", body: "See you in about fifteen minutes.", accent: "#FF6846" }
  ];

  function createShader(gl, type, source) {
    var shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
      console.error(gl.getShaderInfoLog(shader));
      gl.deleteShader(shader);
      return null;
    }
    return shader;
  }

  function createProgram(gl, vertexSource, fragmentSource) {
    var vertex = createShader(gl, gl.VERTEX_SHADER, vertexSource);
    var fragment = createShader(gl, gl.FRAGMENT_SHADER, fragmentSource);
    if (!vertex || !fragment) return null;
    var program = gl.createProgram();
    gl.attachShader(program, vertex);
    gl.attachShader(program, fragment);
    gl.linkProgram(program);
    gl.deleteShader(vertex);
    gl.deleteShader(fragment);
    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
      console.error(gl.getProgramInfoLog(program));
      gl.deleteProgram(program);
      return null;
    }
    return program;
  }

  function roundedRect(ctx, x, y, width, height, radius) {
    var r = Math.min(radius, width / 2, height / 2);
    ctx.beginPath();
    ctx.moveTo(x + r, y);
    ctx.arcTo(x + width, y, x + width, y + height, r);
    ctx.arcTo(x + width, y + height, x, y + height, r);
    ctx.arcTo(x, y + height, x, y, r);
    ctx.arcTo(x, y, x + width, y, r);
    ctx.closePath();
  }

  function fitText(ctx, text, maxWidth) {
    var value = text;
    while (value.length > 3 && ctx.measureText(value).width > maxWidth) value = value.slice(0, -1);
    return value === text ? value : value.slice(0, -1) + "…";
  }

  function drawImagePreview(ctx, x, y, width, height, accent) {
    ctx.fillStyle = "#DCE2E8";
    roundedRect(ctx, x, y, width, height, 12);
    ctx.fill();
    ctx.fillStyle = accent;
    ctx.beginPath();
    ctx.moveTo(x, y + height);
    ctx.lineTo(x + width * 0.38, y + height * 0.38);
    ctx.lineTo(x + width * 0.58, y + height * 0.7);
    ctx.lineTo(x + width * 0.77, y + height * 0.48);
    ctx.lineTo(x + width, y + height * 0.72);
    ctx.lineTo(x + width, y + height);
    ctx.closePath();
    ctx.fill();
    ctx.fillStyle = "#FFF7C9";
    ctx.beginPath();
    ctx.arc(x + width * 0.78, y + height * 0.25, height * 0.12, 0, Math.PI * 2);
    ctx.fill();
  }

  function createAtlas(gl) {
    var tileWidth = 512;
    var tileHeight = 312;
    var columns = 4;
    var rows = 2;
    var rowStride = 512;
    var canvas = document.createElement("canvas");
    canvas.width = tileWidth * columns;
    canvas.height = rowStride * rows;
    var ctx = canvas.getContext("2d");
    ctx.textBaseline = "top";

    PAPER_TYPES.forEach(function (item, index) {
      var column = index % columns;
      var row = Math.floor(index / columns);
      var x = column * tileWidth;
      var y = row * rowStride;
      var width = tileWidth;
      var height = tileHeight;

      var paperGradient = ctx.createLinearGradient(x, y, x + width, y + height);
      paperGradient.addColorStop(0, index % 3 === 0 ? "#F6F2E8" : "#FAF7EF");
      paperGradient.addColorStop(0.46, index % 3 === 2 ? "#EEECE4" : "#F4F1E9");
      paperGradient.addColorStop(1, index % 2 === 0 ? "#EAE7DE" : "#F2EFE6");
      ctx.fillStyle = paperGradient;
      ctx.fillRect(x, y, width, height);

      for (var fiber = 0; fiber < 118; fiber += 1) {
        var fiberSeed = Math.sin((index + 1) * 91.17 + fiber * 17.31) * 43758.5453;
        var fiberUnit = fiberSeed - Math.floor(fiberSeed);
        var fiberY = y + fiberUnit * height;
        var fiberLength = 28 + ((fiber * 47 + index * 13) % 248);
        var fiberX = x + ((fiber * 83 + index * 31) % Math.max(1, width - fiberLength));
        ctx.strokeStyle = fiber % 4 === 0 ? "rgba(88, 76, 54, 0.075)" : "rgba(255, 255, 255, 0.16)";
        ctx.lineWidth = fiber % 5 === 0 ? 1.25 : 0.55;
        ctx.beginPath();
        ctx.moveTo(fiberX, fiberY);
        ctx.bezierCurveTo(
          fiberX + fiberLength * 0.32,
          fiberY + Math.sin(fiber * 1.37) * 1.2,
          fiberX + fiberLength * 0.71,
          fiberY + Math.cos(fiber * 0.91) * 1.4,
          fiberX + fiberLength,
          fiberY + Math.sin(fiber * 1.9) * 1.8
        );
        ctx.stroke();
      }

      for (var fleck = 0; fleck < 360; fleck += 1) {
        var fleckSeedX = Math.sin((index + 5) * 37.11 + fleck * 12.77) * 24634.6345;
        var fleckSeedY = Math.sin((index + 9) * 73.91 + fleck * 7.13) * 56445.2341;
        var fleckX = x + (fleckSeedX - Math.floor(fleckSeedX)) * width;
        var fleckY = y + (fleckSeedY - Math.floor(fleckSeedY)) * height;
        ctx.fillStyle = fleck % 3 === 0 ? "rgba(83, 72, 53, 0.045)" : "rgba(255, 255, 255, 0.12)";
        ctx.fillRect(fleckX, fleckY, fleck % 7 === 0 ? 1.4 : 0.7, fleck % 11 === 0 ? 1.2 : 0.6);
      }

      ctx.strokeStyle = "#17181C";
      ctx.lineWidth = 4;
      ctx.strokeRect(x + 2, y + 2, width - 4, height - 4);

      ctx.fillStyle = item.accent;
      ctx.fillRect(x + 3, y + 3, 14, height - 6);

      ctx.fillStyle = "#17181C";
      ctx.font = "800 22px ui-monospace, SFMono-Regular, Menlo, monospace";
      ctx.fillText(item.kind, x + 36, y + 28);
      ctx.fillStyle = "#777C85";
      ctx.font = "600 19px ui-monospace, SFMono-Regular, Menlo, monospace";
      ctx.textAlign = "right";
      ctx.fillText(item.source.toUpperCase(), x + width - 26, y + 30);
      ctx.textAlign = "left";

      if (item.image) {
        drawImagePreview(ctx, x + 36, y + 78, 126, 112, item.accent);
        ctx.fillStyle = "#17181C";
        ctx.font = "800 30px -apple-system, BlinkMacSystemFont, Helvetica Neue, Arial, sans-serif";
        ctx.fillText(fitText(ctx, item.title, width - 214), x + 188, y + 94);
        ctx.fillStyle = "#6B7079";
        ctx.font = "500 22px -apple-system, BlinkMacSystemFont, Helvetica Neue, Arial, sans-serif";
        ctx.fillText(item.body, x + 188, y + 143);
      } else {
        ctx.fillStyle = "#17181C";
        ctx.font = item.kind === "PASSWORD"
          ? "800 38px ui-monospace, SFMono-Regular, Menlo, monospace"
          : "800 34px -apple-system, BlinkMacSystemFont, Helvetica Neue, Arial, sans-serif";
        ctx.fillText(fitText(ctx, item.title, width - 72), x + 36, y + 92);
        ctx.fillStyle = "#626771";
        ctx.font = "500 23px -apple-system, BlinkMacSystemFont, Helvetica Neue, Arial, sans-serif";
        ctx.fillText(fitText(ctx, item.body, width - 72), x + 36, y + 148);
      }

      if (item.swatches) {
        ["#655DFF", "#08B8C5", "#FF6846", "#EAAF19"].forEach(function (color, swatchIndex) {
          ctx.fillStyle = color;
          ctx.fillRect(x + 36 + swatchIndex * 54, y + 199, 42, 30);
        });
      }

      ctx.strokeStyle = "#C8CCD2";
      ctx.lineWidth = 2;
      ctx.setLineDash([7, 8]);
      ctx.beginPath();
      ctx.moveTo(x + 36, y + height - 40);
      ctx.lineTo(x + width - 26, y + height - 40);
      ctx.stroke();
      ctx.setLineDash([]);
      ctx.fillStyle = "#8C919A";
      ctx.font = "600 17px ui-monospace, SFMono-Regular, Menlo, monospace";
      ctx.fillText("STOWPASTE · LOCAL", x + 36, y + height - 28);
    });

    var texture = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, texture);
    gl.pixelStorei(gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, false);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, canvas);
    gl.generateMipmap(gl.TEXTURE_2D);

    var anisotropy = gl.getExtension("EXT_texture_filter_anisotropic")
      || gl.getExtension("WEBKIT_EXT_texture_filter_anisotropic")
      || gl.getExtension("MOZ_EXT_texture_filter_anisotropic");
    if (anisotropy) {
      var maximum = gl.getParameter(anisotropy.MAX_TEXTURE_MAX_ANISOTROPY_EXT);
      gl.texParameterf(gl.TEXTURE_2D, anisotropy.TEXTURE_MAX_ANISOTROPY_EXT, Math.min(8, maximum));
    }

    return {
      texture: texture,
      columns: columns,
      textureHeight: canvas.height,
      tileHeight: tileHeight,
      rowStride: rowStride
    };
  }

  function createPaperMesh(segmentsX, segmentsY) {
    var vertices = [];

    function pushVertex(u, v) {
      vertices.push(u - 0.5, v - 0.5, u, v);
    }

    for (var row = 0; row < segmentsY; row += 1) {
      var v0 = row / segmentsY;
      var v1 = (row + 1) / segmentsY;
      for (var column = 0; column < segmentsX; column += 1) {
        var u0 = column / segmentsX;
        var u1 = (column + 1) / segmentsX;
        pushVertex(u0, v0);
        pushVertex(u1, v0);
        pushVertex(u0, v1);
        pushVertex(u0, v1);
        pushVertex(u1, v0);
        pushVertex(u1, v1);
      }
    }

    return new Float32Array(vertices);
  }

  function initPaperField(canvas) {
    if (!canvas || canvas.dataset.paperFieldReady === "true") return;
    var gl = canvas.getContext("webgl", { alpha: true, antialias: true, premultipliedAlpha: true });
    var root = canvas.closest(".paper-site");
    if (!gl || !root) {
      if (root) root.classList.add("no-webgl");
      return;
    }
    canvas.dataset.paperFieldReady = "true";

    var vertexSource = [
      "attribute vec2 a_position;",
      "attribute vec2 a_uv;",
      "uniform vec2 u_resolution;",
      "uniform vec2 u_center;",
      "uniform vec2 u_size;",
      "uniform vec3 u_orientation;",
      "uniform float u_depth;",
      "uniform float u_time;",
      "uniform vec2 u_curl;",
      "uniform float u_flutter;",
      "uniform float u_seed;",
      "uniform vec4 u_uv_rect;",
      "varying vec2 v_uv;",
      "varying vec2 v_paper_uv;",
      "varying vec3 v_normal;",
      "varying float v_curve;",
      "varying float v_seed;",
      "vec3 rotateX(vec3 point, float angle) {",
      "  float c = cos(angle);",
      "  float s = sin(angle);",
      "  return vec3(point.x, point.y * c - point.z * s, point.y * s + point.z * c);",
      "}",
      "vec3 rotateY(vec3 point, float angle) {",
      "  float c = cos(angle);",
      "  float s = sin(angle);",
      "  return vec3(point.x * c + point.z * s, point.y, -point.x * s + point.z * c);",
      "}",
      "vec3 rotateZ(vec3 point, float angle) {",
      "  float c = cos(angle);",
      "  float s = sin(angle);",
      "  return vec3(point.x * c - point.y * s, point.x * s + point.y * c, point.z);",
      "}",
      "vec3 orient(vec3 point) {",
      "  return rotateZ(rotateY(rotateX(point, u_orientation.x), u_orientation.y), u_orientation.z);",
      "}",
      "void main() {",
      "  const float PI = 3.14159265359;",
      "  vec2 centered = a_position;",
      "  float envelopeX = sin(a_uv.x * PI);",
      "  float envelopeY = sin(a_uv.y * PI);",
      "  float wavePhase = a_uv.x * PI * 2.0 + u_time * 1.42 + u_seed;",
      "  float crossPhase = a_uv.y * PI * 2.0 - u_time * 0.83 + u_seed * 1.71;",
      "  float wave = sin(wavePhase) * envelopeX * envelopeY;",
      "  wave += cos(crossPhase) * envelopeX * envelopeY * 0.34;",
      "  float curveX = centered.x * centered.x * 4.0 - 1.0;",
      "  float curveY = centered.y * centered.y * 4.0 - 1.0;",
      "  float z = u_size.y * (u_curl.x * curveX + u_curl.y * curveY + u_flutter * wave);",
      "  float dzdu = u_size.y * (u_curl.x * centered.x * 8.0);",
      "  dzdu += u_size.y * u_flutter * envelopeY * (",
      "    PI * cos(a_uv.x * PI) * (sin(wavePhase) + cos(crossPhase) * 0.34)",
      "    + PI * 2.0 * cos(wavePhase) * envelopeX",
      "  );",
      "  float dzdv = u_size.y * (u_curl.y * centered.y * 8.0);",
      "  dzdv += u_size.y * u_flutter * envelopeX * (",
      "    PI * cos(a_uv.y * PI) * (sin(wavePhase) + cos(crossPhase) * 0.34)",
      "    + PI * 2.0 * -sin(crossPhase) * envelopeY * 0.34",
      "  );",
      "  vec3 tangentU = vec3(u_size.x, 0.0, dzdu);",
      "  vec3 tangentV = vec3(0.0, u_size.y, dzdv);",
      "  vec3 local = vec3(centered.x * u_size.x, centered.y * u_size.y, z);",
      "  vec3 transformed = orient(local);",
      "  vec3 normal = normalize(orient(normalize(cross(tangentU, tangentV))));",
      "  float cameraDistance = max(u_resolution.y * 1.32, 760.0);",
      "  float perspective = cameraDistance / max(280.0, cameraDistance + transformed.z);",
      "  vec2 pixel = u_center + transformed.xy * perspective;",
      "  vec2 clip = pixel / u_resolution * 2.0 - 1.0;",
      "  float layer = mix(0.72, -0.72, u_depth) - transformed.z / max(u_resolution.y, 1.0) * 0.04;",
      "  gl_Position = vec4(clip.x, -clip.y, layer, 1.0);",
      "  v_uv = mix(u_uv_rect.xy, u_uv_rect.zw, a_uv);",
      "  v_paper_uv = a_uv;",
      "  v_normal = normal;",
      "  v_curve = clamp(abs(z) / max(u_size.y, 1.0) * 18.0, 0.0, 1.0);",
      "  v_seed = u_seed;",
      "}"
    ].join("\n");

    var fragmentSource = [
      "precision mediump float;",
      "uniform sampler2D u_texture;",
      "uniform float u_shadow;",
      "uniform float u_shadow_strength;",
      "varying vec2 v_uv;",
      "varying vec2 v_paper_uv;",
      "varying vec3 v_normal;",
      "varying float v_curve;",
      "varying float v_seed;",
      "float hash21(vec2 point) {",
      "  point = fract(point * vec2(123.34, 456.21));",
      "  point += dot(point, point + 45.32);",
      "  return fract(point.x * point.y);",
      "}",
      "void main() {",
      "  float edgeDistance = min(min(v_paper_uv.x, 1.0 - v_paper_uv.x), min(v_paper_uv.y, 1.0 - v_paper_uv.y));",
      "  if (u_shadow > 0.5) {",
      "    float softness = smoothstep(0.0, 0.065, edgeDistance);",
      "    gl_FragColor = vec4(0.025, 0.024, 0.035, softness * u_shadow_strength);",
      "    return;",
      "  }",
      "  vec3 printed = texture2D(u_texture, v_uv).rgb;",
      "  float micro = hash21(floor(v_paper_uv * vec2(690.0, 420.0)) + v_seed * 19.0);",
      "  float grain = hash21(floor(v_paper_uv * vec2(238.0, 154.0)) + v_seed * 7.0);",
      "  float fiber = sin(v_paper_uv.x * 910.0 + hash21(vec2(floor(v_paper_uv.y * 83.0), v_seed)) * 6.28318);",
      "  float edgeShade = mix(0.76, 1.0, smoothstep(0.0, 0.036, edgeDistance));",
      "  float paperNoise = 0.965 + micro * 0.036 + grain * 0.018 + fiber * 0.006;",
      "  vec3 normal = normalize(v_normal);",
      "  vec3 lightDirection = normalize(vec3(-0.34, -0.42, 0.84));",
      "  float frontFacing = smoothstep(-0.08, 0.16, normal.z);",
      "  float diffuse = 0.69 + abs(dot(normal, lightDirection)) * 0.29;",
      "  float grazing = pow(1.0 - abs(normal.z), 2.0) * 0.11;",
      "  float ink = 1.0 - dot(printed, vec3(0.299, 0.587, 0.114));",
      "  vec3 reverseSide = vec3(0.89, 0.875, 0.825) - ink * 0.045;",
      "  vec3 surface = mix(reverseSide, printed, frontFacing);",
      "  float curvatureShade = 1.0 - v_curve * 0.055 + grazing;",
      "  vec3 color = surface * paperNoise * edgeShade * diffuse * curvatureShade;",
      "  gl_FragColor = vec4(color, 1.0);",
      "}"
    ].join("\n");

    var program = createProgram(gl, vertexSource, fragmentSource);
    if (!program) {
      root.classList.add("no-webgl");
      return;
    }

    var buffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
    var mesh = createPaperMesh(12, 8);
    var vertexCount = mesh.length / 4;
    gl.bufferData(gl.ARRAY_BUFFER, mesh, gl.STATIC_DRAW);

    gl.useProgram(program);
    var positionLocation = gl.getAttribLocation(program, "a_position");
    var uvLocation = gl.getAttribLocation(program, "a_uv");
    gl.enableVertexAttribArray(positionLocation);
    gl.enableVertexAttribArray(uvLocation);
    gl.vertexAttribPointer(positionLocation, 2, gl.FLOAT, false, 16, 0);
    gl.vertexAttribPointer(uvLocation, 2, gl.FLOAT, false, 16, 8);

    var uniforms = {
      resolution: gl.getUniformLocation(program, "u_resolution"),
      center: gl.getUniformLocation(program, "u_center"),
      size: gl.getUniformLocation(program, "u_size"),
      orientation: gl.getUniformLocation(program, "u_orientation"),
      depth: gl.getUniformLocation(program, "u_depth"),
      time: gl.getUniformLocation(program, "u_time"),
      curl: gl.getUniformLocation(program, "u_curl"),
      flutter: gl.getUniformLocation(program, "u_flutter"),
      seed: gl.getUniformLocation(program, "u_seed"),
      uvRect: gl.getUniformLocation(program, "u_uv_rect"),
      shadow: gl.getUniformLocation(program, "u_shadow"),
      shadowStrength: gl.getUniformLocation(program, "u_shadow_strength")
    };

    var atlas = createAtlas(gl);
    gl.activeTexture(gl.TEXTURE0);
    gl.bindTexture(gl.TEXTURE_2D, atlas.texture);
    gl.uniform1i(gl.getUniformLocation(program, "u_texture"), 0);
    gl.enable(gl.BLEND);
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
    gl.disable(gl.DEPTH_TEST);

    var width = 1;
    var height = 1;
    var dpr = 1;
    var particles = [];
    var ordered = false;
    var orderedSince = 0;
    var orderMix = 0;
    var reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    var lastTime = performance.now();
    var animationFrame = 0;

    function randomRange(min, max) { return min + Math.random() * (max - min); }
    function clamp(value, min, max) { return Math.max(min, Math.min(max, value)); }
    function wrapAngle(value) {
      while (value > Math.PI) value -= Math.PI * 2;
      while (value < -Math.PI) value += Math.PI * 2;
      return value;
    }

    function paperNormal(particle) {
      var sinPitch = Math.sin(particle.pitch);
      var cosPitch = Math.cos(particle.pitch);
      var sinYaw = Math.sin(particle.yaw);
      var cosYaw = Math.cos(particle.yaw);
      var sinRoll = Math.sin(particle.roll);
      var cosRoll = Math.cos(particle.roll);
      var yawedX = sinYaw * cosPitch;
      var yawedY = -sinPitch;
      return {
        x: cosRoll * yawedX - sinRoll * yawedY,
        y: sinRoll * yawedX + cosRoll * yawedY,
        z: cosYaw * cosPitch
      };
    }

    function makeParticle(index) {
      var depth = randomRange(0.08, 0.96);
      return {
        tile: index % PAPER_TYPES.length,
        x: randomRange(-100, width + 100),
        y: randomRange(-height * 0.4, height * 1.15),
        depth: depth,
        vx: randomRange(-24, 24),
        vy: randomRange(30, 72) + depth * 20,
        gravity: randomRange(66, 82) + depth * 14,
        mass: randomRange(0.82, 1.18),
        skinDrag: randomRange(0.00042, 0.00072),
        pressureDrag: randomRange(0.0062, 0.0094),
        liftCoefficient: randomRange(0.00028, 0.00068),
        phase: randomRange(0, Math.PI * 2),
        windPhase: randomRange(0, Math.PI * 2),
        vortexPhase: randomRange(0, Math.PI * 2),
        vortexRate: randomRange(0.82, 1.24),
        centerBias: randomRange(-0.12, 0.12),
        pitch: randomRange(-1.18, 1.18),
        yaw: randomRange(-1.05, 1.05),
        roll: randomRange(-Math.PI, Math.PI),
        pitchVelocity: randomRange(-0.8, 0.8),
        yawVelocity: randomRange(-0.58, 0.58),
        rollVelocity: randomRange(-0.72, 0.72),
        baseWidth: randomRange(178, 276),
        curlX: randomRange(-0.026, 0.026),
        curlY: randomRange(-0.019, 0.019),
        flexibility: randomRange(0.011, 0.024),
        airLoad: 0.5,
        seed: randomRange(1, 97)
      };
    }

    function recycleParticle(particle) {
      particle.x = randomRange(-120, width + 120);
      particle.y = -randomRange(180, 520);
      particle.vx = randomRange(-22, 22);
      particle.vy = randomRange(26, 64) + particle.depth * 18;
      particle.pitch = randomRange(-1.1, 1.1);
      particle.yaw = randomRange(-0.95, 0.95);
      particle.roll = randomRange(-Math.PI, Math.PI);
      particle.pitchVelocity = randomRange(-0.72, 0.72);
      particle.yawVelocity = randomRange(-0.52, 0.52);
      particle.rollVelocity = randomRange(-0.68, 0.68);
      particle.phase = randomRange(0, Math.PI * 2);
      particle.windPhase = randomRange(0, Math.PI * 2);
      particle.vortexPhase = randomRange(0, Math.PI * 2);
      particle.airLoad = 0.5;
    }

    function resetParticles() {
      var count = width < 560 ? 14 : width < 960 ? 19 : 26;
      particles = [];
      for (var i = 0; i < count; i += 1) particles.push(makeParticle(i));
    }

    function resize() {
      var rect = canvas.getBoundingClientRect();
      width = Math.max(1, rect.width);
      height = Math.max(1, rect.height);
      dpr = Math.min(window.devicePixelRatio || 1, 2);
      var pixelWidth = Math.round(width * dpr);
      var pixelHeight = Math.round(height * dpr);
      if (canvas.width !== pixelWidth || canvas.height !== pixelHeight) {
        canvas.width = pixelWidth;
        canvas.height = pixelHeight;
        gl.viewport(0, 0, pixelWidth, pixelHeight);
      }
      resetParticles();
    }

    function setOrdered(value) {
      if (reducedMotion) value = true;
      if (value && !ordered) orderedSince = performance.now();
      if (!value) orderedSince = 0;
      ordered = value;
      root.classList.toggle("is-organized", value);
    }

    function attachTriggers() {
      root.querySelectorAll(".js-organize-trigger").forEach(function (trigger) {
        if (trigger.dataset.organizeReady === "true") return;
        trigger.dataset.organizeReady = "true";
        trigger.addEventListener("pointerenter", function () { setOrdered(true); });
        trigger.addEventListener("pointerleave", function () { setOrdered(false); });
        trigger.addEventListener("focus", function () { setOrdered(true); });
        trigger.addEventListener("blur", function () { setOrdered(false); });
        trigger.addEventListener("touchstart", function () { setOrdered(true); }, { passive: true });
      });
    }

    function orderedTarget(index, count, time) {
      var columns = width < 560 ? 3 : width < 920 ? 4 : 6;
      var rows = Math.ceil(count / columns);
      var marginX = width < 560 ? 12 : Math.max(28, width * 0.035);
      var top = width < 560 ? 76 : 86;
      var bottom = width < 560 ? 48 : 58;
      var cellWidth = (width - marginX * 2) / columns;
      var cellHeight = (height - top - bottom) / rows;
      var column = index % columns;
      var row = Math.floor(index / columns);
      var trackHeight = rows * cellHeight;
      var elapsed = ordered && !reducedMotion ? Math.max(0, time - orderedSince) : 0;
      var scrollSpeed = width < 560 ? 9 : 14;
      var scrollDistance = elapsed * 0.001 * scrollSpeed;
      var wrappedY = top + ((cellHeight * (row + 0.5) + scrollDistance) % trackHeight);
      return {
        x: marginX + cellWidth * (column + 0.5),
        y: wrappedY,
        width: Math.min(246, cellWidth * 0.88, cellHeight * 1.48)
      };
    }

    function updateParticle(particle, time, delta) {
      var seconds = time * 0.001;
      var windX = Math.sin(seconds * 0.17) * 16;
      windX += Math.sin(seconds * 0.047 + 1.8) * 11;
      windX += Math.sin((particle.y / Math.max(height, 1)) * 4.2 - seconds * 0.24 + particle.windPhase * 0.18) * 7;
      windX += Math.sin(seconds * 0.63 + particle.phase * 1.73) * 4.5;
      var windY = Math.sin(seconds * 0.19 + 0.7) * 2.2;
      windY += Math.sin(seconds * 0.41 + particle.windPhase * 0.24) * 1.5;
      var relativeX = windX - particle.vx;
      var relativeY = windY - particle.vy;
      var airSpeed = Math.max(0.001, Math.sqrt(relativeX * relativeX + relativeY * relativeY));
      var normal = paperNormal(particle);
      var normalFlow = relativeX * normal.x + relativeY * normal.y;
      var pressure = normalFlow * Math.abs(normalFlow) * particle.pressureDrag / particle.mass;
      var skin = airSpeed * particle.skinDrag / particle.mass;
      var crossX = -relativeY / airSpeed;
      var crossY = relativeX / airSpeed;
      var attack = Math.abs(normalFlow) / airSpeed;
      var vortexLift = Math.sin(particle.vortexPhase + particle.phase) * airSpeed * airSpeed;
      vortexLift *= particle.liftCoefficient * (0.24 + Math.abs(normal.z) * 0.76);

      var accelerationX = relativeX * skin + normal.x * pressure + crossX * vortexLift;
      var accelerationY = particle.gravity + relativeY * skin + normal.y * pressure + crossY * vortexLift;
      particle.vx = clamp(particle.vx + accelerationX * delta, -230, 230);
      particle.vy = clamp(particle.vy + accelerationY * delta, -80, 282);
      particle.x += particle.vx * delta;
      particle.y += particle.vy * delta;

      var flowLoad = clamp(airSpeed / 92, 0.18, 2.7);
      particle.airLoad += (flowLoad - particle.airLoad) * (1 - Math.exp(-2.8 * delta));
      particle.vortexPhase += delta * (1.25 + airSpeed * 0.011) * particle.vortexRate;
      var buffet = Math.sin(particle.vortexPhase);
      buffet += Math.sin(particle.vortexPhase * 0.61 + particle.phase * 1.9) * 0.36;
      var pressureTorque = particle.centerBias * normalFlow * 0.032;
      var pitchTorque = buffet * flowLoad * (0.48 + attack * 1.18) + pressureTorque;
      pitchTorque += (relativeX / airSpeed) * 0.22 * flowLoad;
      var yawTorque = Math.sin(particle.vortexPhase * 0.73 + particle.phase) * flowLoad * (0.32 + attack * 0.68);
      yawTorque += (relativeX / airSpeed) * 0.38 * flowLoad - pressureTorque * 0.28;
      var rollTorque = Math.sin(particle.vortexPhase * 0.47 + particle.windPhase) * flowLoad * 0.24;
      rollTorque += (relativeX / airSpeed) * flowLoad * 0.54 + normal.x * attack * 0.2;

      particle.pitchVelocity += pitchTorque * delta;
      particle.yawVelocity += yawTorque * delta;
      particle.rollVelocity += rollTorque * delta;
      particle.pitchVelocity *= Math.exp(-(0.34 + attack * 1.08) * delta);
      particle.yawVelocity *= Math.exp(-(0.42 + attack * 0.88) * delta);
      particle.rollVelocity *= Math.exp(-(0.27 + attack * 0.5) * delta);
      particle.pitchVelocity = clamp(particle.pitchVelocity, -2.55, 2.55);
      particle.yawVelocity = clamp(particle.yawVelocity, -2.18, 2.18);
      particle.rollVelocity = clamp(particle.rollVelocity, -1.82, 1.82);
      particle.pitch = wrapAngle(particle.pitch + particle.pitchVelocity * delta);
      particle.yaw = wrapAngle(particle.yaw + particle.yawVelocity * delta);
      particle.roll = wrapAngle(particle.roll + particle.rollVelocity * delta);

      if (particle.y > height + 260 || particle.x < -520 || particle.x > width + 520) recycleParticle(particle);
    }

    function renderPaper(particle, centerX, centerY, paperWidth, paperHeight, pitch, yaw, roll, curlX, curlY, flutter, uvRect, time, shadow) {
      var shadowScale = shadow ? 1.045 : 1;
      var shadowOffset = shadow ? 3.5 + particle.depth * 5.5 : 0;
      gl.uniform2f(uniforms.center, (centerX + shadowOffset) * dpr, (centerY + shadowOffset * 1.28) * dpr);
      gl.uniform2f(uniforms.size, paperWidth * shadowScale * dpr, paperHeight * shadowScale * dpr);
      gl.uniform3f(uniforms.orientation, pitch, yaw, roll);
      gl.uniform1f(uniforms.depth, particle.depth);
      gl.uniform1f(uniforms.time, time * 0.001 + particle.phase);
      gl.uniform2f(uniforms.curl, curlX, curlY);
      gl.uniform1f(uniforms.flutter, flutter);
      gl.uniform1f(uniforms.seed, particle.seed);
      gl.uniform4f(uniforms.uvRect, uvRect[0], uvRect[1], uvRect[2], uvRect[3]);
      gl.uniform1f(uniforms.shadow, shadow ? 1 : 0);
      gl.uniform1f(uniforms.shadowStrength, shadow ? 0.1 + particle.depth * 0.075 : 0);
      gl.drawArrays(gl.TRIANGLES, 0, vertexCount);
    }

    function drawParticle(particle, index, time, delta) {
      if (!reducedMotion) updateParticle(particle, time, delta);

      var scale = 0.7 + particle.depth * 0.43;
      var scatterWidth = particle.baseWidth * scale;
      var target = orderedTarget(index, particles.length, time);
      var centerX = particle.x + (target.x - particle.x) * orderMix;
      var centerY = particle.y + (target.y - particle.y) * orderMix;
      var paperWidth = scatterWidth + (target.width - scatterWidth) * orderMix;
      var paperHeight = paperWidth * 0.61;
      var loose = 1 - orderMix;
      var pitch = particle.pitch * loose;
      var yaw = particle.yaw * loose;
      var roll = particle.roll * loose;
      var aeroPulse = Math.sin(particle.vortexPhase) * 0.45 + Math.sin(particle.vortexPhase * 0.57 + particle.phase) * 0.2;
      var curlX = (particle.curlX + aeroPulse * 0.0105 * particle.airLoad) * loose;
      var curlY = (particle.curlY - aeroPulse * 0.007 * particle.airLoad) * loose;
      var flutter = particle.flexibility * (0.42 + particle.airLoad * 0.58) * loose;
      var tileColumn = particle.tile % atlas.columns;
      var tileRow = Math.floor(particle.tile / atlas.columns);
      var uvRect = [
        tileColumn / atlas.columns,
        tileRow * atlas.rowStride / atlas.textureHeight,
        (tileColumn + 1) / atlas.columns,
        (tileRow * atlas.rowStride + atlas.tileHeight) / atlas.textureHeight
      ];

      renderPaper(particle, centerX, centerY, paperWidth, paperHeight, pitch, yaw, roll, curlX, curlY, flutter, uvRect, time, true);
      renderPaper(particle, centerX, centerY, paperWidth, paperHeight, pitch, yaw, roll, curlX, curlY, flutter, uvRect, time, false);
    }

    function frame(now) {
      if (!canvas.isConnected) return;
      var delta = Math.min((now - lastTime) / 1000, 0.034);
      lastTime = now;
      var destination = ordered || reducedMotion ? 1 : 0;
      var response = destination ? 13 : 3.2;
      orderMix += (destination - orderMix) * (1 - Math.exp(-response * delta));

      gl.clearColor(0, 0, 0, 0);
      gl.clear(gl.COLOR_BUFFER_BIT);
      gl.useProgram(program);
      gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
      gl.uniform2f(uniforms.resolution, canvas.width, canvas.height);

      particles.slice().sort(function (a, b) { return a.depth - b.depth; }).forEach(function (particle) {
        drawParticle(particle, particles.indexOf(particle), now, delta);
      });
      animationFrame = requestAnimationFrame(frame);
    }

    var resizeObserver = new ResizeObserver(resize);
    resizeObserver.observe(canvas);
    attachTriggers();
    resize();
    if (reducedMotion) setOrdered(true);
    animationFrame = requestAnimationFrame(frame);

    window.addEventListener("pagehide", function cleanup() {
      cancelAnimationFrame(animationFrame);
      resizeObserver.disconnect();
    }, { once: true });
  }

  function scan() {
    document.querySelectorAll("canvas[data-paper-field]").forEach(initPaperField);
  }

  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", scan, { once: true });
  else scan();

  new MutationObserver(scan).observe(document.documentElement, { childList: true, subtree: true });
})();
