/// @description Insert description here
// You can write your code in this editor
// Toggle pause with ESC
if (keyboard_check_pressed(vk_f2)) {
    global.paused = !global.paused;
}

// Stop game updates if paused
if (global.paused) {
    exit; // cancels the rest of this Step event
}
