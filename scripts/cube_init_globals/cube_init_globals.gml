/// @description Initialize all cube/block-related global variables
/// @function cube_init_globals()
/// Call this once at game start (e.g., in obj_game Create event)

function cube_init_globals() {
    // Core cube system
    global.cube_list = [];
    global.block_id = 0;
    global.grid_size = 64;
    
    // Spatial hash for fast collision lookups
    global.cube_spatial_hash = ds_map_create();
    
    // Block types/materials
    global.block_types = {
        air: 0,
        grass: 1,
        dirt: 2,
        stone: 3,
        wood: 4,
        sand: 5,
        water: 6,
        glass: 7
    };
    
    // Block type colors (for rendering variety)
    global.block_colors = [];
    global.block_colors[global.block_types.air] = c_white;
    global.block_colors[global.block_types.grass] = make_color_rgb(34, 139, 34);
    global.block_colors[global.block_types.dirt] = make_color_rgb(139, 69, 19);
    global.block_colors[global.block_types.stone] = make_color_rgb(128, 128, 128);
    global.block_colors[global.block_types.wood] = make_color_rgb(139, 90, 43);
    global.block_colors[global.block_types.sand] = make_color_rgb(238, 214, 175);
    global.block_colors[global.block_types.water] = make_color_rgb(30, 144, 255);
    global.block_colors[global.block_types.glass] = make_color_rgb(173, 216, 230);
    
    // Undo/Redo system
    global.cube_undo_stack = [];
    global.cube_redo_stack = [];
    global.cube_max_undo = 50; // Maximum undo history
    
    // Builder settings
    global.current_block_type = global.block_types.grass;
    global.block_place_sound = true;
    global.block_remove_sound = true;
    
    show_debug_message("Cube system initialized successfully");
}
