// obj_player Collision with obj_collision_parent
// Calculate intended movement
var x_move = x - xprevious;
var y_move = y - yprevious;

// Apply X movement and check collision
if (x_move != 0) {
    var wallx = instance_place(x, yprevious, obj_collision_parent); // Check X at previous Y
    if (wallx > 0 && wallx.collision_active) {
        x = xprevious; // Block X movement
    }
}

// Apply Y movement and check collision
if (y_move != 0) {
    var wally = instance_place(x, y, obj_collision_parent); // Check Y at current X
    if (wally > 0 && wally.collision_active) {
        y = yprevious; // Block Y movement
    }
}