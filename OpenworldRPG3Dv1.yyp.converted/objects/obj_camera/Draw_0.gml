/// @description Draw the 3D world

// Clear background
if (global.render_scale_enabled) {
    // Ensure render surface exists and is valid (defensive against accidental overwrites)
    var rs_ok = false;
    try {
        rs_ok = surface_exists(global.render_surface);
    } catch (e) {
        rs_ok = false;
        if (global.debug_mode) show_debug_message("[RENDER] surface_exists threw for global.render_surface: " + string(e) + " value=" + string(global.render_surface));
        // Defensive: clear the corrupted value so we can create a proper surface
        global.render_surface = noone;
    }
    if (!rs_ok) {
        // create a new runtime surface
        global.render_surface = surface_create(global.render_width, global.render_height);
        if (global.debug_mode) show_debug_message("[RENDER] Created render_surface: " + string(global.render_surface));
    }
    // Render into our low-res surface and clear it
    scr_safe_surface_set_target(global.render_surface);
    draw_clear(c_black);

    // Startup diagnostics: log window/app-surface/display sizes for the first couple seconds to catch resize events
    if (!variable_global_exists("_startup_diag_frames")) global._startup_diag_frames = 0;
    if (!variable_global_exists("_startup_diag_prev_app_w")) { global._startup_diag_prev_app_w = -1; global._startup_diag_prev_app_h = -1; }
    if (global._startup_diag_frames < 180) {
        var winw = window_get_width(); var winh = window_get_height();
        var dispw = display_get_width(); var disph = display_get_height();
        var appw = surface_exists(application_surface) ? surface_get_width(application_surface) : -1;
        var apph = surface_exists(application_surface) ? surface_get_height(application_surface) : -1;
        if (appw != global._startup_diag_prev_app_w || apph != global._startup_diag_prev_app_h || global._startup_diag_frames < 3) {
            show_debug_message("[DIAG] frame=" + string(global._startup_diag_frames) + " WIN=" + string(winw) + "x" + string(winh) + " APP=" + string(appw) + "x" + string(apph) + " DISP=" + string(dispw) + "x" + string(disph));
            if (appw > 0 && appw < winw) show_debug_message("[DIAG] application_surface is smaller than window: app_w=" + string(appw) + " win_w=" + string(winw));
            global._startup_diag_prev_app_w = appw; global._startup_diag_prev_app_h = apph;
        }
        global._startup_diag_frames += 1;
    }
} else {
    draw_clear(c_black);
} 
// Postprocess/blit moved to the GUI-layer (obj_builderController) to ensure the world is drawn first.
// For debugging, we previously logged application_surface and window state here but it spammed the console each frame.
// The quick pre-world log is now commented out to avoid noise. Uncomment if you need to re-enable temporarily.
/*
if (global.debug_mode) {
    show_debug_message("[DEBUG] camera pre-world: app_surf_exists=" + string(surface_exists(application_surface)) + " window=" + string(window_get_width()) + "x" + string(window_get_height()));
}
*/

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

// Player info (safe lookup)
var _p = instance_exists(obj_player) ? instance_find(obj_player, 0) : noone;
var cx = 0; var cy = 0; var cz = 0; var c_dir = 0; var c_pitch = 0;
if (_p != noone) {
    cx = _p.x;
    cy = _p.y;
    // player's z is bottom/feet; compute camera height from feet using eye_offset or ph
    var eye_ofs = (variable_instance_exists(_p, "eye_offset") ? _p.eye_offset : (variable_instance_exists(_p, "ph") ? (_p.ph * 0.75) : 24));
    cz = _p.z + eye_ofs;
    c_dir = _p.direction;
    c_pitch = _p.pitch;
} else {
    // safe defaults if player not present
    cx = 0; cy = 0; cz = 0; c_dir = 0; c_pitch = 0;
}

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
// Use the actual window aspect so render-scaling (small internal surface) does not change the camera FOV/zoom.
var aspect = window_get_width() / window_get_height();
var proj = matrix_build_projection_perspective_fov(
    80,
    aspect,
    1,
    32000
);

// Apply camera
camera_set_view_mat(cam, view);
camera_set_proj_mat(cam, proj);
camera_apply(cam);

// Do NOT reset the render target here — keep the surface bound while other objects draw
// The GUI layer (obj_builderController) will call surface_reset_target() before blitting.

shader_reset(); 