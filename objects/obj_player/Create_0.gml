// obj_player - Create Event
// Description: Initializes player properties, movement speed, inventory attachment, and crouch state
// Variable Definitions (set in object editor):
// - coins - real - Player's coin count
// - move_speed - real - Base movement speed (pixels per frame, e.g., 3)
// - input_direction - real - Current movement direction (degrees)
// - depth - real - Rendering depth (e.g., -12210)
// - nearest_item_to_pickup - real - Nearest obj_item instance for pickup
// - pickup_cooldown - real - Cooldown timer for item pickup
// - melee_damage - real - Punching damage (e.g., 5)

persistent = true; // Persist across rooms
move_speed = 3; // Movement speed in pixels per frame
default_move_speed = move_speed; // Store default speed
crouch_speed = move_speed * 0.5; // 50% speed when crouching
input_direction = 0; // Initial movement direction
depth = -12210;
nearest_item_to_pickup = noone; // Tracks the nearest item instance
pickup_cooldown = 0; // Optional cooldown timer
is_crouching = false; // False = walking, True = prone

// Punching setup
last_xscale = 1;
last_direction = 0;
is_punching = false;
has_hit = false;
melee_damage = 5; // Punching damage
punch_hitbox = { x: 0, y: 0, size: 8 }; // Initialize with default values, updated in Step Event

// Particle system for punch hit effect
part_system = part_system_create();
part_type = part_type_create();
part_type_shape(part_type, pt_shape_star); // Spark-like shape
part_type_size(part_type, 0.5, 1, -0.02, 0); // Small, shrinking particles
part_type_color2(part_type, c_yellow, c_white); // Yellow to white fade
part_type_alpha2(part_type, 1, 0); // Fade out
part_type_speed(part_type, 1, 2, 0, 0); // Slight outward motion
part_type_direction(part_type, 0, 360, 0, 0); // Random direction for burst
part_type_life(part_type, 10, 20); // Short lifespan (~0.2–0.3 seconds at 60 FPS)