
/// Collision Event with obj_player

if (!held_by_player && place_meeting(x, y, obj_player)) {
    held_by_player = true;
    trigger_active = true;
    // Optionally move out of room
    // x = y = z = -9999;
}
