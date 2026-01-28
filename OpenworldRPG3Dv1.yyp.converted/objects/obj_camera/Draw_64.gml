/// @description Insert description here
// You can write your code in this editor
/// @description UI
// You can write your code in this editor
if (asset_get_index("scr_world_to_screen") != -1) {
    var p = (instance_exists(obj_player) ? instance_find(obj_player,0) : noone);
    if (p != noone) {
        var proj = scr_world_to_screen(p.x, p.y, p.z);
        draw_text(32, 32, "Player world: x=" + string(p.x) + " y=" + string(p.y) + " z=" + string(p.z) + " proj_ok=" + string(proj[3]));
    }
}

// Draw debug cubes if enabled
if (global.debug_mode && variable_global_exists("debug_draw_cubes") && global.debug_draw_cubes) {
    if (asset_get_index("scr_debug_draw_cubes") != -1) scr_debug_draw_cubes();
}

