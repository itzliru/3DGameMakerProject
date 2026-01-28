/// par_solid - Draw Event
// Draw the sprite with 64x64 math (no mesh shader — avoids vertex-layout mismatch for 2D sprite draws)
draw_sprite(spr_blockOther, 0, x, y);

// Get block texture: prefer instance `tex` (set in Create), then `spr_blockOther`, then `spr_block` as final fallback
var block_tex = -1;
if (variable_instance_exists(id, "tex")) {
    block_tex = tex;
} else if (sprite_exists(spr_blockOther)) {
    block_tex = sprite_get_texture(spr_blockOther, 0);
} else if (sprite_exists(spr_block)) {
    block_tex = sprite_get_texture(spr_block, 0);
}

// Draw cube 64x64x64 (width, length, height) using postprocess-compatible PS1 shader if available
var __ps1_was_set = false;
if (asset_get_index("sh_ps1_style_post") != -1) {
    shader_set(sh_ps1_style_post);
    __ps1_was_set = true;
    var u_screen = shader_get_uniform(sh_ps1_style_post, "u_ScreenSize");
    if (u_screen != -1) shader_set_uniform_f(u_screen, display_get_width(), display_get_height());
}

// Only draw the 3D block mesh when enabled on the instance
if (variable_instance_exists(id, "draw_3d_block") && draw_3d_block) {
    d3d_draw_block(
        x, y, z,
        x + 64, y + 64, z + 64,
        block_tex, 1
    );
}
if (__ps1_was_set) shader_reset();

// Lighting: use ambient light only
var r = color_get_red(global.ambient_light);
var g = color_get_green(global.ambient_light);
var b = color_get_blue(global.ambient_light);

draw_set_color(make_color_rgb(r, g, b));

