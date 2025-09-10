/// cube_save(filename)
var _filename = argument0;

// Make sure cube_list exists
if (!variable_global_exists("cube_list")) global.cube_list = [];

// Wrap cube_list in a struct so json_encode works
var data_struct = { cubes: global.cube_list };

// Encode as JSON
var data = json_encode(data_struct);

// Save to file
var file = file_text_open_write(_filename);
file_text_write_string(file, data);
file_text_close(file);

show_debug_message("Cubes saved to " + string(_filename));
