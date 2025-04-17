// obj_enemy_parent - Create Event
// Description: Initializes the enemy with AI properties, pathfinding, alert visuals, and stun mechanics.
// Variable Definitions (set in object editor):
// - point_owner - string - Navigation point owner (e.g., "default")
// - patrol_speed - real - Speed during patrol (default 2)
// - current_point - real - Index of current patrol point (default 0)
// - patrol_points - array - List of patrol points (default empty)
// - target_x - real - X coordinate of current target (default x)
// - target_y - real - Y coordinate of current target (default y)
// - last_player_x - real - Last known player X (default x)
// - last_player_y - real - Last known player Y (default y)
// - state - string - AI state (e.g., "patrol", "chase", "attack", "search", "stunned")
// - search_timer - real - Frames remaining in search (default 0)
// - search_timer_max - real - Max search duration (default 1200)
// - search_pause_timer - real - Pause timer for search rotations (default 0)
// - detection_range - real - Vision range (default 150)
// - detection_angle - real - Vision cone angle (default 90)
// - facing_direction - real - Direction enemy is facing (default 0)
// - attack_range - real - Range for attacks (default 48)
// - attack_timer - real - Tracks attack cooldown (default 0)
// - attack_cooldown - real - Frames between attacks (default 60)
// - is_attacking - boolean - Is enemy attacking? (default false)
// - hp - real - Enemy health (default 50)
// - alert_icon_timer - real - Timer for alert icon animation (default 0)
// - alert_icon_scale - real - Scale of alert icon (default 1)
// - alert_icon_alpha - real - Opacity of alert icon (default 1)
// - wait_timer - real - General wait timer (default 0)
// - pre_wait_timer - real - Rotation phase timer (default 0)
// - stunned - boolean - Is enemy stunned? (default false)
// - stun_timer - real - Frames remaining in stun (default 0)
// - stun_flash_timer - real - Controls flashing effect (default 0)

if (!variable_instance_exists(id, "point_owner")) point_owner = "default";
if (!variable_instance_exists(id, "patrol_speed")) patrol_speed = 2;
if (!variable_instance_exists(id, "current_point")) current_point = 0;

if (!variable_instance_exists(id, "patrol_points")) patrol_points = [];
if (!variable_instance_exists(id, "target_x")) target_x = x;
if (!variable_instance_exists(id, "target_y")) target_y = y;
if (!variable_instance_exists(id, "path")) path = path_add();
if (!variable_instance_exists(id, "grid")) grid = noone; // Will be set to global.mp_grid in Room Start
if (!variable_instance_exists(id, "last_player_x")) last_player_x = x;
if (!variable_instance_exists(id, "last_player_y")) last_player_y = y;

if (!variable_instance_exists(id, "state")) state = "patrol";
if (!variable_instance_exists(id, "search_timer")) search_timer = 0;
if (!variable_instance_exists(id, "search_timer_max")) search_timer_max = 1200;
if (!variable_instance_exists(id, "search_pause_timer")) search_pause_timer = 0;
if (!variable_instance_exists(id, "detection_range")) detection_range = 150;
if (!variable_instance_exists(id, "detection_angle")) detection_angle = 90;
if (!variable_instance_exists(id, "facing_direction")) facing_direction = 0;
if (!variable_instance_exists(id, "attack_range")) attack_range = 48;
if (!variable_instance_exists(id, "attack_timer")) attack_timer = 0;
if (!variable_instance_exists(id, "attack_cooldown")) attack_cooldown = 60;
if (!variable_instance_exists(id, "is_attacking")) is_attacking = false;
if (!variable_instance_exists(id, "hp")) hp = 50;

if (!variable_instance_exists(id, "alert_icon_timer")) alert_icon_timer = 0;
if (!variable_instance_exists(id, "alert_icon_scale")) alert_icon_scale = 1;
if (!variable_instance_exists(id, "alert_icon_alpha")) alert_icon_alpha = 1;

if (!variable_instance_exists(id, "wait_timer")) wait_timer = 0;
if (!variable_instance_exists(id, "pre_wait_timer")) pre_wait_timer = 0; // In steps, for rotation phase

if (!variable_instance_exists(id, "stunned")) stunned = false; // Stun state
if (!variable_instance_exists(id, "stun_timer")) stun_timer = 0; // Stun duration
if (!variable_instance_exists(id, "stun_flash_timer")) stun_flash_timer = 0; // Flash timer

if (!variable_instance_exists(id, "has_alerted")) has_alerted = false; // Track if alert animation has played

// Set solid to true to handle collisions automatically
solid = true;