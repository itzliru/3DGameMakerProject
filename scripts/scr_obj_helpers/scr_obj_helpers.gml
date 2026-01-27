// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

//PineAppleGames 2026

enum HelperType {
    OBJ,
    CAM_DRAW,
    CAM_MATRIX,
    Diagnostics
}

//global helper map located in globals.gml
/*
global.helper_map = {
    helper      : scr_obj_helpers
 
};
*/

function scr_helper_dispatch(_type, _arg0, _arg1, _arg2) {
    switch (_type) {
        case HelperType.OBJ:
            import_obj(_arg0, _arg1);
        break;

        case HelperType.CAM_DRAW:
            scr_cam_draw_helper(_arg0, _arg1);
        break;

        case HelperType.CAM_MATRIX:
            scr_cam_matrix_helper(_arg0, _arg1, _arg2);
        break;
        
        case HelperType.Diagnostics:
            debug_player();
        break;
    }
}

function scr_obj_helpers(){





}


///CoPilot Version
function debug_player(_who) {
    if (!variable_global_exists("debug_mode") || !global.debug_mode) return;
    var cam = instance_exists(obj_camera) ? instance_find(obj_camera, 0) : noone;
    var player = undefined;
    if (argument_count > 0) player = _who;
    if (player == undefined) player = (instance_exists(obj_player) ? instance_find(obj_player, 0) : noone);

    if (cam == noone) {
        show_debug_message("[DEBUG] Camera: none");
    } else {
        var cx = (variable_instance_exists(cam, "x") ? variable_instance_get(cam, "x") : "(na)");
        var cy = (variable_instance_exists(cam, "y") ? variable_instance_get(cam, "y") : "(na)");
        var cz = (variable_instance_exists(cam, "z") ? variable_instance_get(cam, "z") : "(na)");
        show_debug_message("[DEBUG] Camera Pos: x=" + string(cx) + " y=" + string(cy) + " z=" + string(cz));

        if (variable_instance_exists(cam, "direction") || variable_instance_exists(cam, "pitch")) {
            var cdir = variable_instance_exists(cam, "direction") ? variable_instance_get(cam, "direction") : "(na)";
            var cp = variable_instance_exists(cam, "pitch") ? variable_instance_get(cam, "pitch") : "(na)";
            show_debug_message("[DEBUG] Camera Dir/Pitch: dir=" + string(cdir) + " pitch=" + string(cp));
        }

        // Optional camera focus/origin offsets (fx,fy,fz)
        if (variable_instance_exists(cam, "fx") || variable_instance_exists(cam, "fy") || variable_instance_exists(cam, "fz")) {
            var cfx = variable_instance_exists(cam, "fx") ? variable_instance_get(cam, "fx") : "(na)";
            var cfy = variable_instance_exists(cam, "fy") ? variable_instance_get(cam, "fy") : "(na)";
            var cfz = variable_instance_exists(cam, "fz") ? variable_instance_get(cam, "fz") : "(na)";
            show_debug_message("[DEBUG] Camera FX/FY/FZ: fx=" + string(cfx) + " fy=" + string(cfy) + " fz=" + string(cfz));
        }

        // Optional view matrix / transform (may be array/struct)
        if (variable_instance_exists(cam, "view")) {
            var viewVal = variable_instance_get(cam, "view");
            show_debug_message("[DEBUG] Camera View Matrix: " + string(viewVal));
        }
    }

    if (player == noone) {
        show_debug_message("[DEBUG] Player: none");
    } else {
        var px = (variable_instance_exists(player, "x") ? variable_instance_get(player, "x") : "(na)");
        var py = (variable_instance_exists(player, "y") ? variable_instance_get(player, "y") : "(na)");
        var pz = (variable_instance_exists(player, "z") ? variable_instance_get(player, "z") : "(na)");
        show_debug_message("[DEBUG] Player Pos: x=" + string(px) + " y=" + string(py) + " z=" + string(pz));
        dump_instance_state(player);
    }
}
///CoPilot Version
// Print a compact set of known/likely runtime fields for an instance safely.
function dump_instance_state(_inst) {
    if (_inst == noone || !instance_exists(_inst)) return;
    var keys = ["x","y","z","direction","pitch","fb_vel","rl_vel","z_vel","on_ground","prev_ground_z","resolve_cooldown","sprite_index"];
    var out = "[DUMP] inst=" + string(_inst);
    for (var i = 0; i < array_length(keys); ++i) {
        var k = keys[i];
        var v = variable_instance_exists(_inst, k) ? variable_instance_get(_inst, k) : "(na)";
        out += " " + k + "=" + string(v);
    }
    show_debug_message(out);
}
///CoPilot Version
// Return an array of par_solid instance ids within a simple box+z radius.
function list_nearby_par_solid(_x, _y, _z, _radius) {
    var ids = [];
    if (!instance_exists(par_solid)) return ids;
    with (par_solid) {
        if (abs(x - _x) <= _radius && abs(y - _y) <= _radius && abs(z - _z) <= _radius) {
            array_push(ids, id);
        }
    }
    show_debug_message("[DEBUG] list_nearby_par_solid: found " + string(array_length(ids)) + " within " + string(_radius));
    return ids;
}
///CoPilot Version
// Snapshot nearby scene: par_solid, some object counts, and cube_list summary (if present).
function snapshot_scene(_x, _y, _z, _radius) {
    if (!variable_global_exists("debug_mode") || !global.debug_mode) return;
    show_debug_message("[SNAPSHOT] at " + string(_x) + "," + string(_y) + "," + string(_z) + " radius=" + string(_radius));
    var ps = list_nearby_par_solid(_x, _y, _z, _radius);
    for (var i = 0; i < array_length(ps); ++i) {
        var iid = ps[i];
        if (instance_exists(iid)) {
            var ix = variable_instance_exists(iid, "x") ? variable_instance_get(iid, "x") : "(na)";
            var iy = variable_instance_exists(iid, "y") ? variable_instance_get(iid, "y") : "(na)";
            var iz = variable_instance_exists(iid, "z") ? variable_instance_get(iid, "z") : "(na)";
            show_debug_message("  par_solid id=" + string(iid) + " pos=" + string(ix) + "," + string(iy) + "," + string(iz));
        }
    }

    if (variable_global_exists("cube_list")) {
        var count = 0;
        try {
            count = array_length(global.cube_list);
        } catch (e) {
            count = 0;
        }
        show_debug_message("[SNAPSHOT] cube_list length=" + string(count));
    } else {
        show_debug_message("[SNAPSHOT] no global.cube_list present");
    }
}
///CoPilot Version
// Simple safe wrapper for asset_get_index that logs in debug mode.
function asset_index_safe(_name) {
    var idx = asset_get_index(_name);
    if (variable_global_exists("debug_mode") && global.debug_mode) show_debug_message("[ASSET] " + string(_name) + " -> " + string(idx));
    return idx;
}
///CoPilot Version
// Stub: register_debug_hotkeys can be called from a Step event to centralize hotkey wiring.
function register_debug_hotkeys() {
    if (!variable_global_exists("debug_mode") || !global.debug_mode) return;
    if (keyboard_check_pressed(vk_f6)) {
        if (asset_get_index("scr_debug_list_cubes") != -1) scr_debug_list_cubes();
        else show_debug_message("[DEBUG] scr_debug_list_cubes not available");
    }
    if (keyboard_check_pressed(vk_f7)) {
        if (!variable_global_exists("debug_draw_cubes")) global.debug_draw_cubes = false;
        global.debug_draw_cubes = !global.debug_draw_cubes;
        show_debug_message("[DEBUG] debug_draw_cubes = " + string(global.debug_draw_cubes));
    }
    if (keyboard_check_pressed(vk_f8)) {
        var px = (instance_exists(obj_player) ? instance_find(obj_player,0).x : 0);
        var py = (instance_exists(obj_player) ? instance_find(obj_player,0).y : 0);
        var pz = (instance_exists(obj_player) ? instance_find(obj_player,0).z : 0);
        if (asset_get_index("scr_debug_col_probe") != -1) scr_debug_col_probe(px, py, pz, 16,16,32);
        else show_debug_message("[DEBUG] scr_debug_col_probe not available");
    }
}


