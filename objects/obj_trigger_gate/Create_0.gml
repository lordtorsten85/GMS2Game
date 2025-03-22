/// obj_trigger_gate is an example of an item linked with an obj_green_keycard_console
// has a string variable definition "my_tag" which is used to link it with a console
// in the room editor so its events are triggered by only one console
/// obj_trigger_gate - Create
event_inherited();
state = "closed";

image_speed = 0;

solid = true; // So the player can’t walk through if you use collision logic

function Activate() {
    // Speed up the animation
	image_index = 0;
    image_speed = image_number/30;
	state = "opening";
}

function Deactivate() {
    // Speed up the animation
	image_index = 6;
    image_speed = image_number/30 * -1;
	show_debug_message(image_index);
    state = "closing";
}