// PS1-style postprocess-compatible vertex shader (fullscreen quad)
attribute vec3 in_Position;
attribute vec2 in_TextureCoord;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
    vec4 object_space_pos = vec4(in_Position, 1.0);
    v_vColour = vec4(1.0, 1.0, 1.0, 1.0);
    v_vTexcoord = in_TextureCoord;

    vec4 clipSpace = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    // keep the original behavior of snapping in clip-space for posterity (can be tweaked)
    clipSpace.xyz = floor(clipSpace.xyz);
    gl_Position = clipSpace;
}