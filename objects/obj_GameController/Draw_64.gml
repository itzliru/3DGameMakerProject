// ==============================
// Sky Background
// ==============================
//draw_set_color(global.sky_color);
//draw_rectangle(0, 0, display_get_width(), display_get_height(), false);


// ==============================
// Debug / Development Overlay
// ==============================
if (global.debug_mode) {
    var yy = 20;
    draw_set_color(c_white);
    draw_text(20, yy, "DEBUG MODE ON"); yy += 20;
    
    if (global.show_fps) {
        draw_text(20, yy, "FPS: " + string(fps_real)); yy += 20;
    }
    
    draw_text(20, yy, "World Time: " + string(global.world_time)); yy += 20;
    draw_text(20, yy, "Player Health: " + string(global.player_health) + "/" + string(global.player_max_health)); yy += 20;
}
// ==============================
// Day/Night Tint Overlay
// ==============================
draw_set_alpha(0.5); // how strong the tint is
draw_set_color(global.ambient_light);
draw_rectangle(0, 0, display_get_width(), display_get_height(), false);
draw_set_alpha(1); // reset
