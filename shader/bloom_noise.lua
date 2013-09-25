return love.graphics.newShader[[
// use floats! integers suck
extern vec2 image_size = vec2(1300, 800);
extern float factor = 0.1;
extern float addPercent = 0.01; // 0..1.0 higher is darker
extern float clamp = 0.95; // 0..1.0 lower is smoother

float rand(vec2 n)
{
  return 0.5 + 0.5 * fract(sin(dot(n.xy, vec2(12.9898, 78.233))) * 43758.5453);
}
vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc)
{
    vec2 offset = vec2(1) / image_size;
    color = Texel(tex, tc/3); // maybe add a weight here?

    color += Texel(tex, tc + vec2(-offset.x, offset.y));
    color += Texel(tex, tc + vec2(0.0, offset.y));
    color += Texel(tex, tc + vec2(offset.x, offset.y));

    color += Texel(tex, tc + vec2(-offset.x, 0.0));
    color += Texel(tex, tc + vec2(0.0, 0.0));
    color += Texel(tex, tc + vec2(offset.x, 0.0));

    color += Texel(tex, tc + vec2(-offset.x, -offset.y));
    color += Texel(tex, tc + vec2(0.0, -offset.y));
    color += Texel(tex, tc + vec2(offset.x, -offset.y));

    float grey = 1.0 * rand(tc * factor);
    float clampedGrey = max(grey, clamp);
    vec4 clampedNoise = vec4(clampedGrey, clampedGrey, clampedGrey, 1);
    return (color / 9.0) * clampedNoise * (1.0 - addPercent);
}
]]

