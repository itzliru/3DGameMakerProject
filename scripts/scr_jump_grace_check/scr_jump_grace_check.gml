/// scr_jump_grace_check()
/// Returns true if a nearby par_solid top is within horizontal/vertical "grace" and makes the instance consider itself on-ground.
function scr_jump_grace_check() {
    if (instance_number(par_solid) == 0) return false;

    var _gr = (variable_instance_exists(id, "jump_grace_radius") ? jump_grace_radius : (variable_global_exists("jump_grace_radius") ? global.jump_grace_radius : 24));
    var _gv = (variable_instance_exists(id, "jump_grace_vertical") ? jump_grace_vertical : (variable_global_exists("jump_grace_vertical") ? global.jump_grace_vertical : 12));

    for (var __k = 0; __k < instance_number(par_solid); __k++) {
        var __ps = instance_find(par_solid, __k);
        if (!instance_exists(__ps)) continue;
        var __pw = variable_instance_exists(__ps, "width") ? __ps.width : 64;
        var __pl = variable_instance_exists(__ps, "length") ? __ps.length : 64;
        var _left = __ps.x - _gr;
        var _right = __ps.x + __pw + _gr;
        var _front = __ps.y - _gr;
        var _back = __ps.y + __pl + _gr;
        if (x >= _left && x < _right && y >= _front && y < _back) {
            var _topz = __ps.z + (variable_instance_exists(__ps, "height") ? __ps.height : 64);
            if (z >= _topz - _gv) {
                prev_ground_z = _topz;
                if (global.debug_mode) show_debug_message("[JUMP_GRACE] near top=" + string(_topz) + " gr=" + string(_gr) + " gv=" + string(_gv));
                return true;
            }
        }
    }
    return false;
}