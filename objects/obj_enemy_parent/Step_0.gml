// obj_enemy_parent - Step Event
// Description: Updates enemy AI, pathfinding, alert visuals, and stun mechanics.

// Handle stun
if (state == "stunned") {
    stun_timer -= 1;
    stun_flash_timer -= 1;
    
    // Update flashing effect
    if (stun_flash_timer <= 0) {
        stun_flash_timer = 10; // Reset flash cycle (10 steps)
    }
    
    // Exit stun when timer expires
    if (stun_timer <= 0) {
        state = "patrol"; // Return to patrol
        stunned = false;
        stun_flash_timer = 0;
        image_alpha = 1; // Reset alpha
        path_end(); // Clear path
    }
    
    // Skip normal AI behavior
    exit;
}

if (attack_timer > 0) attack_timer--;
if (alert_icon_timer > 0) alert_icon_timer--;

var player_spotted = false;
if (instance_exists(obj_player)) {
    var player_dist = point_distance(x, y, obj_player.x, obj_player.y);
    if (player_dist <= detection_range) {
        var player_dir = point_direction(x, y, obj_player.x, obj_player.y);
        var angle_diff = abs(angle_difference(facing_direction, player_dir));
        if (angle_diff <= detection_angle / 2) {
            var los_target_x = obj_player.x;
            var los_target_y = obj_player.y;
            var cell_x = floor(los_target_x / 32);
            var cell_y = floor(los_target_y / 32);
            if (mp_grid_get_cell(grid, cell_x, cell_y) == -1) {
                var found = false;
                for (var radius = 1; radius <= 3 && !found; radius++) {
                    for (var i = -radius; i <= radius && !found; i++) {
                        for (var j = -radius; j <= radius && !found; j++) {
                            var test_cell_x = cell_x + i;
                            var test_cell_y = cell_y + j;
                            if (mp_grid_get_cell(grid, test_cell_x, test_cell_y) == 0) {
                                los_target_x = test_cell_x * 32 + 16;
                                los_target_y = test_cell_y * 32 + 16;
                                found = true;
                            }
                        }
                    }
                }
                if (!found) {
                    los_target_x = last_player_x;
                    los_target_y = last_player_y;
                }
            }

            var temp_path = path_add();
            if (mp_grid_path(grid, temp_path, x, y, los_target_x, los_target_y, true)) {
                var path_length = path_get_length(temp_path);
                var direct_dist = point_distance(x, y, los_target_x, los_target_y);
                if (abs(path_length - direct_dist) < 5) {
                    player_spotted = true;
                    if (state != "chase" && state != "attack") {
                        state = "chase";
                        with (obj_manager) {
                            enemies_alerted = true;
                            global.alert_timer = 10 * game_get_speed(gamespeed_fps);
                        }
                        if (!has_alerted) {
                            alert_icon_timer = 60;
                            alert_icon_scale = 1.5;
                            alert_icon_alpha = 1;
                            has_alerted = true;
                        }
                    }
                    search_timer = 0;
                    last_player_x = obj_player.x;
                    last_player_y = obj_player.y;
                }
            }
            path_delete(temp_path);
        }
    }
}

