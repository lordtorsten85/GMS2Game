// obj_nav_point - Create Event
// Description: Ensures navigation point properties have defaults if not set in Room Editor
// Variable Definitions:
// - point_owner - string - Tag associating this point with an enemy (set in Room Editor)
// - point_index - real - Index in the enemy's navigation sequence (set in Room Editor)

if (!variable_instance_exists(id, "point_owner")) point_owner = "default";
if (!variable_instance_exists(id, "point_index")) point_index = 0;