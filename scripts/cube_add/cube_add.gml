/// cube_add(x, y, z, size, collision)

// Ensure globals exist
if (!variable_global_exists("block_id")) global.block_id = 0;
if (!variable_global_exists("cube_list")) global.cube_list = [];

// Handle arguments safely
var _x    = argument_count > 0 ? argument0 : 0;
var _y    = argument_count > 1 ? argument1 : 0;
var _z    = argument_count > 2 ? argument2 : 0;
var _size = argument_count > 3 ? argument3 : (variable_global_exists("block_size") ? global.block_size : (variable_global_exists("grid_size") ? global.grid_size : 64));
var _col  = argument_count > 4 ? argument4 : (variable_global_exists("block_collision") ? global.block_collision : true);

// Snap to grid (use floor for deterministic placement)
// Use a local, deterministic snap so we never read unsafe globals during early init.
var _gs_local = variable_global_exists("grid_size") ? global.grid_size : 64;
var _snap = [ floor(_x / _gs_local) * _gs_local, floor(_y / _gs_local) * _gs_local, floor(_z / _gs_local) * _gs_local ];

_x = _snap[0]; _y = _snap[1]; _z = _snap[2];

// Reject overlapping placement (check placed cubes AND scene geometry like par_solid)
if (cube_collision_check(_x, _y, _z, _size, _size, _size, /*obj_check=*/par_solid, /*buffer=*/0)) {
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
