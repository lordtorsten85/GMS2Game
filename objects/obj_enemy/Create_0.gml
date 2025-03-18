// obj_enemy - Create Event
// Description: Initializes specific properties for this enemy type, inheriting from obj_enemy_parent
// Variable Definitions:
// - point_owner - string - Tag to match with obj_nav_point instances (set in Room Editor)

event_inherited();

if (!variable_instance_exists(id, "point_owner")) point_owner = "enemy1";

move_speed = 1.5;           // Override move speed
vision_range = 150;         // Vision cone distance
vision_angle = 45;          // Vision cone half-angle
chase_range = 200;          // Distance to lose player
chase_scan_range = 300;     // Override chase scan range

px = 0;                     // Player x-position for detection
py = 0;                     // Player y-position for detection
dist_to_player = 0;         // Distance to player
angle_to_player = 0;        // Angle to player
in_cone = false;            // Whether player is in vision cone