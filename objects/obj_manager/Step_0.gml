// obj_manager
// Event: Step
// Description: Manages global dragging logic for inventories, centralizing start, movement, and drop, respecting multi-cell items' linked cells for pickups (top-left only) and drops (allowing valid drops on empty spots), preventing snapping back unnecessarily.
// Variable Definitions (from Create): 
// - global.dragging_inventory: instance (The inventory instance currently dragging, or -1 if none)

if (instance_exists(obj_inventory)) {
    var gui_mouse_x = device_mouse_x_to_gui(0);
    var gui_mouse_y = device_mouse_y_to_gui(0);

    // Start dragging from any inventory (only from top-left for multi-cell items)
    if (mouse_check_button_pressed(mb_left) && global.dragging_inventory == -1) {
        var dragged_inventory = noone;
        with (obj_inventory) {
            if (is_open) {
                var bounds_width = (object_index == obj_equipment_slots ? grid_width * slot_size + (grid_width - 1) * spacing : grid_width * slot_size);
                if (point_in_rectangle(gui_mouse_x, gui_mouse_y, inv_gui_x, inv_gui_y, inv_gui_x + bounds_width, inv_gui_y + grid_height * slot_size)) {
                    show_debug_message("Mouse clicked over inventory type: " + inventory_type + " at GUI [" + string(gui_mouse_x) + "," + string(gui_mouse_y) + "]");
                    if (ds_exists(inventory, ds_type_grid)) {
                        dragged_inventory = id; // Store the inventory instance to use outside the with block
                    } else {
                        show_debug_message("Error: Invalid grid for " + inventory_type);
                    }
                }
            }
        }
        // Call inventory_start_dragging as a script with corrected safety check
        if (dragged_inventory != noone && instance_exists(dragged_inventory) && (dragged_inventory.object_index == obj_inventory || dragged_inventory.object_index == obj_equipment_slots)) {
            inventory_start_dragging(dragged_inventory); // Explicitly call the script with the inventory instance
            if (dragged_inventory.dragging != -1) { // Check if dragging started successfully
                global.dragging_inventory = dragged_inventory; // Set this inventory as the dragging instance
                show_debug_message("Started dragging via obj_manager in " + dragged_inventory.inventory_type);
            }
        } else {
            show_debug_message("Error: Invalid or non-existent inventory instance for dragging");
        }
    }

    // Handle dropping (allow valid drops on empty spots, block invalid ones, prevent snapping back unnecessarily)
    if (mouse_check_button_released(mb_left) && global.dragging_inventory != -1) {
        var origin_inv = global.dragging_inventory;
        if (instance_exists(origin_inv) && is_array(origin_inv.dragging)) {
            var item_id = origin_inv.dragging[0];
            var qty = origin_inv.dragging[2];
            var item_name = global.item_data[item_id][0];
            var item_width = global.item_data[item_id][1];
            var item_height = global.item_data[item_id][2];
            var max_stack = global.item_data[item_id][7];
            var item_x = gui_mouse_x + origin_inv.drag_offset_x;
            var item_y = gui_mouse_y + origin_inv.drag_offset_y;
            var drop_valid = false;
            var over_inventory = false;

            // Check all inventories for a valid drop
            with (obj_inventory) {
                if (is_open) {
                    var bounds_width = (object_index == obj_equipment_slots ? grid_width * slot_size + (grid_width - 1) * spacing : grid_width * slot_size);
                    if (point_in_rectangle(gui_mouse_x, gui_mouse_y, inv_gui_x, inv_gui_y, inv_gui_x + bounds_width, inv_gui_y + grid_height * slot_size)) {
                        over_inventory = true;
                        var drop_x = floor((item_x - inv_gui_x) / slot_size);
                        var drop_y = floor((item_y - inv_gui_y) / slot_size);
                        var x_offset = (item_x - inv_gui_x) % slot_size;
                        var y_offset = (item_y - inv_gui_y) % slot_size;
                        if (x_offset > slot_size / 2 && drop_x + item_width < grid_width) drop_x += 1;
                        if (y_offset > slot_size / 2 && drop_y + item_height < grid_height) drop_y += 1;
                        drop_x = clamp(drop_x, 0, grid_width - item_width);
                        drop_y = clamp(drop_y, 0, grid_height - item_height);

                        if (object_index == obj_equipment_slots) {
                            drop_x = floor((gui_mouse_x - inv_gui_x) / (slot_size + spacing));
                            drop_y = 0;
                            if (drop_x < 0 || drop_x >= grid_width) continue;
                        }

                        show_debug_message("Checking drop for " + item_name + " x" + string(qty) + " at [" + string(drop_x) + "," + string(drop_y) + "] in " + inventory_type);

                        if (inventory_handle_drop(self)) { // Use centralized drop function to respect multi-cell footprints and allow valid drops
                            other.drop_valid = true;
                            show_debug_message("Dropped " + item_name + " via obj_manager in " + inventory_type);
                            break;
                        } else {
                            show_debug_message("Blocked: No space or overlap with multi-cell item at [" + string(drop_x) + "," + string(drop_y) + "] in " + inventory_type);
                        }
                    }
                }
            }

            // Handle drop outcome (allow valid drops, prevent unnecessary snapping back)
            if (global.dragging_inventory != -1) {
                if (over_inventory && !drop_valid) {
                    // Snap back to origin only if truly invalid (no space or overlap)
                    show_debug_message("Invalid drop, snapping back to [" + string(origin_inv.original_mx) + "," + string(origin_inv.original_my) + "] in " + origin_inv.inventory_type);
                    // Clear any existing instance of the item in the grid before re-adding
                    for (var i = 0; i < origin_inv.grid_width; i++) {
                        for (var j = 0; j < origin_inv.grid_height; j++) {
                            var slot = origin_inv.inventory[# i, j];
                            if (slot != -1 && is_array(slot) && slot[0] == item_id) {
                                inventory_remove(i, j, origin_inv.inventory);
                                show_debug_message("Cleared duplicate " + item_name + " from [" + string(i) + "," + string(j) + "] in " + origin_inv.inventory_type);
                            }
                        }
                    }
                    // Add back to original position
                    inventory_add_at(origin_inv.original_mx, origin_inv.original_my, item_id, qty, origin_inv.original_grid);
                    origin_inv.dragging = -1;
                    global.dragging_inventory = -1;
                } else if (!over_inventory && instance_exists(obj_player)) {
                    // Drop on ground if outside all inventories
                    var world_x = round(obj_player.x) + irandom_range(-8, 8); // Slight offset to avoid stacking
                    var world_y = round(obj_player.y) + irandom_range(-8, 8);
                    instance_create_layer(world_x, world_y, "Instances", obj_item, { item_id: item_id });
                    origin_inv.dragging = -1;
                    global.dragging_inventory = -1;
                    show_debug_message("Dropped " + item_name + " x" + string(qty) + " on ground at [" + string(world_x) + "," + string(world_y) + "]");
                }
            }
        } else {
            show_debug_message("Error: Invalid dragging state in obj_manager");
            global.dragging_inventory = -1; // Reset if invalid
        }
    }
}