/// --- PS1 Shader Pass ---
var __shader_was_set = false;
if (asset_get_index("sh_ps1_post") != -1) {
    shader_set(sh_ps1_post);
    __shader_was_set = true;
    var u_screen = shader_get_uniform(sh_ps1_post, "u_ScreenSize");
    shader_set_uniform_f(u_screen, display_get_width(), display_get_height());
} else if (asset_get_index("sh_ps1_style") != -1) {
    shader_set(sh_ps1_style);
    __shader_was_set = true;
    var u_screen = shader_get_uniform(sh_ps1_style, "u_ScreenSize");
    shader_set_uniform_f(u_screen, display_get_width(), display_get_height());
} else {
    show_debug_message("Warning: no PS1 postprocess shader found (sh_ps1_post/sh_ps1_style) — skipping postprocess");
}

draw_surface(application_surface, 0, 0);
if (__shader_was_set) shader_reset();

// --- Only draw debug tools in debug mode ---
if (!global.debug_mode) exit;

// --- 3D Grid on floor (Z=0) ---
//draw_set_color(c_ltgray);
//for (var i = 0; i < room_width; i += global.grid_size) {
  //  for (var j = 0; j < room_height; j += global.grid_size) {
   //     d3d_draw_block(i, j, 0, i + 1, j + 1, 1, -1, 1); // thin lines
   // }
//}
if (global.debug_mode) {
    draw_set_color(c_ltgray);
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
