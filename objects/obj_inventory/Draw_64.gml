// obj_inventory - Draw GUI Event
// Renders the inventory UI with a stretched frame, translucent gray grid slots, white borders, items, and feedback
// Highlights cells under a hovered item before pickup, green/red for dragging validity

if (is_open) {
    // Safety check: Ensure the inventory grid exists
    if (!ds_exists(inventory, ds_type_grid)) {
        show_debug_message("Error: Inventory grid does not exist for " + inventory_type);
        return;
    }

    // Define padding for the frame (24 pixels on all sides)
    var padding = 24;

    // Calculate frame dimensions, including padding
    var frame_width = (grid_width * slot_size) + (2 * padding);
    var frame_height = (grid_height * slot_size) + (2 * padding);
    var frame_x = inv_gui_x - padding;
    var frame_y = inv_gui_y - padding;

    // Draw the stretched frame sprite as the background
    draw_sprite_stretched(spr_inventory_frame, 0, frame_x, frame_y, frame_width, frame_height);

    // Set alpha for translucent gray cells (hologram effect)
    draw_set_alpha(0.3);
    draw_set_color(c_gray);

    // Draw translucent gray backgrounds for each slot
    for (var i = 0; i < grid_width; i++) {
        for (var j = 0; j < grid_height; j++) {
            var slot_x = inv_gui_x + i * slot_size;
            var slot_y = inv_gui_y + j * slot_size;
            draw_rectangle(slot_x, slot_y, slot_x + slot_size - 1, slot_y + slot_size - 1, false);
        }
    }

    // Reset alpha to fully opaque for borders and highlights
    draw_set_alpha(1.0);

    // Draw white borders around each slot
    draw_set_color(c_white);
    for (var i = 0; i < grid_width; i++) {
        for (var j = 0; j < grid_height; j++) {
            var slot_x = inv_gui_x + i * slot_size;
            var slot_y = inv_gui_y + j * slot_size;
            draw_rectangle(slot_x, slot_y, slot_x + slot_size - 1, slot_y + slot_size - 1, true);
        }
    }

    // Highlight cells under a hovered item before dragging
    var gui_mouse_x = device_mouse_x_to_gui(0);
    var gui_mouse_y = device_mouse_y_to_gui(0);
    if (dragging == -1 && point_in_rectangle(gui_mouse_x, gui_mouse_y, inv_gui_x, inv_gui_y, inv_gui_x + grid_width * slot_size, inv_gui_y + grid_height * slot_size)) {
        var mx = floor((gui_mouse_x - inv_gui_x) / slot_size);
        var my = floor((gui_mouse_y - inv_gui_y) / slot_size);
        if (mx >= 0 && mx < grid_width && my >= 0 && my < grid_height) {
            var slot = inventory[# mx, my];
            if (slot != -1 && is_array(slot)) {
                var item_id = slot[0];
                var placement_id = slot[1];
                var item_width = global.item_data[item_id][1];
                var item_height = global.item_data[item_id][2];
                
                // Find top-left of the item
                var top_left_x = mx;
                var top_left_y = my;
                while (top_left_x > 0 && is_array(inventory[# top_left_x - 1, my]) && inventory[# top_left_x - 1, my][1] == placement_id) {
                    top_left_x -= 1;
                }
                while (top_left_y > 0 && is_array(inventory[# mx, top_left_y - 1]) && inventory[# mx, top_left_y - 1][1] == placement_id) {
                    top_left_y -= 1;
                }

                // Draw hover highlight
                draw_set_color(c_yellow); // Light yellow for hover feedback
                draw_set_alpha(0.4); // Subtle glow
                for (var i = top_left_x; i < top_left_x + item_width; i++) {
                    for (var j = top_left_y; j < top_left_y + item_height; j++) {
                        var slot_x = inv_gui_x + i * slot_size;
                        var slot_y = inv_gui_y + j * slot_size;
                        draw_rectangle(slot_x, slot_y, slot_x + slot_size - 1, slot_y + slot_size - 1, false);
                    }
                }
                show_debug_message("Hovering over " + global.item_data[item_id][0] + " in " + inventory_type + " at [" + string(top_left_x) + "," + string(top_left_y) + "] - Size: " + string(item_width) + "x" + string(item_height));
            }
        }
    }

    // Add drag feedback for any inventory being hovered over while dragging
    if (global.dragging_inventory != -1 && instance_exists(global.dragging_inventory)) {
        var dragging_inv = global.dragging_inventory;
        var item_id = dragging_inv.dragging[0];
        var item_width = global.item_data[item_id][1];
        var item_height = global.item_data[item_id][2];

        // Check if mouse is hovering over this inventory
        if (point_in_rectangle(gui_mouse_x, gui_mouse_y, inv_gui_x, inv_gui_y, inv_gui_x + grid_width * slot_size, inv_gui_y + grid_height * slot_size)) {
            var item_x = gui_mouse_x + dragging_inv.drag_offset_x;
            var item_y = gui_mouse_y + dragging_inv.drag_offset_y;

            // Calculate drop position
            var drop_x = floor((item_x - inv_gui_x) / slot_size);
            var drop_y = floor((item_y - inv_gui_y) / slot_size);
            var x_offset = (item_x - inv_gui_x) % slot_size;
            var y_offset = (item_y - inv_gui_y) % slot_size;
            if (x_offset > slot_size / 2 && drop_x + item_width < grid_width) drop_x += 1;
            if (y_offset > slot_size / 2 && drop_y + item_height < grid_height) drop_y += 1;
            drop_x = clamp(drop_x, 0, grid_width - item_width);
            drop_y = clamp(drop_y, 0, grid_height - item_height);

            // Validity highlight (green/red)
            var can_drop = can_place_item(inventory, drop_x, drop_y, item_width, item_height);
            draw_set_color(can_drop ? c_lime : c_red);
            draw_set_alpha(0.5);
            for (var i = drop_x; i < drop_x + item_width; i++) {
                for (var j = drop_y; j < drop_y + item_height; j++) {
                    var slot_x = inv_gui_x + i * slot_size;
                    var slot_y = inv_gui_y + j * slot_size;
                    draw_rectangle(slot_x, slot_y, slot_x + slot_size - 1, slot_y + slot_size - 1, false);
                }
            }
            show_debug_message("Dragging over " + inventory_type + " - Drop position [" + string(drop_x) + "," + string(drop_y) + "] is " + (can_drop ? "valid (green)" : "invalid (red)"));
        }
    }

    // Reset drawing settings for items
    draw_set_alpha(1.0);
    draw_set_color(c_white);

    // Draw items, scaling multicell items appropriately
    for (var i = 0; i < grid_width; i++) {
        for (var j = 0; j < grid_height; j++) {
            var slot = inventory[# i, j];
            if (slot != -1 && is_array(slot)) {
                var item_id = slot[0];
                var placement_id = slot[1];
                var qty = slot[2];

                // Only draw from the top-left cell of multicell items
                if (i == 0 || !is_array(inventory[# i-1, j]) || inventory[# i-1, j][1] != placement_id) {
                    if (j == 0 || !is_array(inventory[# i, j-1]) || inventory[# i, j-1][1] != placement_id) {
                        var item_width = global.item_data[item_id][1];
                        var item_height = global.item_data[item_id][2];
                        var sprite = global.item_data[item_id][5];
                        var total_width = item_width * slot_size;
                        var total_height = item_height * slot_size;
                        var scale_x = total_width / sprite_get_width(sprite);
                        var scale_y = total_height / sprite_get_height(sprite);
                        var slot_x = inv_gui_x + i * slot_size;
                        var slot_y = inv_gui_y + j * slot_size;
                        draw_sprite_ext(sprite, 0, slot_x, slot_y, scale_x, scale_y, 0, c_white, 1);
                    }
                }
            }
        }
    }
}