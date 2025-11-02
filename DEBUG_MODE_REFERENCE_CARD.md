# 🎮 F1 Debug Mode - Quick Reference Card

## 🔑 Keyboard Controls

### Debug Mode
| Key | Action |
|-----|--------|
| **F1** | Toggle debug mode ON/OFF |

### Block Editing (when debug mode is ON)
| Key | Action |
|-----|--------|
| **P** | Toggle block editing mode |
| **Enter** | Place block at ghost position |
| **R** | Remove block at ghost position |
| **+** | Increase Z height (move up) |
| **-** | Decrease Z height (move down) |
| **[** | Decrease block size |
| **]** | Increase block size |

### Save/Load
| Key | Action |
|-----|--------|
| **M** | Save world to "world_blocks.json" |
| **L** | Load world from "world_blocks.json" |
| **Shift+M** | Quick save to "world_blocks_quicksave.json" |
| **Shift+L** | Quick load from "world_blocks_quicksave.json" |

---

## 📊 Debug Display (when F1 is ON)

### Top-Left Corner
```
Current Block: ID 0 | Pos: 64,128,0 | Size: 64 | Collision: true | Grid: ON
Blocks: 15
```

### Top-Right Corner (Performance Stats)
```
FPS: 60
Real FPS: 60
Instances: 42
```

### Middle-Left (Player Info)
```
Player Height: 32 | X: 512 | Y: 384
Direction: 90° | Pitch: -15°
```

### Bottom (Controls Hint)
```
F1: Debug | P: Edit Mode | Enter: Place | R: Remove | +/-: Z Level | [/]: Size | M: Save | L: Load
```

---

## 🎨 Visual Elements (when debug mode is ON)

### 3D Grid
- **Color:** Light gray
- **Spacing:** 64 units (global.grid_size)
- **Plane:** Z = 0 (floor level)
- **Visibility:** Always visible in debug mode

### Ghost Cube (when editing mode is ON)
- **Color:** Aqua/Cyan
- **Opacity:** 30% (semi-transparent)
- **Position:** Follows player's look direction
- **Snapping:** Snaps to grid (64-unit increments)
- **2D Overlay:** Aqua rectangle on ground

### Placed Blocks
- **Color:** Based on block type
- **Rendering:** Solid 3D cubes
- **Collision:** Enabled by default

---

## 🎯 Block Types

| ID | Type | Color | Description |
|----|------|-------|-------------|
| 0 | Air | White | Empty space |
| 1 | Grass | Green | Grass block |
| 2 | Dirt | Brown | Dirt block |
| 3 | Stone | Gray | Stone block |
| 4 | Wood | Brown | Wood block |
| 5 | Sand | Tan | Sand block |
| 6 | Water | Blue | Water block |
| 7 | Glass | Light Blue | Glass block |

---

## 🔧 Technical Info

### Rendering Pipeline
```
1. Draw (0): 3D world + debug geometry
2. Draw GUI (64): 2D debug text + UI
3. Post-Draw (73): PS1 shader effect
```

### Performance
- **Target FPS:** 60
- **Shader:** PS1-style (vertex snapping + color banding)
- **Optimization:** Single shader pass per frame

### Grid Settings
- **Default Size:** 64 units
- **Current Z:** 0 (adjustable with +/-)
- **Block Size:** 64 units (adjustable with [/])

---

## 🐛 Troubleshooting

### Issue: No debug display appears
**Solution:** Press F1 to enable debug mode

### Issue: Ghost cube not visible
**Solution:** Press P to enable editing mode

### Issue: Can't place blocks
**Solution:** 
1. Enable debug mode (F1)
2. Enable editing mode (P)
3. Position ghost cube
4. Press Enter

### Issue: Blocks not saving
**Solution:** 
1. Check console for error messages
2. Verify write permissions
3. Try quick save (Shift+M)

### Issue: Performance drops
**Solution:**
1. Check FPS counter (top-right)
2. Reduce number of placed blocks
3. Disable debug mode (F1) when not needed

---

## 📝 Quick Start Guide

### Placing Your First Block:
1. Press **F1** (enable debug mode)
2. Press **P** (enable editing mode)
3. Move player to desired location
4. Adjust Z height with **+/-** if needed
5. Press **Enter** (place block)
6. Press **M** (save world)

