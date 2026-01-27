/// scr_compute_ground_from_grid(_start_z, _grid_size, _mode)
/// Pure math helper: compute a grid-aligned ground Z below or at _start_z with no scene queries.
/// _mode: "floor" (default), "ceil", or "round" - chooses how to align to grid.
function scr_compute_ground_from_grid(_start_z, _grid_size, _mode) {
    var gs = (argument_count > 1 && is_real(_grid_size)) ? _grid_size : (variable_global_exists("grid_size") ? global.grid_size : 64);
    var mode = (argument_count > 2) ? string(_mode) : "floor";

    if (mode == "ceil") return ceil(_start_z / gs) * gs;
    else if (mode == "round") return round(_start_z / gs) * gs;
    // default floor (snap downwards)
    return floor(_start_z / gs) * gs;
}