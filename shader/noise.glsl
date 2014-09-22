extern vec2 offset = vec2(0,0);
extern float scale = 0.0125;

// from http://www.ozone3d.net/blogs/lab/20110427/glsl-random-generator/
float rand(vec2 n)
{
  return 0.5 * fract(sin(dot(vec2(floor(n.x * 400), floor(n.y * 400)), vec2(12.9898, 78.233))) * 43758.5453);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
  float grey = 1 + scale - scale * 2 * rand(texture_coords + offset);
  vec4 noise = vec4(grey, grey, grey, 1);
  vec4 other = Texel(texture, texture_coords * sqrt(grey));
  vec4 n = (Texel(texture, texture_coords) + other) / 2;
  return n * noise * color;
}
