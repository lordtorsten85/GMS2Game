// obj_item
// Event: Create
// Description: Initializes an item instance on the ground with its item ID, sprite, and stack quantity, used for pickup by the player. Retrieves item_id and stack_quantity from the room editor or creation arguments, ensuring items draw correctly with cached sprite data and preserve stack quantities for ground drops. Note: stack_quantity is defined in the object editor as a real with a default of 1.
// Variable Definitions:
// - item_id: real (The ID of the item from the ITEM enum, defaults to -1 in object editor)
// - item_sprite: real (The sprite index for the item, or -1 if none)
// - stack_quantity: real (The number of items in the stack, defined in object editor with default 1)

item_sprite = -1; // Default to no sprite, updated based on item_id

// Retrieve item_id from room editor or creation arguments (already defaults to -1, no override needed)
if (variable_instance_exists(id, "item_id")) {
    item_id = variable_instance_get(id, "item_id");
    // Validate item_id against global.item_data indices (0, 1, 2 for valid items)
    if (item_id < ITEM.NONE || item_id >= array_length(global.item_data)) {
        show_debug_message("Warning: Invalid item_id " + string(item_id) + " for obj_item at [" + string(x) + "," + string(y) + "], defaulting to ITEM.NONE");
        item_id = ITEM.NONE;
    }
}

// Update item_sprite based on the final item_id
item_sprite = (item_id != ITEM.NONE) ? global.item_data[item_id][5] : -1;

// Retrieve stack_quantity from creation arguments or use the object editor default (already set to 1)
if (variable_instance_exists(id, "stack_quantity")) {
    stack_quantity = variable_instance_get(id, "stack_quantity");
    if (stack_quantity <= 0) {
        show_debug_message("Warning: Invalid stack_quantity " + string(stack_quantity) + " for obj_item at [" + string(x) + "," + string(y) + "], defaulting to 1");
        stack_quantity = 1;
    }
} else {
    show_debug_message("Warning: No stack_quantity set for obj_item at [" + string(x) + "," + string(y) + "], using object editor default of 1");
}

show_debug_message("Created obj_item with Item ID: " + string(item_id) + ", Sprite: " + string(item_sprite) + ", and Stack Quantity: " + string(stack_quantity) + " at [" + string(x) + "," + string(y) + "]");