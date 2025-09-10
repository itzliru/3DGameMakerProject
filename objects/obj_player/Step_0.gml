/// ==============================
/// obj_player Step Event
if (global.paused) {
    exit;
}
/// 3D FPS-style movement and mouse look
/// ==============================
/// ===== Add at the top of Step Event if not declared in Create Event =====
if (!variable_global_exists("z_vel")) z_vel = 0;  // Vertical velocity
if (!variable_global_exists("gravity")) gravity = 1; // Gravity strength
if (!variable_global_exists("jump_spd")) jump_spd = 12; // Jump impulse
if (!variable_global_exists("on_ground")) on_ground = false; // Ground check
// -------- Mouse Look --------
// -------- Mouse Look --------
direction -= sensitivity * (display_mouse_get_x() - display_get_width() * 0.5);
pitch     += sensitivity * (display_mouse_get_y() - display_get_height() * 0.5); // flip sign

// Clamp vertical look
pitch = clamp(pitch, -80, 80);

// Reset mouse to center
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

// Jump Input
if (keyboard_check_pressed(vk_space) && on_ground) {
    z_vel = -jump_spd;
    on_ground = false;
}

// Apply Gravity
z_vel += gravity;

// Z axis
if (!place_meeting_ext(x, y, z + z_vel, par_solid, pw, pd, ph, buf)) {
    z += z_vel;
    on_ground = false;
} else {
    while (!place_meeting_ext(x, y, z + sign(z_vel), par_solid, pw, pd, ph, buf)) {
        z += sign(z_vel);
    }
    if (z_vel > 0) {
        on_ground = true;
    }
    z_vel = 0;
}
