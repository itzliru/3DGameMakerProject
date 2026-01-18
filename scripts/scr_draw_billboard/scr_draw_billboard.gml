/// scr_draw_billboard(spr_or_tex, x, y, z, w = 1, h = 1, up = [0,0,1], keep_upright = true)
/// Draws a world-space camera-facing billboard using a textured quad (primitive) so it participates in 3D depth.
/// - spr_or_tex: sprite_index OR texture id (sprite preferred)
/// - x,y,z: world position
/// - w,h: size in world units
/// - up: optional up vector (array) — default [0,0,1]
/// - keep_upright: when true, billboard rotates only around the up vector (no full spherical billboarding)

var _src = argument_count > 0 ? argument0 : noone;
var _wx  = argument_count > 1 ? argument1 : 0;
var _wy  = argument_count > 2 ? argument2 : 0;
var _wz  = argument_count > 3 ? argument3 : 0;
var _w   = argument_count > 4 ? argument4 : 1;
var _h   = argument_count > 5 ? argument5 : 1;
var _up  = argument_count > 6 ? argument6 : [0,0,1];
var _upright = argument_count > 7 ? argument7 : true;

// Resolve implementation (deterministic — uses the initializer in globals.gml when available)
var _impl = "none";
if (variable_global_exists("billboard_impl")) _impl = global.billboard_impl;
else {
    // backward-compatible resolver if globals weren't available for some reason
    if (asset_get_index("scr_draw_billboard") != -1) _impl = "scr_draw_billboard";
    else if (asset_get_index("scr_draw_billboard_simple") != -1) _impl = "scr_draw_billboard_simple";
}

// Honor the user/global preference — if explicitly disabled, prefer the simple implementation
if (variable_global_exists("use_advanced_billboards") && !global.use_advanced_billboards) {
    if (asset_get_index("scr_draw_billboard_simple") != -1) {
        scr_draw_billboard_simple(_src, _wx, _wy, _wz, _w, _h);
    }
    return;
}

// If resolved to the simple implementation, call it immediately and return (no premature simple-fallbacks when advanced is available)
if (_impl == "scr_draw_billboard_simple") {
    if (asset_get_index("scr_draw_billboard_simple") != -1) {
        scr_draw_billboard_simple(_src, _wx, _wy, _wz, _w, _h);
    }
    return;
}

// If there's no viable impl, bail out silently
if (_impl == "none") return;

// From here on we expect the advanced primitive billboard implementation to be used
// (the rest of the function implements that path)}

// Validate source: accept sprite_index or texture id
var _is_sprite = sprite_exists(_src);
var _tex = -1;
if (_is_sprite) _tex = sprite_get_texture(_src, 0);
else if (is_real(_src)) _tex = _src;

// If we don't have a texture or matrix support, fall back to screen projection
if (_tex == -1) {
    if (asset_get_index("scr_draw_billboard_simple") != -1) scr_draw_billboard_simple(_src, _wx, _wy, _wz, _w, _h);
    return;
}

// Compute right/up vectors from camera
var cam_inst = instance_exists(obj_player) ? instance_find(obj_player,0) : noone;
if (cam_inst == noone) {
    // fallback to simple draw
    if (asset_get_index("scr_draw_billboard_simple") != -1) scr_draw_billboard_simple(_src, _wx, _wy, _wz, _w, _h);
    return;
}

// Camera forward vector (approx)
var yaw = degtorad(cam_inst.direction);
var pitch = degtorad(cam_inst.pitch);
var fwd_x = dcos(cam_inst.pitch) * lengthdir_x(1, cam_inst.direction);
var fwd_y = dcos(cam_inst.pitch) * lengthdir_y(1, cam_inst.direction);
var fwd_z = dsin(cam_inst.pitch);

// Up vector (world)
var upx = _up[0]; var upy = _up[1]; var upz = _up[2];

// Right = normalize(cross(fwd, up))
var rx = fwd_y * upz - fwd_z * upy;
var ry = fwd_z * upx - fwd_x * upz;
var rz = fwd_x * upy - fwd_y * upx;
var rlen = point_distance_3d(0,0,0, rx, ry, rz);
if (rlen <= 0.0001) {
    rx = 1; ry = 0; rz = 0; rlen = 1;
}
rx /= rlen; ry /= rlen; rz /= rlen;

// Recompute up = normalize(cross(right, forward)) to ensure orthogonality
var ux = ry * fwd_z - rz * fwd_y;
var uy = rz * fwd_x - rx * fwd_z;
var uz = rx * fwd_y - ry * fwd_x;
var ulen = point_distance_3d(0,0,0, ux, uy, uz);
if (ulen <= 0.0001) { ux = upx; uy = upy; uz = upz; ulen = 1; }
ux /= ulen; uy /= ulen; uz /= ulen;

// If keep_upright is requested, project right onto X/Y plane so billboard doesn't pitch with camera
if (_upright) {
    // remove vertical component from right, re-normalize, recompute up
    rx = rx; ry = ry; rz = 0;
    var r2 = point_distance_3d(0,0,0, rx, ry, 0);
    if (r2 <= 0.0001) { rx = 1; ry = 0; }
    else { rx /= r2; ry /= r2; }
    ux = -ry; uy = rx; uz = 0; // simple 2D orthogonal
}

// Half extents
var hx = _w * 0.5;
var hy = _h * 0.5;

// Four corners in world space (bottom-left, bottom-right, top-left, top-right)
var blx = _wx - rx*hx - ux*hy;
var bly = _wy - ry*hx - uy*hy;
var blz = _wz - rz*hx - uz*hy;
var brx = _wx + rx*hx - ux*hy;
var bry = _wy + ry*hx - uy*hy;
var brz = _wz + rz*hx - uz*hy;
var tlx = _wx - rx*hx + ux*hy;
var tly = _wy - ry*hx + uy*hy;
var tlz = _wz - rz*hx + uz*hy;
var trx = _wx + rx*hx + ux*hy;
var try_ = _wy + ry*hx + uy*hy;
var trz = _wz + rz*hx + uz*hy;

// Draw textured quad using primitive (participates in 3D depth)
var ok = false;
// Some targets don't expose texture_exists(); treat any non-negative numeric texture id as valid.
if (is_real(_tex) && _tex >= 0) ok = true;
else if (_is_sprite && sprite_exists(_src)) ok = true;
if (!ok) {
    if (asset_get_index("scr_draw_billboard_simple") != -1) scr_draw_billboard_simple(_src, _wx, _wy, _wz, _w, _h);
    return;
}

// Use primitive triangle strip with the texture
draw_primitive_begin_texture(pr_trianglestrip, _tex);
// bottom-left (u=0,v=1)
draw_vertex_texture(blx, bly, blz, 0, 1);
// bottom-right (u=1,v=1)
draw_vertex_texture(brx, bry, brz, 1, 1);
// top-left (u=0,v=0)
draw_vertex_texture(tlx, tly, tlz, 0, 0);
// top-right (u=1,v=0)
draw_vertex_texture(trx, try_, trz, 1, 0);
draw_primitive_end();

// Optional debug marker
if (global.debug_mode && global.debug_force_billboards) {
    var proj = (asset_get_index("scr_world_to_screen") != -1 ? scr_world_to_screen(_wx,_wy,_wz) : [_wx,_wy,1,true]);
    if (proj[3]) draw_text(proj[0], proj[1]-18, "BB:" + string(_src));
}
