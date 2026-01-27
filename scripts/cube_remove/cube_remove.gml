/// cube_remove(x, y, z)
function cube_remove(gx, gy, gz) {
    if (is_undefined(gx) || is_undefined(gy) || is_undefined(gz)) return;
    for (var i = 0; i < array_length(global.cube_list); i++) {
        var c = global.cube_list[i];
        if (variable_struct_exists(c, "x") && variable_struct_exists(c, "y") && variable_struct_exists(c, "z")) {
            if (c.x == gx && c.y == gy && c.z == gz) {
                array_delete(global.cube_list, i, 1);
                break;
            }
        }
    }
}
