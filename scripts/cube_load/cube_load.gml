/// cube_load(filename)
var _filename = argument0;

if (file_exists(_filename)) {
    var file = file_text_open_read(_filename);
    var data = "";
    while (!file_text_eof(file)) {
        data += file_text_read_string(file);
        file_text_readln(file);
    }
    file_text_close(file);

    var parsed = json_decode(data);

    if (is_struct(parsed) && variable_struct_exists(parsed, "cubes")) {
        global.cube_list = parsed.cubes;
    } else {
        global.cube_list = [];
    }

    show_debug_message("Cubes loaded from " + string(_filename));
}
