/// Drop device
function drop_device(dev_inst) {
    // Defensive: ensure instance exists and is valid before touching it
    if (dev_inst == noone) return false;
    if (!instance_exists(dev_inst)) return false;

    // Clear instance-held state safely
    if (variable_instance_exists(dev_inst, "held")) dev_inst.held = false;
    if (variable_instance_exists(dev_inst, "player_ref")) dev_inst.player_ref = noone;
    if (variable_instance_exists(dev_inst, "z")) dev_inst.z = (variable_global_exists("current_z") ? global.current_z : 0);

    // Remove from global inventory if present
    if (variable_global_exists("player_inventory")) {
        for (var i = 0; i < array_length(global.player_inventory); i++) {
            if (global.player_inventory[i] == dev_inst) global.player_inventory[i] = noone;
        }
    }

    // Sync legacy names
    if (variable_global_exists("held_device") && global.held_device == dev_inst) global.held_device = noone;
    held_device = (variable_global_exists("held_device") ? global.held_device : noone);
    return true;
}
/// Drop currently held device
function drop_current_device() {
    if (variable_global_exists("held_device") && global.held_device != noone) {
        if (instance_exists(global.held_device)) drop_device(global.held_device);
        global.held_device = noone;
    } else if (held_device != noone && instance_exists(held_device)) {
        drop_device(held_device);
        held_device = noone;
    }
}

function pick_up_device(dev_inst, player_inst) {
    dev_inst.held = true;
    dev_inst.player_ref = player_inst;
}

/// Compatibility & globals setup
if (!variable_global_exists("player_inventory")) global.player_inventory = array_create(5, noone);
if (!variable_global_exists("inventory_index")) global.inventory_index = 0;
if (!variable_global_exists("held_device")) global.held_device = noone;

// Keep local legacy names in sync for older code
if (!variable_global_exists("inventory")) inventory = global.player_inventory;
if (!variable_global_exists("inventory_index")) inventory_index = global.inventory_index;
if (!variable_global_exists("held_device")) held_device = global.held_device;

/// Returns true if the given instance is already in the player's inventory
function has_device(dev_inst) {
    if (!variable_global_exists("player_inventory")) return false;
    for (var i = 0; i < array_length(global.player_inventory); i++) {
        if (global.player_inventory[i] == dev_inst) return true;
    }
    return false;
}

/// Add device to inventory (optional player_inst). Returns true on success
function add_device(dev_inst, player_inst) {
    if (!variable_global_exists("player_inventory")) global.player_inventory = array_create(5, noone);
    // refuse if already present
    if (has_device(dev_inst)) return false;

    // find open slot
    var added = false;
    for (var i = 0; i < global.max_inventory_slots; i++) {
        if (global.player_inventory[i] == noone) {
            global.player_inventory[i] = dev_inst;
            global.inventory_index = i;
            added = true;
            break;
        }
    }
    if (!added) return false; // inventory full

    // Mark instance as held and link to player if provided
    dev_inst.held = true;
    dev_inst.player_ref = (argument_count > 1 && instance_exists(player_inst)) ? player_inst : noone;

    // Legacy sync
    inventory = global.player_inventory;
    inventory_index = global.inventory_index;
    held_device = dev_inst;
    global.held_device = dev_inst;

    return true;
}

/// Cycle inventory (next)
function next_device() {
    var inv = global.player_inventory;
    if (array_length(inv) == 0) return;

    // Clean invalid entries before cycling
    scr_device_manager.cleanup_inventory();

    // Drop current
    if (variable_global_exists("held_device") && global.held_device != noone && instance_exists(global.held_device)) drop_device(global.held_device);

    // Advance index (skip empty slots)
    var start = global.inventory_index;
    for (var i = 1; i <= global.max_inventory_slots; i++) {
        var idx = (start + i) mod global.max_inventory_slots;
        var cand = global.player_inventory[idx];
        if (cand != noone && instance_exists(cand)) {
            global.inventory_index = idx;
            pick_up_device(cand, instance_exists(obj_player) ? instance_find(obj_player,0) : noone);
            global.held_device = cand;
            break;
        }
    }

    // Legacy sync
    inventory = global.player_inventory;
    inventory_index = global.inventory_index;
}

/// Cycle inventory (previous)
function prev_device() {
    var inv = global.player_inventory;
    if (array_length(inv) == 0) return;

    // Clean invalid entries before cycling
    scr_device_manager.cleanup_inventory();

    if (variable_global_exists("held_device") && global.held_device != noone && instance_exists(global.held_device)) drop_device(global.held_device);

    var start = global.inventory_index;
    for (var i = 1; i <= global.max_inventory_slots; i++) {
        var idx = (start - i + global.max_inventory_slots) mod global.max_inventory_slots;
        var cand = global.player_inventory[idx];
        if (cand != noone && instance_exists(cand)) {
            global.inventory_index = idx;
            pick_up_device(cand, instance_exists(obj_player) ? instance_find(obj_player,0) : noone);
            global.held_device = cand;
            break;
        }
    }

    // Legacy sync
    inventory = global.player_inventory;
    inventory_index = global.inventory_index;
}
/// obj_device_proto Script: UpdateScreen()
function update_screen(dev_inst) {
    if (!surface_exists(dev_inst.device_screen)) return;

    surface_set_target(dev_inst.device_screen);
    draw_clear_alpha(c_black, 0);

    // Example dynamic content
    draw_text(2, 2, "Type: " + dev_inst.device_type);
    draw_text(2, 12, "Battery: " + string(dev_inst.battery) + "%");

    surface_reset_target();
}


//var scanner = instance_create_layer(x, y, "Instances", obj_device_scanner);
//add_device(scanner);
/// Inventory setup on player create event
//inventory = [];           // Array to hold device instances
//inventory_index = 0;      // Currently selected device
//held_device = noone;      // Reference to currently held device

/// Clean up inventory by removing dead/destroyed instances
function cleanup_inventory() {
    if (!variable_global_exists("player_inventory")) return;
    var changed = false;
    for (var i = 0; i < array_length(global.player_inventory); i++) {
        var v = global.player_inventory[i];
        if (v == noone) continue;
        if (!instance_exists(v)) {
            global.player_inventory[i] = noone;
            changed = true;
        }
    }
    if (changed) {
        // adjust inventory_index to nearest valid slot
        var found = false;
        for (var j = 0; j < global.max_inventory_slots; j++) {
            if (global.player_inventory[j] != noone) { global.inventory_index = j; found = true; break; }
        }
        if (!found) global.inventory_index = 0;
    }
}

///draw event on player ui 
//if (held_device != noone && surface_exists(held_device.device_screen)) {
//    var screen_w = held_device.screen_w;
//    var screen_h = held_device.screen_h;
//
    // Draw the device HUD screen in the center of the player’s view
//    draw_surface(held_device.device_screen, display_get_width()/2 - screen_w/2, display_get_height()/2 - screen_h/2);
//}
//for (var i = 0; i < array_length(inventory); i++) {
  //  update_screen(inventory[i]);
//}

