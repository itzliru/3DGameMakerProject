/// par_solid - Draw Event
// Enable PS1 shader
shader_set(sh_ps1_style);

// Draw the sprite with 64x64 math
draw_sprite(spr_blockOther, 0, x, y);

// Reset shader
shader_reset();

// Get block texture
var tex = sprite_get_texture(spr_block, 0);

// Draw cube 64x64x64 (width, length, height)
d3d_draw_block(
    x, y, z,           // bottom corner
    x + 64, y + 64, z + 64, // top corner
    tex, 1
);

// Optional fog/lighting (if you want it):
var cam_x = obj_player.x;
var cam_y = obj_player.y;
var cam_z = obj_player.z + obj_player.height;

var block_x = x + 64;
var block_y = y + 64;
var block_z = z + 64;

var dist = point_distance_3d(cam_x, cam_y, cam_z, block_x, block_y, block_z);
var fog_factor = clamp(1 - exp(-dist * global.fog_density), 0, 1);

var r = color_get_red(global.ambient_light);
var g = color_get_green(global.ambient_light);
var b = color_get_blue(global.ambient_light);

var final_color = merge_color(make_color_rgb(r, g, b), global.fog_color, fog_factor);
draw_set_color(final_color);

