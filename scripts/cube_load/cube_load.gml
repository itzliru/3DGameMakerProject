/// cube_load(filename)
function cube_load(_filename) {
    if (is_undefined(_filename) || _filename == undefined || _filename == "") _filename = "cubes.json";

    if (file_exists(_filename)) {
    var file = file_text_open_read(_filename);
    var data = "";
    while (!file_text_eof(file)) {
        data += file_text_read_string(file);
        file_text_readln(file);
    }
    file_text_close(file);

    var parsed = json_decode(data);

    // Accept either a struct with `cubes` or a ds_map with key "cubes"
    var in_list = undefined;
    if (is_struct(parsed) && variable_struct_exists(parsed, "cubes")) {
        in_list = parsed.cubes;
    } else if (is_real(parsed) && ds_map_exists(parsed, "cubes")) {
        in_list = ds_map_find_value(parsed, "cubes");
    }

    if (in_list != undefined) {
        // Validate and normalise loaded cubes to avoid runtime errors
        var out_list = [];
        var dropped = 0;
        for (var i = 0; i < array_length(in_list); i++) {
            var c = in_list[i];
            if (!is_struct(c)) { dropped++; continue; }
            if (!variable_struct_exists(c, "x") || !variable_struct_exists(c, "y") || !variable_struct_exists(c, "z")) { dropped++; continue; }
            var sx = is_real(c.x) ? c.x : real(c.x);
            var sy = is_real(c.y) ? c.y : real(c.y);
            var sz = is_real(c.z) ? c.z : real(c.z);
            var ssize = (variable_struct_exists(c, "size") && is_real(c.size)) ? c.size : (variable_global_exists("grid_size") ? global.grid_size : 64);
            if (ssize <= 0) { dropped++; continue; }

            var cube = {
                id: variable_struct_exists(c, "id") ? c.id : -1,
                x: sx,
                y: sy,
                z: sz,
                size: ssize,
                collision: variable_struct_exists(c, "collision") ? c.collision : true,
                mask: variable_struct_exists(c, "mask") ? c.mask : { left: sx, right: sx + ssize, top: sy, bottom: sy + ssize, front: sz, back: sz + ssize }
            };
            array_push(out_list, cube);
        }
        global.cube_list = out_list;
        if (dropped > 0) show_debug_message("cube_load: dropped " + string(dropped) + " malformed entries from " + string(_filename));
    } else {
        global.cube_list = [];
    }

    show_debug_message("Cubes loaded from " + string(_filename));
}
}
