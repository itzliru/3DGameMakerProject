/// @description Duplicate a cube at a new position
/// @function cube_duplicate(index, [offset_x], [offset_y], [offset_z])
/// @param {real} index The array index of the cube to duplicate
/// @param {real} [offset_x] X offset for the duplicate (defaults to grid_size)
/// @param {real} [offset_y] Y offset for the duplicate (defaults to 0)
/// @param {real} [offset_z] Z offset for the duplicate (defaults to 0)
/// @return {struct|undefined} Returns the duplicated cube struct, or undefined if duplication failed

function cube_duplicate(index, offset_x = undefined, offset_y = 0, offset_z = 0) {
    // Make sure cube_list exists
    if (!variable_global_exists("cube_list")) {
        return undefined;
    }
    
    // Validate index
    if (index < 0 || index >= array_length(global.cube_list)) {
        show_debug_message("Cannot duplicate cube: invalid index " + string(index));
        return undefined;
    }
    
    var src = global.cube_list[index];
    
    // Set default offset
    if (is_undefined(offset_x)) {
        offset_x = variable_global_exists("grid_size") ? global.grid_size : 64;
    }
    
    // Calculate new position
    var new_x = src.x + offset_x;
    var new_y = src.y + offset_y;
    var new_z = src.z + offset_z;
    
    // Use cube_add to create the duplicate (handles collision checking, spatial hash, etc.)
    var block_type = variable_struct_exists(src, "block_type") ? src.block_type : 1;
    var new_cube = cube_add(new_x, new_y, new_z, src.size, src.collision, block_type);
    
    if (!is_undefined(new_cube)) {
        show_debug_message("Cube duplicated: ID " + string(src.id) + " -> ID " + string(new_cube.id));
    }
    
    return new_cube;
}

/// @description Duplicate a cube by its position
/// @function cube_duplicate_at_position(x, y, z, [offset_x], [offset_y], [offset_z])
/// @param {real} x The x coordinate of the cube to duplicate
/// @param {real} y The y coordinate of the cube to duplicate
/// @param {real} z The z coordinate of the cube to duplicate
/// @param {real} [offset_x] X offset for the duplicate (defaults to grid_size)
/// @param {real} [offset_y] Y offset for the duplicate (defaults to 0)
/// @param {real} [offset_z] Z offset for the duplicate (defaults to 0)
/// @return {struct|undefined} Returns the duplicated cube struct, or undefined if duplication failed

function cube_duplicate_at_position(_x, _y, _z, offset_x = undefined, offset_y = 0, offset_z = 0) {
    var index = cube_get_index_at_position(_x, _y, _z);
    
    if (index < 0) {
        show_debug_message("Cannot duplicate cube: no cube found at (" + string(_x) + "," + string(_y) + "," + string(_z) + ")");
        return undefined;
    }
    
    return cube_duplicate(index, offset_x, offset_y, offset_z);
}
