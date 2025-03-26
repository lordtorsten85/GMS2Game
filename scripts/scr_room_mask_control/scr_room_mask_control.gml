// scr_room_mask_control - Function: update_room_masks
// Description: Updates all room masks based on player position, handling multiple entry/exit points
function update_room_masks() {
    if (!variable_global_exists("active_room_tag")) global.active_room_tag = ""; // Init global tag

    var player_in_any_mask = false;
    var new_active_tag = "";

    // Check which mask (if any) the player is in
    with (obj_room_mask) {
        var player_in_me = (place_meeting(x + 4, y + 4, obj_player) || 
                           place_meeting(x + sprite_width - 4, y + sprite_height - 4, obj_player));

        if (player_in_me) {
            new_active_tag = linked_room_tag;
            player_in_any_mask = true;
            show_debug_message("Player in mask at [" + string(x) + "," + string(y) + "] with tag '" + linked_room_tag + "', frame " + string(current_time));
            break; // First mask wins, avoids overlap fights
        }
    }

    // Update the global active tag
    if (player_in_any_mask) {
        global.active_room_tag = new_active_tag;
    } else {
        global.active_room_tag = ""; // Clear if player’s out of all masks
    }

    // Update all masks based on the active tag
    with (obj_room_mask) {
        if (global.active_room_tag == "") {
            target_alpha = 1; // Hide if no active tag
        } else if (linked_room_tag == global.active_room_tag) {
            target_alpha = 0; // Reveal if tag matches
            show_debug_message("Revealing mask at [" + string(x) + "," + string(y) + "] with tag '" + linked_room_tag + "'");
        } else {
            target_alpha = 1; // Hide others
            show_debug_message("Hiding mask at [" + string(x) + "," + string(y) + "] with tag '" + linked_room_tag + "'");
        }
        image_alpha = lerp(image_alpha, target_alpha, 0.1);
    }
}