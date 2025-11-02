/// @description Save all cubes to a JSON file
/// @function cube_save([filename])
/// @param {string} [filename] The filename to save to (defaults to "world_blocks.json")
/// @return {bool} Returns true if save was successful, false otherwise

function cube_save(_filename = "world_blocks.json") {
    // Make sure cube_list exists
    if (!variable_global_exists("cube_list")) {
        show_debug_message("Cannot save cubes: cube_list does not exist");
        return false;
    }
    
    try {
        // Create save data structure with metadata
        var data_struct = {
            version: "1.0",
            timestamp: date_current_datetime(),
            block_count: array_length(global.cube_list),
            cubes: global.cube_list
        };
        
        // Encode as JSON
        var data = json_encode(data_struct);
        
        // Save to file
        var file = file_text_open_write(_filename);
        if (file < 0) {
            show_debug_message("Cannot save cubes: failed to open file " + string(_filename));
            return false;
        }
        
        file_text_write_string(file, data);
        file_text_close(file);
        
        show_debug_message("Successfully saved " + string(array_length(global.cube_list)) + " cubes to " + string(_filename));
        return true;
        
    } catch (e) {
        show_debug_message("Error saving cubes: " + string(e));
        return false;
    }
}

/// @description Quick save to default location
/// @function cube_quick_save()
/// @return {bool} Returns true if save was successful, false otherwise

function cube_quick_save() {
    return cube_save("world_blocks_quicksave.json");
}
