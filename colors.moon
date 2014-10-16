export husl = require 'lib.husl'
return {
  text: {255, 255, 255}
  text2: {0, 0, 0}
  text_background: {0,0,0,55}
  background: {0, 0, 0}
  white: {255, 255, 255}
  husl: (color, callback) ->
    print unpack(color)
    h, s, l = husl.rgb_to_husl(unpack(color))
    return {husl.husl_to_rgb(callback(h, s, l))}
}
