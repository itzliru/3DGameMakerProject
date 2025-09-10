
// Cube data
//global.cube_mesh = undefined; // will store the cube mesh template
//global.cube_list = [];        // stores all placed cubes
//global.grid_size = 64;        // cube size (64x64x64)

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

global.ui_healthbar_enabled = true;
global.ui_ammo_counter_enabled = true;
global.ui_minimap_enabled = false;

global.master_volume = 1;      // 0 to 1
global.music_volume = 0.8;
global.sfx_volume = 1;

global.debug_mode = true;
global.show_fps = true;
global.show_collision = false;
