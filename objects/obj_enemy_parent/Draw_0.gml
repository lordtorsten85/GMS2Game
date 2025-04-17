// obj_enemy_parent - Draw Event
// Description: Draws the enemy sprite with vision cone, alert icon, and stun flashing effect.

// Handle stun flashing
if (state == "stunned" && stun_flash_timer > 5) {
    image_alpha = 0.5; // Dim sprite during flash
} else {
    image_alpha = 1; // Normal opacity
}

draw_self();

var cone_color;
switch (state) {
    case "patrol": cone_color = c_green; break;
    case "chase": cone_color = c_red; break;
    case "attack": cone_color = c_red; break;
    case "search": cone_color = c_yellow; break;
    case "stunned": cone_color = c_blue; break; // Blue for stun
    default: cone_color = c_green;
}

draw_set_alpha(0.3);
draw_set_color(cone_color);

var cone_length = detection_range;
var cone_angle_half = detection_angle / 2;
var step = 2;

draw_primitive_begin(pr_trianglefan);
draw_vertex(x, y);
for (var i = -cone_angle_half; i <= cone_angle_half; i += step) {
    var dir = facing_direction + i;
    var target_x = x + lengthdir_x(cone_length, dir);
    var target_y = y + lengthdir_y(cone_length, dir);
    var draw_x = target_x;
    var draw_y = target_y;
    
    // Check for collision with obj_collision_parent (includes doors)
    var hit = collision_line(x, y, target_x, target_y, obj_collision_parent, false, true);
    if (hit != noone) {
        var is_active = true;
        // Check if it’s a door and adjust based on its state
        if (object_is_ancestor(hit.object_index, obj_proximity_door) || hit.object_index == obj_proximity_door) {
            // Door is considered "active" (blocks vision) if closed
            if (variable_instance_exists(hit, "locked") && hit.locked) {
                is_active = !hit.solid; // Locked doors use collision_active
            } else {
                is_active = (hit.image_index < hit.image_number - 1); // Unlocked doors use animation state
            }
        } // Non-door collisions (e.g., walls) are always active unless they have collision_active
        
        if (is_active) {
            var dist = point_distance(x, y, target_x, target_y);
            var step_size = 4;
            var steps = floor(dist / step_size);
            for (var j = 1; j <= steps; j++) {
                var check_dist = min(j * step_size, cone_length);
                var check_x = x + lengthdir_x(check_dist, dir);
                var check_y = y + lengthdir_y(check_dist, dir);
                var point_hit = collision_point(check_x, check_y, obj_collision_parent, false, true);
                if (point_hit != noone) {
                    var point_active = true;
                    if (object_is_ancestor(point_hit.object_index, obj_proximity_door) || point_hit.object_index == obj_proximity_door) {
                        if (variable_instance_exists(point_hit, "locked") && point_hit.locked) {
                            point_active = point_hit.solid;
                        } else {
                            point_active = (point_hit.image_index < point_hit.image_number - 1);
                        }
                    }
                    if (point_active) {
                        draw_x = x + lengthdir_x(check_dist - step_size, dir);
                        draw_y = y + lengthdir_y(check_dist - step_size, dir);
                        break;
                    }
                    if (j == steps) {
                        draw_x = target_x;
                        draw_y = target_y;
                    }
                }
            }
        }
    }
    
    draw_vertex(draw_x, draw_y);
}
draw_primitive_end();

draw_set_alpha(1);
draw_set_color(c_white);

// Draw centered alert icon if active
if (alert_icon_timer > 0) {
    var icon_x = x - (sprite_get_width(spr_enemy_alert) * alert_icon_scale / 2);
    var icon_y = y - sprite_height - 10;
    draw_sprite_ext(spr_enemy_alert, 0, icon_x, icon_y, alert_icon_scale, alert_icon_scale, 0, c_white, alert_icon_alpha);
    alert_icon_scale = max(1, alert_icon_scale - 0.02);
    alert_icon_alpha = max(0, alert_icon_alpha - 0.016);
}