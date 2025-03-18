function navigate_to_point(target_x, target_y, obj) {
    var dir = point_direction(obj.x, obj.y, target_x, target_y);
    var dist = point_distance(obj.x, obj.y, target_x, target_y);
    var moved = false;
    var bubble_size = 8;      // 8px buffer
    var look_ahead = 32;      // 32px ahead
    static last_x = -1;
    static last_y = -1;
    static stuck_counter = 0;
    static last_dodge_dir = 0;
    var move_dir = dir;       // Track actual movement direction
    
    show_debug_message("Navigating to (" + string(target_x) + ", " + string(target_y) + ") from (" + string(obj.x) + ", " + string(obj.y) + ") with move_speed: " + string(obj.move_speed));
    
    if (last_x == obj.x && last_y == obj.y) {
        stuck_counter += 1;
        show_debug_message("Stuck counter: " + string(stuck_counter) + " at (" + string(obj.x) + ", " + string(obj.y) + ")");
    } else {
        stuck_counter = 0;
    }
    last_x = obj.x;
    last_y = obj.y;
    
    var effective_speed = obj.move_speed;
    if (effective_speed <= 0) effective_speed = 0.5;
    
    // Try direct path
    var test_dirs = [0, 15, -15, 30, -30];
    for (var i = 0; i < array_length(test_dirs); i++) {
        var test_dir = dir + test_dirs[i];
        var check_x = obj.x + lengthdir_x(look_ahead, test_dir);
        var check_y = obj.y + lengthdir_y(look_ahead, test_dir);
        if (!collision_line(obj.x, obj.y, check_x, check_y, obj_collision_parent, false, true)) {
            var step_x = lengthdir_x(effective_speed, test_dir);
            var step_y = lengthdir_y(effective_speed, test_dir);
            var next_x = obj.x + step_x;
            var next_y = obj.y + step_y;
            if (!place_meeting(next_x + lengthdir_x(bubble_size, test_dir), next_y + lengthdir_y(bubble_size, test_dir), obj_collision_parent) &&
                !place_meeting(next_x - lengthdir_x(bubble_size, test_dir), next_y - lengthdir_y(bubble_size, test_dir), obj_collision_parent) &&
                !place_meeting(next_x + lengthdir_x(bubble_size, test_dir + 90), next_y + lengthdir_y(bubble_size, test_dir + 90), obj_collision_parent) &&
                !place_meeting(next_x - lengthdir_x(bubble_size, test_dir - 90), next_y - lengthdir_y(bubble_size, test_dir - 90), obj_collision_parent)) {
                obj.x = next_x;
                obj.y = next_y;
                moved = true;
                move_dir = test_dir; // Update direction of travel
                show_debug_message("Moving directly with bubble for " + obj.point_owner + " at (" + string(obj.x) + ", " + string(obj.y) + ")");
                break;
            }
        }
    }
    
    if (!moved) {
        // Dodge with consistent speed
        var best_dir = -1;
        var best_dot = -1;
        var dodge_dirs = [0, 45, -45, 90, -90, 135, -135];
        for (var i = 0; i < array_length(dodge_dirs); i++) {
            var dodge_dir = dir + dodge_dirs[i];
            var test_x = obj.x + lengthdir_x(look_ahead, dodge_dir);
            var test_y = obj.y + lengthdir_y(look_ahead, dodge_dir);
            if (!collision_line(obj.x, obj.y, test_x, test_y, obj_collision_parent, false, true)) {
                var dot = dot_product(lengthdir_x(1, dodge_dir), lengthdir_y(1, dodge_dir), lengthdir_x(1, dir), lengthdir_y(1, dir));
                if (abs(angle_difference(dodge_dir, last_dodge_dir)) > 90) dot -= 0.5;
                show_debug_message("Clear direction: " + string(dodge_dirs[i]) + " with dot product: " + string(dot));
                if (dot > best_dot) {
                    best_dot = dot;
                    best_dir = dodge_dir;
                }
            }
        }
        if (best_dir != -1) {
            var step_x = lengthdir_x(effective_speed, best_dir); // No *2, same speed
            var step_y = lengthdir_y(effective_speed, best_dir);
            obj.x += step_x;
            obj.y += step_y;
            moved = true;
            last_dodge_dir = best_dir;
            move_dir = best_dir; // Update direction of travel
            show_debug_message("Dodging with bubble for " + obj.point_owner + " with angle " + string(best_dir - dir) + " at (" + string(obj.x) + ", " + string(obj.y) + ")");
        } else if (stuck_counter > 3) {
            var escape_dirs = [0, 90, -90, 45, -45, 135, -135, 180];
            for (var i = 0; i < array_length(escape_dirs); i++) {
                var escape_dir = dir + escape_dirs[i];
                var step_size = 128;
                var step_x = lengthdir_x(step_size, escape_dir);
                var step_y = lengthdir_y(step_size, escape_dir);
                var next_x = obj.x + step_x;
                var next_y = obj.y + step_y;
                if (!place_meeting(next_x, next_y, obj_collision_parent)) {
                    obj.x = next_x;
                    obj.y = next_y;
                    moved = true;
                    stuck_counter = 0;
                    move_dir = escape_dir; // Update direction of travel
                    show_debug_message("Forced escape with bubble for " + obj.point_owner + " with angle " + string(escape_dirs[i]) + " at (" + string(obj.x) + ", " + string(obj.y) + ")");
                    break;
                }
            }
            if (!moved) {
                show_debug_message("Completely stuck at (" + string(obj.x) + ", " + string(obj.y) + ") for " + obj.point_owner);
            }
        } else {
            show_debug_message("Stuck at (" + string(obj.x) + ", " + string(obj.y) + ") for " + obj.point_owner);
        }
    }
    
    // Set facing to movement direction
    if (moved) obj.facing = move_dir;
    
    return moved;
}