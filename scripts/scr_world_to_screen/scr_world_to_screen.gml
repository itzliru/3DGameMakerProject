/// scr_world_to_screen(wx, wy, wz)
/// Projects a world-space point (wx,wy,wz) to screen coordinates using the active camera.
/// Returns [sx, sy, depth, visible]
var wx = argument0;
var wy = argument1;
var wz = argument2;

// Prefer using the GPU/view/projection matrices when available for exact results
if (variable_global_exists("fov")) {
    // Try to use the combined world-view-projection matrix
    var m = undefined;
    // matrix_world_view_projection constant should be available in modern runtimes
    try {
        m = matrix_get(matrix_world_view_projection);
    } catch (e) {
        m = undefined;
    }

    if (is_array(m) && array_length(m) >= 16) {
        // Column-major multiplication: clip = M * [wx, wy, wz, 1]
        var cx = m[0]*wx + m[4]*wy + m[8]*wz + m[12]*1;
        var cy = m[1]*wx + m[5]*wy + m[9]*wz + m[13]*1;
        var cz = m[2]*wx + m[6]*wy + m[10]*wz + m[14]*1;
        var cw = m[3]*wx + m[7]*wy + m[11]*wz + m[15]*1;

        // If point is behind camera or w is nearly zero, not visible
        if (cw == 0 || cw < 0.0001) return [0,0,cw,false];
        var nx = cx / cw; // normalized device coords (-1..1)
        var ny = cy / cw;
        var nd = cz / cw;

        var sw = display_get_width();
        var sh = display_get_height();
        var sx = (nx * 0.5 + 0.5) * sw;
        var sy = (-ny * 0.5 + 0.5) * sh; // flip Y
        return [ sx, sy, nd, true ];
    }
}

// Fallback: approximate projection using the player/camera orientation (legacy)
var cam = camera_get_active();
var cam_inst = instance_exists(obj_player) ? instance_find(obj_player, 0) : noone;
if (cam_inst == noone) {
    // no camera instance available — fall back to 2D projection
    return [ wx, wy, 1, true ];
}

var cx2 = cam_inst.x;
var cy2 = cam_inst.y;
var cz2 = cam_inst.z;
var yaw = cam_inst.direction; // degrees
var pitch = cam_inst.pitch;   // degrees

// Translate to camera space
var dx = wx - cx2;
var dy = wy - cy2;
var dz = wz - cz2;

// Rotate by -yaw around Z
var ryaw = -degtorad(yaw);
var cosy = cos(ryaw);
var siny = sin(ryaw);
var rx = dx * cosy - dy * siny;
var ry = dx * siny + dy * cosy;
var rz = dz;

// Rotate by -pitch around X (pitch: positive looks up)
var rpitch = -degtorad(pitch);
var cosp = cos(rpitch);
var sinp = sin(rpitch);
var ry2 = ry * cosp - rz * sinp;
var rz2 = ry * sinp + rz * cosp;

if (rz2 <= 0.001) return [0,0,rz2,false];

var fov = (variable_global_exists("fov") ? global.fov : 70);
var screen_w = display_get_width();
var screen_h = display_get_height();
var focal = (screen_w * 0.5) / tan(degtorad(fov * 0.5));
var sx = screen_w * 0.5 + (rx * focal) / rz2;
var sy = screen_h * 0.5 - (ry2 * focal) / rz2;
return [ sx, sy, rz2, true ];