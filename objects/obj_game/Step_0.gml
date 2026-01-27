/// @description Insert description here
// You can write your code in this editor
// Toggle pause with ESC
if (keyboard_check_pressed(vk_f2)) {
    global.paused = !global.paused;
    global.is_paused = global.paused;
}

// Debug: global input and focus check (helps diagnose Space not registering)
if (global.debug_mode) {
    var __space_p = keyboard_check_pressed(vk_space);
    var __space_h = keyboard_check(vk_space);
    var __has_focus = true;
    try { __has_focus = window_has_focus(); } catch (e) { __has_focus = true; }
    if (__space_p || __space_h || !__has_focus) {
        show_debug_message("[SYS-INPUT] space_pressed=" + string(__space_p) + " space_held=" + string(__space_h) + " window_has_focus=" + string(__has_focus));
    }

}

// Debug toggles (always available)
if (keyboard_check_pressed(ord("["))) global.show_fps = !global.show_fps;
if (keyboard_check_pressed(ord("]"))) global.show_collision = !global.show_collision;

// Inventory hotkeys / scroll
if (mouse_wheel_up()) { if (is_callable(prev_device)) prev_device(); }
if (mouse_wheel_down()) { if (is_callable(next_device)) next_device(); }
for (var _k = 0; _k < min(global.max_inventory_slots, 5); _k++) {
    if (keyboard_check_pressed(ord(string(_k+1)))) {
        global.inventory_index = _k;
        var dev = global.player_inventory[_k];
        if (dev != noone && is_callable(pick_up_device)) pick_up_device(dev, instance_exists(obj_player) ? instance_find(obj_player,0) : noone);
    }
} 

// Stop game updates if paused
if (global.paused) {
    exit; // cancels the rest of this Step event
}

// World time (advance when running)
if (!global.paused && !global.is_game_over) {
    global.world_time += 1;
    if (global.world_time >= global.day_length) global.world_time = 0;
}

// Periodic cleanup: every 120 ticks (approx 2s) sanitize inventory and other transient lists
if (current_time mod 2000 < 50) {
    // Guarded call: ensure the device-manager script asset exists and the cleanup function is defined
    if (asset_get_index("scr_device_manager") != -1 && !is_undefined(cleanup_inventory)) {
        cleanup_inventory();
    }
}

// Window enforcement removed: this retry logic was causing a startup offset/black strip in some runner configurations. If needed, we can reintroduce a safer, optional mechanism behind a user toggle.

// Hotkey: F11 - toggle borderless/fullscreen test (useful to check whether the black bar goes away in borderless mode)
if (keyboard_check_pressed(vk_f11)) {
    global._window_borderless_test = !global._window_borderless_test;
    // Prefer borderless when available, otherwise try fullscreen, else log
    try {
        if (!is_undefined(window_set_borderless)) {
            window_set_borderless(global._window_borderless_test);
            window_set_size(display_get_width(), display_get_height());
            window_set_position(0, 0);
            show_debug_message("[WINDOW] borderless test -> " + string(global._window_borderless_test));
        } else if (!is_undefined(window_set_fullscreen)) {
            window_set_fullscreen(global._window_borderless_test);
            show_debug_message("[WINDOW] fullscreen test -> " + string(global._window_borderless_test));
        } else {
            show_debug_message("[WINDOW] borderless/fullscreen APIs not available in this runtime");
        }
    } catch (e) {
        show_debug_message("[WINDOW] borderless/fullscreen toggle threw: " + string(e));
    }
}

// Manual blit nudging: '[' / ']' adjust X offset, ';' / '\'' adjust Y offset (debug-only)
if (global.debug_mode) {
    if (!variable_global_exists("_blit_offset_x")) global._blit_offset_x = 0;
    if (!variable_global_exists("_blit_offset_y")) global._blit_offset_y = 0;

    if (keyboard_check_pressed(ord("["))) {
        global._blit_offset_x -= 8;
        show_debug_message("[BLIT] offset_x -> " + string(global._blit_offset_x));
    }
    if (keyboard_check_pressed(ord("]"))) {
        global._blit_offset_x += 8;
        show_debug_message("[BLIT] offset_x -> " + string(global._blit_offset_x));
    }
    if (keyboard_check_pressed(ord(";"))) {
        global._blit_offset_y -= 8;
        show_debug_message("[BLIT] offset_y -> " + string(global._blit_offset_y));
    }
    if (keyboard_check_pressed(ord("'"))) {
        global._blit_offset_y += 8;
        show_debug_message("[BLIT] offset_y -> " + string(global._blit_offset_y));
    }
}

// Debug: list placed devices (press F3)
if (keyboard_check_pressed(vk_f3) && global.debug_mode) {
    var cnt = instance_number(obj_waveform_device);
    show_debug_message("[DEBUG] obj_waveform_device instances: " + string(cnt));
    with (obj_waveform_device) {
        var proj = (asset_get_index("scr_world_to_screen") != -1) ? scr_world_to_screen(x,y,z) : [x,y,z,true];
        show_debug_message("  id=" + string(id) + " layer=" + string(layer) + " depth=" + string(depth) + " x,y,z=" + string(x) + "," + string(y) + "," + string(z) + " proj_ok=" + string(proj[3]) + " sprite=" + string(sprite_index) + " held=" + string(held_by_player));
    }
}

// Centralized debug hotkeys and diagnostic dispatch
if (variable_global_exists("debug_mode") && global.debug_mode) {
    // handle F6/F7/F8 and related debug hotkeys
    if (global.debug_mode) {
        register_debug_hotkeys();
    }
    // call the helper dispatch for diagnostics (invokes debug_player)
    scr_helper_dispatch(HelperType.Diagnostics);
}
 
 
// Debug toggles: F4 = disable postprocess shader
if (keyboard_check_pressed(vk_f4) && global.debug_mode) {
    global.debug_disable_postprocess = !global.debug_disable_postprocess;
    show_debug_message("debug_disable_postprocess = " + string(global.debug_disable_postprocess));
}
// F5 debug toggle removed (was used to force-show billboards)
