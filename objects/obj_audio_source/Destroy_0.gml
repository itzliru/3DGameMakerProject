/// Destroy Event of obj_audio_source

if (audio_is_playing(sound_id)) {
    audio_stop_sound(sound_id);
}

// Also unregister from the waveform device
if (instance_exists(obj_waveform_device)) {
    var dev = obj_waveform_device;
    
    var idx = array_index_of(dev.audio_sources, sound_id);
    if (idx != -1) {
        array_delete(dev.audio_sources, idx, 1);
        array_delete(dev.sound_owners, idx, 1);
    }
}