switch (state) {
case "patrol":
    if (instance_exists(obj_manager) && obj_manager.enemies_alerted && instance_exists(obj_player)) {
        // Check if there's a path to the player
        var temp_path = path_add();
        if (mp_grid_path(grid, temp_path, x, y, obj_player.x, obj_player.y, true)) {
            state = "chase";
            if (!has_alerted) {
                alert_icon_timer = 60;
                alert_icon_scale = 1.5;
                alert_icon_alpha = 1;
                has_alerted = true;
            }
            //show_debug_message(point_owner + " alerted and chasing - path found");
        }
        path_delete(temp_path);
    }
    if (array_length(patrol_points) > 0) {
        if (point_distance(x, y, target_x, target_y) <= patrol_speed || path_position == 1) {
            //show_debug_message(point_owner + " at point " + string(current_point) + " | Pre-wait: " + string(pre_wait_timer) + " | Wait: " + string(wait_timer / game_get_speed(gamespeed_fps)) + " seconds");
            if (pre_wait_timer > 0) {
                pre_wait_timer--;
                var target_dir = facing_direction;
                var dir = patrol_points[current_point].wait_direction;
                switch (dir) {
                    case "up": target_dir = 90; break;
                    case "down": target_dir = 270; break;
                    case "left": target_dir = 180; break;
                    case "right": target_dir = 0; break;
                    case "none": target_dir = facing_direction; break;
                    default: target_dir = facing_direction; break;
                }
                facing_direction = angle_lerp(facing_direction, target_dir, 0.1);
            } else if (wait_timer > 0) {
                wait_timer--;
            } else {
                current_point = (current_point + 1) % array_length(patrol_points);
                target_x = patrol_points[current_point].x;
                target_y = patrol_points[current_point].y;
                wait_timer = patrol_points[current_point].point_wait * game_get_speed(gamespeed_fps);
                if (patrol_points[current_point].point_wait > 0) {
                    pre_wait_timer = 0.5 * game_get_speed(gamespeed_fps);
                } else {
                    pre_wait_timer = 0;
                }
                path_end();
                if (mp_grid_path(grid, path, x, y, target_x, target_y, true)) {
                    path_start(path, patrol_speed, path_action_stop, false); // Nav points are not solid
                    //show_debug_message(point_owner + " moving to point " + string(current_point) + " at " + string(target_x) + "," + string(target_y));
                } else {
                    //show_debug_message(point_owner + " cannot path to point " + string(current_point) + " at " + string(target_x) + "," + string(target_y));
                }
            }
        } else {
            if (mp_grid_path(grid, path, x, y, target_x, target_y, true)) {
                path_start(path, patrol_speed, path_action_stop, false); // Nav points are not solid
                var next_x = path_get_x(path, min(path_position + 0.1, 1));
                var next_y = path_get_y(path, min(path_position + 0.1, 1));
                facing_direction = angle_lerp(facing_direction, point_direction(x, y, next_x, next_y), 0.1);
            } else {
                path_end();
                //show_debug_message(point_owner + " patrol path blocked");
            }
        }
    }
    break;

    case "chase":
        if (instance_exists(obj_player)) {
            var player_dist = point_distance(x, y, obj_player.x, obj_player.y);
            if (player_dist <= attack_range && attack_timer <= 0) {
                state = "attack";
                is_attacking = true;
                path_end();
                facing_direction = angle_lerp(facing_direction, point_direction(x, y, obj_player.x, obj_player.y), 0.1);
            } else {
                var player_mask_radius = (obj_player.bbox_right - obj_player.bbox_left) / 2;
                var enemy_mask_radius = (bbox_right - bbox_left) / 2;
                var safe_distance = min(player_mask_radius + enemy_mask_radius + 2, attack_range - 4); // Ensure enemies can get within attack range
                var dir_to_player = point_direction(x, y, obj_player.x, obj_player.y);
                var ideal_x = obj_player.x - lengthdir_x(safe_distance, dir_to_player);
                var ideal_y = obj_player.y - lengthdir_y(safe_distance, dir_to_player);

                // Find a unique, non-overlapping position around the player
                var cell_x = floor(ideal_x / 32);
                var cell_y = floor(ideal_y / 32);
                var target_x_adjusted = ideal_x;
                var target_y_adjusted = ideal_y;
                var found = false;

                // First, check if the ideal position is free and not targeted by another enemy
                if (mp_grid_get_cell(grid, cell_x, cell_y) == 0) {
                    var overlap = false;
                    with (obj_enemy_parent) {
                        if (id != other.id && state == "chase") {
                            // Check distance to this enemy's current position and target position
                            var dist_to_current = point_distance(x, y, ideal_x, ideal_y);
                            var dist_to_target = point_distance(target_x, target_y, ideal_x, ideal_y);
                            if (dist_to_current < 32 || dist_to_target < 32) { // Increased separation distance
                                overlap = true;
                                break;
                            }
                        }
                    }
                    if (!overlap) {
                        target_x_adjusted = ideal_x;
                        target_y_adjusted = ideal_y;
                        found = true;
                    }
                }

                // If the ideal position is occupied or forbidden, search for a nearby free cell
                if (!found) {
                    for (var radius = 1; radius <= 7 && !found; radius++) {
                        for (var i = -radius; i <= radius && !found; i++) {
                            for (var j = -radius; j <= radius && !found; j++) {
                                var test_cell_x = cell_x + i;
                                var test_cell_y = cell_y + j;
                                if (mp_grid_get_cell(grid, test_cell_x, test_cell_y) == 0) {
                                    var test_x = test_cell_x * 32 + 16;
                                    var test_y = test_cell_y * 32 + 16;
                                    var overlap = false;
                                    with (obj_enemy_parent) {
                                        if (id != other.id && state == "chase") {
                                            var dist_to_current = point_distance(x, y, test_x, test_y);
                                            var dist_to_target = point_distance(target_x, target_y, test_x, test_y);
                                            if (dist_to_current < 32 || dist_to_target < 32) { // Increased separation distance
                                                overlap = true;
                                                break;
                                            }
                                        }
                                    }
                                    if (!overlap) {
                                        target_x_adjusted = test_x;
                                        target_y_adjusted = test_y;
                                        found = true;
                                    }
                                }
                            }
                        }
                    }
                }

                // Fallback with random offset to avoid exact overlap
                if (!found) {
                    var offset_angle = irandom(360);
                    var offset_dist = 32; // Minimum separation
                    target_x_adjusted = last_player_x + lengthdir_x(offset_dist, offset_angle);
                    target_y_adjusted = last_player_y + lengthdir_y(offset_dist, offset_angle);
                }

                if (mp_grid_path(grid, path, x, y, target_x_adjusted, target_y_adjusted, true)) {
                    path_start(path, patrol_speed * 1.5, path_action_stop, true); // Respect solid objects
                    facing_direction = angle_lerp(facing_direction, point_direction(x, y, obj_player.x, obj_player.y), 0.1);
                } else {
                    path_end();
                    //show_debug_message(point_owner + " chase path blocked");
                }
            }
            last_player_x = obj_player.x;
            last_player_y = obj_player.y;
            if (player_spotted) {
                with (obj_manager) {
                    global.alert_timer = 10 * game_get_speed(gamespeed_fps);
                }
            }
        }
        if (instance_exists(obj_manager) && !obj_manager.enemies_alerted) {
            state = "search";
            search_timer = search_timer_max;
            target_x = last_player_x;
            target_y = last_player_y;
            has_alerted = false; // Reset alert animation state when alert ends
        }
        break;

    case "attack":
        if (instance_exists(obj_player)) {
            facing_direction = angle_lerp(facing_direction, point_direction(x, y, obj_player.x, obj_player.y), 0.1);
            if (is_attacking) {
                var player_dist = point_distance(x, y, obj_player.x, obj_player.y);
                if (player_dist <= attack_range + 4) {
                    obj_manager.health_current -= 10;
                    // Spawn particle effect at player's position (same as original obj_enemy)
                    effect_create_above(4, obj_player.x, obj_player.y, 1, c_white);
                    is_attacking = false;
                }
            }
            if (attack_timer <= 0) {
                state = "chase";
                attack_timer = attack_cooldown;
            }
            if (player_spotted) {
                with (obj_manager) {
                    global.alert_timer = 10 * game_get_speed(gamespeed_fps);
                }
            }
        } else {
            state = "search";
            target_x = last_player_x;
            target_y = last_player_y;
        }
        if (instance_exists(obj_manager) && !obj_manager.enemies_alerted) {
            state = "search";
            search_timer = search_timer_max;
            target_x = last_player_x;
            target_y = last_player_y;
            has_alerted = false; // Reset alert animation state when alert ends
        }
        break;

    case "search":
    if (path_position >= 1 || point_distance(x, y, target_x, target_y) <= patrol_speed * 2) {
        path_end();
        if (search_pause_timer > 0) {
            search_pause_timer--;
        } else {
            var attempts = 0;
            do {
                var angle = irandom(360);
                var dist = irandom_range(32, 256);
                target_x = last_player_x + lengthdir_x(dist, angle);
                target_y = last_player_y + lengthdir_y(dist, angle);
                target_x = round(target_x / 32) * 32;
                target_y = round(target_y / 32) * 32;
                attempts++;
            } until (mp_grid_path(grid, path, x, y, target_x, target_y, true) || attempts > 10);
            if (attempts > 10) {
                target_x = x;
                target_y = y;
                //show_debug_message(point_owner + " couldn’t find a searchable spot near last position");
            }
            search_pause_timer = 180;
        }
    } else if (mp_grid_path(grid, path, x, y, target_x, target_y, true)) {
        path_start(path, patrol_speed, path_action_stop, true); // Respect solid objects
        var next_x = path_get_x(path, min(path_position + 0.1, 1));
        var next_y = path_get_y(path, min(path_position + 0.1, 1));
        facing_direction = angle_lerp(facing_direction, point_direction(x, y, next_x, next_y), 0.1);
    } else {
        path_end();
        //show_debug_message(point_owner + " search path blocked");
        target_x = x;
        target_y = y;
        search_pause_timer = 0;
    }
    search_timer--;
    if (search_timer <= 0 && !player_spotted) {
        state = "patrol";
        path_end();
        if (array_length(patrol_points) > 0) {
            target_x = patrol_points[current_point].x;
            target_y = patrol_points[current_point].y;
        }
        has_alerted = false; // Reset alert animation state when returning to patrol
    }
    break;
}