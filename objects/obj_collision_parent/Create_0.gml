/*
 * obj_collision_parent - Create Event
 * Initializes collision properties for parent object.
 * Variable Definitions (set in object editor if needed):
 * - point_owner - string (optional, not used here)
 */

if (!variable_instance_exists(id, "collision_active")) collision_active = true; // Default to active