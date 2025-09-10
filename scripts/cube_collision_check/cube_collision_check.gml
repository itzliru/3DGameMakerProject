/// cube_collision_check(x, y, z)
var xx = argument0;
var yy = argument1;
var zz = argument2;

for (var i = 0; i < array_length(global.cube_list); i++) {
    var c = global.cube_list[i];
    if (c.collision) {
        if (xx >= c.mask.left && xx < c.mask.right &&
            yy >= c.mask.top  && yy < c.mask.bottom &&
            zz >= c.mask.front && zz < c.mask.back) {
            return true;
        }
    }
}
return false;
