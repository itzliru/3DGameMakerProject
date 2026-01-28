/// cube_add(x, y, z, size, collision)
function cube_add(_x, _y, _z, _size, _col) {
    // Ensure globals exist
    if (!variable_global_exists("block_id")) global.block_id = 0;
    if (!variable_global_exists("cube_list")) global.cube_list = [];

    // Handle defaults
    if (is_undefined(_x)) _x = 0;
    if (is_undefined(_y)) _y = 0;
    if (is_undefined(_z)) _z = 0;
    if (is_undefined(_size)) _size = (variable_global_exists("block_size") ? global.block_size : (variable_global_exists("grid_size") ? global.grid_size : 64));
    if (is_undefined(_col)) _col = (variable_global_exists("block_collision") ? global.block_collision : true);

// Snap to grid (use floor for deterministic placement)
// Use a local, deterministic snap so we never read unsafe globals during early init.
var _gs_local = variable_global_exists("grid_size") ? global.grid_size : 64;
var _snap = [ floor(_x / _gs_local) * _gs_local, floor(_y / _gs_local) * _gs_local, floor(_z / _gs_local) * _gs_local ];

_x = _snap[0]; _y = _snap[1]; _z = _snap[2];

// Reject overlapping placement (check placed cubes AND scene geometry like par_solid)
var _collides = undefined;
// Use the `invoke` helper to call the collision checker directly (wrapped to avoid runtime faults)
_collides = false;
try {
    _collides = cube_collision_check(_x, _y, _z, _size, _size, _size, par_solid, 0);
} catch (e) {
    // collision helper unavailable at runtime -> assume no collision
    _collides = false;
}
if (is_undefined(_collides)) _collides = false;
if (_collides) {
    return -1; // placement failed due to collision
}

// Create cube struct
var cube = {
    id: global.block_id,
    x: _x,
    y: _y,
    z: _z,
    size: _size,
    collision: _col,
    mask: {
        left: _x,
        right: _x + _size,
        top: _y,
        bottom: _y + _size,
        front: _z,
        back: _z + _size
    }
};

// Store cube in list
array_push(global.cube_list, cube);
    global.block_id++;
    return cube.id;
}
