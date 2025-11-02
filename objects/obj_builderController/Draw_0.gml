/// --- Draw 3D Debug Elements (Grid and Blocks) ---

// Only draw debug tools in debug mode
if (!global.debug_mode) exit;

// --- 3D Grid on floor (Z=0) ---
//draw_set_color(c_ltgray);
//for (var i = 0; i < room_width; i += global.grid_size) {
  //  for (var j = 0; j < room_height; j += global.grid_size) {
   //     d3d_draw_block(i, j, 0, i + 1, j + 1, 1, -1, 1); // thin lines
   // }
//}
if (global.debug_mode) {
    draw_set_color(c_ltgray);
    var floor_z = 0; // Z plane for grid
    var grid_step = global.grid_size;

    for (var i = 0; i <= room_width; i += grid_step) {
        d3d_draw_block(i, 0, floor_z, i, room_height, floor_z); // X lines
    }
    for (var j = 0; j <= room_height; j += grid_step) {
        d3d_draw_block(0, j, floor_z, room_width, j, floor_z); // Y lines
    }
}
// --- Ghost Cube (3D visualization) ---
if (global.editing_block) {
    var gx = global.ghost_x;
    var gy = global.ghost_y;
    var gz = global.ghost_z;
    var s  = global.block_size;

    // Configure GPU for transparent rendering
    gpu_set_zwriteenable(false);  // Don't write to depth buffer for transparency
    gpu_set_alphatestenable(true);
    gpu_set_alphatestref(1);
    
    // Draw semi-transparent 3D ghost cube
    draw_set_alpha(0.3);
    draw_set_color(c_aqua);
    d3d_draw_block(gx, gy, gz, gx + s, gy + s, gz + s, -1, 1);
    draw_set_alpha(1);
    
    // Restore GPU settings
    gpu_set_zwriteenable(true);
    gpu_set_alphatestenable(false);

    // Optional 2D overlay rectangle on ground
    draw_set_alpha(0.4);
    draw_set_color(c_aqua);
    draw_rectangle(gx, gy, gx + s, gy + s, false);
    draw_set_alpha(1);
}

// --- Draw Placed Cubes ---
if (variable_global_exists("cube_list")) {
    for (var i = 0; i < array_length(global.cube_list); i++) {
        var c = global.cube_list[i];
        d3d_draw_block(c.x, c.y, c.z, c.x + c.size, c.y + c.size, c.z + c.size, -1, 1);
    }
}
