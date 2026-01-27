/// scr_debug_draw_cubes()
/// Draw debug AABBs for cubes (call from Draw event when global.debug_mode is true)
function scr_debug_draw_cubes() {
    if (!global.debug_mode) return;
    if (!variable_global_exists("cube_list")) return;

    draw_set_alpha(0.25);
    for (var i = 0; i < array_length(global.cube_list); i++) {
        var c = global.cube_list[i];
        if (!is_struct(c)) continue;
        var cx = c.x; var cy = c.y; var cz = c.z; var s = c.size;
        var left = cx; var right = cx + s;
        var front = cy; var back = cy + s;
        var bottom = cz; var top = cz + s;
        draw_set_color(c.collision ? c_lime : c_aqua);
        d3d_draw_block_simple(left, front, bottom, right, back, top);
    }
    draw_set_alpha(1);
}
