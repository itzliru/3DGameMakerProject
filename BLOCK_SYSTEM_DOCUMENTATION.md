# Block Placement System Documentation

## Overview
This document describes the refined block placement system for the 3D Open World RPG project. The system has been modernized with improved error handling, spatial optimization, and additional features.

---

## Core Functions

### Initialization

#### `cube_init_globals()`
Initializes all block-related global variables. **Call this once at game start** (e.g., in `obj_game` or `obj_builderController` Create event).

**Initializes:**
- `global.cube_list` - Array of all placed cubes
- `global.block_id` - Unique ID counter
- `global.grid_size` - Default grid size (64)
- `global.cube_spatial_hash` - DS map for fast collision lookups
- `global.block_types` - Block type definitions (grass, dirt, stone, etc.)
- `global.block_colors` - Color mapping for each block type
- `global.cube_undo_stack` - Undo history
- `global.cube_redo_stack` - Redo history
- `global.current_block_type` - Currently selected block type

---

### Block Placement

#### `cube_add(x, y, z, [size], [collision], [block_type])`
Adds a new cube/block to the world.

**Parameters:**
- `x` (real) - X coordinate
- `y` (real) - Y coordinate
- `z` (real) - Z coordinate
- `size` (real, optional) - Cube size (defaults to `global.grid_size`)
- `collision` (bool, optional) - Enable collision (defaults to `true`)
- `block_type` (real, optional) - Block material type (defaults to `global.current_block_type`)

**Returns:** Cube struct if successful, `undefined` if placement failed

**Features:**
- Duplicate position checking (prevents overlapping blocks)
- Automatic spatial hash updates
- Undo stack integration
- Debug logging

**Example:**
```gml
// Place a grass block at (0, 0, 0)
var cube = cube_add(0, 0, 0);

// Place a stone block with custom size
var stone = cube_add(64, 0, 0, 32, true, global.block_types.stone);
```

---

### Block Removal

#### `cube_remove(x, y, z)`
Removes a cube at the specified position.

**Parameters:**
- `x` (real) - X coordinate
- `y` (real) - Y coordinate
- `z` (real) - Z coordinate

**Returns:** `true` if removed, `false` if no cube found

**Features:**
- Automatic spatial hash cleanup
- Undo stack integration
- Debug logging

**Example:**
```gml
if (cube_remove(0, 0, 0)) {
    show_debug_message("Block removed successfully");
}
```

#### `cube_remove_by_index(index)`
Removes a cube by its array index.

**Parameters:**
- `index` (real) - Array index in `global.cube_list`

**Returns:** `true` if removed, `false` otherwise

---

### Block Queries

#### `cube_get_at_position(x, y, z)`
Finds a cube at the specified position.

**Parameters:**
- `x` (real) - X coordinate
- `y` (real) - Y coordinate
- `z` (real) - Z coordinate

**Returns:** Cube struct if found, `undefined` otherwise

**Example:**
```gml
var cube = cube_get_at_position(0, 0, 0);
if (!is_undefined(cube)) {
    show_debug_message("Found cube ID: " + string(cube.id));
}
```

#### `cube_get_index_at_position(x, y, z)`
Finds the array index of a cube at the specified position.

**Returns:** Array index if found, `-1` otherwise

---

### Collision Detection

#### `cube_collision_check(x, y, z)`
Checks if a point collides with any cube.

**Parameters:**
- `x` (real) - X coordinate
- `y` (real) - Y coordinate
- `z` (real) - Z coordinate

**Returns:** `true` if collision detected, `false` otherwise

**Example:**
```gml
if (cube_collision_check(player.x, player.y, player.z)) {
    // Player is inside a block
}
```

#### `cube_collision_check_box(x1, y1, z1, x2, y2, z2)`
Checks if a 3D box (AABB) collides with any cube.

**Parameters:**
- `x1, y1, z1` (real) - Minimum corner of box
- `x2, y2, z2` (real) - Maximum corner of box

**Returns:** `true` if collision detected, `false` otherwise

**Example:**
```gml
// Check if player bounding box collides
if (cube_collision_check_box(player.x, player.y, player.z, 
                              player.x + 32, player.y + 32, player.z + 64)) {
    // Collision detected
}
```

#### `cube_collision_get(x, y, z)`
Gets the cube that a point collides with.

**Returns:** Cube struct if collision, `undefined` otherwise

---

### Block Duplication

#### `cube_duplicate(index, [offset_x], [offset_y], [offset_z])`
Duplicates a cube at a new position.

**Parameters:**
- `index` (real) - Array index of cube to duplicate
- `offset_x` (real, optional) - X offset (defaults to `global.grid_size`)
- `offset_y` (real, optional) - Y offset (defaults to 0)
- `offset_z` (real, optional) - Z offset (defaults to 0)

**Returns:** New cube struct if successful, `undefined` otherwise

**Example:**
```gml
// Duplicate the first cube, offset by one grid unit to the right
var new_cube = cube_duplicate(0, 64, 0, 0);
```

#### `cube_duplicate_at_position(x, y, z, [offset_x], [offset_y], [offset_z])`
Duplicates a cube by its position.

---

### Save/Load System

#### `cube_save([filename])`
Saves all cubes to a JSON file.

**Parameters:**
- `filename` (string, optional) - Filename (defaults to "world_blocks.json")

**Returns:** `true` if successful, `false` otherwise

