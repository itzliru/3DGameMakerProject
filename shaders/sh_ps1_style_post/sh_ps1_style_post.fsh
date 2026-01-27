varying vec2 v_vTexcoord;
varying vec4 v_vColour;

float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main()
{
    vec4 tex = texture2D(gm_BaseTexture, v_vTexcoord);
    vec4 col = v_vColour * tex;

    float levels = 16.0;
    col.rgb = floor(col.rgb * levels) / levels;
    col.rgb += (rand(gl_FragCoord.xy) - 0.5) / levels;

    gl_FragColor = col;
}