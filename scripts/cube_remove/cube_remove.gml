/// @description Remove a cube/block from the world
/// @function cube_remove(x, y, z)
/// @param {real} x The x coordinate of the cube to remove
/// @param {real} y The y coordinate of the cube to remove
/// @param {real} z The z coordinate of the cube to remove
/// @return {bool} Returns true if a cube was removed, false otherwise

function cube_remove(_x, _y, _z) {
    // Ensure cube_list exists
    if (!variable_global_exists("cube_list")) {
        return false;
    }
    
    // Find the cube at this position
    var index = cube_get_index_at_position(_x, _y, _z);
    
    if (index < 0) {
        show_debug_message("Cannot remove cube: no cube found at (" + string(_x) + "," + string(_y) + "," + string(_z) + ")");
        return false;
    }
    
    // Store cube data for undo
    var removed_cube = global.cube_list[index];
    
    // Remove from spatial hash
    if (variable_global_exists("cube_spatial_hash")) {
        var key = string(_x) + "," + string(_y) + "," + string(_z);
        ds_map_delete(global.cube_spatial_hash, key);
        
        // Rebuild spatial hash indices after removal
        // (since array indices shift after deletion)
        cube_rebuild_spatial_hash();
    }
    
    // Remove from array
    array_delete(global.cube_list, index, 1);
    
    // Add to undo stack
    if (variable_global_exists("cube_undo_stack")) {
        array_push(global.cube_undo_stack, {
            action: "remove",
            cube: removed_cube,
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
    
    show_debug_message("Cube removed: ID " + string(removed_cube.id) + " from (" + string(_x) + "," + string(_y) + "," + string(_z) + ")");
    
    return true;
}

/// @description Remove a cube by its array index
/// @function cube_remove_by_index(index)
/// @param {real} index The array index of the cube to remove
/// @return {bool} Returns true if a cube was removed, false otherwise

function cube_remove_by_index(index) {
    // Ensure cube_list exists
    if (!variable_global_exists("cube_list")) {
        return false;
    }
    
    // Validate index
    if (index < 0 || index >= array_length(global.cube_list)) {
        show_debug_message("Cannot remove cube: invalid index " + string(index));
        return false;
    }
    
    var cube = global.cube_list[index];
    return cube_remove(cube.x, cube.y, cube.z);
}

/// @description Rebuild the spatial hash map after array modifications
/// @function cube_rebuild_spatial_hash()

function cube_rebuild_spatial_hash() {
    if (!variable_global_exists("cube_spatial_hash") || !variable_global_exists("cube_list")) {
        return;
    }
    
    // Clear existing hash
    ds_map_clear(global.cube_spatial_hash);
    
    // Rebuild from cube_list
    for (var i = 0; i < array_length(global.cube_list); i++) {
        var cube = global.cube_list[i];
        var key = string(cube.x) + "," + string(cube.y) + "," + string(cube.z);
        ds_map_add(global.cube_spatial_hash, key, i);
    }
}
