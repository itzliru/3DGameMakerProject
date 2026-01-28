/// scr_debug_draw_par_solid(_highlight_list)
/// Draws AABBs for all par_solid instances; if _highlight_list is an array of instances, draws those in different color.
function scr_debug_draw_par_solid(_highlight_list) {
    if (!global.debug_mode) return;
    var highlights = undefined;
    if (argument_count > 0 && is_array(argument0)) highlights = argument0;

    draw_set_alpha(0.25);
    for (var i = 0; i < instance_number(par_solid); i++) {
        var inst = instance_find(par_solid, i);
        if (!instance_exists(inst)) continue;
        var iw = variable_instance_exists(inst, "width") ? inst.width : 64;
        var il = variable_instance_exists(inst, "length") ? inst.length : 64;
        var ih = variable_instance_exists(inst, "height") ? inst.height : 64;
        var left = inst.x; var right = inst.x + iw;
        var front = inst.y; var back = inst.y + il;
        var bottom = inst.z; var top = inst.z + ih;
        var is_high = (highlights != undefined && array_contains(highlights, inst));
        draw_set_color(is_high ? c_orange : c_blue);
        d3d_draw_block_simple(left, front, bottom, right, back, top);
    }
    draw_set_alpha(1);
}