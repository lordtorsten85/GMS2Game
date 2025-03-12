// obj_console - Step Event
// Description: Handles player interaction and triggers linked objects based on inventory contents

var interaction_distance = 64; // Tightened range for precise interaction

if (instance_exists(obj_player)) {
    // Use bounding box for more accurate distance check
    var dist = point_distance(bbox_left + (bbox_right - bbox_left) / 2, 
                             bbox_top + (bbox_bottom - bbox_top) / 2, 
                             obj_player.x, obj_player.y);
    show_debug_message("Distance from console center to player: " + string(dist));
    
    if (dist < interaction_distance) {
        can_interact = true;
        if (keyboard_check_pressed(ord("E"))) {
            is_open = !is_open;
            if (is_open && instance_exists(global.backpack)) {
                global.backpack.is_open = true; // Auto-open backpack
                show_debug_message("Backpack opened with console");
            } else if (!is_open && instance_exists(global.backpack)) {
                global.backpack.is_open = false; // Close backpack when console closes
                show_debug_message("Backpack closed with console (E key)");
            }
            show_debug_message("Console GUI " + (is_open ? "opened" : "closed"));
        }
    } else {
        can_interact = false;
        if (is_open) {
            is_open = false;
            if (instance_exists(global.backpack)) {
                global.backpack.is_open = false; // Close backpack when walking away
                show_debug_message("Backpack closed with console (walked away)");
            }
            show_debug_message("Console and backpack closed - player walked away");
        }
    }
}

// Check inventory for required items
var all_items_present = true;
for (var k = 0; k < array_length(required_items); k++) {
    var req_item = required_items[k][0];
    var req_qty = required_items[k][1];
    var found_qty = 0;
    
    for (var i = 0; i < grid_width; i++) {
        for (var j = 0; j < grid_height; j++) {
            var slot = inventory[# i, j];
            if (slot != -1 && is_array(slot) && slot[0] == req_item) {
                found_qty += slot[2];
            }
        }
    }
    if (found_qty < req_qty) {
        all_items_present = false;
        break;
    }
}

// Trigger linked objects
with (all) {
    if (variable_instance_exists(id, "my_tag") && my_tag == other.target_tag) {
        if (all_items_present && variable_instance_exists(id, "state") && state == "closed") {
            Activate();
            show_debug_message("Activated object with tag: " + my_tag);
        } else if (!all_items_present && variable_instance_exists(id, "state") && state == "open") {
            Deactivate();
            show_debug_message("Deactivated object with tag: " + my_tag);
        }
    }
}