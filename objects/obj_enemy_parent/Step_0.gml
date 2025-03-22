// Object: obj_enemy_parent
// Event: Step
if (current_target == noone && state != "detected") exit;

var player = instance_nearest(x, y, obj_player);
var player_detected = false;
var active_range = (state == "patrol") ? detection_range : chase_range;
var active_angle = (state == "patrol") ? detection_angle : chase_angle;
if (instance_exists(player)) {
    var dist = point_distance(x, y, player.x, player.y);
    var dir_to_player = point_direction(x, y, player.x, player.y);
    var angle_diff = abs(angle_difference(facing_direction, dir_to_player));
    if (dist <= active_range && angle_diff <= active_angle / 2) {
        player_detected = true;
        last_player_x = player.x;
        last_player_y = player.y;
        with (obj_manager) {
            enemies_alerted = true;
            alert_timer = 10 * game_get_speed(gamespeed_fps);
            show_debug_message("Enemy " + other.point_owner + " detected player - all enemies alerted!");
        }
    }
}

// Update alert icon animation
if (alert_icon_timer > 0) {
    alert_icon_timer--;
    var progress = 1 - (alert_icon_timer / alert_icon_duration); // 0 to 1 over duration
    if (progress < 0.2) {
        // 0 to 0.2s: Quick scale up to 1.5
        alert_icon_scale = (progress / 0.2) * 1.5; // 0 to 1.5
        alert_icon_alpha = 1;
    } else if (progress < 0.4) {
        // 0.2s to 0.4s: Scale down to 1
        alert_icon_scale = 1.5 - (((progress - 0.2) / 0.2) * 0.5); // 1.5 to 1
        alert_icon_alpha = 1;
    } else {
        // 0.4s to 1s: Fade out
        alert_icon_scale = 1;
        alert_icon_alpha = 1 - ((progress - 0.4) / 0.6); // 1 to 0 over 0.6s
    }
}

