/// par_solid Create Event
z = 0;
height = 1;
width  = 2;
length = 2;

// Assign a proper sprite texture
if (sprite_exists(spr_blockOther)) {
    tex = sprite_get_texture(spr_blockOther, 0);
} else {
    tex = -1; // fallback
}
// Create Event of par_solid

// Create a new model and store its ID