function scr_cam_draw_helper(){





}

function scr_cam_matrix_helper(){





}
//Charles' Version
function import_obj(_filename, _vertex_format)
{
    var buffer = buffer_load(_filename);
    if (buffer == -1) {
        if (global.debug_mode) {
            show_debug_message("import_obj: failed to load " + _filename);
        }
        return undefined;
    }

    var text = buffer_read(buffer, buffer_string);
    

    var lines = string_split(text, "\n");

    var vb = vertex_create_buffer();
    vertex_begin(vb, _vertex_format);

    var positions = [];
    var normals   = [];
    var uvs       = [];

    for (var i = 0; i < array_length(lines); i++)
    {
        var line = string_trim(lines[i]);
        if (line == "" || string_char_at(line, 1) == "#") continue;

        var parts = string_split(line, " ");

        switch (parts[0])//parsing might need tokens if this doesnt work
        {
            case "v":
                array_push(positions, [
                    real(parts[1]),
                    real(parts[2]),
                    real(parts[3])
                ]);
            break;

            case "vt":
                array_push(uvs, [
                    real(parts[1]),
                    1.0 - real(parts[2])
                ]);
            break;

            case "vn":
                array_push(normals, [
                    real(parts[1]),
                    real(parts[2]),
                    real(parts[3])
                ]);
            break;

            case "f":
                // simple triangulated faces only
                for (var t = 1; t <= 3; t++)
                {
                    var idx = string_split(parts[t], "/");

                    var p = positions[real(idx[0]) - 1];
                    var uv = (array_length(idx) > 1 && idx[1] != "")
                             ? uvs[real(idx[1]) - 1]
                             : [0,0];
                    var n = (array_length(idx) > 2)
                            ? normals[real(idx[2]) - 1]
                            : [0,0,1];

                    vertex_position_3d(vb, p[0], p[1], p[2]);
                    vertex_texcoord(vb, uv[0], uv[1]);
                    vertex_normal(vb, n[0], n[1], n[2]);
                    vertex_colour(vb, c_white, 1);
                }
            break;
        }
    }
    buffer_delete(buffer);
    vertex_end(vb);
    vertex_freeze(vb);



    return {
        vb            : vb,
        format        : _vertex_format,
        vertex_count  : vertex_get_number(vb),
        aabb_min      : [0,0,0], // optional later
        aabb_max      : [0,0,0]
      
    };
}

