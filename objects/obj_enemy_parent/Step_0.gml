// obj_enemy_parent - Step Event
// Handles patrol, alert, and search states with player detection and dynamic pathfinding.

// Variable Definitions:
// - point_owner (string): Identifier for nav points.
// - patrol_speed (real): Speed at which the enemy moves between points, overridable by children.
// - current_point (real): Current nav point index.

// Player detection
var player_spotted = false;
if (instance_exists(obj_player)) {
    var player_dist = point_distance(x, y, obj_player.x, obj_player.y);
    var player_dir = point_direction(x, y, obj_player.x, obj_player.y);
    var angle_diff = abs(angle_difference(facing_direction, player_dir));
    if (player_dist <= detection_range && angle_diff <= detection_angle / 2) {
        var los_clear = !collision_line(x, y, obj_player.x, obj_player.y, obj_collision_parent, true, true);
        if (los_clear) {
            player_spotted = true;
            if (state != "alert") {
                state = "alert";
                with (obj_manager) {
                    enemies_alerted = true;
                    global.alert_timer = 10 * game_get_speed(gamespeed_fps);
                }
                alert_icon_timer = 60;    // Show alert icon for 1 sec
                alert_icon_scale = 1.5;
                alert_icon_alpha = 1;
                show_debug_message(point_owner + " triggered alert!");
            }
            last_player_x = obj_player.x;
            last_player_y = obj_player.y;
        }
    }
}

