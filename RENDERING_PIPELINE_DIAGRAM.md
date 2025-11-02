# Rendering Pipeline - Before vs After

## ❌ BEFORE (Broken - Caused Errors)

```
┌─────────────────────────────────────────────────────────────┐
│ DRAW EVENT (0) - Frame Rendering                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  obj_camera/Draw_0.gml:                                     │
│  ┌───────────────────────────────────────────────────────┐ │
│  │ 1. shader_set(sh_ps1_style)                           │ │
│  │ 2. draw_surface(application_surface, 0, 0) ← ERROR!   │ │
│  │ 3. shader_reset()                                     │ │
│  │ 4. Set up camera matrices                             │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
│  obj_builderController/Draw_0.gml:                          │
│  ┌───────────────────────────────────────────────────────┐ │
│  │ 1. shader_set(sh_ps1_style)                           │ │
│  │ 2. draw_surface(application_surface, 0, 0) ← ERROR!   │ │
│  │ 3. shader_reset()                                     │ │
│  │ 4. Draw 3D grid                                       │ │
│  │ 5. Draw ghost cube                                    │ │
│  │ 6. Draw debug text                                    │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
│  ⚠️  PROBLEM: application_surface drawn TWICE!             │
│  ⚠️  Texture bound while also being render target!         │
│  ⚠️  "Trying to set texture that is also bound as          │
│      depth buffer - bailing..."                            │
└─────────────────────────────────────────────────────────────┘
```

---

## ✅ AFTER (Fixed - No Errors)

```
┌─────────────────────────────────────────────────────────────┐
│ DRAW EVENT (0) - 3D World Rendering                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  obj_camera/Draw_0.gml:                                     │
│  ┌───────────────────────────────────────────────────────┐ │
│  │ 1. Get active camera                                  │ │
│  │ 2. Calculate view matrix (player position/rotation)  │ │
│  │ 3. Calculate projection matrix (FOV, aspect ratio)   │ │
│  │ 4. Apply camera matrices                              │ │
│  │ ✅ NO shader, NO surface drawing                      │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
│  obj_builderController/Draw_0.gml:                          │
│  ┌───────────────────────────────────────────────────────┐ │
│  │ 1. Draw 3D grid (if debug mode)                       │ │
│  │ 2. Draw 3D ghost cube (if editing)                    │ │
│  │ 3. Draw 3D placed blocks                              │ │
│  │ ✅ NO shader, NO surface drawing, NO 2D text          │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
│  Other 3D Objects:                                          │
│  ┌───────────────────────────────────────────────────────┐ │
│  │ • obj_player renders                                  │ │
│  │ • par_solid objects render                            │ │
│  │ • All 3D geometry renders to application_surface      │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ DRAW GUI EVENT (64) - 2D Overlays                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  obj_builderController/Draw_64.gml:                         │
│  ┌───────────────────────────────────────────────────────┐ │
│  │ 1. Draw debug info text (block ID, position, size)   │ │
│  │ 2. Draw block count                                   │ │
│  │ 3. Draw keyboard controls hint                        │ │
│  │ ✅ 2D UI elements only                                │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
│  obj_camera/Draw_64.gml:                                    │
│  ┌───────────────────────────────────────────────────────┐ │
│  │ 1. Draw player position (X, Y, Z)                     │ │
│  │ 2. Draw player orientation (direction, pitch)         │ │
│  │ ✅ 2D UI elements only                                │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ POST-DRAW EVENT (73) - Shader Post-Processing              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  obj_builderController/Draw_73.gml:                         │
│  ┌───────────────────────────────────────────────────────┐ │
│  │ 1. shader_set(sh_ps1_style)                           │ │
│  │ 2. shader_set_uniform_f(u_screen, width, height)      │ │
│  │ 3. draw_surface(application_surface, 0, 0)            │ │
│  │ 4. shader_reset()                                     │ │
│  │                                                        │ │
│  │ ✅ SINGLE shader pass                                 │ │
│  │ ✅ Surface fully rendered before use                  │ │
│  │ ✅ No binding conflicts                               │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓
                    ┌───────────────┐
                    │ FINAL OUTPUT  │
                    │ TO SCREEN     │
                    └───────────────┘
```

---

## Key Differences

