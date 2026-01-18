
// Cube data
global.cube_mesh = undefined; // will store the cube mesh template
if (!variable_global_exists("cube_list")) global.cube_list = [];
if (!variable_global_exists("grid_size")) global.grid_size = 64;
if (!variable_global_exists("block_size")) global.block_size = global.grid_size;
if (!variable_global_exists("block_collision")) global.block_collision = true;
if (!variable_global_exists("current_z")) global.current_z = 0;

// Utility: snap a position (array or components) to the world grid
global.snap_to_grid = function(a, b, c, mode) {
    var gs = global.grid_size;
    var ax, ay, az;
    if (is_array(a)) { ax = a[0]; ay = a[1]; az = a[2]; }
    else { ax = a; ay = b; az = c; }
    var m = (argument_count > 3) ? mode : "floor";
    var snapfn = (m == "round") ? round : floor;
    return [ snapfn(ax / gs) * gs, snapfn(ay / gs) * gs, snapfn(az / gs) * gs ];
};

player_health = 100;
global.player_max_health = 100;
global.player_shield = 0;          // optional if you have armor/shield
global.player_speed = 4;           // movement speed
global.player_jump_strength = 8;   // jump power
global.player_score = 0;           // points/EXP
global.player_ammo = 30;
global.player_max_ammo = 30;
global.player_position = [0,0,0];  // XYZ position in world
global.gravity = -0.3;             // gravity strength
global.world_time = 1000;             // game time tracker
global.day_length = 9000;           // ticks until day/night cycle
global.fov = 70;                   // camera field of view
global.render_distance = 2000;     // how far objects render
global.ambient_light = c_white;    // lighting tint

global.current_level = 0;
global.max_levels = 10;
global.is_paused = false;
global.is_game_over = false;
global.checkpoint_position = [0,0,0]; // last save/respawn point

// Inventory (simple scrollable slots — used by scr_device_manager)
if (!variable_global_exists("player_inventory")) global.player_inventory = array_create(5, noone);
if (!variable_global_exists("inventory_index")) global.inventory_index = 0;
if (!variable_global_exists("max_inventory_slots")) global.max_inventory_slots = 5;
if (!variable_global_exists("ui_inventory_enabled")) global.ui_inventory_enabled = true;

global.ui_healthbar_enabled = true;
global.ui_ammo_counter_enabled = true;
global.ui_minimap_enabled = false;

global.master_volume = 1;      // 0 to 1
global.music_volume = 0.8;
global.sfx_volume = 1;

global.debug_mode = true;
global.show_fps = true;
global.show_collision = false;

// Runtime debug helpers (safe defaults)
if (!variable_global_exists("debug_disable_postprocess")) global.debug_disable_postprocess = false;
if (!variable_global_exists("debug_force_billboards")) global.debug_force_billboards = false;

// Day/night defaults (safe fallbacks)
if (!variable_global_exists("world_time")) global.world_time = 0;
if (!variable_global_exists("day_length")) global.day_length = 9000;
if (!variable_global_exists("sky_color")) global.sky_color = c_black;
if (!variable_global_exists("fog_color")) global.fog_color = c_black;
if (!variable_global_exists("fog_density")) global.fog_density = 0.001;
// Billboard system toggle & tracking (use_advanced_billboards controls preference)
if (!variable_global_exists("use_advanced_billboards")) global.use_advanced_billboards = true;
if (!variable_global_exists("billboard_track_enabled")) global.billboard_track_enabled = true;
if (!variable_global_exists("_billboard_draw_count")) global._billboard_draw_count = 0; // diagnostic counter (incremented when billboards are drawn)

// Billboard implementation selector: resolved at init to avoid runtime ambiguity.
// Possible values: "scr_draw_billboard" | "scr_draw_billboard_simple" | "none"
if (!variable_global_exists("billboard_impl")) {
    if (asset_get_index("scr_draw_billboard") != -1) global.billboard_impl = "scr_draw_billboard";
    else if (asset_get_index("scr_draw_billboard_simple") != -1) global.billboard_impl = "scr_draw_billboard_simple";
    else global.billboard_impl = "none";
}

// Backwards-compatibility: if use_advanced_billboards is false, prefer the simple impl
if (global.use_advanced_billboards == false && global.billboard_impl == "scr_draw_billboard") {
    if (asset_get_index("scr_draw_billboard_simple") != -1) global.billboard_impl = "scr_draw_billboard_simple";
}