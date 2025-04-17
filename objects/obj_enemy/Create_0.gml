// obj_enemy - Create Event
// Description: Sets up the melee enemy with patrol speed and attack properties.
// Variable Definitions (set in object editor):
// - hp - real - Enemy health (default 50)
// - patrol_speed - real - Speed during patrol (default 1)
// - attack_range - real - Range for melee attack (default 48)
// - attack_cooldown - real - Frames between attacks (default 60)
// - attack_timer - real - Tracks attack cooldown (default 0)
// - is_attacking - boolean - Is enemy attacking? (default false)

event_inherited(); // Inherit from obj_enemy_parent

// Protect variable definitions
if (!variable_instance_exists(id, "hp")) hp = 50;
if (!variable_instance_exists(id, "patrol_speed")) patrol_speed = 1;
if (!variable_instance_exists(id, "attack_range")) attack_range = 48;
if (!variable_instance_exists(id, "attack_cooldown")) attack_cooldown = 60;
if (!variable_instance_exists(id, "attack_timer")) attack_timer = 0;
if (!variable_instance_exists(id, "is_attacking")) is_attacking = false;

image_speed = 0.5;