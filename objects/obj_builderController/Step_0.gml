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
    var p_inst = instance_exists(obj_player) ? instance_find(obj_player, 0) : noone;
    if (p_inst != noone) {
        // Forward vector from player yaw/pitch
        var dir_x = lengthdir_x(cos(degtorad(p_inst.pitch)), p_inst.direction);
        var dir_y = lengthdir_y(cos(degtorad(p_inst.pitch)), p_inst.direction);
        var dir_z = sin(degtorad(p_inst.pitch));

        var raw_x = p_inst.x + dir_x * ghost_dist;
        var raw_y = p_inst.y + dir_y * ghost_dist;
        var raw_z = p_inst.z + dir_z * ghost_dist;

        // Safe snap helper (local, deterministic — avoids reading global.snap_to_grid during early init)
        var _safe_snap = function(a, b, c, mode) {
            var _gs = variable_global_exists("grid_size") ? global.grid_size : 64;
            var ax, ay, az;
            if (is_array(a)) { ax = a[0]; ay = a[1]; az = a[2]; } else { ax = a; ay = b; az = c; }
            var fn = (argument_count > 3 && mode == "round") ? round : floor;
            return [ fn(ax / _gs) * _gs, fn(ay / _gs) * _gs, fn(az / _gs) * _gs ];
        };

        var _snap = _safe_snap([raw_x, raw_y, raw_z], 0, 0, "floor");
        global.ghost_x = _snap[0];
        global.ghost_y = _snap[1];
        global.ghost_z = _snap[2];


        // Check if placement collides (use safe invoke helper)
        var _gb = false;
        try {
            _gb = cube_collision_check(global.ghost_x, global.ghost_y, global.ghost_z, global.block_size, global.block_size, global.block_size, par_solid, 0);
        } catch (e) {
            _gb = false;
        }
        global.ghost_blocked = _gb;
    }
}

// --- Place block ---
if (global.editing_block && keyboard_check_pressed(vk_enter)) {
    if (global.ghost_blocked) {
        show_debug_message("Placement blocked at " + string(global.ghost_x) + "," + string(global.ghost_y) + "," + string(global.ghost_z));
    } else {
        var newid = cube_add(global.ghost_x, global.ghost_y, global.ghost_z, global.block_size, global.block_collision);
        if (newid == -1) show_debug_message("Failed to place cube (collision).");
        else show_debug_message("Placed cube id="+string(newid));
    }
}

// --- Remove block ---
if (keyboard_check_pressed(ord("R"))) {
    cube_remove(global.ghost_x, global.ghost_y, global.ghost_z);
}

// --- Save / Load ---
if (keyboard_check_pressed(ord("M"))) cube_save();
if (keyboard_check_pressed(ord("L"))) cube_load();
