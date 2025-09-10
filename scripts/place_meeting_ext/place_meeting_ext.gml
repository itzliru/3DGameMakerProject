/// place_meeting_ext(xx, yy, zz, obj, w, h, d, buffer)
/// Returns true if a box at (xx,yy,zz) with size w,h,d intersects any obj
/// Assumes par_solid blocks are 64×64×64
/// buffer = pixels to shrink each block for collision

function place_meeting_ext(xx, yy, zz, obj, w, h, d, buffer) {
    with (obj) {
        var left   = x + buffer;
        var right  = x + 64 - buffer;
        var front  = y + buffer;
        var back   = y + 64 - buffer;
        var bottom = z + buffer;
        var top    = z + 64 - buffer;

        // Check AABB collision between two boxes
        if (!(xx + w <= left ||      // Player is completely left
              xx >= right ||         // Player is completely right
              yy + h <= front ||    // Player is completely in front
              yy >= back ||          // Player is completely behind
              zz + d <= bottom ||   // Player is completely below
              zz >= top)) {          // Player is completely above
            return true;
        }
    }
    return false;
}
