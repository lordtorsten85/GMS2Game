// obj_enemy_parent - Step Event
if (hp <= 0) {
    instance_destroy();
    exit;
}

switch (state) {
    case "patrol":
        if (array_length(nav_points) > 0) {
            var target_x = nav_points[current_nav_index][0];
            var target_y = nav_points[current_nav_index][1];
            var moved = navigate_to_point(target_x, target_y, id);
            if (moved && point_distance(x, y, target_x, target_y) < move_speed) {
                current_nav_index = (current_nav_index + 1) % array_length(nav_points);
                show_debug_message("Reached nav point " + string(current_nav_index) + " for " + point_owner);
            }
        } else {
            show_debug_message("No nav points to patrol for " + point_owner);
        }
        break;

    case "chase":
        if (instance_exists(obj_player)) {
            var dist = point_distance(x, y, obj_player.x, obj_player.y);
            if (dist > min_chase_distance) {
                var dir = point_direction(x, y, obj_player.x, obj_player.y);
                facing += clamp(angle_difference(dir, facing), -facing_change_speed, facing_change_speed);
                navigate_to_point(obj_player.x, obj_player.y, id);
            }
            if (dist > chase_scan_range) {
                state = "pursue";
                last_player_x = obj_player.x;
                last_player_y = obj_player.y;
            }
        }
        break;

    case "pursue":
        if (pursue_timer == 0) pursue_timer = 180;
        pursue_timer -= 1;
        var dir = point_direction(x, y, last_player_x, last_player_y);
        facing += clamp(angle_difference(dir, facing), -facing_change_speed, facing_change_speed);
        navigate_to_point(last_player_x, last_player_y, id);
        if (point_distance(x, y, last_player_x, last_player_y) < move_speed || pursue_timer <= 0) {
            state = "scan";
            pursue_timer = 0;
        }
        break;

    case "scan":
        if (scan_timer == 0) scan_timer = 120;
        scan_timer -= 1;
        facing += 360 / 120;
        if (facing >= 360) facing -= 360;
        if (scan_timer <= 0) {
            state = "return";
            scan_timer = 0;
        }
        break;

    case "return":
        if (array_length(nav_points) > 0) {
            var nearest_idx = 0;
            var min_dist = infinity;
            for (var i = 0; i < array_length(nav_points); i++) {
                var dist = point_distance(x, y, nav_points[i][0], nav_points[i][1]);
                if (dist < min_dist && !collision_line(x, y, nav_points[i][0], nav_points[i][1], obj_collision_parent, false, true)) {
                    min_dist = dist;
                    nearest_idx = i;
                }
            }
            var target_x = nav_points[nearest_idx][0];
            var target_y = nav_points[nearest_idx][1];
            navigate_to_point(target_x, target_y, id);
            if (point_distance(x, y, target_x, target_y) < move_speed) {
                state = "patrol";
                current_nav_index = nearest_idx;
            }
        }
        break;
}