/// import_map(filename [, options])
/// - Loads an OBJ scene for rendering and creates collision geometry.
/// Options (optional struct):
///   .create_par_solid  (bool)  default true  -> create `par_solid` fallback instances
///   .use_colworld      (bool)  default true  -> register shapes with `global.col_world` when present
///   .detailed_collision(bool)  default false -> parse triangles and create `ColMesh` (costly)
///   .layer             (string) default "Instances"
///   .depth             (real)   default 0
/// Returns a struct: { instances: [...], col_objects: [...], mesh: <import_obj return> }
function import_map(_filename, _opts) {
    if (argument_count == 0) return undefined;
    var opts = (argument_count > 1 && !is_undefined(argument1)) ? argument1 : {};
    var create_par = (is_struct(opts) && !is_undefined(opts.create_par_solid)) ? opts.create_par_solid : true;
    var use_colworld = (is_struct(opts) && !is_undefined(opts.use_colworld)) ? opts.use_colworld : true;
    var detailed = (is_struct(opts) && !is_undefined(opts.detailed_collision)) ? opts.detailed_collision : false;
    var layer_name = (is_struct(opts) && !is_undefined(opts.layer)) ? opts.layer : "Instances_1";
    var depth = (is_struct(opts) && !is_undefined(opts.depth)) ? opts.depth : 0;

    // Read file and parse minimal geometry (positions + faces). We duplicate a tiny amount of import_obj parsing
    var buffer = buffer_load(_filename);
    if (buffer == -1) {
        if (variable_global_exists("debug_mode") && global.debug_mode) show_debug_message("import_map: failed to load " + string(_filename));
        return undefined;
    }
    var text = buffer_read(buffer, buffer_string);
    buffer_delete(buffer);

    var lines = string_split(text, "\n");
    var positions = [];
    var faces = []; // arrays of index triples
    for (var i = 0; i < array_length(lines); ++i) {
        var line = string_trim(lines[i]);
        if (line == "" || string_char_at(line,1) == "#") continue;
        var parts = string_split(line, " ");
        switch (parts[0]) {
            case "v":
                // store as [x,y,z]
                if (array_length(parts) >= 4) array_push(positions, [ real(parts[1]), real(parts[2]), real(parts[3]) ]);
            break;
            case "f":
                // triangulate polygon faces (fan)
                if (array_length(parts) >= 4) {
                    // parse indices (v/vt/vn) -> take first value
                    var idxs = array_create(array_length(parts) - 1);
                    for (var j = 1; j < array_length(parts); ++j) {
                        var tok = string_split(parts[j], "/");
                        idxs[j-1] = real(tok[0]);
                    }
                    // fan triangulation
                    for (var k = 1; k < array_length(idxs) - 1; ++k) {
                        array_push(faces, [ idxs[0], idxs[k], idxs[k+1] ]);
                    }
                }
            break;
        }
    }

    // Compute AABB
    var aabb_min = undefined;
    var aabb_max = undefined;
    if (array_length(positions) > 0) {
        aabb_min = [ positions[0][0], positions[0][1], positions[0][2] ];
        aabb_max = [ positions[0][0], positions[0][1], positions[0][2] ];
        for (var i = 1; i < array_length(positions); ++i) {
            var p = positions[i];
            aabb_min[0] = min(aabb_min[0], p[0]); aabb_min[1] = min(aabb_min[1], p[1]); aabb_min[2] = min(aabb_min[2], p[2]);
            aabb_max[0] = max(aabb_max[0], p[0]); aabb_max[1] = max(aabb_max[1], p[1]); aabb_max[2] = max(aabb_max[2], p[2]);
        }
    } else {
        aabb_min = [0,0,0]; aabb_max = [0,0,0];
    }

    // Create a render mesh using existing helper (use a sensible vertex format)
    var vf = undefined;
    try {
        vertex_format_begin();
        vertex_format_add_position_3d();
        vertex_format_add_normal();
        vertex_format_add_texcoord();
        vertex_format_add_color();
        vf = vertex_format_end();
    } catch (e) {
        vf = undefined;
    }
    var mesh = undefined;
    try {
        mesh = import_obj(_filename, vf);
    } catch (e) {
        mesh = undefined;
    }

    var created_instances = [];
    var created_colobjects = [];

    // Create par_solid fallback (coarse AABB)
    if (create_par && asset_get_index("par_solid") != -1) {
        var cx = (aabb_min[0] + aabb_max[0]) * 0.5;
        var cy = (aabb_min[1] + aabb_max[1]) * 0.5;
        var cz = (aabb_min[2] + aabb_max[2]) * 0.5;
        var sx = max(1, aabb_max[0] - aabb_min[0]);
        var sy = max(1, aabb_max[1] - aabb_min[1]);
        var sz = max(1, aabb_max[2] - aabb_min[2]);
        var inst = noone;
        try {
            if (!is_undefined(layer_get_id) && layer_get_id(layer_name) != -1) inst = instance_create_layer(cx, cy, layer_name, par_solid);
            else inst = instance_create_depth(cx, cy, depth, par_solid);
        } catch (e) {
            inst = instance_create_depth(cx, cy, depth, par_solid);
        }
        if (inst != noone) {
            inst.x = cx; inst.y = cy; inst.z = cz;
            inst.width = sx; inst.length = sy; inst.height = sz;
            inst.collision = true;
            // metadata
            inst._import_map_source = _filename;
            array_push(created_instances, inst.id);
            if (variable_global_exists("debug_mode") && global.debug_mode) show_debug_message("import_map: created par_solid id=" + string(inst.id) + " aabb=[" + string(aabb_min) + "," + string(aabb_max) + "]");
        }
    }

    // Register with ColWorld if requested
    if (use_colworld && variable_global_exists("col_world") && !is_undefined(global.col_world)) {
        var shape = undefined;
        if (detailed && array_length(faces) > 0 && is_callable(ColMesh)) {
            // Build triangle_array by pushing only valid triangles (avoid leaving undefined slots)
            var triangle_array = [];
            for (var i = 0; i < array_length(faces); ++i) {
                var f = faces[i];
                var p1 = positions[real(f[0]) - 1];
                var p2 = positions[real(f[1]) - 1];
                var p3 = positions[real(f[2]) - 1];
                if (p1 == undefined || p2 == undefined || p3 == undefined) continue; // skip malformed
                array_push(triangle_array, new ColTriangle(new Vector3(p1[0], p1[1], p1[2]), new Vector3(p2[0], p2[1], p2[2]), new Vector3(p3[0], p3[1], p3[2])));
            }
            if (array_length(triangle_array) > 0) {
                shape = new ColMesh(triangle_array);
            } else {
                // no valid triangles collected -> fallback to AABB
                var center_v = new Vector3((aabb_min[0] + aabb_max[0]) * 0.5, (aabb_min[1] + aabb_max[1]) * 0.5, (aabb_min[2] + aabb_max[2]) * 0.5);
                var half = new Vector3(max(0.5, (aabb_max[0] - aabb_min[0]) * 0.5), max(0.5, (aabb_max[1] - aabb_min[1]) * 0.5), max(0.5, (aabb_max[2] - aabb_min[2]) * 0.5));
                shape = new ColAABB(center_v, half);
            }
            // coarse AABB shape
            var center_v = new Vector3((aabb_min[0] + aabb_max[0]) * 0.5, (aabb_min[1] + aabb_max[1]) * 0.5, (aabb_min[2] + aabb_max[2]) * 0.5);
            var half = new Vector3(max(0.5, (aabb_max[0] - aabb_min[0]) * 0.5), max(0.5, (aabb_max[1] - aabb_min[1]) * 0.5), max(0.5, (aabb_max[2] - aabb_min[2]) * 0.5));
            shape = new ColAABB(center_v, half);
        }

        var colobj = new ColObject(shape, _filename);
        try {
            global.col_world.Add(colobj);
            array_push(created_colobjects, colobj);
            if (variable_global_exists("debug_mode") && global.debug_mode) show_debug_message("import_map: registered collision object with ColWorld for " + string(_filename));
        } catch (e) {
            if (variable_global_exists("debug_mode") && global.debug_mode) show_debug_message("import_map: failed to add to ColWorld: " + string(e));
        }
    }

    return { instances: created_instances, col_objects: created_colobjects, mesh: mesh, aabb_min: aabb_min, aabb_max: aabb_max };
}
/// import_map(filename [, options])
/// - Loads an OBJ scene for rendering and creates collision geometry.
/// Options (optional struct):
///   .create_par_solid    (bool)  default true
///   .use_colworld        (bool)  default true
///   .detailed_collision  (bool)  default false
///   .layer               (string) default "Instances"
///   .depth               (real)   default 0
///   .rollback_on_failure (bool)  default false  -> remove created instances if col_world registration fails
///
/// Returns a struct: { instances: [...], col_objects: [...], mesh: <import_obj return>, aabb_min:..., aabb_max:..., errors:[...] }