// State machine
switch (state) {
    case "patrol":
        // Move between nav points or join alert
        if (instance_exists(obj_manager) && obj_manager.enemies_alerted) {
            state = "alert";
            alert_icon_timer = 60;    // Show alert icon when alerted by camera or others
            alert_icon_scale = 1.5;
            alert_icon_alpha = 1;
            show_debug_message(point_owner + " joining alert from camera or enemy");
        } else if (array_length(patrol_points) > 0) {
            // Check if reached current nav point or path ended
            if (point_distance(x, y, target_x, target_y) <= patrol_speed || path_position >= 1) {
                current_point = (current_point + 1) % array_length(patrol_points);
                target_x = patrol_points[current_point].x;
                target_y = patrol_points[current_point].y;
                show_debug_message(point_owner + " moving to nav point " + string(current_point) + ": [" + string(target_x) + "," + string(target_y) + "]");
            }
            if (mp_grid_path(grid, path, x, y, target_x, target_y, true)) {
                path_start(path, patrol_speed, path_action_stop, false);
                var target_dir = point_direction(x, y, target_x, target_y);
                facing_direction = angle_lerp(facing_direction, target_dir, 0.2);
            } else {
                path_end();
                show_debug_message(point_owner + " patrol path blocked");
            }
        }
        break;

    case "alert":
        // Chase player with dynamic pathfinding
        if (instance_exists(obj_player)) {
            var chase_x = obj_player.x;
            var chase_y = obj_player.y;
            
            var cell_x = chase_x div 32;
            var cell_y = chase_y div 32;
            if (mp_grid_get_cell(grid, cell_x, cell_y) == -1) {
                var found = false;
                for (var radius = 1; radius <= 3 && !found; radius++) {
                    for (var i = -radius; i <= radius && !found; i++) {
                        for (var j = -radius; j <= radius && !found; j++) {
                            var test_x = (cell_x + i) * 32 + 16;
                            var test_y = (cell_y + j) * 32 + 16;
                            if (mp_grid_get_cell(grid, cell_x + i, cell_y + j) == 0 && mp_grid_path(grid, path, x, y, test_x, test_y, true)) {
                                chase_x = test_x;
                                chase_y = test_y;
                                found = true;
                            }
                        }
                    }
                }
                if (found) {
                    show_debug_message(point_owner + " adjusted target to open spot: [" + string(chase_x) + "," + string(chase_y) + "]");
                } else {
                    chase_x = x;
                    chase_y = y;
                    show_debug_message(point_owner + " no open spot near player, holding position");
                }
            }

            target_x = chase_x;
            target_y = chase_y;
            if (mp_grid_path(grid, path, x, y, target_x, target_y, true)) {
                path_start(path, patrol_speed * 1.2, path_action_stop, false);
                var player_dir = point_direction(x, y, obj_player.x, obj_player.y);
                facing_direction = angle_lerp(facing_direction, player_dir, 0.1);
                show_debug_message(point_owner + " chasing player at [" + string(target_x) + "," + string(target_y) + "]");
            } else {
                path_end();
                show_debug_message(point_owner + " path to target blocked, waiting");
            }
        }
        // Transition to search when alert timer ends
        if (instance_exists(obj_manager) && !obj_manager.enemies_alerted) {
            state = "search";
            search_timer = search_timer_max;
            path_end();
            if (instance_exists(obj_player)) {
                last_player_x = obj_player.x; // Update last position when alert ends
                last_player_y = obj_player.y;
            }
            target_x = last_player_x;
            target_y = last_player_y;
            show_debug_message(point_owner + " entering search phase, heading to last known position: [" + string(target_x) + "," + string(target_y) + "]");
        }
        break;

    case "search":
        // Move to target with pathfinding, pause, and pick new spots near last known position
        if (path_position >= 1 || point_distance(x, y, target_x, target_y) <= patrol_speed * 2) { // Wider reach check
            path_end();
            if (search_pause_timer > 0) {
                search_pause_timer--; // Pause to "look around"
            } else {
                // Pick a random spot within 256px of last_player_x/y
                var attempts = 0;
                do {
                    var angle = irandom(360);
                    var dist = irandom_range(32, 256); // Within 256px radius
                    target_x = last_player_x + lengthdir_x(dist, angle);
                    target_y = last_player_y + lengthdir_y(dist, angle);
                    // Snap to grid
                    target_x = round(target_x / 32) * 32;
                    target_y = round(target_y / 32) * 32;
                    attempts++;
                } until (mp_grid_path(grid, path, x, y, target_x, target_y, true) || attempts > 10);
                if (attempts > 10) {
                    target_x = x;
                    target_y = y;
                    show_debug_message(point_owner + " couldn’t find a searchable spot near last position");
                } else {
                    show_debug_message(point_owner + " searching near last position at: [" + string(target_x) + "," + string(target_y) + "]");
                }
                search_pause_timer = 180; // 3 sec pause
            }
        } else if (mp_grid_path(grid, path, x, y, target_x, target_y, true)) {
            path_start(path, patrol_speed, path_action_stop, false);
            var next_x = path_get_x(path, path_position + 0.01);
            var next_y = path_get_y(path, path_position + 0.01);
            var move_dir = point_direction(x, y, next_x, next_y);
            facing_direction = angle_lerp(facing_direction, move_dir, 0.03);
            show_debug_message(point_owner + " moving to search target: [" + string(target_x) + "," + string(target_y) + "]");
        } else {
            path_end();
            show_debug_message(point_owner + " search path blocked, picking new spot");
            target_x = x;
            target_y = y;
            search_pause_timer = 0; // Reset pause to try again
        }
        // Countdown search timer
        search_timer--;
        if (search_timer <= 0 && !player_spotted) {
            state = "patrol";
            path_end();
            if (array_length(patrol_points) > 0) {
                target_x = patrol_points[current_point].x;
                target_y = patrol_points[current_point].y;
                if (!mp_grid_path(grid, path, x, y, target_x, target_y, true)) {
                    target_x = x;
                    target_y = y;
                    show_debug_message("Return path blocked for " + point_owner);
                }
            }
            show_debug_message(point_owner + " returning to patrol");
        }
        break;
}

// Update alert icon
if (alert_icon_timer > 0) {
    alert_icon_timer--;
    alert_icon_scale = max(1, alert_icon_scale - 0.02);
    alert_icon_alpha = max(0, alert_icon_alpha - 0.016);
}