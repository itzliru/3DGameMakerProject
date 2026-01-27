/// draw_sprite_billboard(sprite, subimage, xx, yy, zz)
/// Small helper that sets a billboard-friendly shader and places a sprite in world space by modifying the world matrix.
function draw_sprite_billboard(sprite, subimage, xx, yy, zz) {
    if (asset_get_index("shd_billboard") == -1) {
        if (global.debug_mode) show_debug_message("shd_billboard missing — cannot draw sprite billboard");
        return;
    }

    shader_set(shd_billboard);
    // Translate to world position; keep rotation/scale identity so the shader shapes the quad to face camera
    matrix_set(matrix_world, matrix_build(xx, yy, zz, 0, 0, 0, 1, 1, 1));
    // Draw sprite at origin in object space
    draw_sprite(sprite, subimage, 0, 0);
    // Reset world matrix to identity to avoid affecting other draws
    matrix_set(matrix_world, matrix_build_identity());
    shader_reset();
}