**Save Format:**
```json
{
  "version": "1.0",
  "timestamp": 45123.456,
  "block_count": 150,
  "cubes": [
    {
      "id": 0,
      "x": 0,
      "y": 0,
      "z": 0,
      "size": 64,
      "collision": true,
      "block_type": 1,
      "color": 8900346,
      "mask": {...}
    },
    ...
  ]
}
```

**Example:**
```gml
if (cube_save("my_world.json")) {
    show_debug_message("World saved!");
}
```

#### `cube_load([filename], [clear_existing])`
Loads cubes from a JSON file.

**Parameters:**
- `filename` (string, optional) - Filename (defaults to "world_blocks.json")
- `clear_existing` (bool, optional) - Clear existing cubes first (defaults to `true`)

**Returns:** `true` if successful, `false` otherwise

**Example:**
```gml
if (cube_load("my_world.json")) {
    show_debug_message("World loaded!");
}
```

#### `cube_quick_save()` / `cube_quick_load()`
Quick save/load shortcuts using "world_blocks_quicksave.json"

---

## Block Types

The system includes predefined block types:

| Type | ID | Default Color |
|------|----|--------------| 
| Air | 0 | White |
| Grass | 1 | Green (34, 139, 34) |
| Dirt | 2 | Brown (139, 69, 19) |
| Stone | 3 | Gray (128, 128, 128) |
| Wood | 4 | Brown (139, 90, 43) |
| Sand | 5 | Tan (238, 214, 175) |
| Water | 6 | Blue (30, 144, 255) |
| Glass | 7 | Light Blue (173, 216, 230) |

**Access via:**
```gml
global.block_types.grass
global.block_types.stone
// etc.
```

---

## Builder Controller Controls

### Keyboard Controls (when `global.debug_mode` is enabled)

| Key | Action |
|-----|--------|
| **F1** | Toggle debug mode |
| **P** | Toggle block editing mode |
| **+** | Increase Z plane |
| **-** | Decrease Z plane |
| **[** | Decrease block size |
| **]** | Increase block size |
| **Enter** | Place block at ghost position |
| **R** | Remove block at ghost position |
| **M** | Save world |
| **L** | Load world |
| **Shift+M** | Quick save |
| **Shift+L** | Quick load |

---

## Cube Data Structure

Each cube is stored as a struct with the following properties:

```gml
{
    id: 0,              // Unique identifier
    x: 0,               // X position
    y: 0,               // Y position
    z: 0,               // Z position
    size: 64,           // Cube size
    collision: true,    // Collision enabled
    block_type: 1,      // Material type
    color: 8900346,     // Render color
    mask: {             // Collision bounds
        left: 0,
        right: 64,
        top: 0,
        bottom: 64,
        front: 0,
        back: 64
    }
}
```

---

## Performance Optimization

### Spatial Hashing
The system uses a spatial hash map (`global.cube_spatial_hash`) for O(1) position lookups instead of O(n) linear searches.

**Key format:** `"x,y,z"` → array index

**Automatic updates:**
- Updated on `cube_add()`
- Cleaned on `cube_remove()`
- Rebuilt via `cube_rebuild_spatial_hash()`

---

## Undo/Redo System

The system tracks block placement and removal actions:

- **Undo Stack:** `global.cube_undo_stack`
- **Redo Stack:** `global.cube_redo_stack`
- **Max History:** `global.cube_max_undo` (default: 50)

**Action Format:**
```gml
{
    action: "add" or "remove",
    cube: {...},
    index: 0
}
```

---

## Migration Guide

### Old Code → New Code

**Old:**
```gml
cube_add(x, y, z, size, collision);
```

**New:**
```gml
var cube = cube_add(x, y, z, size, collision, block_type);
if (is_undefined(cube)) {
    // Handle placement failure
}
```

**Old:**
```gml
cube_remove(x, y, z);
```

**New:**
```gml
if (cube_remove(x, y, z)) {
    // Block removed successfully
}
```

**Old:**
```gml
cube_save(filename);
cube_load(filename);
```

**New:**
```gml
if (cube_save(filename)) {
    show_debug_message("Save successful");
}

if (cube_load(filename)) {
    show_debug_message("Load successful");
}
```

---

## Best Practices

1. **Always initialize:** Call `cube_init_globals()` at game start
2. **Check return values:** Use return values to handle failures gracefully
3. **Use spatial hash:** The system automatically maintains it for fast lookups
4. **Save regularly:** Implement autosave using `cube_quick_save()`
5. **Validate positions:** Check for existing blocks before placement
6. **Clean up:** The system handles cleanup automatically

---

## Troubleshooting

### "Cannot place cube: position already occupied"
- A cube already exists at that position
- Use `cube_get_at_position()` to check before placing

### "Cannot load cubes: file not found"
- File doesn't exist or path is incorrect
- Use `file_exists()` to verify before loading

### Spatial hash out of sync
- Call `cube_rebuild_spatial_hash()` to rebuild
- This happens automatically after removals

---

## Future Enhancements

Potential additions to the system:
- Chunk-based world management
- Multi-block selection and operations
- Block rotation and orientation
- Custom block shapes (stairs, slabs, etc.)
- Texture/sprite support per block type
- Lighting system integration
- Network synchronization for multiplayer

---

**Last Updated:** November 2, 2025
**Version:** 1.0