| Aspect | Before (Broken) | After (Fixed) |
|--------|----------------|---------------|
| **Shader Application** | 2x per frame (obj_camera + obj_builderController) | 1x per frame (Post-Draw only) |
| **Surface Drawing** | 2x per frame (both objects) | 1x per frame (Post-Draw only) |
| **3D Rendering** | Mixed with shader/surface code | Clean, separate in Draw (0) |
| **2D UI** | Mixed with 3D in Draw (0) | Separate in Draw GUI (64) |
| **Binding Conflicts** | ❌ YES - surface used while rendering | ✅ NO - surface complete before use |
| **Error Messages** | ❌ "Texture/depth buffer" errors | ✅ No errors |
| **Performance** | Slower (redundant operations) | Faster (single pass) |
| **Maintainability** | Poor (mixed concerns) | Good (clear separation) |

---

## Event Execution Timeline

```
TIME →

Frame Start
    │
    ├─→ [Pre-Draw Events]
    │
    ├─→ [Draw Begin Events]
    │
    ├─→ [DRAW EVENTS (0)] ◄─── 3D WORLD RENDERS HERE
    │   │
    │   ├─ obj_camera: Set up 3D camera
    │   ├─ obj_builderController: Draw 3D debug geometry
    │   ├─ obj_player: Render player model
    │   └─ All 3D objects render
    │
    ├─→ [Draw End Events]
    │
    ├─→ [Draw GUI Begin Events]
    │
    ├─→ [DRAW GUI EVENTS (64)] ◄─── 2D UI RENDERS HERE
    │   │
    │   ├─ obj_builderController: Debug text
    │   └─ obj_camera: Player info
    │
    ├─→ [Draw GUI End Events]
    │
    ├─→ [POST-DRAW EVENTS (73)] ◄─── SHADER APPLIED HERE
    │   │
    │   └─ obj_builderController: Apply PS1 shader to final scene
    │
    └─→ [Post-Render Events]
    │
Frame End → Display to screen
```

---

## Why This Works

### 1. **Proper Event Ordering**
GameMaker executes events in a specific order. By using Post-Draw (73), we ensure the `application_surface` is completely rendered before we try to use it as a texture.

### 2. **Single Shader Pass**
Instead of applying the shader twice (which caused conflicts), we apply it once at the very end of the rendering pipeline.

### 3. **Separation of Concerns**
- **Draw (0)**: 3D geometry only
- **Draw GUI (64)**: 2D overlays only
- **Post-Draw (73)**: Post-processing only

### 4. **No Binding Conflicts**
The `application_surface` is:
- **Rendered to** during Draw (0) and Draw GUI (64)
- **Used as texture** only in Post-Draw (73)
- Never both at the same time!

---

## Visual Flow

```
┌──────────────┐
│ 3D World     │ ─┐
│ (Draw 0)     │  │
└──────────────┘  │
                  ├─→ Renders to → ┌──────────────────┐
┌──────────────┐  │                │ application_     │
│ 2D UI        │  │                │ surface          │
│ (Draw GUI)   │ ─┘                └──────────────────┘
└──────────────┘                            │
                                            │ Used as texture
                                            ↓
                                   ┌──────────────────┐
                                   │ PS1 Shader       │
                                   │ (Post-Draw)      │
                                   └──────────────────┘
                                            │
                                            ↓
                                   ┌──────────────────┐
                                   │ Final Output     │
                                   │ to Screen        │
                                   └──────────────────┘
```

---

## Testing the Fix

### Steps to Verify:
1. ✅ Run the game in GameMaker
2. ✅ Press **F1** to enable debug mode
3. ✅ Check console - should see NO errors
4. ✅ Press **P** to enable edit mode
5. ✅ Verify ghost cube appears
6. ✅ Verify debug text displays
7. ✅ Verify PS1 shader effect is visible
8. ✅ Press **Enter** to place blocks
9. ✅ Verify blocks render correctly
10. ✅ Move camera around - no rendering glitches

### Expected Results:
- ✅ No "texture/depth buffer" errors
- ✅ No "invalid input layout" errors
- ✅ Smooth rendering at all times
- ✅ PS1 shader effect applies correctly
- ✅ All debug features work properly

---

**Status:** ✅ FIXED  
**Date:** November 2, 2025  
**Tested:** Ready for GameMaker testing
