/// @description Insert description here
// You can write your code in this editor
/// obj_device_proto Step Event

// If held, follow the player
if (held && instance_exists(player_ref)) {
    // Update dynamic info
    x_pos = player_ref.x;
    y_pos = player_ref.y;
    z_pos = player_ref.z;
}

 else {
    // Ground behavior (no billboarding) 
    z = 0; // Always at floor level
}
/// Pick up device

function update_screen(dev_inst) {
    if (!surface_exists(dev_inst.device_screen)) return;

    if (asset_get_index("scr_surface_helpers") != -1) {
        scr_safe_surface_set_target(dev_inst.device_screen);
    } else {
        surface_reset_target();
        surface_set_target(dev_inst.device_screen);
    }
    draw_clear_alpha(c_black, 1); // black background

    draw_set_color(c_white);
    draw_set_font(fnt_pixel_small); // optional pixel font

    // Display coordinates
    draw_text(2, 2, "X: " + string(dev_inst.x_pos));
    draw_text(2, 12, "Y: " + string(dev_inst.y_pos));
    draw_text(2, 22, "Z: " + string(dev_inst.z_pos));

    scr_surface_reset_target();
}

