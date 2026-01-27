sensitivity = 0.1 //Mouse movement
max_spd = 2; //speed of character
acc = 0.1; //acelleration

fb_vel = 0; //forwards and backwards velocity
rl_vel = 0; //right and left
z_vel = 0;
// Ensure z exists (player bottom) before using it
if (!variable_instance_exists(id, "z")) z = 0;
// Initialize instance basegravZ early (prefer a positive magnitude from global.basegravZ)
if (!variable_instance_exists(id, "basegravZ")) {
    if (variable_global_exists("basegravZ")) basegravZ = abs(global.basegravZ);
    else basegravZ = 1;
    
} 

if (!variable_instance_exists(id, "jump_spd") || jump_spd <= 0) {
    // Prefer a global tuning value if present; clamp to a sensible gameplay range
    jump_spd = (variable_global_exists("player_jump_strength") ? global.player_jump_strength : 8);
    jump_spd = clamp(jump_spd, 2, 32);
} // default jump impulse

// Physical extents (used by collision code)
if (!variable_instance_exists(id, "pw")) pw = 16;
if (!variable_instance_exists(id, "pd")) pd = 16;
if (!variable_instance_exists(id, "ph")) ph = 32; // player height
if (!variable_instance_exists(id, "buf")) buf = -2;  // collision buffer

// Ensure z represents the player's bottom (feet). Snap to grid-based ground if possible.
if (asset_get_index("scr_compute_ground_from_grid") != -1) {
    // assume initial z is centre or arbitrary; use current z as start and compute bottom aligned to grid
    var start_z = z;
    var snapped = scr_compute_ground_from_grid(start_z, (variable_global_exists("grid_size") ? global.grid_size : 64), "floor");
    z = snapped; // set player's bottom
    on_ground = true;
    // record the last known ground plane so we don't accidentally snap up while airborne
    prev_ground_z = z;
    // eye offset from feet to camera (e.g., 75% of player height)
    eye_offset = ph * 0.75;
} else {
    // fallback
    if (!variable_instance_exists(id, "z")) z = 0;
    on_ground = true;
}

pitch = 0;
          
up_vel = 0;    

gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
// obj_player Create
direction = 0; // yaw (rotation around Z+)
pitch = 0;     // looking up/down
