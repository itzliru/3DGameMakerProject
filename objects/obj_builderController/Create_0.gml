
/// --- BuilderController Create Event (Drago3D safe) ---

// Debug and editing flags
global.debug_mode       = true;
global.editing_block    = false;

// Grid and cube defaults
global.grid_size        = 64;
global.current_z        = 0;
global.block_size       = 64;
global.block_id         = 0;
global.block_collision  = true;

// Cube storage
if (!variable_global_exists("cube_list")) global.cube_list = [];

// Optional cube template (par_solid or similar)
if (!variable_global_exists("cube_mesh")) {
    // We don’t call drago3d_model_create anymore
    // We'll draw ghost and placed cubes via d3d_draw_block
    global.cube_mesh = undefined;  
}
