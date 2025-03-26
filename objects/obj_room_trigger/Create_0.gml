// obj_room_trigger - Create Event
// Description: Lightweight trigger for room entry/exit
// Variable Definitions (set in Room Editor):
// - room_tag - string - Matches linked_room_tag (e.g., "EntryRoom")
if (!variable_instance_exists(id, "room_tag")) room_tag = "none";