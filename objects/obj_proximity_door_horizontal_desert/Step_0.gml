// Step event


// Check player
if (point_distance(x, y, obj_player.x, obj_player.y) < trigger_distance) {
    trigger = true;
}
// Check all enemies
if (instance_exists(obj_enemy_parent)) {
    with (obj_enemy_parent) {
        if (point_distance(x, y, other.x, other.y) < other.enemy_trigger_distance) {
            trigger = true;
            break;
        }
    }
}

if (trigger) {
    // Open the door
    if (image_index < image_number - 1) {
        image_speed = 1;
    }
    if (image_index >= image_number - 1) {
        image_speed = 0;
        image_index = image_number - 1;
		update_collision_grid();
        collision_active = false;
    }
} else {
    // Close the door
    if (image_index > 0) {
		update_collision_grid();
        collision_active = true;
        image_speed = -1;
    }
    if (image_index <= 0) {
        image_speed = 0;
        image_index = 0;
    }
}