/// scr_draw_billboard_simple(sprite_index, x, y, z, w, h)
/// Projects a world point to screen and draws a camera-facing sprite there.
var _spr = argument0;
var _x   = argument1;
var _y   = argument2;
var _z   = argument3;
var _w   = argument4;
var _h   = argument5;

if (_spr == undefined || _x == undefined || _y == undefined || _z == undefined) exit;
if (_w == undefined) _w = 1;
if (_h == undefined) _h = 1;

// Project world -> screen (guarded: some builds may not have scr_world_to_screen available)
var proj = undefined;
if (asset_get_index("scr_world_to_screen") != -1) {
    // call the accurate projector
    proj = scr_world_to_screen(_x, _y, _z);
} else {
    // fallback: approximate projection using camera view (2D-friendly)
    var cam = camera_get_active();
    var cam_x = camera_get_view_x(cam) + camera_get_view_width(cam) * 0.5;
    var cam_y = camera_get_view_y(cam) + camera_get_view_height(cam) * 0.5;
    proj = [ _x, _y, 1, true ];
    if (!variable_global_exists("_warned_billboard_proj")) {
        show_debug_message("Warning: scr_world_to_screen missing — using fallback projection for billboards.");
        global._warned_billboard_proj = true;
    }
}
if (proj == undefined || proj[3] == false) exit; // behind camera or invalid
var sx = proj[0];
var sy = proj[1];

// Compute facing angle in screen space (optional)
var cam_inst = instance_exists(obj_player) ? instance_find(obj_player,0) : noone;
var angle = 0;
if (cam_inst != noone) {
    angle = point_direction(sx, sy, display_get_width()/2, display_get_height()/2);
}

// If a sprite resource was passed, draw it; if a texture index was passed, attempt a primitive fallback
if (sprite_exists(_spr)) {
    draw_sprite_ext(_spr, 0, sx, sy, _w, _h, angle, c_white, 1);
} else {
    // fallback: draw a small debug rectangle so designers can see the object
    draw_set_color(c_red);
    draw_rectangle(sx-4, sy-4, sx+4, sy+4, true);
    draw_set_color(c_white);
}

// Debug: show depth when debug_mode
if (global.debug_mode) {
    var _depth_str = string(round(proj[2] * 100) / 100);
    draw_text(sx+6, sy-6, _depth_str);
    if (global.debug_force_billboards) {
        // extra diagnostics: sprite texture index and screen coords
        if (sprite_exists(_spr)) show_debug_message("[DBG] billboard sprite=" + string(_spr) + " tex=" + string(sprite_get_texture(_spr,0)) + " sx=" + string(sx) + " sy=" + string(sy));
    }
}
