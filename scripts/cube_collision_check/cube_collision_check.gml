/// cube_collision_check(x, y, z, w, h, d, obj, buffer)
/// Returns true if an AABB at (x,y,z) with size w,h,d overlaps any placed cube OR specified object instances.
/// - obj (optional): object to test against (e.g., par_solid). If omitted, this will fallback to checking `par_solid` via `place_meeting_ext` if available.
/// - buffer (optional): shrink amount passed to `place_meeting_ext`.
var xx = argument_count > 0 ? argument0 : undefined;
var yy = argument_count > 1 ? argument1 : undefined;
var zz = argument_count > 2 ? argument2 : undefined;
var ww = argument_count > 3 ? argument3 : undefined;
var hh = argument_count > 4 ? argument4 : undefined;
var dd = argument_count > 5 ? argument5 : undefined;
var obj_check = argument_count > 6 ? argument6 : undefined;
var pm_buffer = argument_count > 7 ? argument7 : 0;

// Basic argument validation: ensure we have numeric values to compare
var _gs_fallback = variable_global_exists("grid_size") ? global.grid_size : 64;
if (!is_real(xx)) {
    if (is_string(argument0) && string(argument0) != "") xx = real(argument0);
}
if (!is_real(yy)) {
    if (is_string(argument1) && string(argument1) != "") yy = real(argument1);
}
if (!is_real(zz)) {
    if (is_string(argument2) && string(argument2) != "") zz = real(argument2);
}
if (!is_real(ww)) {
    if (is_string(argument3) && string(argument3) != "") ww = real(argument3);
    else ww = (variable_global_exists("block_size") ? global.block_size : _gs_fallback);
}
if (!is_real(hh)) hh = ww;
if (!is_real(dd)) dd = ww;

// If any primary coordinate is still invalid, bail safely and log diagnostics
if (!is_real(xx) || !is_real(yy) || !is_real(zz)) {
    show_debug_message("[cube_collision_check] invalid args — count=" + string(argument_count) +
        " | x=" + string(argument0) + " y=" + string(argument1) + " z=" + string(argument2) +
        " | caller_context=" + string(room) +
        " | using fallback grid_size=" + string(_gs_fallback)
    );
    return false;
}

// 1) Check against placed cube list (defensive)
if (variable_global_exists("cube_list")) {
    for (var i = 0; i < array_length(global.cube_list); i++) {
        var c = global.cube_list[i];

        // Defensive: skip entries that are missing or malformed
        if (!is_struct(c)) continue;
        if (!variable_struct_exists(c, "x") || !variable_struct_exists(c, "y") || !variable_struct_exists(c, "z")) continue;

        // Ensure numeric fields (coerce or skip)
        var cx = is_real(c.x) ? c.x : (is_real(real(c.x)) ? real(c.x) : undefined);
        var cy = is_real(c.y) ? c.y : (is_real(real(c.y)) ? real(c.y) : undefined);
        var cz = is_real(c.z) ? c.z : (is_real(real(c.z)) ? real(c.z) : undefined);
        var csize = (variable_struct_exists(c, "size") && is_real(c.size)) ? c.size : 0;
        var ccoll = variable_struct_exists(c, "collision") ? c.collision : true;

        if (cx == undefined || cy == undefined || cz == undefined) continue;
        if (csize <= 0) continue; // invalid size
        if (!ccoll) continue; // skip non-colliding blocks

        var left   = cx;
        var right  = cx + csize;
        var front  = cy;
        var back   = cy + csize;
        var bottom = cz;
        var top    = cz + csize;

        // AABB overlap test
        if (!(xx + ww <= left || xx >= right ||
              yy + hh <= front || yy >= back ||
              zz + dd <= bottom || zz >= top)) {
            return true;
        }
    }
}

// 2) If requested or available, consult place_meeting_ext / object instances (e.g., par_solid)
if (is_undefined(obj_check) && script_exists(place_meeting_ext) && asset_get_index("par_solid") != -1) {
    obj_check = par_solid;
}

if (!is_undefined(obj_check) && script_exists(place_meeting_ext)) {
    // call the existing helper which checks all instances of obj_check
    if (place_meeting_ext(xx, yy, zz, obj_check, ww, hh, dd, pm_buffer)) return true;
}

return false;
