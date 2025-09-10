/// scr_draw_billboard_simple(tex, x, y, z, w, h)
var _tex = argument0;
var _x   = argument1;
var _y   = argument2;
var _z   = argument3;
var _w   = argument4;
var _h   = argument5;

// safety check
if (_tex == undefined || _x == undefined || _y == undefined || _z == undefined) exit;

if (_w == undefined) _w = 1;
if (_h == undefined) _h = 1;

// simple 2D XY-facing billboard
var cam = camera_get_active();
var cam_x = camera_get_view_x(cam);
var cam_y = camera_get_view_y(cam);

var dx = cam_x - _x;
var dy = cam_y - _y;
var angle = point_direction(0, 0, dx, dy);

draw_sprite_ext(_tex, 0, _x, _y, _w, _h, angle, c_white, 1);
