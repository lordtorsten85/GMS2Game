// obj_enemy - Create Event
// Description: Initializes enemy with health, movement, animation, patrol, and scan logic
// Variable Definitions (set in object editor or creation):
// - hp - real - Health points (e.g., 30)
// - move_speed - real - Movement speed toward player or patrol (e.g., 2.5)
// - image_speed - real - Animation speed for idle sprite
// - waypoints - ds_list - List of x-coordinates for patrol route
// - waypoints_y - ds_list - List of y-coordinates for patrol route
// - current_waypoint - int - Index of current waypoint target
// - patrol_point_1_x - real - Original x-position of first patrol point
// - patrol_point_1_y - real - Original y-position of first patrol point
// - patrol_point_2_x - real - Original x-position of second patrol point
// - patrol_point_2_y - real - Original y-position of second patrol point
// - scan_range - real - Distance to detect player (e.g., 150)
// - scan_angle - real - Vision cone angle (e.g., 60 degrees)
// - state - string - Current state (e.g., "patrol", "chase", "pursue", "scan", "return")
// - scan_timer - real - Timer for scanning state (e.g., 60 frames)
// - pursue_timer - real - Timer for pursuing last known position (e.g., 180 frames)
// - last_player_x - real - Last known player x-position
// - last_player_y - real - Last known player y-position
// - facing - real - Current facing direction for sprite and detection (degrees)
// - facing_target - real - Target facing direction for smooth cone rotation (degrees)
// - cone_facing - real - Current facing direction for the scan cone (degrees)

hp = 30; // Health points
move_speed = 2.5; // Increased speed for more intense chase (player speed is 4)
image_speed = 0.1; // Slow animation speed for 4-frame idle
sprite_index = spr_enemy_bot_idle; // Assign the 4-frame idle sprite

// Patrol setup with waypoints
waypoints = ds_list_create(); // List of x-coordinates
waypoints_y = ds_list_create(); // List of y-coordinates
ds_list_add(waypoints, x - 100); // Waypoint 1 (original patrol_x1)
ds_list_add(waypoints_y, y); // Same y-position for simplicity
ds_list_add(waypoints, x + 100); // Waypoint 2 (original patrol_x2)
ds_list_add(waypoints_y, y); // Same y-position for simplicity
current_waypoint = 0; // Start at first waypoint
patrol_point_1_x = x - 100; // Store original patrol point 1 x
patrol_point_1_y = y; // Store original patrol point 1 y
patrol_point_2_x = x + 100; // Store original patrol point 2 x
patrol_point_2_y = y; // Store original patrol point 2 y

// Scan setup
scan_range = 150; // Detection range
scan_angle = 60; // Vision cone (30° left and right of facing)
state = "patrol"; // Initial state
scan_timer = 0; // Initialize scan timer
pursue_timer = 0; // Initialize pursue timer
last_player_x = x; // Initialize last known player position
last_player_y = y;
facing = 0; // Start facing right
facing_target = 0; // Start facing right for smooth rotation
cone_facing = 0; // Initialize cone facing for smooth rotation