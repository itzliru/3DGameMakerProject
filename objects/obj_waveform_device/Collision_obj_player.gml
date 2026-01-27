
/// Collision Event with obj_player (robust 3D proximity pickup)
var pickup_radius = 48; // world units
var p = instance_nearest(x, y, obj_player);
if (p != noone && !held_by_player) {
    var d3 = point_distance_3d(x, y, z, p.x, p.y, p.z);
    if (d3 <= pickup_radius) {
        // Prefer device manager API if present
        var added = false;
        if (is_callable(add_device)) {
            added = add_device(id, p); // add_device handles globals and returns bool
        }
        if (!added) {
            // Fallback: local pickup behaviour
            held_by_player = true;
            player_ref = p;
        }

        if (added) {
            // play pickup SFX if available
            if (asset_get_index("snd_pickup") != -1) audio_play_sound(snd_pickup, 1, false);
            instance_destroy();
        }
    }
}
