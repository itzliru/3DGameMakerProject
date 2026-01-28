/// cube_save(filename)
function cube_save(_filename) {
	// Make sure cube_list exists
	if (!variable_global_exists("cube_list")) global.cube_list = [];

	// Handle default filename
	if (is_undefined(_filename) || _filename == undefined || _filename == "") _filename = "cubes.json";

	// Wrap cube_list in a ds_map so older APIs/static analyzer expecting ds_map are satisfied
	var data_map = ds_map_create();
	ds_map_add(data_map, "cubes", global.cube_list);

	// Encode as JSON
	var data = json_encode(data_map);

	// Save to file
	var file = file_text_open_write(_filename);
	file_text_write_string(file, data);
	file_text_close(file);

	show_debug_message("Cubes saved to " + string(_filename));
	ds_map_destroy(data_map);
}
