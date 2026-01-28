/// scr_find_ground_height_at(_x,_y,_start_z,_pw,_pd,_ph,_buf,_max_fall)
/// Helper: compute the highest cube top under the (_x,_y) column using logical cube list (no par_solid check).
/// Returns top Z (c.z + c.size) of highest matching cube, or noone if none.
function scr_find_ground_height_at(_x, _y, _start_z, _pw, _pd, _ph, _buf, _max_fall) {
    var best = -1000000000;
    if (variable_global_exists("cube_list")) {
        for (var i = 0; i < array_length(global.cube_list); i++) {
            var c = global.cube_list[i];
            if (c.x <= _x && _x < c.x + c.size && c.y <= _y && _y < c.y + c.size) {
                best = max(best, c.z + c.size);
            }
        }
    }
    if (best > -1000000000) {
        return best;
    } else {
        return noone;
    }
}