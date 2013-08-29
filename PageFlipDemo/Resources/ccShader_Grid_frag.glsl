
varying vec2 v_texCoord;
uniform sampler2D CC_Texture0;
uniform sampler2D CC_Texture1;

void main()
{
  if (gl_FrontFacing) {
    gl_FragColor = vec4(texture2D(CC_Texture0, v_texCoord).xyz, 1.0);
  } else {
    gl_FragColor = vec4(texture2D(CC_Texture1, vec2(1.0 - v_texCoord.x, v_texCoord.y)).xyz, 1.0);
  }
}
