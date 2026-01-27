/// scr_safe_surface_set_target(surface)
/// Ensures any previously-bound surface is reset before binding the requested surface.
/// This avoids unbalanced surface stacks when multiple modules set targets.
function scr_surface_reset_target() {
    // Attempt to reset the surface stack; use try/catch to avoid throwing if the engine rejects it.
    try {
        surface_reset_target();
        global._surface_target_active = false;
        if (global.debug_mode) show_debug_message("[SURF] scr_surface_reset_target: reset stack (try succeeded)");
    } catch (e) {
        // If the engine complains, log and clear our flag to avoid repeated errors
        if (global.debug_mode) show_debug_message("[SURF] scr_surface_reset_target: exception when resetting surface: " + string(e));
        global._surface_target_active = false;
    }
}

function scr_safe_surface_set_target(surf) {
    if (!argument_count) return;
    var s = argument0;
    // Defensive: if the target surface is invalid, don't set it
    var s_ok = false;
    try {
        s_ok = surface_exists(s);
    } catch (e) {
        if (global.debug_mode) show_debug_message("[SURF] scr_safe_surface_set_target: surface_exists threw: " + string(e) + " arg=" + string(s));
        s_ok = false;
    }
    if (!s_ok) {
        if (global.debug_mode) show_debug_message("[SURF] scr_safe_surface_set_target: requested surface does not exist or invalid: " + string(s));
        return noone;
    }
    // Reset any existing target first to avoid stacking
    scr_surface_reset_target();
    surface_set_target(s);
    global._surface_target_active = true;
    return s;
}
