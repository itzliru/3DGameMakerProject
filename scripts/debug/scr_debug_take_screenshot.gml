/// scr_debug_take_screenshot([filename])
/// Saves a screenshot and returns the filename, or `noone` on failure.
function scr_debug_take_screenshot(_filename) {
    var fname = (argument_count > 0 && _filename != undefined && _filename != "") ? _filename : "screenshot_" + string(irandom(9999999)) + ".png";
    try {
        var dir = "screenshots/";
        // Ensure target directory exists in the runtime working directory
        if (!directory_exists(dir)) directory_create(dir);
        var target = dir + fname;
        // Try saving into screenshots/ subfolder first; fall back to root on failure
        if (!is_undefined(screen_save)) {
            try {
                screen_save(target);
                if (variable_global_exists("debug_mode") && global.debug_mode) show_debug_message("[SCREEN] saved -> " + string(target));
                return target;
            } catch (e_inner) {
                // fallback to saving without directory
                screen_save(fname);
                if (variable_global_exists("debug_mode") && global.debug_mode) show_debug_message("[SCREEN] saved (fallback) -> " + string(fname));
                return fname;
            }
        }
        if (!is_undefined(display_save)) {
            try {
                display_save(target);
                if (variable_global_exists("debug_mode") && global.debug_mode) show_debug_message("[SCREEN] saved (display_save) -> " + string(target));
                return target;
            } catch (e_inner) {
                display_save(fname);
                if (variable_global_exists("debug_mode") && global.debug_mode) show_debug_message("[SCREEN] saved (display_save fallback) -> " + string(fname));
                return fname;
            }
        }
        if (variable_global_exists("debug_mode") && global.debug_mode) show_debug_message("[SCREEN] no save API available");
        return noone;
    } catch (e) {
        if (variable_global_exists("debug_mode") && global.debug_mode) show_debug_message("[SCREEN] save threw: " + string(e));
        return noone;
    }
}
