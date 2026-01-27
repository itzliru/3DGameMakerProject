/// ==============================
/// obj_player Step Event
if (global.paused) {
    exit;
}
// Minimal input tracking: record last Space detection time for potential features
if (keyboard_check_pressed(vk_space)) last_space_detected = current_time;
/// 3D FPS-style movement and mouse look
/// ==============================
/// ===== Add at the top of Step Event if not declared in Create Event =====
// Instance vertical velocity
if (!variable_instance_exists(id, "z_vel")) z_vel = 0;  // Vertical velocity
// Small resolver cooldown to avoid repeated snap/ping-pong when resolving overlaps
if (!variable_instance_exists(id, "resolve_cooldown")) resolve_cooldown = 0;
if (resolve_cooldown > 0) resolve_cooldown -= 1;
// Initialize instance Z-gravity once: prefer a positive value derived from global.gravity if present

if (!variable_instance_exists(id, "jump_spd")) jump_spd = 4; // Jump impulse
// Per-instance vertical speed caps (safety)
if (!variable_instance_exists(id, "max_fall_speed")) max_fall_speed = 256; // positive: max downwards speed
if (!variable_instance_exists(id, "max_rise_speed")) max_rise_speed = max(12, jump_spd * 2); // positive: max upwards speed magnitude
if (!variable_instance_exists(id, "on_ground")) on_ground = false; // Ground check
// -------- Mouse Look --------
// -------- Mouse Look --------
direction -= sensitivity * (display_mouse_get_x() - display_get_width() * 0.5);
pitch     += sensitivity * (display_mouse_get_y() - display_get_height() * 0.5); // flip sign

// Clamp vertical look
pitch = clamp(pitch, -80, 80);

// Compute mouse deltas (for debugging) and reset mouse to center
var _mouse_dx = display_mouse_get_x() - display_get_width() * 0.5;
var _mouse_dy = display_mouse_get_y() - display_get_height() * 0.5;
display_mouse_set(display_get_width() * 0.5, display_get_height() * 0.5);

// -------- Keyboard Input --------
var fb_keys = keyboard_check(ord("W")) - keyboard_check(ord("S")); // Forward/back
var rl_keys = keyboard_check(ord("A")) - keyboard_check(ord("D")); // Right/left (fixed)

// -------- Accelerate --------
fb_vel += fb_keys * acc;
rl_vel += rl_keys * acc;

// -------- Clamp Speeds --------
fb_vel = clamp(fb_vel, -max_spd, max_spd);
rl_vel = clamp(rl_vel, -max_spd, max_spd);

// -------- Deceleration / Friction --------
if (fb_keys == 0) fb_vel *= 0.9;
if (rl_keys == 0) rl_vel *= 0.9;

// -------- Translate Velocity to X/Y --------
var x_vel = lengthdir_x(fb_vel, direction) + lengthdir_x(rl_vel, direction + 90);
var y_vel = lengthdir_y(fb_vel, direction) + lengthdir_y(rl_vel, direction + 90);


/// -------- Collision Handling --------
var pw = 16;  // Player width
var pd = 16;  // Player depth
var ph = 32;  // Player height
var buf = -2;  // 2-pixel buffer

// Attempt overlap resolve (scriptized)
scr_resolve_overlap(pw, pd, ph, buf);

// X axis

// X axis
if (!place_meeting_ext(x + x_vel, y, z, par_solid, pw, pd, ph, buf)) {
    x += x_vel;
} else {
    while (!place_meeting_ext(x + sign(x_vel), y, z, par_solid, pw, pd, ph, buf)) {
        x += sign(x_vel);
    }
    x_vel = 0;
}

// Y axis
if (!place_meeting_ext(x, y + y_vel, z, par_solid, pw, pd, ph, buf)) {
    y += y_vel;
} else {
    while (!place_meeting_ext(x, y + sign(y_vel), z, par_solid, pw, pd, ph, buf)) {
        y += sign(y_vel);
    }
    y_vel = 0;
}

