// obj_enemy_parent - Create Event
// Initializes the patrol system, motion planning, state machine, and detection cone.

// Variable Definitions:
// - point_owner (string): Identifier to match nav points to this enemy.
// - patrol_speed (real): Speed at which the enemy moves between points, overridable by children.
// - current_point (real): Current index in the patrol_points array.

// Protect variable definitions
if (!variable_instance_exists(id, "point_owner")) point_owner = "default";
if (!variable_instance_exists(id, "patrol_speed")) patrol_speed = 2;
if (!variable_instance_exists(id, "current_point")) current_point = 0;

// Initialize patrol and movement variables
patrol_points = [];          // Array of nav point instances
target_x = x;                // Current target X to move toward
target_y = y;                // Current target Y to move toward
path = path_add();           // Path for motion planning
grid = noone;                // Motion planning grid (set in Room Start)
last_player_x = x;           // Last known player X position
last_player_y = y;           // Last known player Y position

// State machine
state = "patrol";            // States: "patrol", "alert", "search"
search_timer = 0;            // Timer for search state (in steps)
search_timer_max = 1200;     // 20 sec at 60 FPS for search phase
search_pause_timer = 0;      // Pause timer for "looking around" in search

// Detection cone variables
detection_range = 150;       // Range for detection
detection_angle = 90;        // Angle of detection cone
facing_direction = 0;        // Direction enemy is facing (degrees)

// Alert icon variables
alert_icon_timer = 0;        // Frames to show alert icon
alert_icon_scale = 1;        // Scale of alert sprite
alert_icon_alpha = 1;        // Alpha of alert sprite

// Enemy Properties
if (!variable_instance_exists(id, "hp")) hp = 50;