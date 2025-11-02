/// @description Find a cube at the specified position
/// @function cube_get_at_position(x, y, z)
/// @param {real} x The x coordinate to check
/// @param {real} y The y coordinate to check
/// @param {real} z The z coordinate to check
/// @return {struct|undefined} Returns the cube struct if found, undefined otherwise

function cube_get_at_position(_x, _y, _z) {
    // Ensure cube_list exists
    if (!variable_global_exists("cube_list")) {
        return undefined;
    }
    
    // Check spatial hash first if available (O(1) lookup)
    if (variable_global_exists("cube_spatial_hash")) {
        var key = string(_x) + "," + string(_y) + "," + string(_z);
        var cube_index = ds_map_find_value(global.cube_spatial_hash, key);
        
        if (!is_undefined(cube_index) && cube_index >= 0 && cube_index < array_length(global.cube_list)) {
            return global.cube_list[cube_index];
        }
    }
    
    // Fallback to linear search
    for (var i = 0; i < array_length(global.cube_list); i++) {
        var cube = global.cube_list[i];
        if (cube.x == _x && cube.y == _y && cube.z == _z) {
            return cube;
        }
    }
    
    return undefined;
}

/// @description Find the index of a cube at the specified position
/// @function cube_get_index_at_position(x, y, z)
/// @param {real} x The x coordinate to check
/// @param {real} y The y coordinate to check
/// @param {real} z The z coordinate to check
/// @return {real} Returns the array index if found, -1 otherwise

function cube_get_index_at_position(_x, _y, _z) {
    // Ensure cube_list exists
    if (!variable_global_exists("cube_list")) {
        return -1;
    }
    
    // Check spatial hash first if available
    if (variable_global_exists("cube_spatial_hash")) {
        var key = string(_x) + "," + string(_y) + "," + string(_z);
        var cube_index = ds_map_find_value(global.cube_spatial_hash, key);
        
        if (!is_undefined(cube_index) && cube_index >= 0) {
            return cube_index;
        }
    }
    
    // Fallback to linear search
    for (var i = 0; i < array_length(global.cube_list); i++) {
        var cube = global.cube_list[i];
        if (cube.x == _x && cube.y == _y && cube.z == _z) {
            return i;
        }
    }
    
    return -1;
}
