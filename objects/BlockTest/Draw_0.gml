// Get camera position
var cam_x = camera_get_view_x(view_camera[0]);
var cam_y = camera_get_view_y(view_camera[0]);
var cam_z = camera_get_view_z(view_camera[0]);

// Example object position
var obj_x = x;
var obj_y = y;
var obj_z = z;

// Calculate distance from camera to object
var dist = point_distance_3d(cam_x, cam_y, cam_z, obj_x, obj_y, obj_z);

// Fog factor (0 = no fog, 1 = fully fogged)
var fog_factor = clamp(1 - exp(-dist * global.fog_density), 0, 1);

// Pick base object color (could be texture average or your material color)
var base_color = c_white;

// Blend with fog color
var final_color = merge_color(base_color, global.fog_color, fog_factor);

// Apply color before drawing
draw_set_color(final_color);

// Now draw your 3D primitive/model
// Example: draw a 3D block
d3d_draw_block(
    x-16, y-16, z-16,
    x+16, y+16, z+16,
    background_get_texture(bkg_grass), 1, 1
);

// Reset color
draw_set_color(c_white);
