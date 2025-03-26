// obj_room_mask - Step Event
// Description: Updates visibility based on global room state
if (!variable_global_exists("current_room_tag")) {
    if (variable_global_exists("initial_room_tag")) {
        global.current_room_tag = global.initial_room_tag;
    } else {
        global.current_room_tag = "";
    }
}

if (global.current_room_tag == linked_room_tag) {
    target_alpha = 0; // Reveal if active
} else {
    target_alpha = 1; // Hide if not
}
image_alpha = lerp(image_alpha, target_alpha, 0.1);