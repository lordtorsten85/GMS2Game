// obj_enemy - Step Event
// Description: Updates sprite direction, animation, and checks for death.

event_inherited(); // Inherit from obj_enemy_parent

image_xscale = (facing_direction > 90 && facing_direction < 270) ? -1 : 1;

if (state == "chase") {
    image_speed = 0.6;
} else if (state == "patrol") {
    image_speed = 0.4;
} else if (state == "attack") {
    image_speed = 0.5;
} else if (state == "stunned") {
    image_speed = 0; // Freeze animation during stun
}

if (hp <= 0) {
    instance_destroy();
}