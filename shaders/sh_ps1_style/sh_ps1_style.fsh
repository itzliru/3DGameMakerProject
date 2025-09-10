//
// PS1 style fragment shader
//
varying vec2 v_vTexcoord;   // <- no noperspective, must match .vsh
varying vec4 v_vColour;

// tiny hash-based random for dithering
float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main()
{
    // Sample texture (UVs are interpolated affinely by GM here)
    vec4 tex = texture2D(gm_BaseTexture, v_vTexcoord);
    vec4 col = v_vColour * tex;

    // ===== Colour Banding =====
    float levels = 16.0; // reduce RGB to 16 steps per channel
    col.rgb = floor(col.rgb * levels) / levels;

    // ===== Optional Dithering =====
    col.rgb += (rand(gl_FragCoord.xy) - 0.5) / levels;

    gl_FragColor = col;
}
