/// Draw GUI Event: First-person HUD device
if (held_by_player) {

    // --- HUD position in screen space ---
    var hud_x = display_get_width() - 100;  // bottom-right corner
    var hud_y = display_get_height() - 150;

    // Draw the device sprite
    draw_sprite(spr_monitor_device, 0, hud_x, hud_y);

    // --- Prepare waveform surface ---
if (!surface_exists(device_surface)) {
    device_surface = surface_create(screen_w, screen_h);
}


    if (global.debug_mode) show_debug_message("[SURF] set target: device_surface (inst=" + string(id) + ")");
    scr_safe_surface_set_target(device_surface);
    draw_clear_alpha(c_black, 0); // clear previous waveform

    // --- Draw sprite-based waveform (circular buffer) ---
    for (var i = 0; i < buffer_length; i++) {
        var idx = (waveform_index + i) mod buffer_length;
        var amp = waveform_buffer[idx];
        var frame = floor(amp * (sprite_get_number(spr_wavebar) - 1));
        draw_sprite_part(spr_wavebar, frame, 0, 0, bar_width, screen_h, i * bar_width, 0);
    }

    scr_surface_reset_target();
    if (global.debug_mode) show_debug_message("[SURF] reset target: device_surface (inst=" + string(id) + ")");

    // Draw the waveform surface inside the device screen rectangle
    draw_surface(device_surface, hud_x + screen_offset_x, hud_y + screen_offset_y);
}
/// First-person HUD device


