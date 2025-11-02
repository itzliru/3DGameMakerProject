/// --- BuilderController Step Event ---

// --- Debug toggle ---
if (keyboard_check_pressed(vk_f1)) {
    global.debug_mode = !global.debug_mode;
}

// --- Only works in debug mode ---
if (!global.debug_mode) exit;

// --- Adjust Z plane ---
if (keyboard_check_pressed(ord("+"))) global.current_z += global.grid_size;
if (keyboard_check_pressed(ord("-"))) global.current_z -= global.grid_size;

// --- Adjust block size ---
if (keyboard_check_pressed(ord("["))) global.block_size = max(16, global.block_size - 16);
if (keyboard_check_pressed(ord("]"))) global.block_size += 16;

// --- Toggle edit mode ---
if (keyboard_check_pressed(ord("P"))) {
    global.editing_block = !global.editing_block;
}

// --- Ghost Cube Position (snap to grid under player feet) ---
if (global.editing_block) {
    var ghost_dist = 128; // distance in front of player
    var p = obj_player;

    // Forward vector from player yaw/pitch
    var dir_x = lengthdir_x(cos(degtorad(p.pitch)), p.direction);
    var dir_y = lengthdir_y(cos(degtorad(p.pitch)), p.direction);
    var dir_z = sin(degtorad(p.pitch));

    var raw_x = p.x + dir_x * ghost_dist;
    var raw_y = p.y + dir_y * ghost_dist;

    // Snap to grid
    global.ghost_x = round(raw_x / global.grid_size) * global.grid_size;
    global.ghost_y = round(raw_y / global.grid_size) * global.grid_size;
    global.ghost_z = global.current_z; // vertical position adjustable
}

// --- Place block ---
if (global.editing_block && keyboard_check_pressed(vk_enter)) {
    cube_add(global.ghost_x, global.ghost_y, global.ghost_z, global.block_size, global.block_collision);
}

// --- Remove block ---
if (keyboard_check_pressed(ord("R"))) {
    cube_remove(global.ghost_x, global.ghost_y, global.ghost_z);
}

// --- Save / Load ---
if (keyboard_check_pressed(ord("M"))) {
    if (cube_save("world_blocks.json")) {
        show_debug_message("World saved successfully!");
    }
}
if (keyboard_check_pressed(ord("L"))) {
    if (cube_load("world_blocks.json")) {
        show_debug_message("World loaded successfully!");
    }
}

// --- Quick Save / Load (Shift + M/L) ---
if (keyboard_check(vk_shift) && keyboard_check_pressed(ord("M"))) {
    if (cube_quick_save()) {
        show_debug_message("Quick save successful!");
    }
}
if (keyboard_check(vk_shift) && keyboard_check_pressed(ord("L"))) {
    if (cube_quick_load()) {
        show_debug_message("Quick load successful!");
    }
}
