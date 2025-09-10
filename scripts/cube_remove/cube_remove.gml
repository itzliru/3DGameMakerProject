/// cube_remove(x, y, z)
var gx = argument0;
var gy = argument1;
var gz = argument2;

for (var i = 0; i < array_length(global.cube_list); i++) {
    var c = global.cube_list[i];
    if (c.x == gx && c.y == gy && c.z == gz) {
        array_delete(global.cube_list, i, 1);
        break;
    }
}
