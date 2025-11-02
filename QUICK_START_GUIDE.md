# Block System Quick Start Guide

## 🚀 Getting Started in 3 Steps

### Step 1: Initialize the System
In your `obj_game` or `obj_builderController` **Create Event**, add:

```gml
cube_init_globals();
```

That's it! The system is now ready to use.

---

### Step 2: Place Your First Block

```gml
// Place a grass block at position (0, 0, 0)
var my_block = cube_add(0, 0, 0);

// Place a stone block with custom size
var stone = cube_add(64, 0, 0, 32, true, global.block_types.stone);
```

---

### Step 3: Save Your World

```gml
// Save
if (cube_save("my_world.json")) {
    show_debug_message("World saved!");
}

// Load
if (cube_load("my_world.json")) {
    show_debug_message("World loaded!");
}
```

---

## 🎮 Keyboard Controls

Press **F1** to enable debug mode, then:

| Key | Action |
|-----|--------|
| **P** | Toggle block editing mode |
| **Enter** | Place block |
| **R** | Remove block |
| **+/-** | Adjust Z height |
| **[/]** | Change block size |
| **M** | Save world |
| **L** | Load world |
| **Shift+M** | Quick save |
| **Shift+L** | Quick load |

---

## 📦 Common Operations

### Check if Position is Occupied
```gml
var existing = cube_get_at_position(x, y, z);
if (is_undefined(existing)) {
    // Position is free
    cube_add(x, y, z);
}
```

### Remove a Block
```gml
if (cube_remove(x, y, z)) {
    show_debug_message("Block removed!");
}
```

### Check Collision
```gml
if (cube_collision_check(player.x, player.y, player.z)) {
    // Player is inside a block!
}
```

### Duplicate a Block
```gml
// Duplicate block at index 0, offset by 64 units on X axis
var new_block = cube_duplicate(0, 64, 0, 0);
```

---

## 🎨 Block Types

```gml
global.block_types.air      // 0
global.block_types.grass    // 1 (green)
global.block_types.dirt     // 2 (brown)
global.block_types.stone    // 3 (gray)
global.block_types.wood     // 4 (brown)
global.block_types.sand     // 5 (tan)
global.block_types.water    // 6 (blue)
global.block_types.glass    // 7 (light blue)
```

### Change Current Block Type
```gml
global.current_block_type = global.block_types.stone;
```

---

## 🔧 Troubleshooting

### "Cannot place cube: position already occupied"
**Solution:** Check if position is free first:
```gml
if (is_undefined(cube_get_at_position(x, y, z))) {
    cube_add(x, y, z);
}
```

### "Cannot load cubes: file not found"
**Solution:** Make sure the file exists:
```gml
if (file_exists("my_world.json")) {
    cube_load("my_world.json");
}
```

### Blocks not appearing
**Solution:** Make sure you called `cube_init_globals()` in Create event

---

## 📚 Need More Help?

- **Full API Reference:** See `BLOCK_SYSTEM_DOCUMENTATION.md`
- **All Changes:** See `REFINEMENT_SUMMARY.md`
- **Debug Console:** Check for error messages (F1 to enable debug mode)

---

## 💡 Pro Tips

1. **Always check return values** - Functions return `undefined` or `false` on failure
2. **Use quick save/load** - Shift+M and Shift+L for rapid testing
3. **Enable debug mode** - Press F1 to see block info and grid
4. **Save often** - Use autosave with `cube_quick_save()` in a timer
5. **Check the console** - All operations log debug messages

---

## 🎯 Example: Complete Block Placer

```gml
/// obj_builderController Create Event
cube_init_globals();
global.debug_mode = true;
global.editing_block = true;

/// obj_builderController Step Event
// Place block on left click
if (mouse_check_button_pressed(mb_left)) {
    var grid_x = floor(mouse_x / global.grid_size) * global.grid_size;
    var grid_y = floor(mouse_y / global.grid_size) * global.grid_size;
    
    var block = cube_add(grid_x, grid_y, 0);
    if (!is_undefined(block)) {
        show_debug_message("Block placed!");
    }
}

// Remove block on right click
if (mouse_check_button_pressed(mb_right)) {
    var grid_x = floor(mouse_x / global.grid_size) * global.grid_size;
    var grid_y = floor(mouse_y / global.grid_size) * global.grid_size;
    
    if (cube_remove(grid_x, grid_y, 0)) {
        show_debug_message("Block removed!");
    }
}

// Save on S key
if (keyboard_check_pressed(ord("S"))) {
    cube_save("my_world.json");
}

/// obj_builderController Draw Event
// Draw all blocks
for (var i = 0; i < array_length(global.cube_list); i++) {
    var cube = global.cube_list[i];
    draw_set_color(cube.color);
    d3d_draw_block(cube.x, cube.y, cube.z, 
                   cube.x + cube.size, 
                   cube.y + cube.size, 
                   cube.z + cube.size, -1, 1);
}
```

---

**Ready to build? Start placing blocks! 🎮**
