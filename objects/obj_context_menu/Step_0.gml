// obj_context_menu
// Event: Step
// Description: Handles context menu interaction, closing on left-click outside or processing option selections with a larger clickable area. Ensures multi-cell items are fully removed from inventory when dropped, and handles Split Stack for stackable items by leaving half in the inventory and starting a manual drag without immediate drop. Updated to drop or take stacked items correctly and preserve stack quantities.
// Variable Definitions:
// - inventory: instance (The obj_inventory instance the menu is attached to)
// - item_id: real (The ID of the clicked item from the ITEM enum)
// - slot_x: real (X position of the clicked slot in the inventory grid)
// - slot_y: real (Y position of the clicked slot in the inventory grid)
// - menu_x: real (GUI X position of the menu)
// - menu_y: real (GUI Y position of the menu)
// - menu_width: real (Width of the menu in pixels)
// - menu_height: real (Height of the menu in pixels)
// - options: array (Array of option strings, e.g., ["Drop", "Split Stack", "Take"])

var gui_mouse_x = device_mouse_x_to_gui(0);
var gui_mouse_y = device_mouse_y_to_gui(0);

// Close menu on left-click outside
if (mouse_check_button_pressed(mb_left)) {
    if (!point_in_rectangle(gui_mouse_x, gui_mouse_y, menu_x, menu_y, menu_x + menu_width, menu_y + menu_height)) {
        instance_destroy();
        show_debug_message("Closed context menu for " + (inventory.inventory_type != "" ? inventory.inventory_type : "unknown"));
    }
}

// Handle option selection with larger clickable area
if (mouse_check_button_pressed(mb_left) && point_in_rectangle(gui_mouse_x, gui_mouse_y, menu_x, menu_y, menu_x + menu_width, menu_y + menu_height)) {
    var option_height = 30; // Larger clickable area (30 pixels per option)
    var option_index = floor((gui_mouse_y - menu_y) / option_height);
    if (option_index >= 0 && option_index < array_length(options)) {
        var option = options[option_index];
        var qty = 0;
        var top_left_x = slot_x;
        var top_left_y = slot_y;

        if (inventory != noone && ds_exists(inventory.inventory, ds_type_grid)) {
            var slot = inventory.inventory[# slot_x, slot_y];
            if (slot != -1 && is_array(slot)) {
                var placement_id = slot[1]; // Get placement_id to find the top-left cell
                qty = slot[2]; // Get the stack quantity
                
                // Find the top-left cell of the multi-cell item using placement_id
                top_left_x = slot_x;
                top_left_y = slot_y;
                while (top_left_x > 0 && is_array(inventory.inventory[# top_left_x - 1, slot_y]) && inventory.inventory[# top_left_x - 1, slot_y][1] == placement_id) top_left_x -= 1;
                while (top_left_y > 0 && is_array(inventory.inventory[# slot_x, top_left_y - 1]) && inventory.inventory[# slot_x, top_left_y - 1][1] == placement_id) top_left_y -= 1;

                var item_width = global.item_data[item_id][1];
                var item_height = global.item_data[item_id][2];
            }
        }
        
        if (option == "Drop" && inventory.inventory_type == "backpack" && item_id != ITEM.NONE) {
            // Drop the full stack on the ground
            var world_x = obj_player.x + irandom_range(-8, 8); // Use world coordinates for ground drop
            var world_y = obj_player.y + irandom_range(-8, 8);
            var dropped_item = instance_create_layer(world_x, world_y, "Instances", obj_item, { item_id: item_id, stack_quantity: qty });
            
            // Remove the entire multi-cell item from the inventory
            for (var i = top_left_x; i < top_left_x + item_width && i < inventory.grid_width; i++) {
                for (var j = top_left_y; j < top_left_y + item_height && j < inventory.grid_height; j++) {
                    inventory.inventory[# i, j] = -1;
                }
            }
            show_debug_message("Dropped " + string(qty) + " " + global.item_data[item_id][0] + " on ground at [" + string(world_x) + "," + string(world_y) + "] with stack_quantity: " + string(dropped_item.stack_quantity));
        } else if (option == "Split Stack" && inventory.inventory_type == "backpack" && item_id != ITEM.NONE) {
            // Split the stack, leaving half in inventory and starting a manual drag without immediate drop
            if (qty > 1) {
                var keep_qty = floor(qty / 2); // Keep half (rounded down)
                var drag_qty = qty - keep_qty; // Drag the other half (ensures at least 1 if odd)

                // Update the inventory with the kept quantity in the top-left slot
                var slot = inventory.inventory[# top_left_x, top_left_y];
                if (slot != -1 && is_array(slot)) {
                    slot[2] = keep_qty; // Update the quantity
                    inventory.inventory[# top_left_x, top_left_y] = slot;
                }

                // Set up dragging for the split portion, mimicking a manual drag without triggering an immediate drop
                if (inventory.dragging == -1) { // Ensure no other dragging is active
                    var item_width = global.item_data[item_id][1];
                    var item_height = global.item_data[item_id][2];
                    inventory.dragging = [item_id, slot[1], drag_qty]; // [item_id, placement_id, qty]
                    global.dragging_inventory = inventory;
                    gui_mouse_x = device_mouse_x_to_gui(0);
                    gui_mouse_y = device_mouse_y_to_gui(0);
                    inventory.drag_offset_x = (inventory.inv_gui_x + top_left_x * inventory.slot_size) - gui_mouse_x;
                    inventory.drag_offset_y = (inventory.inv_gui_y + top_left_y * inventory.slot_size) - gui_mouse_y;
                    inventory.original_mx = top_left_x;
                    inventory.original_my = top_left_y;
                    inventory.original_grid = inventory.inventory;
                    show_debug_message("Started dragging " + string(drag_qty) + " " + global.item_data[item_id][0] + " from [" + string(top_left_x) + "," + string(top_left_y) + "] in " + inventory.inventory_type + " (manual drag after split)");
                } else {
                    show_debug_message("Warning: Cannot split stack—another item is already being dragged");
                }
            }
        } else if (option == "Take" && inventory.inventory_type == "container" && item_id != ITEM.NONE) {
            // Take the full stack into the player's backpack
            var success = inventory_add(global.backpack, item_id, qty);
            if (success) {
                show_debug_message("Took " + string(qty) + " " + global.item_data[item_id][0] + " from " + inventory.inventory_type + " into backpack");
            } else {
                show_debug_message("Backpack full - cannot take " + global.item_data[item_id][0] + " from " + inventory.inventory_type);
            }
        }
        instance_destroy(); // Close menu after action
    }
}