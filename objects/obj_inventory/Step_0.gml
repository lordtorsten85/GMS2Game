// obj_inventory - Step Event
// Handles inventory interactions, including dragging and dropping items

if (is_open) {
    var gui_mouse_x = device_mouse_x_to_gui(0);
    var gui_mouse_y = device_mouse_y_to_gui(0);

    // Check if mouse is over this inventory’s GUI area
    if (point_in_rectangle(gui_mouse_x, gui_mouse_y, inv_gui_x, inv_gui_y, inv_gui_x + grid_width * slot_size, inv_gui_y + grid_height * slot_size)) {
        if (mouse_check_button_pressed(mb_left)) {
            show_debug_message("Mouse clicked over inventory type: " + inventory_type + " at GUI [" + string(gui_mouse_x) + "," + string(gui_mouse_y) + "]");
            if (instance_exists(id) && ds_exists(inventory, ds_type_grid)) {
                inventory_start_dragging(id);
                if (dragging != -1) {
                    global.dragging_inventory = id; // Set global dragging reference
                    show_debug_message("Dragging started for " + inventory_type);
                }
            } else {
                show_debug_message("Error: Invalid instance or grid for " + inventory_type);
            }
        }
    }

    // Existing drop logic remains unchanged unless you report issues there
    if (mouse_check_button_released(mb_left) && dragging != -1) {
        var dropped = false;
        var item_id = dragging[0];
        var qty = dragging[2];
        var item_width = global.item_data[item_id][1];
        var item_height = global.item_data[item_id][2];

        with (obj_inventory) {
            if (is_open) {
                if (point_in_rectangle(gui_mouse_x, gui_mouse_y, inv_gui_x, inv_gui_y, inv_gui_x + grid_width * slot_size, inv_gui_y + grid_height * slot_size)) {
                    var mx = floor((gui_mouse_x - inv_gui_x) / slot_size);
                    var my = floor((gui_mouse_y - inv_gui_y) / slot_size);
                    if (mx >= 0 && mx <= grid_width - item_width && my >= 0 && my <= grid_height - item_height) {
                        if (can_place_item(inventory, mx, my, item_width, item_height)) {
                            inventory_add_at(mx, my, item_id, qty, inventory);
                            dropped = true;
                            break;
                        }
                    }
                }
            }
        }

        if (!dropped) {
            show_debug_message("Drop failed, snapping " + global.item_data[item_id][0] + " back to [" + string(original_mx) + "," + string(original_my) + "] in " + inventory_type);
            inventory_add_at(original_mx, original_my, item_id, qty, original_grid);
        }
        dragging = -1;
        global.dragging_inventory = -1;
    }
}