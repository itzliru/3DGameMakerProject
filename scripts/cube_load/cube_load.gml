/// @description Load cubes from a JSON file
/// @function cube_load([filename], [clear_existing])
/// @param {string} [filename] The filename to load from (defaults to "world_blocks.json")
/// @param {bool} [clear_existing] Whether to clear existing cubes before loading (defaults to true)
/// @return {bool} Returns true if load was successful, false otherwise

function cube_load(_filename = "world_blocks.json", clear_existing = true) {
    // Check if file exists
    if (!file_exists(_filename)) {
        show_debug_message("Cannot load cubes: file not found " + string(_filename));
        return false;
    }
    
    try {
        // Read file
        var file = file_text_open_read(_filename);
        if (file < 0) {
            show_debug_message("Cannot load cubes: failed to open file " + string(_filename));
            return false;
        }
        
        var data = "";
        while (!file_text_eof(file)) {
            data += file_text_read_string(file);
            file_text_readln(file);
        }
        file_text_close(file);
        
        // Parse JSON
        var parsed = json_parse(data);
        
        if (!is_struct(parsed)) {
            show_debug_message("Cannot load cubes: invalid JSON format");
            return false;
        }
        
        // Validate data structure
        if (!variable_struct_exists(parsed, "cubes")) {
            show_debug_message("Cannot load cubes: missing 'cubes' array in save file");
            return false;
        }
        
        // Clear existing cubes if requested
        if (clear_existing) {
            if (variable_global_exists("cube_list")) {
                global.cube_list = [];
            }
            if (variable_global_exists("cube_spatial_hash")) {
                ds_map_clear(global.cube_spatial_hash);
            }
        }
        
        // Ensure globals exist
        if (!variable_global_exists("cube_list")) global.cube_list = [];
        if (!variable_global_exists("block_id")) global.block_id = 0;
        
        // Load cubes
        var loaded_cubes = parsed.cubes;
        var load_count = 0;
        
        for (var i = 0; i < array_length(loaded_cubes); i++) {
            var cube_data = loaded_cubes[i];
            
            // Validate cube data
            if (!is_struct(cube_data)) continue;
            if (!variable_struct_exists(cube_data, "x")) continue;
            if (!variable_struct_exists(cube_data, "y")) continue;
            if (!variable_struct_exists(cube_data, "z")) continue;
            
            // Add cube to list
            array_push(global.cube_list, cube_data);
            
            // Update spatial hash
            if (variable_global_exists("cube_spatial_hash")) {
                var key = string(cube_data.x) + "," + string(cube_data.y) + "," + string(cube_data.z);
                ds_map_add(global.cube_spatial_hash, key, array_length(global.cube_list) - 1);
            }
            
            // Update block_id to prevent ID conflicts
            if (variable_struct_exists(cube_data, "id") && cube_data.id >= global.block_id) {
                global.block_id = cube_data.id + 1;
            }
            
            load_count++;
        }
        
        // Display load info
        var version = variable_struct_exists(parsed, "version") ? parsed.version : "unknown";
        show_debug_message("Successfully loaded " + string(load_count) + " cubes from " + string(_filename) + " (version: " + string(version) + ")");
        
        return true;
        
    } catch (e) {
        show_debug_message("Error loading cubes: " + string(e));
        return false;
    }
}

/// @description Quick load from default location
/// @function cube_quick_load()
/// @return {bool} Returns true if load was successful, false otherwise

function cube_quick_load() {
    return cube_load("world_blocks_quicksave.json");
}
