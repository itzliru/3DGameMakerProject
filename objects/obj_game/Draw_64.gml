if (global.paused) {
    draw_set_color(c_white);
    draw_set_alpha(0.8);
    draw_text(display_get_width()/2 - 50, display_get_height()/2, "PAUSED");
    draw_set_alpha(1);
}

// --- Day/Night tint & fog overlay ---
var t = (global.day_length > 0) ? (global.world_time / global.day_length) : 0;
// compute ambient brightness (smooth)
var light_value = 0.2 + 0.8 * (0.5 + 0.5 * sin(t * pi * 2));
var brightness = clamp(light_value, 0.2, 1);

// Sky tint and fog (safe defaults already in globals)
draw_set_alpha(0.25);
draw_set_color(global.ambient_light);
draw_rectangle(0, 0, display_get_width(), display_get_height(), false);
draw_set_alpha(1);

// --- Debug overlay ---
if (global.debug_mode) {
    var yy = 20;
    draw_set_color(c_white);
    draw_text(20, yy, "DEBUG MODE ON"); yy += 20;
    if (global.show_fps) { draw_text(20, yy, "FPS: " + string(fps_real)); yy += 20; }
    draw_text(20, yy, "World Time: " + string(global.world_time)); yy += 20;
    draw_text(20, yy, "Player Health: " + string(global.player_health) + "/" + string(global.player_max_health)); yy += 20;
    draw_text(20, yy, "Inventory: " + string(global.player_inventory)); yy += 20;
}

// --- Inventory HUD (bottom-left, 5 slots) ---
if (global.ui_inventory_enabled) {
    var base_x = 16;
    var base_y = display_get_height() - 96;
    var slot_w = 48;
    var slot_h = 48;
    draw_set_color(make_color_rgb(0,0,0));
    draw_set_alpha(0.45);
    draw_rectangle(base_x-8, base_y-8, base_x + (slot_w+8)*global.max_inventory_slots, base_y + slot_h + 8, true);
    draw_set_alpha(1);

    for (var i = 0; i < global.max_inventory_slots; i++) {
        var sx = base_x + i * (slot_w + 8);
        var sy = base_y;
        // slot background
        draw_set_color(i == global.inventory_index ? c_yellow : c_ltgray);
        draw_rectangle(sx, sy, sx + slot_w, sy + slot_h, false);

        var dev = global.player_inventory[i];
        if (dev != noone && instance_exists(dev)) {
            var icon = (variable_instance_exists(dev, "icon_sprite") ? dev.icon_sprite : (variable_instance_exists(dev, "sprite_index") ? dev.sprite_index : spr_device_proto));
            draw_sprite_ext(icon, 0, sx + slot_w/2, sy + slot_h/2, 0.5, 0.5, 0, c_white, 1);
        }
        draw_set_color(c_white);
        draw_text(sx + 4, sy - 12, string(i+1));
    }
}
