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

struct VertexOutput {
  @builtin(position) Position : vec4<f32>,
  @location(0) fUV: vec2<f32>,
  @location(1) fPS: vec4<f32>,
}

@vertex
fn main(
  @location(0) position : vec4<f32>,
  @location(1) uv : vec2<f32>
) -> VertexOutput {
  var output : VertexOutput;
  output.Position = position;
  output.fUV = uv;
  output.fPS = position;
  return output;
}
