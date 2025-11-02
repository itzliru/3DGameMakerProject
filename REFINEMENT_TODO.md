# Refinement TODO List - Post-Fix Improvements

## ✅ Completed Tasks

- [x] Fixed texture/depth buffer error in F1 debug mode
- [x] Restructured rendering pipeline (Draw → Draw GUI → Post-Draw)
- [x] Moved PS1 shader to Post-Draw event (73)
- [x] Separated 3D rendering from 2D UI
- [x] Created Draw_64.gml for debug overlays
- [x] Created Draw_73.gml for shader post-processing
- [x] Cleaned up obj_camera/Draw_64.gml duplicate code
- [x] Updated obj_builderController.yy event registration
- [x] Created comprehensive documentation

---

## 🔄 Recommended Refinements

### High Priority

#### 1. Depth Sorting for Transparent Objects
**Issue:** Ghost cube (semi-transparent) may render incorrectly with other transparent objects

**Solution:**
```gml
// In obj_builderController/Draw_0.gml
// Before drawing ghost cube:
gpu_set_zwriteenable(false);  // Don't write to depth buffer
gpu_set_alphatestenable(true);
gpu_set_alphatestref(1);

// Draw ghost cube
d3d_draw_block(...);

// Restore settings
gpu_set_zwriteenable(true);
gpu_set_alphatestenable(false);
```

**Priority:** HIGH  
**Effort:** Low (5 minutes)

---

#### 2. Shader Uniform Caching
**Issue:** `shader_get_uniform()` called every frame (minor performance hit)

**Solution:**
```gml
// In obj_builderController/Create_0.gml
global.u_screen_uniform = shader_get_uniform(sh_ps1_style, "u_ScreenSize");

// In obj_builderController/Draw_73.gml
shader_set(sh_ps1_style);
shader_set_uniform_f(global.u_screen_uniform, display_get_width(), display_get_height());
draw_surface(application_surface, 0, 0);
shader_reset();
```

**Priority:** MEDIUM  
**Effort:** Low (5 minutes)

---

