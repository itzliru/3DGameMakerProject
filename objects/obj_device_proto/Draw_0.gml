/// @description Insert description here
// You can write your code in this editor
/// obj_device_proto Draw Event

// Draw the sprite in 3D world
if (!held) {
    // Billboard: always faces camera
    var cam = camera_get_active();
    var cam_x = obj_player.x; // or camera position if separate
    var cam_y = obj_player.y;
    var cam_z = obj_player.z;

    var dx = x - cam_x;
    var dy = y - cam_y;

    var angle_to_cam = point_direction(0, 0, dx, dy);
    draw_sprite_ext(sprite_index, 0, x, y, 1, 1, angle_to_cam, c_white, 1);
}
var tex = sprite_get_texture(sprite_index, 0);
d3d_draw_block(
    x - 8, y - 8, z,     // bottom corner
    x + 8, y + 8, z + 2, // top corner (thin quad)
    tex, 1
);

// Draw device screen
if (surface_exists(device_screen)) {
    surface_set_target(device_screen);
    draw_clear_alpha(c_black, 0);

    // Dynamic feedback (example)
    draw_text(2, 2, "Status: OK");

    surface_reset_target();

    // Draw the mini-screen as overlay if held
   // if (held) {
    //    draw_surface(device_screen, display_get_width()/2 - screen_w/2, display_get_height()/2 - screen_h/2);


if (held) {
    var screen_x = display_get_width() - device_screen.width - 16; // 16 px padding
    var screen_y = display_get_height() - device_screen.height - 16;

    // Draw body sprite first
    draw_sprite(sprite_index, 0, screen_x - 2, screen_y - 8);

    // Draw dynamic screen
    if (surface_exists(device_screen)) {
        draw_surface(device_screen, screen_x, screen_y);
    }
}
}