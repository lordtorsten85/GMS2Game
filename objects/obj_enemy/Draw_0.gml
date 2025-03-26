// obj_enemy - Create Event
// Sets up sprite and overrides parent variables.

// Variable Definitions:
// - hp (real): Health points for this enemy.

// Protect variable definitions
if (!variable_instance_exists(id, "hp")) hp = 50;

image_speed = 0.5; // Slower base animation

// Inherit parent event
event_inherited();