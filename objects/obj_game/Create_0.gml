/// Engine / game early-init (run as early as possible in room instance order)
// Ensure core globals exist so other objects can safely read them during Create/Step/Draw
if (!variable_global_exists("grid_size")) global.grid_size = 64;
if (!variable_global_exists("block_size")) global.block_size = global.grid_size;
if (!variable_global_exists("block_collision")) global.block_collision = true;
if (!variable_global_exists("current_z")) global.current_z = 0;
if (!variable_global_exists("debug_mode")) global.debug_mode = true;
if (!variable_global_exists("block_id")) global.block_id = 0;
if (!variable_global_exists("cube_list")) global.cube_list = [];
if (!variable_global_exists("screen_w")) global.screen_w = display_get_width();
if (!variable_global_exists("screen_h")) global.screen_h = display_get_height();

if (!variable_global_exists("protoScreenW")) global.protoScreenW = 64;
if (!variable_global_exists("protoScreenH")) global.protoScreenH = 48;

// Provide a guaranteed safe snap_to_grid implementation early so callers never crash
// (unconditional assignment avoids init-order/read-safety issues)
global.snap_to_grid = function(a, b, c, mode) {
    var gs = variable_global_exists("grid_size") ? global.grid_size : 64;
    var ax, ay, az;
    if (is_array(a)) { ax = a[0]; ay = a[1]; az = a[2]; } else { ax = a; ay = b; az = c; }
    var fn = (argument_count > 3 && mode == "round") ? round : floor;
    return [ fn(ax / gs) * gs, fn(ay / gs) * gs, fn(az / gs) * gs ];
};
// Mark as initialized
global._snap_initialized = true;

// Preserve existing minimal behavior
global.paused = false;

// --- Inventory manager (simple global storage + API) ---
if (!variable_global_exists("inventory")) global.inventory = [];

// Low-level inventory operations (operate on global.inventory array)
global.inventory_add = function(device_id, owner) {
    if (is_undefined(device_id)) return false;
    // prevent duplicates
    for (var i = 0; i < array_length(global.inventory); i++) {
        if (global.inventory[i].id == device_id) return false;
    }
    var entry = { id: device_id, owner: owner };
    global.inventory[array_length(global.inventory)] = entry;
    return true;
};
global.device_is_held = function(_inst) {
    if (variable_instance_exists(_inst, "held") && _inst.held) return true;
    if (variable_instance_exists(_inst, "held_by_player") && _inst.held_by_player) return true;
    if (variable_global_exists("inventory_has") && global.inventory_has(_inst)) return true;
    return false;
}

global.inventory_remove = function(device_id) {
    var found = false;
    var newarr = [];
    for (var i = 0; i < array_length(global.inventory); i++) {
        var e = global.inventory[i];
        if (e.id == device_id) { found = true; continue; }
        newarr[array_length(newarr)] = e;
    }
    global.inventory = newarr;
    return found;
};

global.inventory_has = function(device_id) {
    for (var i = 0; i < array_length(global.inventory); i++) {
        if (global.inventory[i].id == device_id) return true;
    }
    return false;
};

global.inventory_list = function() {
    return global.inventory;
};

// Expose convenient script-level wrappers expected by other objects
global.add_device = function(device_id, owner) {
    if (is_undefined(device_id)) return false;
    if (global.inventory_has(device_id)) return false;
    var ok = global.inventory_add(device_id, owner);
    // If adding succeeded and instance exists, mark it held and attach player ref
    if (ok && instance_exists(device_id)) {
        var d = device_id;
        // Support both naming conventions used by different device prototypes
        d.held_by_player = true;
        d.held = true;
        d.player_ref = owner;
    }
    return ok;
}

global.invoke_Inst = function(_inst, _name, _default) {
    return variable_instance_exists(_inst, _name)
        ? variable_instance_get(_inst, _name)
        : _default;
}

global.remove_device = function(device_id) {
    var ok = global.inventory_remove(device_id);
    if (ok && instance_exists(device_id)) {
        var d = device_id;
        d.held_by_player = false;
        d.held = false;
        d.player_ref = noone;
    }
    return ok;
}

