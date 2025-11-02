/// @description Set up 3D camera and view matrices

// Safety check: exit if player doesn't exist
if (!instance_exists(obj_player)) exit;

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

// Projection matrix (80° FOV, near/far plane)
var proj = matrix_build_projection_perspective_fov(
    80,
    window_get_width() / window_get_height(),
    1,
    32000
);

// Apply camera matrices
camera_set_view_mat(cam, view);
camera_set_proj_mat(cam, proj);
camera_apply(cam);