function import_map_safe(_filename, _opts) {
    if (argument_count == 0) return undefined;
    var opts = (argument_count > 1 && !is_undefined(argument1)) ? argument1 : {};
    var create_par = (is_struct(opts) && !is_undefined(opts.create_par_solid)) ? opts.create_par_solid : true;
    var use_colworld = (is_struct(opts) && !is_undefined(opts.use_colworld)) ? opts.use_colworld : true;
    var detailed = (is_struct(opts) && !is_undefined(opts.detailed_collision)) ? opts.detailed_collision : false;
    var layer_name = (is_struct(opts) && !is_undefined(opts.layer)) ? opts.layer : "Instances_1";
    var depth = (is_struct(opts) && !is_undefined(opts.depth)) ? opts.depth : 0;
    var rollback_on_failure = (is_struct(opts) && !is_undefined(opts.rollback_on_failure)) ? opts.rollback_on_failure : false;

    var errors = [];

    // Load file
    var buffer = buffer_load(_filename);
    if (buffer == -1) {
        if (variable_global_exists("debug_mode") && global.debug_mode) show_debug_message("import_map: failed to load " + string(_filename));
        return undefined;
    }
    var text = buffer_read(buffer, buffer_string);
    buffer_delete(buffer);

    // Minimal OBJ parse: positions + faces
    var lines = string_split(text, "\n");
    var positions = [];
    var faces = []; // arrays of index triples (1-based or negative as per OBJ)
    for (var i = 0; i < array_length(lines); ++i) {
        var line = string_trim(lines[i]);
        if (line == "" || string_char_at(line,1) == "#") continue;
        // split by whitespace sequence: OBJ may have multiple spaces — simple split by " " mostly ok
        var parts = string_split(line, " ");
        if (array_length(parts) == 0) continue;
        var t = parts[0];
        if (t == "v") {
            if (array_length(parts) >= 4) {
                var vx = real(parts[1]); var vy = real(parts[2]); var vz = real(parts[3]);
                array_push(positions, [vx, vy, vz]);
            } else {
                array_push(errors, "Malformed v line at " + string(i+1));
            }
        } else if (t == "f") {
            if (array_length(parts) >= 4) {
                // parse face vertex references; handle v/vt/vn and negative indices
                var refCount = array_length(parts) - 1;
                var idxs = array_create(refCount);
                var okFace = true;
                for (var j = 1; j < array_length(parts); ++j) {
                    var tok = string_split(parts[j], "/");
                    // tok[0] is vertex index; could be negative
                    if (tok[0] == "" || tok[0] == undefined) { okFace = false; break; }
                    var vi = real(tok[0]);
                    // store the raw integer (we'll resolve negative indices later)
                    idxs[j-1] = vi;
                }
                if (!okFace) {
                    array_push(errors, "Malformed f token at line " + string(i+1));
                    continue;
                }
                // triangulate (fan)
                for (var k = 1; k < array_length(idxs) - 1; ++k) {
                    array_push(faces, [ idxs[0], idxs[k], idxs[k+1] ]);
                }
            } else {
                array_push(errors, "Ignored degenerate face at line " + string(i+1));
            }
        }
    }

    // Resolve negative indices and validate face indices
    var posCount = array_length(positions);
    var validFaces = array_create(0);
    for (var i = 0; i < array_length(faces); ++i) {
        var f = faces[i];
        var resolved = array_create(3);
        var valid = true;
        for (var j = 0; j < 3; ++j) {
            var idx = real(f[j]);
            if (idx < 0) idx = posCount + 1 + idx; // OBJ negative index: -1 refers to last
            // require integer indices
            idx = floor(idx);
            if (idx < 1 || idx > posCount) { valid = false; break; }
            resolved[j] = idx;
        }
        if (valid) array_push(validFaces, resolved);
        else array_push(errors, "Face with out-of-range index skipped (face #" + string(i+1) + ")");
    }
    faces = validFaces;

    // Compute AABB
    var aabb_min = [0,0,0], aabb_max = [0,0,0];
    if (posCount > 0) {
        aabb_min = [ positions[0][0], positions[0][1], positions[0][2] ];
        aabb_max = [ positions[0][0], positions[0][1], positions[0][2] ];
        for (var i = 1; i < posCount; ++i) {
            var p = positions[i];
            aabb_min[0] = min(aabb_min[0], p[0]); aabb_min[1] = min(aabb_min[1], p[1]); aabb_min[2] = min(aabb_min[2], p[2]);
            aabb_max[0] = max(aabb_max[0], p[0]); aabb_max[1] = max(aabb_max[1], p[1]); aabb_max[2] = max(aabb_max[2], p[2]);
        }
    }

    // Helper: safe vertex format
    var vf = undefined;
    if (!is_undefined(vertex_format_begin)) {
        try {
            vertex_format_begin();
            if (!is_undefined(vertex_format_add_position_3d)) vertex_format_add_position_3d();
            if (!is_undefined(vertex_format_add_normal)) vertex_format_add_normal();
            if (!is_undefined(vertex_format_add_texcoord)) vertex_format_add_texcoord();
            if (!is_undefined(vertex_format_add_color)) vertex_format_add_color();
            vf = vertex_format_end();
        } catch (e) {
            array_push(errors, "vertex format creation failed: " + string(e));
            vf = undefined;
        }
    }

    // Try import_obj for visual mesh
    var mesh = undefined;
    if (!is_undefined(import_obj)) {
        try {
            mesh = import_obj(_filename, vf);
        } catch (e) {
            array_push(errors, "import_obj failed: " + string(e));
            mesh = undefined;
        }
    }

    var created_instances = [];
    var created_colobjects = [];
    var created_meta = []; // store objects for potential rollback

    // Create par_solid fallback (coarse AABB)
    if (create_par && asset_get_index("par_solid") != -1) {
        var cx = (aabb_min[0] + aabb_max[0]) * 0.5;
        var cy = (aabb_min[1] + aabb_max[1]) * 0.5;
        var cz = (aabb_min[2] + aabb_max[2]) * 0.5;
        var sx = max(1, aabb_max[0] - aabb_min[0]);
        var sy = max(1, aabb_max[1] - aabb_min[1]);
        var sz = max(1, aabb_max[2] - aabb_min[2]);
        var inst = noone;
        try {
            if (!is_undefined(layer_get_id) && layer_get_id(layer_name) != -1) inst = instance_create_layer(cx, cy, layer_name, par_solid);
            else inst = instance_create_depth(cx, cy, depth, par_solid);
        } catch (e) {
            inst = instance_create_depth(cx, cy, depth, par_solid);
        }
        if (inst != noone) {
            inst.x = cx; inst.y = cy; inst.z = cz;
            // width/length/height may be custom; guard by existence
            if (variable_instance_exists(inst.id, "width")) inst.width = sx;
            else inst.width = sx;
            if (variable_instance_exists(inst.id, "length")) inst.length = sy;
            if (variable_instance_exists(inst.id, "height")) inst.height = sz;
            inst.collision = true;
            inst._import_map_source = _filename;
            array_push(created_instances, inst.id);
            array_push(created_meta, { type: "instance", id: inst.id });
            if (variable_global_exists("debug_mode") && global.debug_mode) show_debug_message("import_map: created par_solid id=" + string(inst.id));
        } else {
            array_push(errors, "Failed to create par_solid instance");
        }
    }

    // Register with ColWorld if requested
    var add_to_colworld_ok = true;
    if (use_colworld && variable_global_exists("col_world") && !is_undefined(global.col_world)) {
        var shape = undefined;
        try {
                var triangle_array = [];
                for (var i = 0; i < array_length(faces); ++i) {
                    var f = faces[i];
                    var p1 = positions[f[0] - 1];
                    var p2 = positions[f[1] - 1];
                    var p3 = positions[f[2] - 1];
                    // validate again
                    if (p1 == undefined || p2 == undefined || p3 == undefined) {
                        array_push(errors, "Skipping triangle with missing vertex");
                        continue;
                    }
                    array_push(triangle_array, new ColTriangle(new Vector3(p1[0], p1[1], p1[2]), new Vector3(p2[0], p2[1], p2[2]), new Vector3(p3[0], p3[1], p3[2])));
                }
                if (array_length(triangle_array) > 0) {
                    shape = new ColMesh(triangle_array);
                } else {
                    // fallback to AABB if no valid triangles
                    var center_v = new Vector3((aabb_min[0] + aabb_max[0]) * 0.5, (aabb_min[1] + aabb_max[1]) * 0.5, (aabb_min[2] + aabb_max[2]) * 0.5);
                    var half = new Vector3(max(0.5, (aabb_max[0] - aabb_min[0]) * 0.5), max(0.5, (aabb_max[1] - aabb_min[1]) * 0.5), max(0.5, (aabb_max[2] - aabb_min[2]) * 0.5));
                    shape = new ColAABB(center_v, half);
                }
            } else {
                var center_v = new Vector3((aabb_min[0] + aabb_max[0]) * 0.5, (aabb_min[1] + aabb_max[1]) * 0.5, (aabb_min[2] + aabb_max[2]) * 0.5);
                var half = new Vector3(max(0.5, (aabb_max[0] - aabb_min[0]) * 0.5), max(0.5, (aabb_max[1] - aabb_min[1]) * 0.5), max(0.5, (aabb_max[2] - aabb_min[2]) * 0.5));
                shape = new ColAABB(center_v, half);
            }

            var colobj = new ColObject(shape, _filename);
            global.col_world.Add(colobj);
            array_push(created_colobjects, colobj);
            array_push(created_meta, { type: "colobj", obj: colobj });
            if (variable_global_exists("debug_mode") && global.debug_mode) show_debug_message("import_map: registered collision object with ColWorld for " + string(_filename));
        } catch (e) {
            add_to_colworld_ok = false;
            array_push(errors, "Failed to add to ColWorld: " + string(e));
            if (variable_global_exists("debug_mode") && global.debug_mode) show_debug_message("import_map: failed to add to ColWorld: " + string(e));
        }
    }

    // Rollback if requested and registration failed
    if (rollback_on_failure && !add_to_colworld_ok) {
        for (var i = 0; i < array_length(created_meta); ++i) {
            var m = created_meta[i];
            if (m.type == "instance") {
                // destroy instance by id if still exists
                var instid = m.id;
                if (instance_exists(instid)) instance_destroy(instid);
            } else if (m.type == "colobj") {
                // best-effort removal from col_world if present
                try {
                    if (variable_global_exists("col_world") && !is_undefined(global.col_world)) global.col_world.Remove(m.obj);
                } catch (e) { /* ignore */ }
            }
        }
        created_instances = [];
        created_colobjects = [];
    }

    return { instances: created_instances, col_objects: created_colobjects, mesh: mesh, aabb_min: aabb_min, aabb_max: aabb_max, errors: errors };
}

