//if (!held_by_player) {
    // 3D world billboard
  //  draw_sprite(spr_wavedevice, 0, x, y);
//}
//if (!held_by_player) {
//    var tex = sprite_get_texture(spr_wavedevice, 0);

 //   var hw = sprite_get_width(spr_wavedevice)/2;
 //   var hh = sprite_get_height(spr_wavedevice)/2;

    // Right/up vectors relative to camera
//    var right_x = 1; var right_y = 0;
//    var up_x    = 0; var up_y    = 1;

 //   draw_primitive_begin_texture(pr_trianglestrip, tex);

    // bottom-left
  //  draw_vertex_texture(x - right_x*hw - up_x*hh, y - right_y*hw - up_y*hh, 0, 1);
    // bottom-right
   // draw_vertex_texture(x + right_x*hw - up_x*hh, y + right_y*hw - up_y*hh, 1, 1);
    // top-left
   // draw_vertex_texture(x - right_x*hw + up_x*hh, y - right_y*hw + up_y*hh, 0, 0);
    // top-right
   // draw_vertex_texture(x + right_x*hw + up_x*hh, y + right_y*hw + up_y*hh, 1, 0);

   // draw_primitive_end();
//}
//draw_sprite_ext(spr_wavedevice, 0, x, y, 1, 1, direction, c_white, 1);
/// Draw device sprite / HUD marker

// Draw event for obj_waveform_device: draw the device as a 3D billboard when not held
if (!held_by_player) {
    // Prefer the new Dragonite-style billboard shader if available
    if (asset_get_index("shd_billboard") != -1 && sprite_exists(spr_wavedevice)) {
        // Defensive: ensure valid world coords
        if (is_undefined(x) || is_undefined(y) || is_undefined(z) || !is_real(x) || !is_real(y) || !is_real(z)) {
            if (global.debug_mode) show_debug_message("DBG: obj_waveform_device id=" + string(id) + " has invalid coords x=" + string(x) + " y=" + string(y) + " z=" + string(z));
        } else {
            // Draw centered at the object's world position using Z-up as the up vector
            draw_sprite_billboard(spr_wavedevice, 0, x, y, z);
        }
    } else {
        // One-time diagnostic: only warn once globally to avoid spamming the log for every instance
        if (global.debug_mode && !global._billboard_warning_logged) {
            var msg = "DBG: shd_billboard shader missing — billboards will fall back to screen-projection. Add/compile 'shd_billboard' to enable 3D billboards.";
            show_debug_message(msg);
            global._billboard_warning_logged = true;
        }
        // Safe fallback: screen-projected sprite (keeps object visible even without the shader)
        var _proj = (asset_get_index("scr_world_to_screen") != -1 ? scr_world_to_screen(x,y,z) : [x,y,1,true]);
        if (_proj[3] && sprite_exists(sprite_index)) draw_sprite_ext(sprite_index, 0, _proj[0], _proj[1], 1, 1, 0, c_white, 1);
    }
}

// Debug overlay for designers
if (global.debug_mode) {
    var proj2 = undefined;
    if (asset_get_index("scr_world_to_screen") != -1) proj2 = scr_world_to_screen(x, y, z);
    else proj2 = [x, y, 1, true];
    if (proj2[3]) draw_text(proj2[0]+8, proj2[1]-8, "wave: id=" + string(id) + " z=" + string(z));

    // Billboard debug helpers removed. For lightweight debugging, show a small magenta marker
    if (global.debug_mode) {
        draw_set_color(make_color_rgb(255,0,255));
        draw_circle(proj2[0], proj2[1], 12, false);
        draw_text(proj2[0]-8, proj2[1]-32, "DBG:" + string(id));
        draw_set_color(c_white);
    }
}