// Ensure there is a ground floor par_solid instance in the room so non-cube floors are detected
if (asset_get_index("par_solid") != -1) {
    // Create a single large floor instance if none exists
    if (!instance_exists(par_solid)) {
        // Determine sensible coverage for the fallback floor.
        var centerx = 0; var centery = 0; var fw = 0; var fl = 0;
        if (typeof(room_width) == "real") {
            fw = max(256, room_width);
            fl = max(256, room_height);
            centerx = room_width * 0.5;
            centery = room_height * 0.5;
        } else if (variable_global_exists("room_width") && variable_global_exists("room_height")) {
            fw = max(256, global.room_width);
            fl = max(256, global.room_height);
            centerx = global.room_width * 0.5;
            centery = global.room_height * 0.5;
        } else if (variable_global_exists("cube_list") && array_length(global.cube_list) > 0) {
            // Defensive: initialize bounds explicitly (avoid scientific notation and multi-assignment syntax)
            var minx = 1000000000;
            var maxx = -1000000000;
            var miny = 1000000000;
            var maxy = -1000000000;
            for (var i = 0; i < array_length(global.cube_list); i++) {
                var c = global.cube_list[i];
                minx = min(minx, c.x);
                maxx = max(maxx, c.x + c.size);
                miny = min(miny, c.y);
                maxy = max(maxy, c.y + c.size);
            }
            fw = max(256, maxx - minx + (variable_global_exists("grid_size") ? global.grid_size : 64));
            fl = max(256, maxy - miny + (variable_global_exists("grid_size") ? global.grid_size : 64));
            centerx = (minx + maxx) * 0.5;
            centery = (miny + maxy) * 0.5;
        } else if (instance_exists(obj_player)) {
            var p = instance_find(obj_player, 0);
            centerx = p.x; centery = p.y;
            fw = max(512, display_get_width());
            fl = max(512, display_get_height());
        } else {
            fw = max(256, display_get_width());
            fl = max(256, display_get_height());
            centerx = fw * 0.5; centery = fl * 0.5;
        }

        var f = noone;
        // Try to create in named layer if available, otherwise fall back to depth-based creation for compatibility
        try {
            if (layer_get_id("Instances") != -1) {
                f = instance_create_layer(centerx, centery, "Instances", par_solid);
            } else {
                f = instance_create_depth(centerx, centery, 0, par_solid);
            }
        } catch (e) {
            // Fallback: depth creation
            f = instance_create_depth(centerx, centery, 0, par_solid);
        }
        if (f != noone) {
            f.x = centerx; f.y = centery; f.z = (variable_global_exists("ground_level") ? global.ground_level : 0);
            f.width = fw; f.length = fl; f.height = 1;
            // Register created fallback floor for direct diagnostics
            global.fallback_floor = f;
        }
    }
} else {
    // If par_solid asset doesn't exist, ensure the global ground plane remains the authoritative fallback
}

// Ensure runtime window size matches requested globals (helps when IDE options are missing)
if (variable_global_exists("window_width") && variable_global_exists("window_height")) {
    try {
        // Clamp to display size to avoid OS clamping/overflow
        var targ_w = min(global.window_width, display_get_width());
        var targ_h = min(global.window_height, display_get_height());
        window_set_size(targ_w, targ_h);
        if (global.debug_mode) show_debug_message("[WINDOW] window_set_size -> " + string(targ_w) + "x" + string(targ_h) + " (requested " + string(global.window_width) + "x" + string(global.window_height) + ")");
        // Try to explicitly set the window position to the top-left of the primary display — helps in IDE/hosted runners that position windows oddly
        try {
            window_set_position(0, 0);
            if (global.debug_mode) show_debug_message("[WINDOW] window_set_position -> " + string(window_get_x()) + "," + string(window_get_y()));
        } catch (e_pos) {
            if (global.debug_mode) show_debug_message("[WINDOW] window_set_position threw: " + string(e_pos));
        }
    } catch (e) {
        if (global.debug_mode) show_debug_message("[WINDOW] window_set_size threw: " + string(e));
    }

    // If requested, force a fullscreen/borderless presentation (safe checks)
    if (variable_global_exists("force_fullscreen") && global.force_fullscreen) {
        try {
            if (!is_undefined(window_set_fullscreen)) {
                window_set_fullscreen(true);
                if (global.debug_mode) show_debug_message("[WINDOW] force_fullscreen: window_set_fullscreen(true) invoked");
            } else if (!is_undefined(window_set_borderless)) {
                window_set_borderless(true);
                window_set_position(0, 0);
                if (global.debug_mode) show_debug_message("[WINDOW] force_fullscreen: window_set_borderless(true) invoked");
            } else {
                if (global.debug_mode) show_debug_message("[WINDOW] force_fullscreen: no fullscreen API available");
            }
        } catch (e_fs) {
            if (global.debug_mode) show_debug_message("[WINDOW] force_fullscreen threw: " + string(e_fs));
        }
    }
    // Window enforcement disabled — was causing strange offsets in some environments.

    // Allow the player to toggle borderless/fullscreen (F11) at runtime to test whether a borderless fullscreen presentation removes the black bar
    if (!variable_global_exists("_window_borderless_test")) global._window_borderless_test = false;
}


