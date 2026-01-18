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
    // Resolve the billboard implementation once (uses the init-time selector when available)
    var _impl = variable_global_exists("billboard_impl") ? global.billboard_impl : (asset_get_index("scr_draw_billboard") != -1 ? "scr_draw_billboard" : (asset_get_index("scr_draw_billboard_simple") != -1 ? "scr_draw_billboard_simple" : "none"));

    // If the global preference explicitly disables advanced billboards, prefer the simple impl
    if (variable_global_exists("use_advanced_billboards") && !global.use_advanced_billboards) _impl = (asset_get_index("scr_draw_billboard_simple") != -1) ? "scr_draw_billboard_simple" : "none";

    // World-size in world units — tune as needed
    var world_w = 16;
    var world_h = 16;

    // Dispatch deterministically based on resolved impl
    if (_impl == "scr_draw_billboard") {
        if (asset_get_index("scr_draw_billboard") != -1) scr_draw_billboard(sprite_index, x, y, z, world_w, world_h, [0,0,1], true);
        else if (asset_get_index("scr_draw_billboard_simple") != -1) {
            scr_draw_billboard_simple(sprite_index, x, y, z, world_w, world_h);
            if (global.debug_mode) show_debug_message("Warning: scr_draw_billboard missing — used simple fallback");
        }
    } else if (_impl == "scr_draw_billboard_simple") {
        if (asset_get_index("scr_draw_billboard_simple") != -1) scr_draw_billboard_simple(sprite_index, x, y, z, world_w, world_h);
    } else {
        // last resort: draw the sprite directly in screen space so designers can see it
        var _proj = (asset_get_index("scr_world_to_screen") != -1 ? scr_world_to_screen(x,y,z) : [x,y,1,true]);
        if (_proj[3] && sprite_exists(sprite_index)) draw_sprite_ext(sprite_index, 0, _proj[0], _proj[1], 1, 1, 0, c_white, 1);
    }

    // tracking / diagnostics (unchanged)
    if (variable_global_exists("billboard_track_enabled") && global.billboard_track_enabled) {
        billboard_last_seen = current_time;
        if (!variable_global_exists("_billboard_draw_count")) global._billboard_draw_count = 0;
        global._billboard_draw_count += 1;
    }
}

// Debug overlay for designers
if (global.debug_mode) {
    var proj2 = undefined;
    if (asset_get_index("scr_world_to_screen") != -1) proj2 = scr_world_to_screen(x, y, z);
    else proj2 = [x, y, 1, true];
    if (proj2[3]) draw_text(proj2[0]+8, proj2[1]-8, "wave: id=" + string(id) + " z=" + string(z));

    // Force a large on-screen marker when debugging visibility issues
    if (global.debug_force_billboards) {
        // Use explicit RGB so missing color constants can't crash the Draw event
        var _mag = make_color_rgb(255,0,255);
        draw_set_color(_mag);
        draw_circle(proj2[0], proj2[1], 24, false);
        draw_text(proj2[0]-8, proj2[1]-32, "DBG:" + string(id));

        // Force-draw the sprite at screen coords (overlay) to check sampling/origin
        if (sprite_exists(sprite_index)) {
            // attempt to log texture info for debugging
            var tex_idx = sprite_get_texture(sprite_index, 0);
            if (global.debug_mode) show_debug_message("[DBG] sprite=" + string(sprite_index) + " tex_idx=" + string(tex_idx) + " w=" + string(sprite_get_width(sprite_index)) + " h=" + string(sprite_get_height(sprite_index)));
            draw_sprite_ext(sprite_index, 0, proj2[0], proj2[1], 1.5, 1.5, 0, c_white, 1);

            // Debug helper: also draw the canonical wavedevice sprite at the object's world position
            // This helps compare the screen-projected sprite origin vs. the world-space billboard.
            if (sprite_exists(spr_wavedevice)) {
                // Simple world-space draw (should always be visible at the object's origin)
                draw_sprite(spr_wavedevice, 0, x, y);

                // Explicit extents + orientation so you can compare rotation/anchor vs. the billboard
                draw_sprite_ext(spr_wavedevice, 0, x, y, 1, 1, direction, c_white, 1);

                // Helpful debug snippet (commented + available): pixel half-extents and texture id
                // var hw = sprite_get_width(spr_wavedevice)/2;
                // var hh = sprite_get_height(spr_wavedevice)/2;
                // var tex = sprite_get_texture(spr_wavedevice, 0);
            }

            // Optional: draw the sprite as a textured primitive in world-space to validate UV/origin/vertex sampling.
            // Enable by setting `global.debug_force_billboards_primitive = true` at runtime (off by default).
            if (global.debug_mode && variable_global_exists("debug_force_billboards_primitive") && global.debug_force_billboards_primitive) {
                var tex = sprite_get_texture(spr_wavedevice, 0);
                // texture_exists may not be available on all targets — treat non-negative texture ids as valid
                if ((is_real(tex) && tex >= 0) || sprite_exists(spr_wavedevice)) {
                    // Prefer the canonical 3D billboard routine (uses the correct 3D vertex overload).
                    if (asset_get_index("scr_draw_billboard") != -1) {
                        scr_draw_billboard(spr_wavedevice, x, y, z, sprite_get_width(spr_wavedevice), sprite_get_height(spr_wavedevice), [0,0,1], true);

                    // If we don't have the 3D path, project corners to screen and use the 2D textured-vertex overload (4 args)
                    } else if (asset_get_index("scr_world_to_screen") != -1) {
                        var hw = sprite_get_width(spr_wavedevice) / 2;
                        var hh = sprite_get_height(spr_wavedevice) / 2;
                        var p_tl = scr_world_to_screen(x - hw, y + hh, z);
                        var p_tr = scr_world_to_screen(x + hw, y + hh, z);
                        var p_bl = scr_world_to_screen(x - hw, y - hh, z);
                        var p_br = scr_world_to_screen(x + hw, y - hh, z);
                        if (p_tl[3] && p_tr[3] && p_bl[3] && p_br[3]) {
                            draw_primitive_begin_texture(pr_trianglestrip, tex);
                            draw_vertex_texture(p_bl[0], p_bl[1], 0, 1);
                            draw_vertex_texture(p_br[0], p_br[1], 1, 1);
                            draw_vertex_texture(p_tl[0], p_tl[1], 0, 0);
                            draw_vertex_texture(p_tr[0], p_tr[1], 1, 0);
                            draw_primitive_end();
                        }

                    } else {
                        // Last-resort fallback: 2D sprite at world origin (should be visible)
                        draw_sprite(spr_wavedevice, 0, x, y);
                    }
                }
            }
        }

        draw_set_color(c_white);

        // Also render a small 3D debug cube at the world position so we can verify depth/matrix
        // (this uses the existing 3D draw path and will be occluded by world geometry)
        d3d_draw_block_simple(x - 8, y - 8, z, x + 8, y + 8, z + 16, -1);
    }
}
