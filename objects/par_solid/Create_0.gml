/// par_solid Create Event
z = 0;
// Use the project's grid size for block dimensions (fallback to 64 pixels)
var _bs = (variable_global_exists("grid_size") ? global.grid_size : 64);
height = _bs;
width  = _bs;
length = _bs;

// Assign a proper sprite texture
if (sprite_exists(spr_blockOther)) {
    tex = sprite_get_texture(spr_blockOther, 0);
} else {
    tex = -1; // fallback
}
// By default do not draw the 3D block mesh unless explicitly enabled on the instance
if (!variable_instance_exists(id, "draw_3d_block")) draw_3d_block = false;
// Create Event of par_solid

// Create a new model and store its ID

