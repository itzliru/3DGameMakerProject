// ==============================
// World Time
// ==============================
if (!global.is_paused && !global.is_game_over) {
    global.world_time += 1; 
    if (global.world_time >= global.day_length) {
        global.world_time = 0; // loop day/night cycle
    }
}

// ==============================
// Debug Controls (toggle on/off)
// ==============================
if (keyboard_check_pressed(ord("["))) {
    global.show_fps = !global.show_fps;
}

if (keyboard_check_pressed(ord("]"))) {
    global.show_collision = !global.show_collision;
}

// Example pause toggle
if (keyboard_check_pressed(vk_escape)) {
    global.is_paused = !global.is_paused;
}
// ==============================
// Day/Night Cycle - Lighting + Sky + Fog
// ==============================

// Normalize world_time to 0..1
var t = global.world_time / global.day_length;

// Smooth cycle (0 = midnight, 0.5 = noon, 1 = midnight again)
var light_value = 0.2 + 0.2 * sin(t * pi * 2);

// Brightness for ambient light
var brightness = clamp(light_value, 0.2, 1);

// Ambient light color (white fade in/out)
global.ambient_light = make_color_rgb(
    255 * brightness,
    255 * brightness,
    255 * brightness
);

// ==============================
// Sky Color Blending
// ==============================
// Define key colors
var sky_midnight = make_color_rgb(10, 20, 40);   // deep blue
var sky_dawn     = make_color_rgb(255, 120, 60); // orange sunrise
var sky_noon     = make_color_rgb(120, 200, 255);// bright blue
var sky_dusk     = make_color_rgb(255, 100, 80); // red sunset

// Blend depending on time of day
if (t < 0.25) { // Midnight → Dawn
    var lerp_t = t / 0.25;
    global.sky_color = merge_color(sky_midnight, sky_dawn, lerp_t);
}
else if (t < 0.5) { // Dawn → Noon
    var lerp_t = (t - 0.25) / 0.25;
    global.sky_color = merge_color(sky_dawn, sky_noon, lerp_t);
}
else if (t < 0.75) { // Noon → Dusk
    var lerp_t = (t - 0.5) / 0.25;
    global.sky_color = merge_color(sky_noon, sky_dusk, lerp_t);
}
else { // Dusk → Midnight
    var lerp_t = (t - 0.75) / 0.25;
    global.sky_color = merge_color(sky_dusk, sky_midnight, lerp_t);
}

// ==============================
// Fog support removed
// ==============================
// Fog was removed project-wide to avoid postprocess interference. If you need distance fog later, reintroduce controlled logic with explicit assets and toggles.
