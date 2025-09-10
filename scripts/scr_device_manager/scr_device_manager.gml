/// Drop device
function drop_device(dev_inst) {
    dev_inst.held = false;
    dev_inst.player_ref = noone;
    dev_inst.z = 0; // Drop to floor
}
/// Drop currently held device
function drop_current_device() {
    if (held_device != noone) {
        drop_device(held_device);
        held_device = noone;
    }
}

function pick_up_device(dev_inst, player_inst) {
    dev_inst.held = true;
    dev_inst.player_ref = player_inst;
}

/// Add device to inventory
function add_device(dev_inst) {
    array_push(inventory, dev_inst);
    pick_up_device(dev_inst, id);
}

/// Cycle inventory (next)
function next_device() {
    if (array_length(inventory) > 0) {
        // Drop current device
        if (held_device != noone) drop_device(held_device);

        // Move index
        inventory_index += 1;
        if (inventory_index >= array_length(inventory)) inventory_index = 0;

        // Pick up new device
        held_device = inventory[inventory_index];
        pick_up_device(held_device, id);
    }
}

/// Cycle inventory (previous)
function prev_device() {
    if (array_length(inventory) > 0) {
        if (held_device != noone) drop_device(held_device);

        inventory_index -= 1;
        if (inventory_index < 0) inventory_index = array_length(inventory) - 1;

        held_device = inventory[inventory_index];
        pick_up_device(held_device, id);
    }
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

