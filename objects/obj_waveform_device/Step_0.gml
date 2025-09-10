/// Step Event: Update waveform with radius filter

// Ensure surface exists
if (!surface_exists(device_surface)) {
    device_surface = surface_create(screen_w, screen_h);
}

if (trigger_active) {
    var peak = 0;

    // Player position
    var px = obj_player.x;
    var py = obj_player.y;
    var pz = obj_player.z;

    var radius = 300; // detection radius

    for (var i = 0; i < array_length(audio_sources); i++) {
        var snd_id = audio_sources[i];

        if (audio_is_playing(snd_id)) {
            // Linked sound source object
            var owner = sound_owners[i];

            if (owner != noone && instance_exists(owner)) {
                var ox = owner.x;
                var oy = owner.y;
                var oz = owner.z;

                var dist = point_distance_3d(px, py, pz, ox, oy, oz);

                if (dist <= radius) {
                    var falloff = 1 - (dist / radius);
                    peak += audio_get_volume(snd_id) * falloff;
                }
            } else {
                // No owner (global sound)
                peak += audio_get_volume(snd_id);
            }
        }
    }

    peak = clamp(peak, 0, 1);

    // Write into circular buffer
    waveform_buffer[waveform_index] = peak;
    waveform_index = (waveform_index + 1) mod buffer_length;
}
