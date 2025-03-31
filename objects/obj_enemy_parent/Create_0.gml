// obj_enemy_parent - Create Event
// Description: Initializes the enemy’s patrol system, pathfinding, detection cone, and alert icon.
// Variable Definitions (set in object editor):
// - point_owner - string - Identifier to match nav points to this enemy (e.g., "enemy_1")
// - patrol_speed - real - Speed for patrolling (e.g., 2)
// - current_point - real - Current nav point index (e.g., 0)

if (!variable_instance_exists(id, "point_owner")) point_owner = "default";
if (!variable_instance_exists(id, "patrol_speed")) patrol_speed = 2;
if (!variable_instance_exists(id, "current_point")) current_point = 0;

patrol_points = [];          // Array of nav point instances
target_x = x;                // Current target X position
target_y = y;                // Current target Y position
path = path_add();           // Path for motion planning
grid = noone;                // Motion planning grid (set in Room Start)
last_player_x = x;           // Last known player X position
last_player_y = y;           // Last known player Y position

state = "patrol";            // States: "patrol", "chase", "attack", "search"
search_timer = 0;            // Timer for search state (in steps)
search_timer_max = 1200;     // 20 sec at 60 FPS for search phase
search_pause_timer = 0;      // Pause timer for "looking around" in search (3 sec)
detection_range = 150;       // Range for detection
detection_angle = 90;        // Angle of detection cone
facing_direction = 0;        // Direction enemy is facing (degrees)
attack_range = 48;           // Distance to attack player (default, overridable)
attack_timer = 0;            // Cooldown timer for attacks
attack_cooldown = 60;        // 1 sec cooldown at 60 FPS (default, overridable)
is_attacking = false;        // Tracks if currently attacking (for children)
hp = 50;                     // Health points

// Alert icon variables
alert_icon_timer = 0;        // Frames to show alert icon (60 = 1 sec)
alert_icon_scale = 1;        // Scale of alert sprite
alert_icon_alpha = 1;        // Alpha of alert sprite