/// @description Insert description here
// You can write your code in this editor
/// obj_device_proto Create Event

held = false;            // Is it currently held by the player?
player_ref = noone;       // Reference to the player holding it
z = 0;                    // Ground level by default
depth = 9999;                // For sorting in 3D if needed

height = 1;
width  = 2;
length = 2;


held = false;          // Is it currently held by player?
player_ref = noone;    // Who holds it

// HUD / screen setup
screen_w = 60;
screen_h = 32;
device_screen = surface_create(screen_w, screen_h);

// Placeholder device body sprite
sprite_index = spr_device_proto; // Simple phone/calculator outline

// Device type
device_type = "Proto Device";

// Initial battery / status (placeholder)
battery = 100;
