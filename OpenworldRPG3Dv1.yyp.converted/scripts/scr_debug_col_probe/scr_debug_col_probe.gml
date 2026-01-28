/// scr_debug_col_probe(_x,_y,_z,_pw,_pd,_ph)
/// Probes collisions at a point using cube list, par_solid instance check, and ColWorld if present; prints results.
function scr_debug_col_probe(_x, _y, _z, _pw, _pd, _ph) {
    // Robust defaults: prefer explicit args, fall back to global player_position if present, else 0
    var xq = (argument_count > 0) ? argument0 : (variable_global_exists("player_position") ? global.player_position[0] : 0);
    var yq = (argument_count > 1) ? argument1 : (variable_global_exists("player_position") ? global.player_position[1] : 0);
    var zq = (argument_count > 2) ? argument2 : (variable_global_exists("player_position") ? global.player_position[2] : 0);
    var pwq = (argument_count > 3 && argument3 != undefined) ? argument3 : 16;
    var pdq = (argument_count > 4 && argument4 != undefined) ? argument4 : pwq;
    var phq = (argument_count > 5 && argument5 != undefined) ? argument5 : 32;

    show_debug_message("[COL_PROBE] probe at " + string(xq) + "," + string(yq) + "," + string(zq));

    var cube_hit = false;
    try {
        cube_hit = cube_collision_check(xq, yq, zq, pwq, pdq, phq);
    } catch (e) {
        cube_hit = noone;
    }
    show_debug_message("  cube_collision_check -> " + string(cube_hit));

    var pm_hit = false;
    if (asset_get_index("place_meeting_ext") != -1 && asset_get_index("par_solid") != -1) {
        pm_hit = place_meeting_ext(xq, yq, zq, par_solid, pwq, pdq, phq, 0);
    }
    show_debug_message("  place_meeting_ext(par_solid) -> " + string(pm_hit));

    if (variable_global_exists("col_world") && !is_undefined(global.col_world)) {
        var col_hit = scr_col_test_aabb(xq, yq, zq, pwq, pdq, phq);
        if (col_hit != undefined) {
            show_debug_message("  ColWorld hit -> reference=" + string(col_hit.reference) + " shape_min=" + string(col_hit.shape.property_min) + " shape_max=" + string(col_hit.shape.property_max));
        } else {
            show_debug_message("  ColWorld hit -> none");
        }
    } else {
        show_debug_message("  ColWorld not initialized");
    }
}
