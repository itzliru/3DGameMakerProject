/// remove_cube_by_id(id)
/// Removes the first cube with matching `id` from global.cube_list and returns true on success.
function remove_cube_by_id(_id) {
    if (!variable_global_exists("cube_list")) return false;
    for (var i = 0; i < array_length(global.cube_list); i++) {
        var c = global.cube_list[i];
        if (variable_struct_exists(c, "id") && c.id == _id) {
            array_delete(global.cube_list, i, 1);
            show_debug_message("remove_cube_by_id: removed cube id=" + string(_id) + " at index=" + string(i));
            return true;
        }
    }
    show_debug_message("remove_cube_by_id: cube id=" + string(_id) + " not found");
    return false;
}
