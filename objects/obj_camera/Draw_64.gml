/// @description Camera UI Overlay

// Draw player position info
draw_set_color(c_white);
draw_text(32, 96, "Player Height: " + string(obj_player.z) + " | X: " + string(round(obj_player.x)) + " | Y: " + string(round(obj_player.y)));
draw_text(32, 112, "Direction: " + string(round(obj_player.direction)) + "° | Pitch: " + string(round(obj_player.pitch)) + "°");
