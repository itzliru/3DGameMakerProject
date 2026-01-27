/// scr_debug_list_cubes()
/// Prints info about loaded cubes (id, pos, size, collision, mask)
function scr_debug_list_cubes() {
    if (!variable_global_exists("cube_list")) {
        show_debug_message("[DEBUG_CUBES] no cube_list present");
        return;
    }
    show_debug_message("[DEBUG_CUBES] listing " + string(array_length(global.cube_list)) + " cubes:");
    for (var i = 0; i < array_length(global.cube_list); i++) {
        var c = global.cube_list[i];
        if (!is_struct(c)) { show_debug_message("  [" + string(i) + "] malformed entry"); continue; }
        var cube_id = variable_struct_exists(c, "id") ? c.id : -1;
        var cube_x = variable_struct_exists(c, "x") ? c.x : "?";
        var cube_y = variable_struct_exists(c, "y") ? c.y : "?";
        var cube_z = variable_struct_exists(c, "z") ? c.z : "?";
        var cube_size = variable_struct_exists(c, "size") ? c.size : "?";
        var cube_coll = variable_struct_exists(c, "collision") ? c.collision : "?";
        var cube_mask = variable_struct_exists(c, "mask") ? c.mask : "?";
        show_debug_message("  [" + string(i) + "] id=" + string(cube_id) + " pos=[" + string(cube_x) + "," + string(cube_y) + "," + string(cube_z) + "] size=" + string(cube_size) + " coll=" + string(cube_coll) + " mask=" + string(cube_mask));
    }
}