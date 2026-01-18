/// @description Draw the 3D world

// Clear background
draw_clear(c_black);
// Start postprocess shader for fullscreen blit (safe: fall back if shader resource missing)
if (variable_global_exists("debug_disable_postprocess") && global.debug_disable_postprocess) {
    // DEBUG MODE: skip postprocess entirely so we can inspect raw scene
    if (global.debug_mode) show_debug_message("[DEBUG] Skipping postprocess shader (debug_disable_postprocess=true)");
} else {
    var __shader_was_set = false;
    if (asset_get_index("sh_ps1_post") != -1) {
        shader_set(sh_ps1_post);
        __shader_was_set = true;
        var u_screen = shader_get_uniform(sh_ps1_post, "u_ScreenSize");
        shader_set_uniform_f(u_screen, display_get_width(), display_get_height());
    } else if (asset_get_index("sh_ps1_style") != -1) {
        // fallback to the mesh-capable shader if the postprocess shader isn't present
        shader_set(sh_ps1_style);
        __shader_was_set = true;
        var u_screen = shader_get_uniform(sh_ps1_style, "u_ScreenSize");
        shader_set_uniform_f(u_screen, display_get_width(), display_get_height());
    } else {
        show_debug_message("Warning: no PS1 postprocess shader found (sh_ps1_post/sh_ps1_style) — skipping postprocess");
    }

    // Draw the application surface (whole scene) through the postprocess shader
draw_surface(application_surface, 0, 0);

    // Only reset shader if we set one
    if (__shader_was_set) shader_reset();
}

// Debug: log camera & application_surface state when requested
if (global.debug_mode && global.debug_disable_postprocess) {
    var cam = camera_get_active();
    show_debug_message("[DEBUG] camera_active=" + string(cam) + " app_surf_exists=" + string(surface_exists(application_surface)));
    var matw = matrix_get(matrix_world);
    show_debug_message("[DEBUG] matrix_world[0..2]=" + string(matw[0]) + "," + string(matw[1]) + "," + string(matw[2]));
}

// Reset shader

// Get active camera
var cam = camera_get_active();

// Player info
var cx     = obj_player.x;      // player x
var cy     = obj_player.y;      // player y
var cz     = obj_player.z;      // player z (make sure player has this!)
var c_dir  = obj_player.direction; // yaw (turn left/right)
var c_pitch= obj_player.pitch;     // pitch (look up/down)

// Forward vector (where the camera looks)
var dist = 1; // distance forward
var fx = dcos(c_pitch) * lengthdir_x(dist, c_dir);
var fy = dcos(c_pitch) * lengthdir_y(dist, c_dir);
var fz = dsin(c_pitch) * dist;

// View matrix
var view = matrix_build_lookat(
    cx, cy, cz,           // camera position
    cx + fx, cy + fy, cz + fz, // target point
    0, 0, 1               // up vector (Z+ is up)
);

// Projection matrix (60° FOV, near/far plane)
var proj = matrix_build_projection_perspective_fov(
    80,
    window_get_width() / window_get_height(),
    1,
    32000
);

// Apply camera
camera_set_view_mat(cam, view);
camera_set_proj_mat(cam, proj);
camera_apply(cam);
shader_reset();