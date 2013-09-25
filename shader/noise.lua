return love.graphics.newShader[[
extern float factor = 0.2;
extern float addPercent = 0.05;
extern float clamp = 0.99;

// from http://www.ozone3d.net/blogs/lab/20110427/glsl-random-generator/
float rand(vec2 n)
{
  return 0.5 + 0.5 * fract(sin(dot(n.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc)
{
  float grey = 1 * rand(tc * factor);
  float clampedGrey = max(grey, clamp);
  vec4 noise = vec4(grey, grey, grey, 1);
  vec4 clampedNoise = vec4(clampedGrey, clampedGrey, clampedGrey, 1);
  return (Texel(tex, tc) * clampedNoise * (1 - addPercent) + noise * addPercent) * color;
}
]]

