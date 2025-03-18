// obj_enemy_parent - Create Event
// Description: Initializes core properties for the enemy, nav point collection moved to Room Start
// Variable Definitions:
// - point_owner - string - Tag to match with obj_nav_point instances (set in Room Editor or child)

if (!variable_instance_exists(id, "point_owner")) point_owner = "default";

hp = 30;                    // Health points
move_speed = 1.0;           // Movement speed in pixels per step
image_speed = 0.1;          // Animation speed for idle sprite
scan_range = 150;           // Distance to detect player in patrol state
chase_scan_range = 250;     // Distance to detect player in chase state
scan_angle = 60;            // Vision cone angle in degrees
state = "patrol";           // Current state
scan_timer = 0;             // Timer for scanning state
pursue_timer = 0;           // Timer for pursuing last known position
last_player_x = x;          // Last known player x-position
last_player_y = y;          // Last known player y-position
facing = 0;                 // Current facing direction in degrees
facing_target = 0;          // Target facing direction for smooth rotation
collision_avoid_range = 32; // Distance to check for walls ahead
avoidance_angle = 45;       // Angle to adjust direction when avoiding
collision_size = max(sprite_get_bbox_right(sprite_index) - sprite_get_bbox_left(sprite_index), 
                     sprite_get_bbox_bottom(sprite_index) - sprite_get_bbox_top(sprite_index)); // Collision mask size
min_chase_distance = 16;    // Minimum distance to stop chasing player
facing_change_speed = 10;   // Speed of facing direction change in degrees per step

nav_points = [];            // Array to hold nav point coordinates
current_nav_index = 0;      // Current point in patrol sequence