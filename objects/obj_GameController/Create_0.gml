// ==============================
// Player-related globals
// ==============================
global.player_health        = 100;
global.player_max_health    = 100;
global.player_shield        = 0;
global.player_speed         = 4;
global.player_jump_strength = 8;
global.player_score         = 0;
global.player_ammo          = 30;
global.player_max_ammo      = 30;
global.player_position      = [0, 0, 0]; // XYZ coords

// ==============================
// World & Environment
// ==============================

global.gravity          = -0.3;
global.world_time       = 0;
global.day_length       = 6000;   // ticks for a full cycle
global.fov              = 70;    // Field of View (3D camera)
global.render_distance  = 2000;
global.ambient_light    = c_white;

// ==============================
// Game State
// ==============================
global.current_level        = 0;
global.max_levels           = 10;
global.is_paused            = false;
global.is_game_over         = false;
global.checkpoint_position  = [0, 0, 0];

// ==============================
// UI / Display
// ==============================
global.ui_healthbar_enabled   = true;
global.ui_ammo_counter_enabled= true;
global.ui_minimap_enabled     = false;

// ==============================
// Audio
// ==============================
global.master_volume = 1;
global.music_volume  = 0.8;
global.sfx_volume    = 1;

// ==============================
// Debug / Development
// ==============================
global.debug_mode      = true;
global.show_fps        = true;
global.show_collision  = false;