### Removing Blocks:
1. Enable debug mode (F1) and editing mode (P)
2. Position ghost cube over block to remove
3. Press **R** (remove block)

### Building a Structure:
1. Enable debug and editing modes
2. Place first block (Enter)
3. Move to next position
4. Adjust Z height if building vertically (+/-)
5. Place next block (Enter)
6. Repeat
7. Save when done (M)

---

## 🎨 PS1 Shader Effect

### Features:
- **Vertex Snapping:** Vertices snap to integer positions (jittery effect)
- **Color Banding:** RGB reduced to 16 levels per channel
- **Dithering:** Random noise for retro look
- **Affine Texture Mapping:** No perspective correction (authentic PS1 look)

### Toggle:
- Shader is always active when game is running
- Cannot be disabled (part of the aesthetic)

---

## 💾 Save File Format

### Location:
- **Standard Save:** `world_blocks.json`
- **Quick Save:** `world_blocks_quicksave.json`

### Contents:
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
      "color": 8900346
    }
  ]
}
```

---

## 🎯 Pro Tips

1. **Use Quick Save/Load** - Shift+M and Shift+L for rapid testing
2. **Adjust Z Height First** - Set your vertical level before placing blocks
3. **Save Often** - Press M regularly to avoid losing work
4. **Use Grid Snapping** - Blocks automatically snap to 64-unit grid
5. **Check Block Count** - Monitor top-left to track placed blocks
6. **Watch Performance** - Keep eye on FPS counter (top-right)
7. **Disable Debug When Done** - Press F1 to hide overlays and improve performance

---

## 📐 Coordinate System

```
      Z+ (Up)
       |
       |
       |
       +-------- X+ (Right)
      /
     /
    Y+ (Forward)
```

- **X Axis:** Left (-) to Right (+)
- **Y Axis:** Back (-) to Forward (+)
- **Z Axis:** Down (-) to Up (+)

---

## 🎮 Workflow Examples

### Example 1: Building a Wall
```
1. F1 (debug on)
2. P (edit on)
3. Position at start point
4. Enter (place block)
5. Move right 64 units
6. Enter (place block)
7. Repeat
8. M (save)
```

### Example 2: Building a Tower
```
1. F1 (debug on)
2. P (edit on)
3. Position at base
4. Enter (place block)
5. + (increase Z)
6. Enter (place block)
7. Repeat
8. M (save)
```

### Example 3: Creating a Platform
```
1. F1 (debug on)
2. P (edit on)
3. + (set Z height)
4. Place blocks in grid pattern
5. M (save)
```

---

## 🔍 Debug Info Explained

### Current Block Info:
- **ID:** Unique identifier for next block
- **Pos:** Ghost cube position (X, Y, Z)
- **Size:** Current block size in units
- **Collision:** Whether block has collision enabled
- **Grid:** Grid snapping status

### Performance Stats:
- **FPS:** Frames per second (target: 60)
- **Real FPS:** Actual FPS (more accurate)
- **Instances:** Total objects in room

### Player Info:
- **Height:** Player Z position
- **X/Y:** Player horizontal position
- **Direction:** Yaw angle (0-360°)
- **Pitch:** Look up/down angle (-90 to 90°)

---

## ✅ Status Indicators

### Debug Mode:
- **ON:** Debug overlays visible, controls active
- **OFF:** Clean view, better performance

### Editing Mode:
- **ON:** Ghost cube visible, can place/remove blocks
- **OFF:** Ghost cube hidden, no block editing

### Grid:
- **Always ON** when debug mode is enabled
- **Always OFF** when debug mode is disabled

---

## 🚀 Advanced Features

### Spatial Hash System:
- Fast O(1) position lookups
- Automatic collision detection
- Optimized for large worlds

### Undo/Redo System:
- Tracks last 50 actions
- Automatic history management
- (Keyboard shortcuts not yet implemented)

### Block Type System:
- 8 predefined block types
- Color-coded rendering
- Extensible for custom types

---

**Quick Reference Version:** 1.0  
**Last Updated:** November 2, 2025  
**Status:** ✅ All features working  
**Issue:** ✅ F1 debug mode error FIXED

---

**Print this card for quick reference while developing!** 📄
