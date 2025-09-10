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
/// Draw 3D billboard or HUD device

/// Draw Event: 3D world billboard
// Draw event of obj_waveform_device
if (!held_by_player) {
    if (sprite_exists(sprite_index)) {
        // Billboarded sprite: ignore Z for now, simple facing camera
        draw_sprite_ext(sprite_index, 0, x, y, 1, 1, 0, c_white, 1);
    }
}
