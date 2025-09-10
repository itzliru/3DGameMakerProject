/// Create Event
if (!variable_instance_exists(id, "z")) z = 0;

// Waveform buffer
buffer_length = 64;
waveform_buffer = array_create(buffer_length, 0);
waveform_index = 0;
bar_width = 1;

// Screen rectangle inside device sprite
screen_offset_x = 8;
screen_offset_y = 10;
screen_w = 50;
screen_h = 60;

// Device surface for waveform
device_surface = -1;

// State
held_by_player = false;   // starts in the world
trigger_active = false;

// Audio sources
audio_sources = [];
sound_owners  = [];
