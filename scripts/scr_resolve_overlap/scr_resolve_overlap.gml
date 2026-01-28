/// scr_resolve_overlap(_pw, _pd, _ph, _buf)
/// Nudges the calling instance upward a few pixels if overlapping any par_solid.
/// Returns true if a resolve occurred.
function scr_resolve_overlap(_pw, _pd, _ph, _buf) {
    // Quick guards
    if (asset_get_index("place_meeting_ext") == -1) return false;
    if (instance_number(par_solid) == 0) return false;
    // Adjust calling instance coords: this project uses centered player origin, so convert to top-left for tests
    var __qx = x - _pw * 0.5;
    var __qy = y - _pd * 0.5;
    if (!place_meeting_ext(__qx, __qy, z, par_solid, _pw, _pd, _ph, _buf)) return false;

    var __tries = 0;
    while (place_meeting_ext(__qx, __qy, z, par_solid, _pw, _pd, _ph, _buf) && __tries < 8) {
        z += 1;
        __qx = x - _pw * 0.5;
        __qy = y - _pd * 0.5;
        __tries += 1;
    }

    if (__tries > 0) {
        z_vel = 0;
        prev_ground_z = z;
        on_ground = false;
        // Ensure a short cooldown so we don't immediately re-resolve and ping-pong
        if (!variable_instance_exists(id, "resolve_cooldown")) resolve_cooldown = 0;
        resolve_cooldown = max(resolve_cooldown, 6);
        if (global.debug_mode) show_debug_message("[RESOLVE_SIMPLE] nudged player up " + string(__tries) + " px to z=" + string(z));
        return true;
    }
    return false;
}