switch (state) {
    case "patrol":
        if (player_detected || obj_manager.enemies_alerted) {
            state = "detected";
            stored_target = current_target;
            stored_index = patrol_index;
            // Trigger alert icon
            alert_icon_timer = alert_icon_duration;
            alert_icon_scale = 0;
            alert_icon_alpha = 1;
            if (instance_exists(player)) {
                if (mp_grid_path(grid, path, x, y, player.x, player.y, true)) {
                    path_point_index = 1;
                    path_x = path_get_point_x(path, path_point_index);
                    path_y = path_get_point_y(path, path_point_index);
                    target_direction = point_direction(x, y, path_x, path_y);
                    image_xscale = (lengthdir_x(move_speed, target_direction) < 0) ? -1 : 1;
                    image_angle = 0;
                } else {
                    path_x = player.x;
                    path_y = player.y;
                    target_direction = point_direction(x, y, path_x, path_y);
                    show_debug_message("Initial chase path failed for " + point_owner);
                }
            }
        } else {
            var dir = point_direction(x, y, path_x, path_y);
            var move_x = lengthdir_x(move_speed, dir);
            var move_y = lengthdir_y(move_speed, dir);
            var old_x = x;
            var old_y = y;
            x += move_x;
            y += move_y;
            var is_moving = point_distance(old_x, old_y, x, y) > move_speed / 2;
            if (is_moving) {
                target_direction = dir;
                facing_direction = angle_lerp(facing_direction, target_direction, 0.15);
                image_xscale = (move_x < 0) ? -1 : 1;
                image_angle = 0;
            }

            if (point_distance(x, y, path_x, path_y) < move_speed) {
                var point_count = path_get_number(path);
                if (point_count > path_point_index + 1) {
                    path_point_index++;
                    path_x = path_get_point_x(path, path_point_index);
                    path_y = path_get_point_y(path, path_point_index);
                    target_direction = point_direction(x, y, path_x, path_y);
                    image_xscale = (lengthdir_x(move_speed, target_direction) < 0) ? -1 : 1;
                    image_angle = 0;
                } else if (point_distance(x, y, current_target.x, current_target.y) < move_speed) {
                    x = current_target.x;
                    y = current_target.y;
                    if (array_length(patrol_points) > 0) {
                        patrol_index = (patrol_index + 1) % array_length(patrol_points);
                        current_target = patrol_points[patrol_index];
                        if (mp_grid_path(grid, path, x, y, current_target.x, current_target.y, true)) {
                            path_point_index = 1;
                            path_x = path_get_point_x(path, path_point_index);
                            path_y = path_get_point_y(path, path_point_index);
                            target_direction = point_direction(x, y, path_x, path_y);
                            image_xscale = (lengthdir_x(move_speed, target_direction) < 0) ? -1 : 1;
                            image_angle = 0;
                        } else {
                            path_x = x;
                            path_y = y;
                            show_debug_message("Path to nav point failed for " + point_owner);
                        }
                    }
                }
            }
        }
        break;

    case "detected":
        if (player_detected || obj_manager.enemies_alerted) {
            chase_recalc_timer--;
            if (chase_recalc_timer <= 0) {
                if (instance_exists(player)) {
                    if (mp_grid_path(grid, path, x, y, player.x, player.y, true)) {
                        path_point_index = 1;
                        path_x = path_get_point_x(path, path_point_index);
                        path_y = path_get_point_y(path, path_point_index);
                        target_direction = point_direction(x, y, path_x, path_y);
                        image_xscale = (lengthdir_x(move_speed, target_direction) < 0) ? -1 : 1;
                        image_angle = 0;
                    } else {
                        path_x = player.x;
                        path_y = player.y;
                        target_direction = point_direction(x, y, path_x, path_y);
                        show_debug_message("Chase recalc path failed for " + point_owner);
                    }
                }
                chase_recalc_timer = game_get_speed(gamespeed_fps) / 2;
            }
            var dir = point_direction(x, y, path_x, path_y);
            var move_x = lengthdir_x(move_speed, dir);
            var move_y = lengthdir_y(move_speed, dir);
            var old_x = x;
            var old_y = y;
            x += move_x;
            y += move_y;
            var is_moving = point_distance(old_x, old_y, x, y) > move_speed / 2;
            if (is_moving) {
                target_direction = dir;
                facing_direction = angle_lerp(facing_direction, target_direction, 0.15);
                image_xscale = (move_x < 0) ? -1 : 1;
                image_angle = 0;
            }
            if (point_distance(x, y, path_x, path_y) < move_speed) {
                if (path_get_number(path) > path_point_index + 1) {
                    path_point_index++;
                    path_x = path_get_point_x(path, path_point_index);
                    path_y = path_get_point_y(path, path_point_index);
                    target_direction = point_direction(x, y, path_x, path_y);
                    image_xscale = (lengthdir_x(move_speed, target_direction) < 0) ? -1 : 1;
                    image_angle = 0;
                }
            }
        } else {
            state = "search";
            search_timer = 10 * game_get_speed(gamespeed_fps);
            search_wander_timer = 0;
            arrived_at_last = false;
            if (instance_exists(player)) {
                last_player_x = player.x;
                last_player_y = player.y;
            }
            path_clear_points(path);
            if (mp_grid_path(grid, path, x, y, last_player_x, last_player_y, true)) {
                path_point_index = 1;
                path_x = path_get_point_x(path, path_point_index);
                path_y = path_get_point_y(path, path_point_index);
                target_direction = point_direction(x, y, path_x, path_y);
                image_xscale = (lengthdir_x(move_speed, target_direction) < 0) ? -1 : 1;
                image_angle = 0;
                show_debug_message(point_owner + " entering search - heading to last player pos: (" + string(last_player_x) + ", " + string(last_player_y) + ")");
            } else {
                path_x = last_player_x;
                path_y = last_player_y;
                target_direction = point_direction(x, y, path_x, path_y);
                image_xscale = (lengthdir_x(move_speed, target_direction) < 0) ? -1 : 1;
                image_angle = 0;
                show_debug_message("Path to last known position failed for " + point_owner + " - direct move to (" + string(last_player_x) + ", " + string(last_player_y) + ")");
            }
        }
        break;

    case "search":
        if (player_detected || obj_manager.enemies_alerted) {
            state = "detected";
            alert_icon_timer = alert_icon_duration;
            alert_icon_scale = 0;
            alert_icon_alpha = 1;
            if (instance_exists(player)) {
                if (mp_grid_path(grid, path, x, y, player.x, player.y, true)) {
                    path_point_index = 1;
                    path_x = path_get_point_x(path, path_point_index);
                    path_y = path_get_point_y(path, path_point_index);
                    target_direction = point_direction(x, y, path_x, path_y);
                    image_xscale = (lengthdir_x(move_speed, target_direction) < 0) ? -1 : 1;
                    image_angle = 0;
                } else {
                    path_x = player.x;
                    path_y = player.y;
                    target_direction = point_direction(x, y, path_x, path_y);
                    show_debug_message("Search chase path failed for " + point_owner);
                }
            }
        } else {
            if (!arrived_at_last || point_distance(x, y, path_x, path_y) >= move_speed) {
                var dir = point_direction(x, y, path_x, path_y);
                var move_x = lengthdir_x(move_speed, dir);
                var move_y = lengthdir_y(move_speed, dir);
                x += move_x;
                y += move_y;
                target_direction = dir;
                facing_direction = angle_lerp(facing_direction, target_direction, 0.15);
                image_xscale = (move_x < 0) ? -1 : 1;
                image_angle = 0;
            }

            show_debug_message("Search State - " + point_owner + " | Pos: (" + string(x) + ", " + string(y) + ") | Path: (" + string(path_x) + ", " + string(path_y) + ") | Last Player: (" + string(last_player_x) + ", " + string(last_player_y) + ") | Target Dir: " + string(target_direction) + " | Facing Dir: " + string(facing_direction) + " | Moving: " + string(point_distance(x, y, path_x, path_y) >= move_speed) + " | Wander Timer: " + string(search_wander_timer) + " | Arrived: " + string(arrived_at_last));

            if (point_distance(x, y, path_x, path_y) < move_speed) {
                x = path_x;
                y = path_y;
                if (path_get_number(path) > path_point_index + 1) {
                    path_point_index++;
                    path_x = path_get_point_x(path, path_point_index);
                    path_y = path_get_point_y(path, path_point_index);
                    target_direction = point_direction(x, y, path_x, path_y);
                    image_xscale = (lengthdir_x(move_speed, target_direction) < 0) ? -1 : 1;
                    image_angle = 0;
                } else if (!arrived_at_last && point_distance(x, y, last_player_x, last_player_y) < move_speed) {
                    arrived_at_last = true;
                    show_debug_message(point_owner + " arrived at last player pos: (" + string(last_player_x) + ", " + string(last_player_y) + ")");
                }
            }

            if (arrived_at_last && search_wander_timer > 0) {
                search_wander_timer--;
            } else if (arrived_at_last) {
                var wander_x = last_player_x + irandom_range(-50, 50);
                var wander_y = last_player_y + irandom_range(-50, 50);
                path_clear_points(path);
                if (mp_grid_path(grid, path, x, y, wander_x, wander_y, true)) {
                    path_point_index = 1;
                    path_x = path_get_point_x(path, path_point_index);
                    path_y = path_get_point_y(path, path_point_index);
                    target_direction = point_direction(x, y, path_x, path_y);
                    image_xscale = (lengthdir_x(move_speed, target_direction) < 0) ? -1 : 1;
                    image_angle = 0;
                    show_debug_message(point_owner + " wandering to new pos: (" + string(wander_x) + ", " + string(wander_y) + ")");
                } else {
                    path_x = x;
                    path_y = y;
                    show_debug_message("Wander path failed for " + point_owner);
                }
                search_wander_timer = game_get_speed(gamespeed_fps) * 2;
            }

            search_timer--;
            if (search_timer <= 0) {
                state = "patrol";
                current_target = stored_target;
                patrol_index = stored_index;
                if (mp_grid_path(grid, path, x, y, current_target.x, current_target.y, true)) {
                    path_point_index = 1;
                    path_x = path_get_point_x(path, path_point_index);
                    path_y = path_get_point_y(path, path_point_index);
                    target_direction = point_direction(x, y, path_x, path_y);
                    image_xscale = (lengthdir_x(move_speed, target_direction) < 0) ? -1 : 1;
                    image_angle = 0;
                } else {
                    path_x = x;
                    path_y = y;
                    show_debug_message("Return path failed for " + point_owner);
                }
            }
        }
        break;
}