/*
function invoke(){
    // Flexible invoker:
    // Usage: invoke(method_or_name [, arg1, arg2, ...])
    // - If first arg is a string, try `global.helper_map[name]` then script asset lookup.
    // - If first arg is a function reference or script id, call it directly.
    // - For safety we forward up to 5 arguments and log failures in debug mode.

    if (argument_count == 0) return undefined;
    var method = argument0;
    var fn = undefined;

    // If a string, try the helper map then script asset lookup
    if (is_string(method)) {
        if (variable_global_exists("helper_map") && !is_undefined(global.helper_map)) {
            // attempt simple keyed lookup; helper_map is expected to be a struct/table
            try {
                fn = global.helper_map[method];
            } catch (e) {
                fn = undefined;
            }
        }
        if (is_undefined(fn)) {
            var sid = asset_get_index(method);
            if (sid != -1) fn = sid;
        }
    } else {
        // not a string: assume function reference or script id
        fn = method;
    }

    if (is_undefined(fn)) {
        if (variable_global_exists("debug_mode") && global.debug_mode) show_debug_message("[INVOKE] method not found: " + string(method));
        return undefined;
    }

    // collect forwarded args (everything after the first argument)
    var fwd = array_create(max(0, argument_count - 1));
    for (var i = 1; i < argument_count; ++i) fwd[i-1] = argument[i];
    var n = array_length(fwd);

    // Call script asset ids (numeric) via script_execute, otherwise treat as callable and call directly.
    if (is_real(fn)) {
        switch (n) {
            case 0: return script_execute(fn);
            case 1: return script_execute(fn, fwd[0]);
            case 2: return script_execute(fn, fwd[0], fwd[1]);
            case 3: return script_execute(fn, fwd[0], fwd[1], fwd[2]);
            case 4: return script_execute(fn, fwd[0], fwd[1], fwd[2], fwd[3]);
            default:
                if (variable_global_exists("debug_mode") && global.debug_mode) show_debug_message("[INVOKE] forwarding only first 5 args (total=" + string(n) + ")");
                return script_execute(fn, fwd[0], fwd[1], fwd[2], fwd[3], fwd[4]);
        }
    } else {
        // assume callable function reference
        switch (n) {
            case 0: return fn();
            case 1: return fn(fwd[0]);
            case 2: return fn(fwd[0], fwd[1]);
            case 3: return fn(fwd[0], fwd[1], fwd[2]);
            case 4: return fn(fwd[0], fwd[1], fwd[2], fwd[3]);
            default:
                if (variable_global_exists("debug_mode") && global.debug_mode) show_debug_message("[INVOKE] forwarding only first 5 args to function ref (total=" + string(n) + ")");
                return fn(fwd[0], fwd[1], fwd[2], fwd[3], fwd[4]);
        }
    }
}
/*