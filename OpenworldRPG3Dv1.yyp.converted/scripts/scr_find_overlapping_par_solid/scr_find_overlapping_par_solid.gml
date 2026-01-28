/// scr_find_overlapping_par_solid(_x,_y,_z,_w,_h,_d)
/// Returns an array of instances (and bounds) of par_solid overlapping the given AABB. Also logs results when debug.
function scr_find_overlapping_par_solid(_x, _y, _z, _w, _h, _d) {
    var xq = (argument_count > 0 && argument0 != undefined) ? argument0 : (variable_global_exists("player_position") ? global.player_position[0] : 0);
    var yq = (argument_count > 1 && argument1 != undefined) ? argument1 : (variable_global_exists("player_position") ? global.player_position[1] : 0);
    var zq = (argument_count > 2 && argument2 != undefined) ? argument2 : (variable_global_exists("player_position") ? global.player_position[2] : 0);
    var wq = (argument_count > 3 && argument3 != undefined) ? argument3 : 16;
    var hq = (argument_count > 4 && argument4 != undefined) ? argument4 : wq;
    var dq = (argument_count > 5 && argument5 != undefined) ? argument5 : wq;

    var results = [];
    if (instance_number(par_solid) == 0) {
        if (global.debug_mode) show_debug_message("[PAR_PROBE] no par_solid instances in room");
        return results;
    }

    var left = xq;
    var right = xq + wq;
    var front = yq;
    var back = yq + hq;
    var bottom = zq;
    var top = zq + dq;

    for (var i = 0; i < instance_number(par_solid); i++) {
        var inst = instance_find(par_solid, i);
        if (!instance_exists(inst)) continue;
        var iw = variable_instance_exists(inst, "width") ? inst.width : 64;
        var il = variable_instance_exists(inst, "length") ? inst.length : 64;
        var ih = variable_instance_exists(inst, "height") ? inst.height : 64;
        var ileft = inst.x;
        var iright = inst.x + iw;
        var ifront = inst.y;
        var iback = inst.y + il;
        var ibottom = inst.z;
        var itop = inst.z + ih;
        var overlap = !(right <= ileft || left >= iright || back <= ifront || front >= iback || top <= ibottom || bottom >= itop);
        if (overlap) {
            var entry = { inst: inst, bounds: { left: ileft, right: iright, front: ifront, back: iback, bottom: ibottom, top: itop } };
            array_push(results, entry);
            if (global.debug_mode) show_debug_message("[PAR_PROBE] overlap inst=" + string(inst) + " bounds=[" + string(ileft) + "," + string(iright) + "," + string(ifront) + "," + string(iback) + "," + string(ibottom) + "," + string(itop) + "]");
        }
    }

    if (global.debug_mode && array_length(results) == 0) show_debug_message("[PAR_PROBE] no overlapping par_solid found");
    return results;
}