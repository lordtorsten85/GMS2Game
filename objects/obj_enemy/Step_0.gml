// obj_enemy - Step Event
// Description: Handles player detection and state transitions, inheriting core movement logic

event_inherited();

if (hp <= 0) {
    instance_destroy();
    exit;
}

// Player detection
px = obj_player.x;
py = obj_player.y;
dist_to_player = point_distance(x, y, px, py);
angle_to_player = point_direction(x, y, px, py);
in_cone = (dist_to_player <= vision_range && 
          abs(angle_difference(facing, angle_to_player)) <= vision_angle && 
          !collision_line(x, y, px, py, obj_collision_parent, false, true));

// Log state and detection
show_debug_message("State: " + state + ", In cone: " + string(in_cone) + ", Dist to player: " + string(dist_to_player));

// State transitions
if (state == "patrol" && in_cone) {
    state = "chase";
    show_debug_message("Switching to chase at (" + string(x) + ", " + string(y) + ")");
} else if (state == "chase" && !in_cone) {
    state = "pursue";
    last_player_x = px;
    last_player_y = py;
    show_debug_message("Switching to pursue at (" + string(x) + ", " + string(y) + ")");
}