/// cube_add(x, y, z, size, collision)

// Ensure globals exist
if (!variable_global_exists("block_id")) global.block_id = 0;
if (!variable_global_exists("cube_list")) global.cube_list = [];

// Handle arguments safely
var _x    = argument_count > 0 ? argument0 : 0;
var _y    = argument_count > 1 ? argument1 : 0;
var _z    = argument_count > 2 ? argument2 : 0;
var _size = argument_count > 3 ? argument3 : (variable_global_exists("grid_size") ? global.grid_size : 64);
var _col  = argument_count > 4 ? argument4 : true;

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
