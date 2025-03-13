// obj_enemy - Step Event
// Description: Manages enemy movement, collision, and state-based AI (patrol, chase, pursue, scan, return)

if (hp <= 0) {
    instance_destroy();
    exit;
}

// Collision with walls
if (place_meeting(x + lengthdir_x(move_speed, point_direction(x, y, obj_player.x, obj_player.y)), y + lengthdir_y(move_speed, point_direction(x, y, obj_player.x, obj_player.y)), obj_collision_parent)) {
    move_speed = 0; // Stop if hitting a wall
} else {
    move_speed = 2.5; // Reset speed if not colliding
}

// State machine
switch (state) {
    case "patrol":
        // Patrol between waypoints
        var target_x = waypoints[| current_waypoint];
        var target_y = waypoints_y[| current_waypoint];
        var dir = point_direction(x, y, target_x, target_y);
        facing = dir; // Face toward target waypoint
        facing_target = facing; // Update facing_target for smooth cone rotation
        x += lengthdir_x(move_speed, dir);
        y += lengthdir_y(move_speed, dir);
        
        // Check if reached the waypoint
        if (point_distance(x, y, target_x, target_y) < move_speed) {
            current_waypoint = (current_waypoint + 1) % ds_list_size(waypoints); // Move to next waypoint
        }
        
        // Check for player in range
        if (instance_exists(obj_player)) {
            var dist = point_distance(x, y, obj_player.x, obj_player.y);
            if (dist <= scan_range) {
                var dir_to_player = point_direction(x, y, obj_player.x, obj_player.y);
                var angle_diff = abs(angle_difference(facing, dir_to_player));
                if (angle_diff <= scan_angle / 2) {
                    // Simple line-of-sight check (expand with tiles later)
                    state = "chase";
                    last_player_x = obj_player.x; // Update last known position
                    last_player_y = obj_player.y;
                }
            }
        }
        break;
    
    case "chase":
        // Chase player
        if (instance_exists(obj_player)) {
            var dir = point_direction(x, y, obj_player.x, obj_player.y);
            facing = dir; // Face directly toward player for detection
            facing_target = dir; // Smoothly rotate cone toward player
            x += lengthdir_x(move_speed, dir);
            y += lengthdir_y(move_speed, dir);
            last_player_x = obj_player.x; // Continuously update last known position
            last_player_y = obj_player.y;
            
            // Check if player is out of range
            var dist = point_distance(x, y, obj_player.x, obj_player.y);
            if (dist > scan_range) {
                state = "pursue";
            }
        }
        break;
    
    case "pursue":
        // Move to last known player position, then idle when close
        if (pursue_timer == 0) {
            pursue_timer = 180; // Pursue for 3 seconds (180 frames at 60 FPS)
        }
        pursue_timer -= 1;
        
        // Move toward last known position
        move_speed = 2.5;
        var dir_to_last = point_direction(x, y, last_player_x, last_player_y);
        if (point_distance(x, y, last_player_x, last_player_y) > move_speed) {
            facing = dir_to_last; // Face toward last known position while moving
            facing_target = dir_to_last; // Smoothly rotate cone
            x += lengthdir_x(move_speed, dir_to_last);
            y += lengthdir_y(move_speed, dir_to_last);
        } else {
            // Idle when close to last known position
            move_speed = 0;
            facing = dir_to_last; // Fix facing to last direction
            facing_target = dir_to_last; // Fix cone to last direction
        }
        
        // Check if time to give up
        if (pursue_timer <= 0) {
            state = "scan"; // Transition to scan state
            pursue_timer = 0; // Reset timer
        }
        break;
    
    case "scan":
        // Wait, then transition to return
        if (scan_timer == 0) {
            scan_timer = 120; // Wait 2 seconds (120 frames at 60 FPS)
        }
        scan_timer -= 1;
        
        // Pause and look toward last known position
        move_speed = 0;
        var dir_to_last = point_direction(x, y, last_player_x, last_player_y);
        facing = dir_to_last; // Face toward last known position for detection
        facing_target = dir_to_last; // Smoothly rotate cone
        
        if (scan_timer <= 0) {
            state = "return"; // Transition to return state
            scan_timer = 0; // Reset timer
        }
        break;
    
    case "return":
        // Move back to patrol point 1
        move_speed = 2.5;
        var dir_to_patrol = point_direction(x, y, patrol_point_1_x, patrol_point_1_y);
        facing = dir_to_patrol; // Face toward patrol point 1
        facing_target = dir_to_patrol; // Smoothly rotate cone
        x += lengthdir_x(move_speed, dir_to_patrol);
        y += lengthdir_y(move_speed, dir_to_patrol);
        
        // Check if reached patrol point 1
        if (point_distance(x, y, patrol_point_1_x, patrol_point_1_y) < move_speed) {
            x = patrol_point_1_x; // Snap to exact position
            y = patrol_point_1_y;
            current_waypoint = 0; // Start at first waypoint
            state = "patrol"; // Resume patrol
            facing = 0; // Face right (initial direction toward second waypoint)
            facing_target = facing; // Align cone
        }
        break;
}