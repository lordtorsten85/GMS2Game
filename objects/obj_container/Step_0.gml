// obj_container - Step Event
if (place_meeting(x, y, obj_player) && keyboard_check_pressed(ord("E"))) {
	is_open = !is_open;
}

event_inherited();