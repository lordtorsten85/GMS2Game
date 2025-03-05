// obj_player
// Event: Step
// Description: Handles player movement, inventory interactions, and single-item pickup with proximity check, updated to pick up stacked items from the ground with their full quantity, respecting ITEM.NONE (-1).
// Variable Definitions:
// - move_speed: real (Movement speed in pixels per frame)
// - default_move_speed: real (Default movement speed)
// - input_direction: real (Initial movement direction)
// - depth: real (Drawing depth)
// - nearest_item_to_pickup: instance (Tracks the nearest obj_item instance)
// - pickup_cooldown: real (Optional cooldown timer)

var pickup_range = 48;

// Manage pickup cooldown
if (!variable_instance_exists(id, "pickup_cooldown")) pickup_cooldown = 0;
if (pickup_cooldown > 0) pickup_cooldown--;

// Find the nearest obj_item within pickup_range
nearest_item_to_pickup = noone;
var min_dist = pickup_range;
with (obj_item) {
    var dist = point_distance(x, y, other.x, other.y);
    if (dist <= min_dist) {
        other.nearest_item_to_pickup = id;
        min_dist = dist;
      //  show_debug_message("Nearest obj_item flagged: " + string(id) + " at [" + string(x) + "," + string(y) + "] with distance " + string(dist) + ", Stack Quantity: " + string(stack_quantity));
    }
}

// Toggle backpack with Tab
if (keyboard_check_pressed(vk_tab)) {
    if (instance_exists(global.backpack)) {
        global.backpack.is_open = !global.backpack.is_open;
        show_debug_message((global.backpack.is_open ? "Opened" : "Closed") + " backpack at GUI position [64,256]");
    }
}

// Pickup logic: Pick up only the nearest flagged item when 'E' is pressed
if (keyboard_check_pressed(ord("E")) && pickup_cooldown == 0) {
    if (nearest_item_to_pickup != noone) {
        with (nearest_item_to_pickup) {
            var my_item_id = item_id;
            if (my_item_id != ITEM.NONE) { // Only pick up if not ITEM.NONE
			var success = inventory_add_item(global.backpack, my_item_id, stack_quantity, true);
			if (success) {
			    show_debug_message("Picked up Item ID: " + string(my_item_id) + " (" + global.item_data[my_item_id][0] + ") with quantity " + string(stack_quantity));
			    instance_destroy();
			    other.pickup_cooldown = 15;
			} else {
                    show_debug_message("Inventory full - cannot pick up Item ID: " + string(my_item_id) + " with quantity " + string(stack_quantity));
                }
            } else {
                show_debug_message("Cannot pick up: Item at [" + string(x) + "," + string(y) + "] has no valid item_id (ITEM.NONE)");
            }
        }
        nearest_item_to_pickup = noone; // Reset to prevent multiple pickups
        show_debug_message("Reset nearest_item_to_pickup to noone");
    } else {
        show_debug_message("No obj_item within " + string(pickup_range) + " pixels of player at [" + string(x) + "," + string(y) + "]");
    }
}