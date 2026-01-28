/// cube_duplicate(index)
/// Duplicates a cube at `index` and returns the new cube id, or -1 on failure.

// Ensure cube_list exists
if (!variable_global_exists("cube_list")) global.cube_list = [];
if (!variable_global_exists("block_id")) global.block_id = 0;

// Validate argument
if (argument_count < 1) return -1;
var _index = argument0;
if (!is_real(_index) || _index < 0) return -1;
if (_index >= array_length(global.cube_list)) return -1;

var src = global.cube_list[_index];
if (!is_struct(src)) return -1;

// Normalise source values
var sx = (variable_struct_exists(src, "x") && is_real(src.x)) ? src.x : 0;
var sy = (variable_struct_exists(src, "y") && is_real(src.y)) ? src.y : 0;
var sz = (variable_struct_exists(src, "z") && is_real(src.z)) ? src.z : 0;
var ssize = (variable_struct_exists(src, "size") && is_real(src.size)) ? src.size : (variable_global_exists("grid_size") ? global.grid_size : 64);
var scoll = variable_struct_exists(src, "collision") ? src.collision : true;

// Create duplicated cube (keeps same size/collision)
var cube = {
    id: global.block_id,
    x: sx,
    y: sy,
    z: sz,
    size: ssize,
    collision: scoll,
    mask: { left: sx, right: sx + ssize, top: sy, bottom: sy + ssize, front: sz, back: sz + ssize }
};

array_push(global.cube_list, cube);
global.block_id++;

// Return new id
return cube.id;
