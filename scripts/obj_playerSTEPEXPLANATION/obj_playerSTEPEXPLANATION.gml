//// this is the mouse controlls in Step event 
//direction -= sensitivity * (display_mouse_get_x() - display_get_width() * 0.5);
//pitch     -= sensitivity * (display_mouse_get_y() - display_get_height() * 0.5);

// Clamp vertical look so you can’t flip upside down
//pitch = clamp(pitch, -80, 80);

// Lock cursor back to center each step
//display_mouse_set(display_get_width() * 0.5, display_get_height() * 0.5);
///// Works fine. This is a common FPS-style mouse look.
///⚠️ Note: direction is yaw (left/right look), pitch is up/down look.
//If you add roll later, keep them separate.
////key board stuff 
//var fb_keys = (keyboard_check(ord("W"))) - (keyboard_check(ord("S"))); 
//var rl_keys = (keyboard_check(ord("A"))) - (keyboard_check(ord("D"))); 

//fb_vel += fb_keys * acc;
//rl_vel -= rl_keys * acc;
