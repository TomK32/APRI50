extern float factor = 0.2;
extern float addPercent = 0.05;
extern float offset = 0.0; // to move the scan lines downwards
extern float strength = 0.5;
extern int dist = 60;

// based on http://www.ozone3d.net/blogs/lab/20110427/glsl-random-generator/

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
  if(mod(screen_coords.y + 2 * sin(offset) - screen_coords.x / (50 + offset), dist) > dist - 2) {
    vec4 noise = vec4(0.2, 0.2, 0.2, 1);
    return noise * strength;
  } else {
    return Texel(texture, texture_coords) * color;
  }
}
