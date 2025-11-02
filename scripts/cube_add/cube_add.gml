/// @description Add a new cube/block to the world
/// @function cube_add(x, y, z, [size], [collision], [block_type])
/// @param {real} x The x coordinate of the cube
/// @param {real} y The y coordinate of the cube
/// @param {real} z The z coordinate of the cube
/// @param {real} [size] The size of the cube (defaults to global.grid_size or 64)
/// @param {bool} [collision] Whether the cube has collision (defaults to true)
/// @param {real} [block_type] The type/material of the block (defaults to global.current_block_type or 1)
/// @return {struct|undefined} Returns the created cube struct, or undefined if placement failed

function cube_add(_x, _y, _z, _size = undefined, _col = true, _type = undefined) {
    // Ensure globals exist
    if (!variable_global_exists("block_id")) global.block_id = 0;
    if (!variable_global_exists("cube_list")) global.cube_list = [];
    
    // Set defaults
    if (is_undefined(_size)) {
        _size = variable_global_exists("grid_size") ? global.grid_size : 64;
    }
    
    if (is_undefined(_type)) {
        _type = variable_global_exists("current_block_type") ? global.current_block_type : 1;
    }
    
    // Check if a cube already exists at this position
    var existing = cube_get_at_position(_x, _y, _z);
    if (!is_undefined(existing)) {
        show_debug_message("Cannot place cube: position already occupied at (" + string(_x) + "," + string(_y) + "," + string(_z) + ")");
        return undefined;
    }
    
    // Create cube struct
    var cube = {
        id: global.block_id,
        x: _x,
        y: _y,
        z: _z,
        size: _size,
        collision: _col,
        block_type: _type,
        color: variable_global_exists("block_colors") ? global.block_colors[_type] : c_white,
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
    var index = array_length(global.cube_list);
    array_push(global.cube_list, cube);
    
    // Update spatial hash for fast lookups
    if (variable_global_exists("cube_spatial_hash")) {
        var key = string(_x) + "," + string(_y) + "," + string(_z);
        ds_map_add(global.cube_spatial_hash, key, index);
    }
    
    // Add to undo stack
    if (variable_global_exists("cube_undo_stack")) {
        array_push(global.cube_undo_stack, {
            action: "add",
            cube: cube,
            index: index
        });
        
        // Limit undo stack size
        var max_undo = variable_global_exists("cube_max_undo") ? global.cube_max_undo : 50;
        if (array_length(global.cube_undo_stack) > max_undo) {
            array_delete(global.cube_undo_stack, 0, 1);
        }
        
        // Clear redo stack when new action is performed
        if (variable_global_exists("cube_redo_stack")) {
            global.cube_redo_stack = [];
        }
    }
    
    global.block_id++;
    
    show_debug_message("Cube placed: ID " + string(cube.id) + " at (" + string(_x) + "," + string(_y) + "," + string(_z) + ")");
    
    return cube;
}
