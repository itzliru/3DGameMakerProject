/// --- Draw GUI Event - 2D Debug Overlay ---

// Only draw debug info in debug mode
if (!global.debug_mode) exit;

// Draw debug info overlay
if (global.editing_block) {
    var gx = global.ghost_x;
    var gy = global.ghost_y;
    var gz = global.ghost_z;
    var s  = global.block_size;

    draw_set_color(c_white);
    draw_set_alpha(1);
    
    draw_text(32, 32,
        "Current Block: ID " + string(global.block_id) +
        " | Pos: " + string(gx) + "," + string(gy) + "," + string(gz) +
        " | Size: " + string(s) +
        " | Collision: " + string(global.block_collision) +
        " | Grid: ON"
    );
}

// Draw block count
if (variable_global_exists("cube_list")) {
    draw_set_color(c_white);
    draw_text(32, 64, "Blocks: " + string(array_length(global.cube_list)));
}

// Draw performance stats (top-right corner)
draw_set_color(c_lime);
var stats_x = window_get_width() - 200;
draw_text(stats_x, 32, "FPS: " + string(fps));
draw_text(stats_x, 48, "Real FPS: " + string(round(fps_real)));
draw_text(stats_x, 64, "Instances: " + string(instance_count));

// Draw controls hint
draw_set_color(c_yellow);
draw_text(32, window_get_height() - 64, 
    "F1: Debug | P: Edit Mode | Enter: Place | R: Remove | +/-: Z Level | [/]: Size | M: Save | L: Load"
);
