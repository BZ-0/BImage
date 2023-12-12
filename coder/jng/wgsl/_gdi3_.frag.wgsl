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

struct I { j: i32, i: i32 }

fn e(m: ptr<function, array<f32, 16>>, i: I, a: i32, b: i32) -> f32 { 
    return (*m)[((i.j+b)%4)*4 + ((i.i+a)%4)];
}

fn invf(m: ptr<function, array<f32, 16>>, ix: I) -> f32 {
    var i: I = ix;
    var o: i32 = 2+(ix.j-ix.i);
    i.i = i.i + (4+o);
    i.j = i.j + (4-o);
    var inv: f32 = 
        e(m,i,  1,-1) * e(m,i,  0, 0) * e(m,i, -1, 1)
      + e(m,i,  1, 1) * e(m,i,  0,-1) * e(m,i, -1, 0)
      + e(m,i, -1,-1) * e(m,i,  1, 0) * e(m,i,  0, 1)
      - e(m,i, -1,-1) * e(m,i,  0, 0) * e(m,i,  1, 1)
      - e(m,i, -1, 1) * e(m,i,  0,-1) * e(m,i,  1, 0)
      - e(m,i,  1,-1) * e(m,i, -1, 0) * e(m,i,  0, 1);
    return select(-inv, inv, (o%2) == 1);
}

//
fn inverse(m: mat4x4<f32>) -> mat4x4<f32> {
    var M = array<f32, 16>(m[0][0], m[0][1], m[0][2], m[0][3], m[1][0], m[1][1], m[1][2], m[1][3], m[2][0], m[2][1], m[2][2], m[2][3], m[3][0], m[3][1], m[3][2], m[3][3]);

    var inv: array<f32, 16>;
    for (var i: i32=0;i<4;i++) {
        for (var j: i32=0;j<4;j++) {
            inv[j*4+i] = invf(&M, I(j,i));
        }
    }

    //
    var D: f32 = 0.0;
    for (var k: i32 =0;k<4;k++) { D += M[k] * inv[k*4]; }

    //
    var out: array<f32, 16>;
    if (abs(D) > 0.0) {
        D = 1.0 / D;
        for (var i: i32 = 0; i < 16; i++) {
            out[i] = inv[i] * D;
        }
    }

    return mat4x4<f32>(out[0], out[1], out[2], out[3], out[4], out[5], out[6], out[7], out[8], out[9], out[10], out[11], out[12], out[13], out[14], out[15]);
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



//
@fragment
fn main(
  @location(0) fUV: vec2<f32>,
  @location(1) fPS: vec4<f32>
) -> @location(0) vec4<f32> {

    //
    let rgb_xyz_c = transpose(mat4x3<f32>(
        vec3<f32>(U.rxy, 1.f-U.rxy.x-U.rxy.y),
        vec3<f32>(U.gxy, 1.f-U.gxy.x-U.gxy.y),
        vec3<f32>(U.bxy, 1.f-U.bxy.x-U.bxy.y),
        vec3<f32>(0.f)
    ));

    //
    let xyz_rgb_c = inverse(mat4x4<f32>(rgb_xyz_c[0], rgb_xyz_c[1], rgb_xyz_c[2], vec4<f32>(0.0, 0.0, 0.0, 1.0)));

    //
    let a: f32 = textureSample(alpha, sampl, fUV).x;
    let scale: vec4<f32> = vec4<f32>(U.wxy, 1.f-U.wxy.x-U.wxy.y, U.wxy.y) * xyz_rgb_c;
    let linearXYZ: vec4<f32> = vec4<f32>(textureSample(rgb, sampl, fUV).xyz*srgb_xyz, 1.0);
    let linearRGB: vec4<f32> = (linearXYZ/linearXYZ.w)*xyz_rgb_c / scale;
    return vec4<f32>(pow(linearRGB.xyz/linearRGB.w, vec3(0.45f / U.gamma))*a, a);
}
