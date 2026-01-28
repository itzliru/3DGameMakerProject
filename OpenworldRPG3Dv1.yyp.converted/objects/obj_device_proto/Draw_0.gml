/// @description Insert description here
// You can write your code in this editor
/// obj_device_proto Draw Event

// Draw sprite as screen-projected overlay when not held (or if not in inventory)
var show_world = true;
if (variable_instance_exists(id, "held") && held) show_world = false;
if (variable_instance_exists(id, "held_by_player") && held_by_player) show_world = false;
if (variable_global_exists("inventory_has") && global.inventory_has(id)) show_world = false;
if (show_world) {
    var p = (asset_get_index("scr_world_to_screen") != -1) ? scr_world_to_screen(x,y,z) : [x,y,1,true];
    if (p[3] && sprite_exists(sprite_index)) draw_sprite_ext(sprite_index, 0, p[0], p[1], 1, 1, 0, c_white, 1);
}

if (sprite_exists(sprite_index)) {
    var tex = sprite_get_texture(sprite_index, 0);
    d3d_draw_block(
    x - 8, y - 8, z,     // bottom corner
    x + 8, y + 8, z + 2, // top corner (thin quad)
    tex, 1
);
}



// Draw device screen
if (surface_exists(device_screen)) {
    if (global.debug_mode) show_debug_message("[SURF] set target: device_screen (inst=" + string(id) + ") from obj_device_proto");
    scr_safe_surface_set_target(device_screen);
    draw_clear_alpha(c_black, 0);
    draw_text(2, 2, "Status: OK");


    scr_surface_reset_target();
   

    if (global.debug_mode) show_debug_message("[SURF] reset target: device_screen (inst=" + string(id) + ") from obj_device_proto");

    // Determine overlay size: prefer surface size, then instance vars, then global defaults
    var ds_w = 64;
    var ds_h = 48;
    if (surface_exists(device_screen)) {
        ds_w = surface_get_width(device_screen);
        ds_h = surface_get_height(device_screen);
    } else {
        ds_w = (variable_instance_exists(id, "screen_w") ? screen_w : (variable_global_exists("protoScreenW") ? global.protoScreenW : 64));
        ds_h = (variable_instance_exists(id, "screen_h") ? screen_h : (variable_global_exists("protoScreenH") ? global.protoScreenH : 48));
    }

    // Draw as held HUD if this device is held (either naming convention) or present in inventory
  
var is_held =
    (variable_instance_exists(id, "held") && held)
 || (variable_instance_exists(id, "held_by_player") && held_by_player)
 || (variable_global_exists("inventory_has") && global.inventory_has(id));

    if (is_held) {
        var screen_x = display_get_width() - ds_w - 16; // 16 px padding
        var screen_y = display_get_height() - ds_h - 16;
     
        // Draw body sprite first (slightly offset)
        if (sprite_exists(sprite_index)) draw_sprite(sprite_index, 0, screen_x - 2, screen_y - 8);

        // Draw dynamic screen
        if (surface_exists(device_screen)) {
            draw_surface(device_screen, screen_x, screen_y);
        }
    }
}