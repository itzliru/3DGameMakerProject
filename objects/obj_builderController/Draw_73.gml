/// --- Post-Draw Event - Apply PS1 Shader to Final Scene ---

// Safety check: recreate application_surface if it doesn't exist
if (!surface_exists(application_surface)) {
    application_surface = surface_create(window_get_width(), window_get_height());
}

// Apply PS1 shader effect to the entire rendered scene
shader_set(sh_ps1_style);

// Pass screen size uniform (using cached uniform location)
shader_set_uniform_f(global.u_screen_uniform, window_get_width(), window_get_height());

// Draw the application surface with shader applied
draw_surface(application_surface, 0, 0);

// Reset shader
shader_reset();
