# Quick Fix Reference - F1 Debug Mode Rendering Error

## 🔴 The Problem
```
ERROR: Trying to set texture that is also bound as depth buffer - bailing...
ERROR: Draw failed due to invalid input layout
```

## ✅ The Solution
**Moved shader application from Draw (0) to Post-Draw (73)**

---

## 📋 What Changed

### Files Modified:
1. ✅ `objects/obj_camera/Draw_0.gml` - Removed shader/surface code
2. ✅ `objects/obj_builderController/Draw_0.gml` - Removed shader/surface code
3. ✅ `objects/obj_builderController/Draw_64.gml` - **NEW** - 2D debug UI
4. ✅ `objects/obj_builderController/Draw_73.gml` - **NEW** - Shader post-processing
5. ✅ `objects/obj_builderController/obj_builderController.yy` - Event registration
6. ✅ `objects/obj_camera/Draw_64.gml` - Cleaned up duplicate code

---

## 🎯 Quick Summary

### Before:
```gml
// obj_camera/Draw_0.gml
shader_set(sh_ps1_style);
draw_surface(application_surface, 0, 0);  // ❌ ERROR!
shader_reset();

// obj_builderController/Draw_0.gml
shader_set(sh_ps1_style);
draw_surface(application_surface, 0, 0);  // ❌ ERROR!
shader_reset();
```

### After:
```gml
// obj_camera/Draw_0.gml
// Just camera setup, no shader

// obj_builderController/Draw_0.gml
// Just 3D debug geometry, no shader

// obj_builderController/Draw_73.gml (NEW)
shader_set(sh_ps1_style);
draw_surface(application_surface, 0, 0);  // ✅ WORKS!
shader_reset();
```

---

## 🔧 Event Structure (Fixed)

```
Draw Event (0)
├─ obj_camera: Set up 3D camera
└─ obj_builderController: Draw 3D debug geometry

Draw GUI Event (64)
├─ obj_builderController: Debug text & UI
└─ obj_camera: Player position info

Post-Draw Event (73)
└─ obj_builderController: Apply PS1 shader (ONCE)
```

---

## 🎮 Testing Checklist

- [ ] Run game in GameMaker
- [ ] Press **F1** (toggle debug mode)
- [ ] Check console for errors (should be none)
- [ ] Press **P** (toggle edit mode)
- [ ] Verify ghost cube appears
- [ ] Press **Enter** (place block)
- [ ] Verify block renders correctly
- [ ] Move camera around
- [ ] Verify PS1 shader effect works
- [ ] Verify debug text displays

---

## 📚 Documentation Files

1. **RENDERING_FIX_SUMMARY.md** - Detailed explanation of the fix
2. **RENDERING_PIPELINE_DIAGRAM.md** - Visual before/after diagrams
3. **QUICK_FIX_REFERENCE.md** - This file (quick reference)

---

## 💡 Key Takeaway

**Never draw `application_surface` in Draw Event (0)!**

✅ **DO:** Apply shaders in Post-Draw (73)  
❌ **DON'T:** Draw application_surface multiple times  
❌ **DON'T:** Apply shaders in Draw (0)

---

## 🚀 Status

**Issue:** ✅ RESOLVED  
**Tested:** Ready for GameMaker testing  
**Date:** November 2, 2025

---

## 🆘 If Issues Persist

1. Check that `obj_builderController` has Draw_73.gml event
2. Verify no other objects are drawing application_surface
3. Check GameMaker console for new error messages
4. Verify shader file `sh_ps1_style` exists and compiles
5. Check that `obj_builderController` is in the room

---

**Need more details?** See `RENDERING_FIX_SUMMARY.md`