// Jump buffering and coyote-time (robust, works without par_solid if desired)
if (!variable_instance_exists(id, "coyote_time")) coyote_time = 6;           // frames of coyote time
if (!variable_instance_exists(id, "coyote_timer")) coyote_timer = 0;
if (!variable_instance_exists(id, "jump_buffer_time")) jump_buffer_time = 6;  // frames to buffer jump
if (!variable_instance_exists(id, "jump_buffer_timer")) jump_buffer_timer = 0;
// Jump "grace" defaults (horizontal radius in px, vertical tolerance in Z units)
// Defaults increased and allow global override via global.jump_grace_radius or global.jump_grace_vertical
if (!variable_instance_exists(id, "jump_grace_radius")) jump_grace_radius = (variable_global_exists("jump_grace_radius") ? global.jump_grace_radius : 24);
if (!variable_instance_exists(id, "jump_grace_vertical")) jump_grace_vertical = (variable_global_exists("jump_grace_vertical") ? global.jump_grace_vertical : 12);

// Early safety: clamp any wildly-out-of-range z values to a sane range before computing ground
var _z_hard_limit = (variable_global_exists("grid_size") ? global.grid_size * 128 : 64 * 128);
if (z < -_z_hard_limit || z > _z_hard_limit) {
    if (global.debug_mode) show_debug_message("[Z_INIT_CLAMP] z was " + string(z) + " -> clamped to 0 (sanity)");
    z = (variable_global_exists("ground_level") ? global.ground_level : 0);
    z_vel = 0;
}

// Compute ground_z early so jump logic can reference it
// (Simplified) Use flat global ground plane - removed grid snap and debug raycast per request
var ground_z = global.ground_level;
// Prevent snapping up to a higher grid plane while airborne: prefer the last known ground plane
if (!on_ground && variable_instance_exists(id, "prev_ground_z")) {
    // Don't allow an upward change to the ground plane while airborne
    if (ground_z > prev_ground_z) {
        ground_z = prev_ground_z;
    }
    // If the computed grid plane is at or above the player's current bottom (e.g., due to exact grid boundaries), ignore it
    var _snap_eps = 0.5; // small tolerance in Z units
    if (ground_z >= z - _snap_eps) {
        ground_z = prev_ground_z;
    }
}

// Determine if player is standing on ground (bottom z >= ground_z - epsilon)
var ground_below = (z >= ground_z - (variable_global_exists("ground_epsilon") ? global.ground_epsilon : 1));
// If not on ground, check nearby par_solid tops using the scriptized jump-grace helper
if (!ground_below) {
    if (scr_jump_grace_check()) {
        ground_below = true;
    }
}

// Jump input: support Space or 'J' as primary jump keys (fallback if Space isn't detected)
var jump_key_pressed = keyboard_check_pressed(vk_space) || keyboard_check_pressed(ord("J"));
var jump_key_held = keyboard_check(vk_space) || keyboard_check(ord("J"));
// Immediate jump only when pressed and allowed; otherwise buffer the jump (pressing in midair should buffer)
if (jump_key_pressed) {
    if (ground_below || coyote_timer > 0) {
        // immediate jump if grounded or within coyote time
        z_vel = -jump_spd;
        on_ground = false;
        jump_buffer_timer = 0;
        coyote_timer = 0;
    } else {
        // player pressed jump in midair: buffer it briefly
        if (jump_buffer_timer == 0) jump_buffer_timer = jump_buffer_time;
    }
} // Holding the key no longer repeatedly sets the buffer (prevents repeated midair triggers)

// Debug: force jump (K) to test behavior regardless of ground
if (keyboard_check_pressed(ord("K"))) {
    z_vel = -jump_spd;
} 

// ground_z computed earlier for jump logic (moved up)

// Update coyote timer using previously-computed ground_below
if (ground_below) {
    coyote_timer = coyote_time; // reset coyote timer when on ground
} else if (coyote_timer > 0) {
    coyote_timer -= 1;
}



// Countdown jump buffer
if (jump_buffer_timer > 0) jump_buffer_timer -= 1;

// Perform jump if buffered and allowed
if (jump_buffer_timer > 0) {
    var grid_ok = true;
    var _gs = (variable_global_exists("grid_size") ? global.grid_size : 64);
    if (variable_instance_exists(id, "prev_ground_z")) {
        // Only allow buffered jump if the computed ground plane is not suspiciously far below the last known ground (avoid midair false triggers)
        grid_ok = (prev_ground_z - ground_z) <= (_gs * 0.5);
    }

    if ((ground_below && grid_ok) || coyote_timer > 0) {
        if (global.debug_mode) show_debug_message("[JUMP] triggered: ground_below=" + string(ground_below) + " grid_ok=" + string(grid_ok) + " coyote=" + string(coyote_timer) + " jump_spd=" + string(jump_spd));
        z_vel = -jump_spd;
        on_ground = false;
        jump_buffer_timer = 0;
        coyote_timer = 0;
    }
}

