
/// --- BuilderController Create Event (Drago3D safe) ---

// Initialize cube system (only if not already initialized)
if (!variable_global_exists("cube_list") || array_length(global.cube_list) == 0) {
    cube_init_globals();
}

// Debug and editing flags
global.debug_mode       = false;
global.editing_block    = false;

// Grid and cube defaults
global.grid_size        = 64;
global.current_z        = 0;
global.block_size       = 64;
global.block_collision  = true;

// Optional cube template (par_solid or similar)
if (!variable_global_exists("cube_mesh")) {
    // We don't call drago3d_model_create anymore
    // We'll draw ghost and placed cubes via d3d_draw_block
    global.cube_mesh = undefined;  
}

// Ghost cube position
global.ghost_x = 0;
global.ghost_y = 0;
global.ghost_z = 0;

// Cache shader uniform for performance
global.u_screen_uniform = shader_get_uniform(sh_ps1_style, "u_ScreenSize");
