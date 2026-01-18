/// Engine / game early-init (run as early as possible in room instance order)
// Ensure core globals exist so other objects can safely read them during Create/Step/Draw
if (!variable_global_exists("grid_size")) global.grid_size = 64;
if (!variable_global_exists("block_size")) global.block_size = global.grid_size;
if (!variable_global_exists("block_collision")) global.block_collision = true;
if (!variable_global_exists("current_z")) global.current_z = 0;
if (!variable_global_exists("debug_mode")) global.debug_mode = true;
if (!variable_global_exists("block_id")) global.block_id = 0;
if (!variable_global_exists("cube_list")) global.cube_list = [];

// Provide a guaranteed safe snap_to_grid implementation early so callers never crash
// (unconditional assignment avoids init-order/read-safety issues)
global.snap_to_grid = function(a, b, c, mode) {
    var gs = variable_global_exists("grid_size") ? global.grid_size : 64;
    var ax, ay, az;
    if (is_array(a)) { ax = a[0]; ay = a[1]; az = a[2]; } else { ax = a; ay = b; az = c; }
    var fn = (argument_count > 3 && mode == "round") ? round : floor;
    return [ fn(ax / gs) * gs, fn(ay / gs) * gs, fn(az / gs) * gs ];
};
// Mark as initialized
global._snap_initialized = true;

// Preserve existing minimal behavior
global.paused = false;