// Ensure basegravZ is valid each Step (keep in sync with global if present)
if (variable_global_exists("basegravZ")) {
    basegravZ = abs(global.basegravZ);
} else if (variable_instance_exists(id, "basegravZ") && basegravZ == 0) {
    basegravZ = 1; // safety fallback
    if (global.debug_mode) show_debug_message("[BASEGRAVZ] fallback applied: basegravZ was zero -> set to 1");
}



// Apply vertical acceleration (Z only)
z_vel += basegravZ;
// Clamp vertical velocity to avoid runaway values
if (!variable_instance_exists(id, "max_fall_speed")) max_fall_speed = 256;
if (!variable_instance_exists(id, "max_rise_speed")) max_rise_speed = max(16, jump_spd * 3);
z_vel = clamp(z_vel, -max_rise_speed, max_fall_speed);

// Compute next bottom
var next_bottom = z + z_vel;

// Z axis: landing on computed ground (simple landing logic)
if (z_vel > 0 && next_bottom > ground_z) {
    // Land when physics indicates an intersection with the ground plane
    z = ground_z;
    on_ground = true;
    // record last ground plane
    prev_ground_z = ground_z;
    if (!variable_instance_exists(id, "coyote_time")) coyote_time = 6;
    coyote_timer = coyote_time;
    z_vel = 0;
} else {
    // moving in air (up or down without hitting computed ground)
    z = next_bottom;
    on_ground = false;
}

// Safety clamp: prevent runaway extreme Z values from causing persistent flying
var _z_limit = (variable_global_exists("grid_size") ? global.grid_size * 256 : 64 * 256);
if (z < -_z_limit) {
    if (global.debug_mode) show_debug_message("[Z_CLAMP] z was " + string(z) + " -> clamped to -" + string(_z_limit));
    z = -_z_limit;
    z_vel = 0;
}

// Detect unexpected Y changes (debug-only): helpful to find who moved the instance
if (global.debug_mode) {
    if (!variable_instance_exists(id, "__prev_y_for_trace")) __prev_y_for_trace = y;
    var __oldy = __prev_y_for_trace;
    if (y != __oldy) {
        // Update per-instance prev state (no debug spam)
        __prev_y_for_all = y;
    }
    // Safety revert: if the player was not intentionally moving and editing_block is off, undo suspicious Y changes
    var __move_intended = (abs(x_vel) + abs(y_vel) + abs(fb_vel) + abs(rl_vel) > 0.0001) || global.editing_block;
    if (!__move_intended && y != __prev_y_for_trace) {
        y = __prev_y_for_trace;
    }
    __prev_y_for_trace = y;
}

// Debug self-test: validate fallback floor instance collision vs player
if (global.debug_mode) {
    if (variable_global_exists("fallback_floor") && instance_exists(global.fallback_floor)) {
        var ff = global.fallback_floor;
        var fw = (variable_instance_exists(ff, "width") ? ff.width : 64);
        var fl = (variable_instance_exists(ff, "length") ? ff.length : 64);
        var fh = (variable_instance_exists(ff, "height") ? ff.height : 64);
        var left = ff.x + buf;
        var right = ff.x + fw - buf;
        var front = ff.y + buf;
        var back = ff.y + fl - buf;
        var bottom = ff.z + buf;
        var top = ff.z + fh - buf;
        var pbottom = z;
        var ptop = z + ph;
        var overlap = !(x + pw <= left || x >= right || y + pd <= front || y >= back || pbottom + ph <= bottom || pbottom >= top);
        show_debug_message("[FLOOR_TEST] fallback_floor id=" + string(ff) + " overlap=" + string(overlap) + " ff_box=[" + string(left)+"," + string(right)+"," + string(front)+"," + string(back)+"," + string(bottom)+"," + string(top) + "] player_z=" + string(z) + " pbox=[" + string(x) + "," + string(x+pw) + "," + string(y) + "," + string(y+pd) + "," + string(pbottom) + "," + string(ptop) + "]");
    } else {
        show_debug_message("[FLOOR_TEST] no fallback_floor assigned or instance missing; par_solid_count=" + string(instance_number(par_solid)));
    }
}
