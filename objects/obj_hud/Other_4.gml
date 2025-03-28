// obj_hud - Room Start Event
// Ensures starting room is revealed after all instances are created.

// Reveal starting room
var starting_mask = noone;
with (obj_room_mask) {
    if (!variable_instance_exists(id, "isStartingRoom")) isStartingRoom = false; // Default if unset
    if (isStartingRoom) {
        starting_mask = id;
        ds_map_add(global.revealed_rooms, linked_room_tag, true);
        show_debug_message("Starting room revealed: " + linked_room_tag);
    }
}
if (starting_mask == noone) {
    show_debug_message("Warning: No starting room mask found!");
}