/// Create Event of obj_audio_source

// Ensure we have a z variable for 3D positioning
z = 0; // or whatever default you want

// Play a looping sound at this world position
sound_id = audio_play_sound_at(snd_generator_hum, x, y, z, 50, 300, 1, true, 1);

// Register with the waveform device if it exists
if (instance_exists(obj_waveform_device)) {
    var dev = obj_waveform_device;

    // Make sure the device has its arrays
    if (!variable_instance_exists(dev, "audio_sources")) dev.audio_sources = [];
    if (!variable_instance_exists(dev, "sound_owners")) dev.sound_owners  = [];

    // Add this sound + owner instance
    array_push(dev.audio_sources, sound_id);
    array_push(dev.sound_owners, id);
}
