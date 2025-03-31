// obj_enemy - Step Event
// Description: Updates sprite direction, handles damage, and implements melee attack behavior.

event_inherited();

image_xscale = (facing_direction > 90 && facing_direction < 270) ? -1 : 1;

if (state == "chase") {
    image_speed = 0.6;
} else if (state == "patrol") {
    image_speed = 0.4;
} else if (state == "attack") {
    image_speed = 0.5;
}

if (state == "attack" && is_attacking) {
    var player_dist = point_distance(x, y, obj_player.x, obj_player.y);
    if (player_dist <= attack_range + 4) { // Align with parent’s attack_range (56 + 4 = 60 pixels)
        obj_manager.health_current -= 10;
        effect_create_above(4, obj_player.x, obj_player.y, 1, c_white);
        is_attacking = false;
    }
}

if (hp <= 0) {
    instance_destroy();
}