/// @description Check if a point collides with any cube
/// @function cube_collision_check(x, y, z)
/// @param {real} x The x coordinate to check
/// @param {real} y The y coordinate to check
/// @param {real} z The z coordinate to check
/// @return {bool} Returns true if the point collides with a cube, false otherwise

function cube_collision_check(_x, _y, _z) {
    // Ensure cube_list exists
    if (!variable_global_exists("cube_list")) {
        return false;
    }
    
    // Check all cubes for collision
    for (var i = 0; i < array_length(global.cube_list); i++) {
        var cube = global.cube_list[i];
        
        // Skip cubes without collision
        if (!cube.collision) {
            continue;
        }
        
        // AABB point-in-box collision check
        if (_x >= cube.mask.left && _x < cube.mask.right &&
            _y >= cube.mask.top  && _y < cube.mask.bottom &&
            _z >= cube.mask.front && _z < cube.mask.back) {
            return true;
        }
    }
    
    return false;
}

/// @description Check if a box collides with any cube (AABB collision)
/// @function cube_collision_check_box(x1, y1, z1, x2, y2, z2)
/// @param {real} x1 The minimum x coordinate of the box
/// @param {real} y1 The minimum y coordinate of the box
/// @param {real} z1 The minimum z coordinate of the box
/// @param {real} x2 The maximum x coordinate of the box
/// @param {real} y2 The maximum y coordinate of the box
/// @param {real} z2 The maximum z coordinate of the box
/// @return {bool} Returns true if the box collides with any cube, false otherwise

function cube_collision_check_box(_x1, _y1, _z1, _x2, _y2, _z2) {
    // Ensure cube_list exists
    if (!variable_global_exists("cube_list")) {
        return false;
    }
    
    // Check all cubes for collision
    for (var i = 0; i < array_length(global.cube_list); i++) {
        var cube = global.cube_list[i];
        
        // Skip cubes without collision
        if (!cube.collision) {
            continue;
        }
        
        // AABB box-to-box collision check
        if (!(_x2 <= cube.mask.left || _x1 >= cube.mask.right ||
              _y2 <= cube.mask.top  || _y1 >= cube.mask.bottom ||
              _z2 <= cube.mask.front || _z1 >= cube.mask.back)) {
            return true;
        }
    }
    
    return false;
}

/// @description Get the cube that a point collides with
/// @function cube_collision_get(x, y, z)
/// @param {real} x The x coordinate to check
/// @param {real} y The y coordinate to check
/// @param {real} z The z coordinate to check
/// @return {struct|undefined} Returns the colliding cube struct, or undefined if no collision

function cube_collision_get(_x, _y, _z) {
    // Ensure cube_list exists
    if (!variable_global_exists("cube_list")) {
        return undefined;
    }
    
    // Check all cubes for collision
    for (var i = 0; i < array_length(global.cube_list); i++) {
        var cube = global.cube_list[i];
        
        // Skip cubes without collision
        if (!cube.collision) {
            continue;
        }
        
        // AABB point-in-box collision check
        if (_x >= cube.mask.left && _x < cube.mask.right &&
            _y >= cube.mask.top  && _y < cube.mask.bottom &&
            _z >= cube.mask.front && _z < cube.mask.back) {
            return cube;
        }
    }
    
    return undefined;
}
