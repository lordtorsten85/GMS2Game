// obj_player - Create Event
// Initializes player properties, including movement speed and inventory attachment.
// Makes the player persistent across rooms for continuity.

persistent = true; // Persist across rooms
move_speed = 4; // Movement speed in pixels per frame
default_move_speed = move_speed; // Store default speed
input_direction = 0; // Initial movement direction
depth = -12110;
nearest_item_to_pickup = noone; // Tracks the nearest item instance
pickup_cooldown = 0; // Optional cooldown timer