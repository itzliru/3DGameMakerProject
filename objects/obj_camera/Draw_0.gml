/// @description Draw the 3D world

// Clear background
draw_clear(c_black);
// Start shader
shader_set(sh_ps1_style);

// Pass screen size uniform (must be set every frame)
var u_screen = shader_get_uniform(sh_ps1_style, "u_ScreenSize");
shader_set_uniform_f(u_screen, display_get_width(), display_get_height());

// Draw the application surface (whole scene) through the shader
draw_surface(application_surface, 0, 0);

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