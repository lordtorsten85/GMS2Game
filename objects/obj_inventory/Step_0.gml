// obj_inventory - Step Event
// Handles inventory interactions, including dragging and dropping items
// Drops items based on their top-left position, adjusted for majority overlap

if (is_open) {
    var gui_mouse_x = device_mouse_x_to_gui(0);
    var gui_mouse_y = device_mouse_y_to_gui(0);

    // Check if mouse is over this inventory’s GUI area to start dragging
    if (point_in_rectangle(gui_mouse_x, gui_mouse_y, inv_gui_x, inv_gui_y, inv_gui_x + grid_width * slot_size, inv_gui_y + grid_height * slot_size)) {
        if (mouse_check_button_pressed(mb_left)) {
            show_debug_message("Mouse clicked over inventory type: " + inventory_type + " at GUI [" + string(gui_mouse_x) + "," + string(gui_mouse_y) + "]");
            if (instance_exists(id) && ds_exists(inventory, ds_type_grid)) {
                inventory_start_dragging(id);
                if (dragging != -1) {
                    global.dragging_inventory = id;
                    show_debug_message("Dragging started for " + inventory_type);
                }
            } else {
                show_debug_message("Error: Invalid instance or grid for " + inventory_type);
            }
        }
    }

    // Handle dropping the item
    if (mouse_check_button_released(mb_left) && dragging != -1) {
        var dropped = false;
        var item_id = dragging[0];
        var qty = dragging[2];
        var item_width = global.item_data[item_id][1];
        var item_height = global.item_data[item_id][2];
        var item_name = global.item_data[item_id][0];

        // Calculate the item's current pixel bounds while dragging
        var item_x = gui_mouse_x + drag_offset_x; // Top-left X of the item sprite
        var item_y = gui_mouse_y + drag_offset_y; // Top-left Y of the item sprite
        var item_right = item_x + (item_width * slot_size);
        var item_bottom = item_y + (item_height * slot_size);

        show_debug_message("Dropping " + item_name + " (Size: " + string(item_width) + "x" + string(item_height) + ") at pixel bounds [" + string(item_x) + "," + string(item_y) + "] to [" + string(item_right) + "," + string(item_bottom) + "]");

        // Check all open inventories for a valid drop position
        with (obj_inventory) {
            if (is_open) {
                if (point_in_rectangle(gui_mouse_x, gui_mouse_y, inv_gui_x, inv_gui_y, inv_gui_x + grid_width * slot_size, inv_gui_y + grid_height * slot_size)) {
                    // Base drop position on the item's top-left
                    var drop_x = floor((item_x - inv_gui_x) / slot_size);
                    var drop_y = floor((item_y - inv_gui_y) / slot_size);

                    // Adjust if the item is more than halfway into the next cell
                    var x_offset = (item_x - inv_gui_x) % slot_size;
                    var y_offset = (item_y - inv_gui_y) % slot_size;
                    if (x_offset > slot_size / 2 && drop_x + item_width < grid_width) drop_x += 1;
                    if (y_offset > slot_size / 2 && drop_y + item_height < grid_height) drop_y += 1;

                    // Clamp to valid bounds
                    drop_x = clamp(drop_x, 0, grid_width - item_width);
                    drop_y = clamp(drop_y, 0, grid_height - item_height);

                    show_debug_message("Calculated drop position for " + item_name + " at [" + string(drop_x) + "," + string(drop_y) + "] in " + inventory_type + " (x_offset: " + string(x_offset) + ", y_offset: " + string(y_offset) + ")");

                    // Try to place the item
                    if (can_place_item(inventory, drop_x, drop_y, item_width, item_height)) {
                        inventory_add_at(drop_x, drop_y, item_id, qty, inventory);
                        dropped = true;
                        show_debug_message("Dropped " + item_name + " at [" + string(drop_x) + "," + string(drop_y) + "] in " + inventory_type);
                    }

                    if (dropped) break;
                }
            }
        }

        // If no valid drop spot, snap back to original position
        if (!dropped) {
            show_debug_message("Drop failed for " + item_name + ", snapping back to [" + string(original_mx) + "," + string(original_my) + "] in " + inventory_type);
            inventory_add_at(original_mx, original_my, item_id, qty, original_grid);
        }
        dragging = -1;
        global.dragging_inventory = -1;
    }
}