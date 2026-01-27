
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
    var snapfn;
    if (m == "round") snapfn = round;
    else snapfn = floor;
    return [ snapfn(ax / gs) * gs, snapfn(ay / gs) * gs, snapfn(az / gs) * gs ];
};

//global helper map
global.helper_map = {
    helper      : scr_obj_helpers
 
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
global.basegravZ = -0.3;           // base vertical acceleration (negative or positive value accepted, interpreted as magnitude where needed) 
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

// Render scaling / pseudo-resolution (safe defaults)
// Render at a low internal resolution and stretch to the window for a PS1-style look.
if (!variable_global_exists("render_width")) global.render_width = 1920;
if (!variable_global_exists("render_height")) global.render_height = 1080;
if (!variable_global_exists("window_width")) global.window_width = 1920;
if (!variable_global_exists("window_height")) global.window_height = 1080;
// Disable render scaling by default; set true only when intentionally using low-res render scaling
if (!variable_global_exists("render_scale_enabled")) global.render_scale_enabled = false;
// Development convenience: run fullscreen at native display resolution by default for now
if (!variable_global_exists("force_fullscreen")) global.force_fullscreen = true;
if (global.force_fullscreen) {
    // Use the display resolution as the requested window size when forcing fullscreen
    global.window_width = display_get_width();
    global.window_height = display_get_height();
    // Ensure any render-scaling is disabled when running fullscreen
    global.render_scale_enabled = false;
}
if (!variable_global_exists("render_surface")) global.render_surface = noone;

// Day/night defaults (safe fallbacks)
if (!variable_global_exists("world_time")) global.world_time = 0;
if (!variable_global_exists("day_length")) global.day_length = 9000;
if (!variable_global_exists("sky_color")) global.sky_color = c_black;

// Simple global ground plane (units in world Z). Use this for games that use a flat ground.
if (!variable_global_exists("ground_level")) global.ground_level = 0; // default ground plane at Z=0 (player z is bottom)
if (!variable_global_exists("ground_epsilon")) global.ground_epsilon = 1; // tolerance when testing ground contact
// Fog support removed: fog_color/fog_density were removed to prevent screen overlays and rendering interference.
// Billboard system removed; tracking and compatibility variables removed to prepare for a single new implementation.

// Billboard selection removed — new Dragonite-style billboarder will be added as a single authoritative implementation.
// Runtime diagnostic: detect if the billboard shader is available at startup and provide one-time warnings if it is missing.
if (!variable_global_exists("billboard_shader_present")) global.billboard_shader_present = (asset_get_index("shd_billboard") != -1);
if (!variable_global_exists("_billboard_warning_logged")) global._billboard_warning_logged = false;

// Startup shader diagnostics (runs once when game boots in debug mode)
if (global.debug_mode && !variable_global_exists("_startup_shader_diag")) {
    global._startup_shader_diag = true;
    var s_shd = asset_get_index("shd_billboard");
    var s_style_post = asset_get_index("sh_ps1_style_post");
    var s_post = asset_get_index("sh_ps1_post");
    show_debug_message("[SHADERS] shd_billboard=" + string(s_shd) + " sh_ps1_style_post=" + string(s_style_post) + " sh_ps1_post=" + string(s_post));

    // If the shader exists, attempt to set it to cause any compile-time messages to surface
    if (s_shd != -1) {
        // shader_set/shader_reset may produce compile errors in the IDE console
        try {
            shader_set(shd_billboard);
            shader_reset();
            show_debug_message("[SHADERS] shd_billboard set/reset succeeded (no immediate compile errors)");
        } catch (e) {
            show_debug_message("[SHADERS] shd_billboard shader_set threw an error: " + string(e));
        }
    } else {
        show_debug_message("[SHADERS] shd_billboard not found at startup — ensure it is registered in the .yyp and present on disk");
    }
}
// Safe factory for creating a ColWorld using a spatial hash accelerator
if (!variable_global_exists("create_col_world")) {
    global.create_col_world = function(chunk_size) {
        var _cs = (argument_count > 0 && chunk_size != undefined) ? chunk_size : 128;
        if (is_undefined(ColWorld) || is_undefined(ColWorldSpatialHash)) {
            if (global.debug_mode) show_debug_message("[COL] ColWorld or ColWorldSpatialHash missing; cannot create collision world");
            return undefined;
        }
        try {
            var accel = new ColWorldSpatialHash(_cs);
            var world = new ColWorld(accel);
            if (global.debug_mode) show_debug_message("[COL] collision world created (chunk=" + string(_cs) + ")");
            return world;
        } catch (e) {
            if (global.debug_mode) show_debug_message("[COL] create_col_world error: " + string(e));
            return undefined;
        }
    };
}

/// scr_col_init_world(_chunk_size)
function scr_col_init_world(_chunk_size) {
    var _cs = (argument_count > 0 && _chunk_size != undefined) ? _chunk_size : 128;
    var w = global.create_col_world(_cs);
    if (w != undefined) {
        global.col_world = w;
    } else {
        global.col_world = undefined;
    }
}


