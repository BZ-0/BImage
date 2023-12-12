struct RGBW {
    rxy: vec2<f32>,
    gxy: vec2<f32>,
    bxy: vec2<f32>,
    wxy: vec2<f32>,
    gamma: f32
}

@group(0) @binding(0) var<uniform> U : RGBW;
@group(1) @binding(0) var sampl: sampler;
@group(2) @binding(0) var rgb: texture_2d<f32>;
@group(2) @binding(1) var alpha: texture_2d<f32>;

struct G { j: i32, i: i32, m: mat4x4<f32> }

fn getv(m: vec4<f32>, i: i32) -> f32 {
    if (i == 0) { return m[0]; }
    if (i == 1) { return m[1]; }
    if (i == 2) { return m[2]; }
    if (i == 3) { return m[3]; }
    return 0.0;
}

fn getm(m: mat4x4<f32>, j: i32, i: i32) -> f32 {
    if (j == 0) { return getv(m[0], i); }
    if (j == 1) { return getv(m[1], i); }
    if (j == 2) { return getv(m[2], i); }
    if (j == 3) { return getv(m[3], i); }
    return 0.0;
}


fn setv(m: ptr<function,vec4<f32>>, i: i32, a: f32) {
    if (i == 0) { (*m)[0] = a; }
    if (i == 1) { (*m)[1] = a; }
    if (i == 2) { (*m)[2] = a; }
    if (i == 3) { (*m)[3] = a; }
}

fn setm(m: ptr<function,mat4x4<f32>>, j: i32, i: i32, a: f32) {
    if (j == 0) { 
        if (i == 0) { (*m)[0][0] = a; }
        if (i == 1) { (*m)[0][1] = a; }
        if (i == 2) { (*m)[0][2] = a; }
        if (i == 3) { (*m)[0][3] = a; }
    }
    if (j == 1) { 
        if (i == 0) { (*m)[1][0] = a; }
        if (i == 1) { (*m)[1][1] = a; }
        if (i == 2) { (*m)[1][2] = a; }
        if (i == 3) { (*m)[1][3] = a; }
    }
    if (j == 2) { 
        if (i == 0) { (*m)[2][0] = a; }
        if (i == 1) { (*m)[2][1] = a; }
        if (i == 2) { (*m)[2][2] = a; }
        if (i == 3) { (*m)[2][3] = a; }
    }
    if (j == 3) {
        if (i == 0) { (*m)[3][0] = a; }
        if (i == 1) { (*m)[3][1] = a; }
        if (i == 2) { (*m)[3][2] = a; }
        if (i == 3) { (*m)[3][3] = a; }
    }
}


fn e(m: G, a: i32, b: i32) -> f32 { 
    return getm(m.m, (m.j+b)%4, (m.i+a)%4);
}

fn invf(x: G) -> f32 {
    var m: G = x;
    var o: i32 = 2+(m.j-m.i);
    m.i = m.i + (4+o);
    m.j = m.j + (4-o);
    var inv: f32 = 
        e(m,  1,-1) * e(m,  0, 0) * e(m, -1, 1)
      + e(m,  1, 1) * e(m,  0,-1) * e(m, -1, 0)
      + e(m, -1,-1) * e(m,  1, 0) * e(m,  0, 1)
      - e(m, -1,-1) * e(m,  0, 0) * e(m,  1, 1)
      - e(m, -1, 1) * e(m,  0,-1) * e(m,  1, 0)
      - e(m,  1,-1) * e(m, -1, 0) * e(m,  0, 1);
    return select(-inv, inv, (o%2) == 1);
}

fn inverse(m: mat4x4<f32>) -> mat4x4<f32> {
    var inv: mat4x4<f32>;
    for (var i: i32=0;i<4;i++) {
        for (var j: i32=0;j<4;j++) {
            var mx: G = G(j,i,m);
            setm(&inv, j, i, invf(mx));
        }
    }

    //
    var out: mat4x4<f32>;
    var D: f32 = 0.0;
    for (var k: i32 =0;k<4;k++) { D += getm(m, 0, k) * getm(inv, k, 0); }

    //
    if (abs(D) > 0.0) {
        D = 1.0 / D;
        for (var i: i32 = 0; i < 4; i++) {
            for (var j: i32 = 0; j < 4; j++) {
                setm(&out, j, i, getm(inv, j, i) * D);
            }
        }
    }
    return out;
}

//
const srgb_xyz = mat3x3(
    0.4124564,  0.3575761,  0.1804375,
    0.2126729,  0.7151522,  0.0721750,
    0.0193339,  0.1191920,  0.9503041
);

//
const xyz_srgb = mat3x3(
    3.2404542, -1.5371385, -0.4985314,
    -0.9692660,  1.8760108,  0.0415560,
    0.0556434, -0.2040259,  1.0572252
);

@fragment
fn main(
  @location(0) fUV: vec2<f32>,
  @location(1) fPS: vec4<f32>
) -> @location(0) vec4<f32> {

    //
    var rgb_xyz_c: mat3x4<f32> = transpose(mat4x3<f32>(
        vec3<f32>(U.rxy, 1.f-U.rxy.x-U.rxy.y),
        vec3<f32>(U.gxy, 1.f-U.gxy.x-U.gxy.y),
        vec3<f32>(U.bxy, 1.f-U.bxy.x-U.bxy.y),
        vec3<f32>(0.f)
    ));

    //
    var a: f32 = textureSample(alpha, sampl, fUV).x;
    var scale: vec4<f32> = vec4<f32>(U.wxy, 1.f-U.wxy.x-U.wxy.y, U.wxy.y) * inverse(mat4x4<f32>(rgb_xyz_c[0], rgb_xyz_c[1], rgb_xyz_c[2], vec4<f32>(0.0, 0.0, 0.0, 1.0)));
    var linearXYZ: vec4<f32> = vec4<f32>(textureSample(rgb, sampl, fUV).xyz*srgb_xyz, 1.0);
    var linearRGB: vec4<f32> = (linearXYZ/linearXYZ.w)*inverse(mat4x4<f32>(rgb_xyz_c[0], rgb_xyz_c[1], rgb_xyz_c[2], vec4(0.f, 0.f, 0.f, 1.0))) / scale;
    return vec4<f32>(pow(linearRGB.xyz/linearRGB.w, vec3(0.45f / U.gamma))*a, a);
}
