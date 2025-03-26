// obj_room_mask - Create Event
// Description: Sets up the room mask with a blackout sprite
sprite_index = spr_editor_room_change_ingame;
target_alpha = 1;
image_alpha = 1;
if (!variable_instance_exists(id, "linked_room_tag")) linked_room_tag = "none";

if (isStartingRoom)
{
	global.current_room_tag = linked_room_tag
	image_alpha = 1;
	target_alpha = 1;
}