// Feather disable all
/// @desc Draw a 3D block. Skips some of the optional parameters to speed up caching.
/// @param {real} x1 The starting x coordinate of the block
/// @param {real} y1 The starting y coordinate of the block
/// @param {real} z1 The starting z coordinate of the block
/// @param {real} x2 The ending x coordinate of the block
/// @param {real} y2 The ending y coordinate of the block
/// @param {real} z2 The ending z coordinate of the block
/// @param {pointer.Texture|real} tex The texture to draw the block with (defaults to -1 for no texture)
function d3d_draw_block_simple(x1, y1, z1, x2, y2, z2, tex = -1) {
    static vertex = Drago3D_Internals.Vertex;
    static format = Drago3D_Internals.format;
    
    static vb = undefined;
    
    if (vb == undefined) {
        vb = vertex_create_buffer();
        vertex_begin(vb, format);
        
        static cx1 = -0.5;
        static cy1 = -0.5;
        static cz1 = -0.5;
        static cx2 =  0.5;
        static cy2 =  0.5;
        static cz2 =  0.5;
        
        vertex(vb, cx1, cy1, cz1, 0, 0, -1, 0, 0, c_white, 1);
        vertex(vb, cx1, cy2, cz1, 0, 0, -1, 0, 1, c_white, 1);
        vertex(vb, cx2, cy2, cz1, 0, 0, -1, 1, 1, c_white, 1);
        vertex(vb, cx2, cy2, cz1, 0, 0, -1, 1, 1, c_white, 1);
        vertex(vb, cx2, cy1, cz1, 0, 0, -1, 1, 0, c_white, 1);
        vertex(vb, cx1, cy1, cz1, 0, 0, -1, 0, 0, c_white, 1);
        vertex(vb, cx1, cy1, cz2, 0, 0, 1, 0, 0, c_white, 1);
        vertex(vb, cx2, cy1, cz2, 0, 0, 1, 1, 0, c_white, 1);
        vertex(vb, cx2, cy2, cz2, 0, 0, 1, 1, 1, c_white, 1);
        vertex(vb, cx2, cy2, cz2, 0, 0, 1, 1, 1, c_white, 1);
        vertex(vb, cx1, cy2, cz2, 0, 0, 1, 0, 1, c_white, 1);
        vertex(vb, cx1, cy1, cz2, 0, 0, 1, 0, 0, c_white, 1);
        vertex(vb, cx1, cy2, cz1, 0, 1, 0, 0, 0, c_white, 1);
        vertex(vb, cx1, cy2, cz2, 0, 1, 0, 0, 1, c_white, 1);
        vertex(vb, cx2, cy2, cz2, 0, 1, 0, 1, 1, c_white, 1);
        vertex(vb, cx2, cy2, cz2, 0, 1, 0, 1, 1, c_white, 1);
        vertex(vb, cx2, cy2, cz1, 0, 1, 0, 1, 0, c_white, 1);
        vertex(vb, cx1, cy2, cz1, 0, 1, 0, 0, 0, c_white, 1);
        vertex(vb, cx2, cy2, cz1, 1, 0, 0, 0, 0, c_white, 1);
        vertex(vb, cx2, cy2, cz2, 1, 0, 0, 0, 1, c_white, 1);
        vertex(vb, cx2, cy1, cz2, 1, 0, 0, 1, 1, c_white, 1);
        vertex(vb, cx2, cy1, cz2, 1, 0, 0, 1, 1, c_white, 1);
        vertex(vb, cx2, cy1, cz1, 1, 0, 0, 1, 0, c_white, 1);
        vertex(vb, cx2, cy2, cz1, 1, 0, 0, 0, 0, c_white, 1);
        vertex(vb, cx2, cy1, cz1, 0, -1, 0, 0, 0, c_white, 1);
        vertex(vb, cx2, cy1, cz2, 0, -1, 0, 0, 1, c_white, 1);
        vertex(vb, cx1, cy1, cz2, 0, -1, 0, 1, 1, c_white, 1);
        vertex(vb, cx1, cy1, cz2, 0, -1, 0, 1, 1, c_white, 1);
        vertex(vb, cx1, cy1, cz1, 0, -1, 0, 1, 0, c_white, 1);
        vertex(vb, cx2, cy1, cz1, 0, -1, 0, 0, 0, c_white, 1);
        vertex(vb, cx1, cy1, cz1, -1, 0, 0, 0, 0, c_white, 1);
        vertex(vb, cx1, cy1, cz2, -1, 0, 0, 0, 1, c_white, 1);
        vertex(vb, cx1, cy2, cz2, -1, 0, 0, 1, 1, c_white, 1);
        vertex(vb, cx1, cy2, cz2, -1, 0, 0, 1, 1, c_white, 1);
        vertex(vb, cx1, cy2, cz1, -1, 0, 0, 1, 0, c_white, 1);
        vertex(vb, cx1, cy1, cz1, -1, 0, 0, 0, 0, c_white, 1);
        
        vertex_end(vb);
        vertex_freeze(vb);
    }
    
    var sx = x2 - x1;
    var sy = y2 - y1;
    var sz = z2 - z1;
    var cx = mean(x1, x2);
    var cy = mean(y1, y2);
    var cz = mean(z1, z2);
    var transform = matrix_build(cx, cy, cz, 0, 0, 0, sx, sy, sz);
    var current = matrix_get(matrix_world);
    matrix_set(matrix_world, matrix_multiply(transform, current));
    
    // Accept sprite index as `tex` and convert if required
    if (tex != -1) {
        if (is_real(tex) && sprite_exists(tex)) {
            var _orig = tex;
            tex = sprite_get_texture(tex, 0);
            if (global.debug_mode) show_debug_message("[DX] d3d_draw_block_simple: converted sprite index " + string(_orig) + " -> texture " + string(tex));
        }
    }

    vertex_submit(vb, pr_trianglelist, tex);
    
    matrix_set(matrix_world, current);
}