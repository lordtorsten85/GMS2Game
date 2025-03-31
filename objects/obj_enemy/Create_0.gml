// obj_enemy - Create Event
// Description: Sets up the melee enemy with patrol speed and attack properties.

event_inherited();

patrol_speed = 1;

if (!variable_instance_exists(id, "hp")) hp = 50;

attack_range = 48;
attack_cooldown = 60;
attack_timer = 0;
is_attacking = false;

image_speed = 0.5;