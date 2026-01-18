/// @description Insert description here
// You can write your code in this editor
// Toggle pause with ESC
if (keyboard_check_pressed(vk_f2)) {
    global.paused = !global.paused;
    global.is_paused = global.paused;
}

// Debug toggles (always available)
if (keyboard_check_pressed(ord("["))) global.show_fps = !global.show_fps;
if (keyboard_check_pressed(ord("]"))) global.show_collision = !global.show_collision;

// Inventory hotkeys / scroll
if (mouse_wheel_up()) { if (script_exists(prev_device)) prev_device(); }
if (mouse_wheel_down()) { if (script_exists(next_device)) next_device(); }
for (var _k = 0; _k < min(global.max_inventory_slots, 5); _k++) {
    if (keyboard_check_pressed(ord(string(_k+1)))) {
        global.inventory_index = _k;
        var dev = global.player_inventory[_k];
        if (dev != noone && script_exists(pick_up_device)) pick_up_device(dev, instance_exists(obj_player) ? instance_find(obj_player,0) : noone);
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

// Debug: list placed devices (press F3)
if (keyboard_check_pressed(vk_f3) && global.debug_mode) {
    var cnt = instance_number(obj_waveform_device);
    show_debug_message("[DEBUG] obj_waveform_device instances: " + string(cnt));
    with (obj_waveform_device) {
        var proj = (asset_get_index("scr_world_to_screen") != -1) ? scr_world_to_screen(x,y,z) : [x,y,z,true];
        show_debug_message("  id=" + string(id) + " layer=" + string(layer) + " depth=" + string(depth) + " x,y,z=" + string(x) + "," + string(y) + "," + string(z) + " proj_ok=" + string(proj[3]) + " sprite=" + string(sprite_index) + " held=" + string(held_by_player));
    }
}

// Debug toggles: F4 = disable postprocess shader, F5 = force-show billboards
if (keyboard_check_pressed(vk_f4) && global.debug_mode) {
    global.debug_disable_postprocess = !global.debug_disable_postprocess;
    show_debug_message("debug_disable_postprocess = " + string(global.debug_disable_postprocess));
}
if (keyboard_check_pressed(vk_f5) && global.debug_mode) {
    global.debug_force_billboards = !global.debug_force_billboards;
    show_debug_message("debug_force_billboards = " + string(global.debug_force_billboards));
}
