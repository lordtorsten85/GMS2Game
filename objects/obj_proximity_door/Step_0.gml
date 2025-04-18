trigger = false;

// Only check proximity if the door is not locked
if (!locked) {
    if (point_distance(x, y, obj_player.x, obj_player.y) < trigger_distance) {
        trigger = true;
    }
    if (instance_exists(obj_enemy_parent)) {
        with (obj_enemy_parent) {
            var dist = point_distance(x, y, other.x, other.y);
            if (dist < other.trigger_distance) {
                other.trigger = true;
                break;
            }
        }
    }
}

if (trigger && !locked) {
    if (image_index < image_number - 1) {
        image_speed = 1;
    }
    if (image_index >= image_number - 1) {
        image_speed = 0;
        image_index = image_number - 1;
        solid = false; // Allow passage when fully open
        // Clear the grid and update paths for affected enemies
        mp_grid_clear_rectangle(global.mp_grid, 
            x - sprite_width/2, y - sprite_height/2, 
            x + sprite_width/2, y + sprite_height/2);
        with (obj_enemy_parent) {
            // Check if any nav points are within the door's grid rectangle
            var door_left = other.x - other.sprite_width/2;
            var door_right = other.x + other.sprite_width/2;
            var door_top = other.y - other.sprite_height/2;
            var door_bottom = other.y + other.sprite_height/2;
            var affected = false;
            for (var i = 0; i < array_length(patrol_points); i++) {
                var nav_x = patrol_points[i].x;
                var nav_y = patrol_points[i].y;
                if (nav_x >= door_left && nav_x <= door_right && nav_y >= door_top && nav_y <= door_bottom) {
                    affected = true;
                    break;
                }
            }
            if (affected) {
                path_end(); // Force path re-evaluation
                show_debug_message("Enemy " + point_owner + " path ended due to door opening");
            }
        }
        show_debug_message("Proximity door opened; grid cleared at (" + string(x) + "," + string(y) + ")");
    }
} else {
    if (image_index > 0) {
        image_speed = -1;
    }
    if (image_index <= 0) {
        image_speed = 0;
        image_index = 0;
        solid = true; // Block passage when closed
    }
}

// Debug door state
show_debug_message("Door state: trigger=" + string(trigger) + ", locked=" + string(locked) + ", image_index=" + string(image_index) + ", solid=" + string(solid));