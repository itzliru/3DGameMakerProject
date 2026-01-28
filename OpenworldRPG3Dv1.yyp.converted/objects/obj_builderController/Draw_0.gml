/// --- PS1 Shader Pass ---
var __shader_was_set = false;

// Simplified: always blit the application surface directly. Keep postprocess shader support but remove render-surface scaling and diagnostic overlays.
if (!global.debug_disable_postprocess) {
    if (asset_get_index("sh_ps1_post") != -1) {
        shader_set(sh_ps1_post);
        __shader_was_set = true;
        var u_screen = shader_get_uniform(sh_ps1_post, "u_ScreenSize");
        shader_set_uniform_f(u_screen, display_get_width(), display_get_height());
        var u_win = shader_get_uniform(sh_ps1_post, "u_WindowSize");
        if (u_win != -1) shader_set_uniform_f(u_win, window_get_width(), window_get_height());
    } else if (asset_get_index("sh_ps1_style_post") != -1) {
        shader_set(sh_ps1_style_post);
        __shader_was_set = true;
        var u_screen = shader_get_uniform(sh_ps1_style_post, "u_ScreenSize");
        shader_set_uniform_f(u_screen, display_get_width(), display_get_height());
        var u_win = shader_get_uniform(sh_ps1_style_post, "u_WindowSize");
        if (u_win != -1) shader_set_uniform_f(u_win, window_get_width(), window_get_height());
    }
} else {
    shader_reset();
}

if (surface_exists(application_surface)) draw_surface(application_surface, 0, 0);



// Debug HUD: show shader/surface/camera state when in debug mode to help diagnose grey screen issues
if (global.debug_mode) {
    var s_shd = asset_get_index("shd_billboard");
    var s_post = asset_get_index("sh_ps1_post");
    var s_style_post = asset_get_index("sh_ps1_style_post");
    var app_surf_exists = (surface_exists(application_surface));
    var cam = camera_get_active();
    var cam_str = (cam == noone) ? "none" : string(cam);

    draw_set_color(make_color_rgb(0,0,0));
    draw_set_alpha(0.6);
    draw_rectangle(8, 8, 420, 108, true);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_text(16, 16, "SHD(shd_billboard)=" + string(s_shd));
    draw_text(16, 32, "POST(sh_ps1_post)=" + string(s_post) + " STYLE_POST=" + string(s_style_post));
    draw_text(16, 48, "application_surface_exists=" + string(app_surf_exists));
    draw_text(16, 64, "camera_active=" + cam_str);
    draw_text(16, 80, "debug_disable_postprocess=" + string(global.debug_disable_postprocess));

    // F2: scan instances to find objects with unexpectedly large Z values (helps find floating geometry)
    if (keyboard_check_pressed(vk_f3)) {
        show_debug_message("[DEBUG] Instance scan (F3): listing instances with z > 32");
        with (all) {
            if (variable_instance_exists(id, "z") && z > 32) {
                var obj_name = object_get_name(object_index);
                show_debug_message("[INST] id=" + string(id) + " obj=" + string(obj_name) + " sprite=" + string(sprite_index) + " x,y,z=" + string(x) + "," + string(y) + "," + string(z));
            }
        }
    }

    // F4: scan for instances that use the grass texture (helps find misplaced sprites)
    if (keyboard_check_pressed(vk_f4)) {
        if (sprite_exists(spr_grass)) {
            var gtex = sprite_get_texture(spr_grass, 0);
            show_debug_message("[DEBUG] Sprite scan (F4): checking instances for spr_grass texture");
            with (all) {
                // Guard against instances with no sprite (-1)
                if (sprite_exists(sprite_index)) {
                    if (sprite_index == spr_grass || sprite_get_texture(sprite_index, 0) == gtex) {
                        var pr = (asset_get_index("scr_world_to_screen") != -1) ? scr_world_to_screen(x,y,z) : [x,y,1,true];
                        show_debug_message("[SPR] id=" + string(id) + " obj=" + string(object_get_name(object_index)) + " sprite=" + string(sprite_index) + " x,y,z=" + string(x) + "," + string(y) + "," + string(z) + " proj_ok=" + string(pr[3]));
                    }
                }
            }
        } else {
            show_debug_message("[DEBUG] spr_grass not present to scan for");
        }
    }
}


if (__shader_was_set) shader_reset();

// --- Only draw debug tools in debug mode ---
if (!global.debug_mode) exit;

// --- 3D Grid on floor (Z=0) ---
draw_set_color(c_ltgray);
for (var i = 0; i < room_width; i += global.grid_size) {
    for (var j = 0; j < room_height; j += global.grid_size) {
        d3d_draw_block(i, j, 0, i + 1, j + 1, 1, -1, 1); // thin lines
   }
}
if (global.debug_mode) {
    draw_set_alpha(1);
    draw_set_color(c_white);
    var floor_z = 0; // Z plane for grid
    var grid_step = global.grid_size;

    for (var i = 0; i <= room_width; i += grid_step) {
        d3d_draw_block(i, 0, floor_z, i, room_height, floor_z); // X lines
    }
    for (var j = 0; j <= room_height; j += grid_step) {
        d3d_draw_block(0, j, floor_z, room_width, j, floor_z); // Y lines
    }
}
// --- Ghost Cube ---
if (global.editing_block) {
    var gx = global.ghost_x;
    var gy = global.ghost_y;
    var gz = global.ghost_z;
    var s  = global.block_size;
    var blocked = (variable_global_exists("ghost_blocked") ? global.ghost_blocked : false);

    // color: green if placeable, red if blocked
    draw_set_alpha(0.35);
    draw_set_color(blocked ? c_red : c_lime);
    d3d_draw_block(gx, gy, gz, gx + s, gy + s, gz + s, -1, 1);
    draw_set_alpha(1);

    // 2D outline
    draw_set_color(blocked ? c_maroon : c_green);
    draw_rectangle(gx, gy, gx + s, gy + s, false);

    // Debug info
    draw_set_color(c_white);
    draw_text(32, 32,
        "Block ID: " + string(global.block_id) +
        "  Pos: " + string(gx) + "," + string(gy) + "," + string(gz) +
        "  Size: " + string(s) +
        "  Blocked: " + string(blocked)
    );
}

// --- Draw Placed Cubes ---
if (variable_global_exists("cube_list")) {
    for (var i = 0; i < array_length(global.cube_list); i++) {
        var c = global.cube_list[i];
        if (!is_struct(c)) continue;
        if (!variable_struct_exists(c, "x") || !variable_struct_exists(c, "y") || !variable_struct_exists(c, "z") || !variable_struct_exists(c, "size")) continue;
        var cx = c.x; var cy = c.y; var cz = c.z; var cs = c.size;
        if (!is_real(cx) || !is_real(cy) || !is_real(cz) || !is_real(cs)) continue;
        d3d_draw_block(cx, cy, cz, cx + cs, cy + cs, cz + cs, -1, 1);
    }
}

// Debug demo removed per project policy (no test/demo scripts).
