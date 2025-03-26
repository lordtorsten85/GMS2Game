// obj_room_trigger - Step Event
// Description: Detects player entry to set global room state, persists until new room entered
if (!variable_global_exists("current_room_tag")) {
    if (variable_global_exists("initial_room_tag")) {
        global.current_room_tag = global.initial_room_tag;
    } else {
        global.current_room_tag = "";
    }
}

if (place_meeting(x + 4, y + 4, obj_player)) {
    if (global.current_room_tag != room_tag) {
        global.current_room_tag = room_tag;
    }
}