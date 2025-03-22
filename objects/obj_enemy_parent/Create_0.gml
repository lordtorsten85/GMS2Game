// Object: obj_enemy_parent
// Event: Create
// Description: Initializes enemy variables, patrol system, pathfinding, and detection setup.

// Variable Definitions (set in object editor):
// - point_owner (string): Unique identifier matching nav points to this enemy.

if (!variable_instance_exists(id, "point_owner")) point_owner = ""; // Default to empty string if not set
move_speed = 1.4;          // Speed of movement, 30% slower than 2 (override in child if needed)
patrol_points = [];        // Array to store nav point instances
current_target = noone;    // Current nav point instance being targeted
patrol_index = 0;          // Current index in patrol_points array
path = path_add();         // Create a path for motion planning
grid = noone;              // Will hold the mp_grid, set in Room Start
path_x = x;                // Current target x along path
path_y = y;                // Current target y along path
path_point_index = 1;      // Tracks current point on the path

// Detection variables
detection_range = 150;     // Base distance of detection cone (patrol)
detection_angle = 60;      // Base total angle of cone (patrol)
chase_range = 200;         // Larger range during chase and search
chase_angle = 90;          // Larger angle during chase and search
facing_direction = 0;      // Current direction enemy is facing
target_direction = 0;      // Direction enemy is moving towards
state = "patrol";          // "patrol", "detected", "search"
search_timer = 0;          // Timer for search state
chase_recalc_timer = 0;    // Timer to recalc path during chase

// Search variables
last_player_x = 0;         // Last known player X position
last_player_y = 0;         // Last known player Y position
search_wander_timer = 0;   // Timer to pick new wander point and look direction
search_look_angle = 0;     // Angle to look at during search
arrived_at_last = false;   // Tracks if enemy reached last known position

// Animation
image_speed = 0.2;         // Set to your preferred 0.2

// Chase variables
stored_target = noone;     // Stores next nav point when chasing
stored_index = 0;          // Stores patrol_index for resuming