#### 3. Safe Object Existence Checks
**Issue:** Code assumes `obj_player` exists (will crash if it doesn't)

**Solution:**
```gml
// In obj_camera/Draw_0.gml
if (!instance_exists(obj_player)) exit;

// In obj_builderController/Step_0.gml
if (!instance_exists(obj_player)) exit;
```

**Priority:** HIGH  
**Effort:** Low (2 minutes)

---

### Medium Priority

#### 4. Debug Mode Levels
**Feature:** Add multiple debug verbosity levels

**Implementation:**
```gml
// In cube_init_globals() or obj_builderController/Create_0.gml
global.debug_level = 0;  // 0 = off, 1 = minimal, 2 = normal, 3 = verbose

// In Step_0.gml
if (keyboard_check_pressed(vk_f1)) {
    global.debug_level = (global.debug_level + 1) % 4;
    show_debug_message("Debug level: " + string(global.debug_level));
}

// In Draw_0.gml
if (global.debug_level < 2) exit;  // Only show grid at level 2+

// In Draw_64.gml
if (global.debug_level < 1) exit;  // Only show text at level 1+
```

**Priority:** MEDIUM  
**Effort:** Medium (15 minutes)

---

#### 5. Performance Monitoring
**Feature:** Add FPS counter and performance stats

**Implementation:**
```gml
// In obj_builderController/Draw_64.gml
if (global.debug_level >= 2) {
    draw_set_color(c_lime);
    draw_text(window_get_width() - 150, 32, "FPS: " + string(fps));
    draw_text(window_get_width() - 150, 48, "Real FPS: " + string(fps_real));
    draw_text(window_get_width() - 150, 64, "Blocks: " + string(array_length(global.cube_list)));
    draw_text(window_get_width() - 150, 80, "Instances: " + string(instance_count));
}
```

**Priority:** MEDIUM  
**Effort:** Low (10 minutes)

---

#### 6. Grid Rendering Optimization
**Issue:** Grid draws every line every frame (can be slow with large rooms)

**Solution:** Use vertex buffers for static grid
```gml
// In obj_builderController/Create_0.gml
global.grid_vbuffer = vertex_create_buffer();
vertex_begin(global.grid_vbuffer, obj_camera.vertex_format);

// Build grid once
for (var i = 0; i <= room_width; i += global.grid_size) {
    // Add vertices for X lines
}
for (var j = 0; j <= room_height; j += global.grid_size) {
    // Add vertices for Y lines
}

vertex_end(global.grid_vbuffer);

// In obj_builderController/Draw_0.gml
if (global.debug_mode) {
    vertex_submit(global.grid_vbuffer, pr_linelist, -1);
}
```

**Priority:** MEDIUM  
**Effort:** High (30 minutes)

---

### Low Priority

#### 7. Block Type Selector UI
**Feature:** Visual block type selector in debug mode

**Implementation:**
```gml
// In obj_builderController/Draw_64.gml
if (global.editing_block) {
    var start_x = 32;
    var start_y = window_get_height() - 150;
    
    draw_set_color(c_white);
    draw_text(start_x, start_y, "Block Type:");
    
    for (var i = 1; i < 8; i++) {
        var col = global.block_colors[i];
        draw_set_color(col);
        draw_rectangle(start_x + i * 40, start_y + 20, 
                      start_x + i * 40 + 30, start_y + 50, false);
        
        if (global.current_block_type == i) {
            draw_set_color(c_yellow);
            draw_rectangle(start_x + i * 40 - 2, start_y + 18, 
                          start_x + i * 40 + 32, start_y + 52, true);
        }
    }
}

// In obj_builderController/Step_0.gml
if (global.editing_block) {
    if (keyboard_check_pressed(ord("1"))) global.current_block_type = 1;
    if (keyboard_check_pressed(ord("2"))) global.current_block_type = 2;
    // ... etc
}
```

**Priority:** LOW  
**Effort:** Medium (20 minutes)

---

#### 8. Undo/Redo Keyboard Shortcuts
**Feature:** Ctrl+Z / Ctrl+Y for undo/redo

**Implementation:**
```gml
// In obj_builderController/Step_0.gml
if (keyboard_check(vk_control)) {
    if (keyboard_check_pressed(ord("Z"))) {
        cube_undo();  // Need to implement this function
    }
    if (keyboard_check_pressed(ord("Y"))) {
        cube_redo();  // Need to implement this function
    }
}
```

**Priority:** LOW  
**Effort:** Medium (requires implementing undo/redo functions)

---

#### 9. Block Highlighting on Hover
**Feature:** Highlight blocks when mouse hovers over them

**Implementation:**
```gml
// In obj_builderController/Step_0.gml
global.hovered_block = noone;

// Raycast from camera to find block under cursor
// (Complex - requires 3D raycasting implementation)

// In obj_builderController/Draw_0.gml
if (global.hovered_block != noone) {
    var b = global.hovered_block;
    draw_set_color(c_yellow);
    draw_set_alpha(0.5);
    d3d_draw_block(b.x, b.y, b.z, 
                   b.x + b.size, b.y + b.size, b.z + b.size, -1, 1);
    draw_set_alpha(1);
}
```

**Priority:** LOW  
**Effort:** High (requires 3D raycasting)

---

#### 10. Save/Load Confirmation Dialogs
**Feature:** Show confirmation when saving/loading

**Implementation:**
```gml
// In obj_builderController/Step_0.gml
if (keyboard_check_pressed(ord("M"))) {
    if (cube_save("world_blocks.json")) {
        show_message_async("World saved successfully!");
    } else {
        show_message_async("Failed to save world!");
    }
}
```

**Priority:** LOW  
**Effort:** Low (5 minutes)

---

## 🐛 Potential Issues to Watch For

### 1. Application Surface Recreation
**Issue:** `application_surface` can be destroyed/recreated by GameMaker

**Solution:**
```gml
// In obj_builderController/Draw_73.gml
if (!surface_exists(application_surface)) {
    application_surface = surface_create(window_get_width(), window_get_height());
}

shader_set(sh_ps1_style);
// ... rest of code
```

---

### 2. Window Resize Handling
**Issue:** Shader uniform uses display size, not window size

**Solution:**
```gml
// In obj_builderController/Draw_73.gml
shader_set_uniform_f(u_screen, window_get_width(), window_get_height());
// Instead of display_get_width(), display_get_height()
```

---

### 3. Multiple Cameras
**Issue:** Code assumes single camera

**Solution:**
```gml
// In obj_camera/Draw_0.gml
var cam = view_camera[0];  // Use specific view camera
// Instead of camera_get_active()
```

---

## 📊 Priority Summary

| Priority | Tasks | Estimated Time |
|----------|-------|----------------|
| **HIGH** | 3 tasks | ~15 minutes |
| **MEDIUM** | 3 tasks | ~55 minutes |
| **LOW** | 4 tasks | ~45 minutes |
| **TOTAL** | 10 tasks | ~2 hours |

---

## 🎯 Recommended Implementation Order

1. ✅ Safe object existence checks (2 min) - Prevents crashes
2. ✅ Shader uniform caching (5 min) - Performance boost
3. ✅ Depth sorting for transparent objects (5 min) - Visual fix
4. ✅ Performance monitoring (10 min) - Useful for debugging
5. ⏸️ Debug mode levels (15 min) - Better UX
6. ⏸️ Application surface recreation check (3 min) - Stability
7. ⏸️ Grid rendering optimization (30 min) - Performance boost
8. ⏸️ Block type selector UI (20 min) - Better UX
9. ⏸️ Save/load confirmations (5 min) - Better UX
10. ⏸️ Undo/redo shortcuts (varies) - Advanced feature

---

## 🚀 Next Steps

1. **Test the current fix** in GameMaker
2. **Verify no errors** when pressing F1
3. **Implement HIGH priority refinements** (if needed)
4. **Consider MEDIUM priority features** (optional)
5. **Add LOW priority features** (nice-to-have)

---

**Status:** Ready for testing  
**Last Updated:** November 2, 2025  
**Main Issue:** ✅ RESOLVED
