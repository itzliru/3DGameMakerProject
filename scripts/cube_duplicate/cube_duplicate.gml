/// cube_duplicate(index)

// Make sure cube_list exists
if (!variable_global_exists("cube_list")) {
    global.cube_list = [];
}

// Validate index
var _index = argument0;
if (array_length(global.cube_list) > _index) {
    var src = global.cube_list[_index];

    // Ensure block_id exists
    if (!variable_global_exists("block_id")) global.block_id = 0;

    var cube = {
        id: global.block_id,
        x: src.x,
        y: src.y,
        z: src.z,
        size: src.size,
        collision: src.collision,
        mask: src.mask
    };

    array_push(global.cube_list, cube);
    global.block_id++;

    return cube;
}

return undefined; // fails gracefully if index invalid
/// cube_duplicate(index)
if (array_length(global.cube_list) > index) {
    var original = global.cube_list[index];
    cube_add(original.x + global.grid_size,
             original.y,
             original.z);
}
