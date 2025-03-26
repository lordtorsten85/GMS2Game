// Object: obj_enemy_camera
// Event: Step
// Description: Handles scanning, player detection, and state transitions

// Detect player
var player = instance_nearest(x, y, obj_player);
var player_detected = false;
if (instance_exists(player)) {
    var dist = point_distance(x, y, player.x, player.y);
    var dir_to_player = point_direction(x, y, player.x, player.y);
    var angle_diff = abs(angle_difference(facing_direction, dir_to_player));
    if (dist <= detection_range && angle_diff <= detection_angle / 2) {
        player_detected = true;
    }
}

// State machine
switch (state) {
    case "patrol":
        if (player_detected || obj_manager.enemies_alerted) {
            state = "detected";
            if (player_detected && alert_cooldown <= 0) {
                with (obj_manager) {
                    enemies_alerted = true;
                    global.alert_timer = 10 * game_get_speed(gamespeed_fps); // Use global.alert_timer
                    show_debug_message("Camera detected player - all enemies alerted!");
                }
                alert_cooldown = alert_cooldown_duration;
            }
        }
        break;

    case "detected":
        if (!player_detected && !obj_manager.enemies_alerted) {
            state = "search";
            search_timer = search_duration;
            show_debug_message("Camera lost player - entering search state");
        }
        break;

    case "search":
        if (player_detected || obj_manager.enemies_alerted) {
            state = "detected";
            if (player_detected && alert_cooldown <= 0) {
                with (obj_manager) {
                    enemies_alerted = true;
                    global.alert_timer = 10 * game_get_speed(gamespeed_fps); // Use global.alert_timer
                    show_debug_message("Camera re-detected player - all enemies alerted!");
                }
                alert_cooldown = alert_cooldown_duration;
            }
        } else {
            search_timer--;
            if (search_timer <= 0) {
                state = "patrol";
                show_debug_message("Camera search ended - returning to patrol");
            }
        }
        break;
}

// Update facing direction based on state
if (state == "detected" && instance_exists(player)) {
    // Lock onto player in detected state
    facing_direction = point_direction(x, y, player.x, player.y);
} else {
    // Scanning logic for patrol and search states
    if (pause_timer > 0) {
        pause_timer--;
    } else {
        var max_angle = detection_angle / 2;
        scan_angle += scan_speed * scan_direction;
        if (scan_angle >= max_angle) {
            scan_angle = max_angle;
            scan_direction = -1;
            pause_timer = pause_duration;
        } else if (scan_angle <= -max_angle) {
            scan_angle = -max_angle;
            scan_direction = 1;
            pause_timer = pause_duration;
        }
    }
    facing_direction = base_direction + scan_angle;
}

// Update cooldown
if (alert_cooldown > 0) {
    alert_cooldown--;
}