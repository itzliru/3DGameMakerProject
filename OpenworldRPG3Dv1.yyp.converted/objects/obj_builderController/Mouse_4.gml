/// Mouse placement: cast a ray from the player/camera through the mouse and snap to grid.
var p = instance_exists(obj_player) ? instance_find(obj_player, 0) : noone;

// Safe snap helper (local, deterministic — avoids reading global.snap_to_grid during early init)
var _safe_snap = function(a, b, c, mode) {
    var _gs = variable_global_exists("grid_size") ? global.grid_size : 64;
    var ax, ay, az;
    if (is_array(a)) { ax = a[0]; ay = a[1]; az = a[2]; } else { ax = a; ay = b; az = c; }
    var fn = (argument_count > 3 && mode == "round") ? round : floor;
    return [ fn(ax / _gs) * _gs, fn(ay / _gs) * _gs, fn(az / _gs) * _gs ];
};

if (p == noone) {
    // fallback: center-forward placement
    var center_snap = _safe_snap([display_get_width()/2, display_get_height()/2, global.current_z], 0, 0, "floor");
    cube_add(center_snap[0], center_snap[1], center_snap[2]);
    exit;
}

// Normalized mouse offset from screen center (-1..1)
var nx = (mouse_x - display_get_width() / 2) / (display_get_width() / 2);
var ny = (mouse_y - display_get_height() / 2) / (display_get_height() / 2);
var fov = max(10, global.fov);

// Approximate world direction from camera/player using screen offset
var yaw   = p.direction + nx * (fov * 0.5);
var pitch = p.pitch   - ny * (fov * 0.5);
var max_dist = 2048;

var dir_x = lengthdir_x(cos(degtorad(pitch)), yaw);
var dir_y = lengthdir_y(cos(degtorad(pitch)), yaw);
var dir_z = sin(degtorad(pitch));

// Stepped raycast (cheap) — stop at first occupied cell and place at previous free cell
var step = max(4, (variable_global_exists("grid_size") ? global.grid_size : 64) / 4);
var hit = false;
var lastx = p.x; var lasty = p.y; var lastz = p.z;
for (var d = step; d <= max_dist; d += step) {
    var sx = p.x + dir_x * d;
    var sy = p.y + dir_y * d;
    var sz = p.z + dir_z * d;

    var snap = _safe_snap([sx, sy, sz], 0, 0, "floor");
    var _blocked = false;
    var _blocked_tmp = false;
    try {
        _blocked_tmp = cube_collision_check(snap[0], snap[1], snap[2], global.block_size, global.block_size, global.block_size, par_solid, 0);
    } catch (e) {
        _blocked_tmp = false;
    }
    _blocked = _blocked_tmp;
    if (_blocked) {
        hit = true;
        break;
    }
    lastx = sx; lasty = sy; lastz = sz;
}

var place_pos = hit ? _safe_snap([lastx, lasty, lastz], 0, 0, "floor") : _safe_snap([p.x + dir_x * min(max_dist, 512), p.y + dir_y * min(max_dist, 512), p.z + dir_z * min(max_dist, 512)], 0, 0, "floor");

// Attempt to place (cube_add will refuse overlapping placements)
var res = cube_add(place_pos[0], place_pos[1], place_pos[2], global.block_size, global.block_collision);
if (res == -1) show_debug_message("Mouse placement blocked at " + string(place_pos)); else show_debug_message("Placed cube id=" + string(res));
