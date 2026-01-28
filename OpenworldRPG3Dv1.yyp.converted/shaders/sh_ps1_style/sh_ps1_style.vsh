//
// PS1 style vertex snap shader
//
attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec2 v_vTexcoord;   
varying vec4 v_vColour;
varying vec3 v_worldPosition;
varying vec3 v_worldNormal;

void main()
{
    vec4 object_space_pos = vec4(in_Position, 1.0);

    // World position & normal
    v_worldPosition = (gm_Matrices[MATRIX_WORLD] * object_space_pos).xyz;
    v_worldNormal   = normalize((gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.0)).xyz);

    // Pass through colour & UV
    v_vColour   = in_Colour;
    v_vTexcoord = in_TextureCoord;

    // ===== PS1 Clip-Space Snapping =====
    // Standard MVP transform
    vec4 clipSpace = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;

    // Snap vertices in clip space to integer values
    clipSpace.xyz = floor(clipSpace.xyz);

    // Output to rasterizer
    gl_Position = clipSpace;
}
