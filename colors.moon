export husl = require 'lib.husl'
return {
  text: {255, 255, 255}
  text2: {0, 0, 0}
  text_background: {0,0,0,55}
  background: {0, 0, 0}
  white: {255, 255, 255}
  husl: (color, callback) ->
    r, g, b, a = unpack(color)
    r, g, b = husl.husl_to_rgb(callback(husl.rgb_to_husl(r/255, g/255, b/255)))
    return {math.floor(r * 255), math.floor(g * 255), math.floor(b * 255), a}
}
