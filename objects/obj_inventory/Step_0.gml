// obj_inventory - Step Event
// Handles inventory interactions, including dragging and dropping items, with ground dropping support
// Drops items on the ground by the player’s feet using a trace collision check to avoid stacking, snaps back to original inventory position if invalid

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

    // Handle dropping the item (in inventories, snaps back if invalid, or on ground)
    if (mouse_check_button_released(mb_left) && dragging != -1) {
        var dropped = false;
        var item_id = dragging[0];
        var qty = dragging[2];
        var item_name = global.item_data[item_id][0];

        // Calculate the item's current pixel bounds while dragging
        var item_x = gui_mouse_x + drag_offset_x; // Top-left X of the item sprite
        var item_y = gui_mouse_y + drag_offset_y; // Top-left Y of the item sprite

        // Check if mouse is outside all inventories to prioritize ground drop
        var is_outside_inventories = true;
        with (obj_inventory) {
            if (is_open && point_in_rectangle(gui_mouse_x, gui_mouse_y, inv_gui_x, inv_gui_y, inv_gui_x + grid_width * slot_size, inv_gui_y + grid_height * slot_size)) {
                is_outside_inventories = false;
            }
        }

        // If mouse is outside inventories, skip inventory check and attempt ground drop directly
        if (is_outside_inventories) {
            show_debug_message("Mouse outside all inventories, attempting ground drop for " + item_name);
        } else {
            // Check all open inventories for a valid drop position
            with (obj_inventory) {
                if (is_open) {
                    if (point_in_rectangle(gui_mouse_x, gui_mouse_y, inv_gui_x, inv_gui_y, inv_gui_x + grid_width * slot_size, inv_gui_y + grid_height * slot_size)) {
                        var drop_x = floor((item_x - inv_gui_x) / slot_size);
                        var drop_y = floor((item_y - inv_gui_y) / slot_size);
                        var item_width = global.item_data[item_id][1]; // Use grid width for inventory
                        var item_height = global.item_data[item_id][2]; // Use grid height for inventory
                        var x_offset = (item_x - inv_gui_x) % slot_size;
                        var y_offset = (item_y - inv_gui_y) % slot_size;
                        if (x_offset > slot_size / 2 && drop_x + item_width < grid_width) drop_x += 1;
                        if (y_offset > slot_size / 2 && drop_y + item_height < grid_height) drop_y += 1;
                        drop_x = clamp(drop_x, 0, grid_width - item_width);
                        drop_y = clamp(drop_y, 0, grid_height - item_height);

                        show_debug_message("Checking drop for " + item_name + " at [" + string(drop_x) + "," + string(drop_y) + "] in " + inventory_type);

                        if (can_place_item(inventory, drop_x, drop_y, item_width, item_height)) {
                            inventory_add_at(drop_x, drop_y, item_id, qty, inventory);
                            dropped = true;
                            show_debug_message("Dropped " + item_name + " at [" + string(drop_x) + "," + string(drop_y) + "] in " + inventory_type);
                            break;
                        }
                    }
                }
            }

            // If drop in inventory fails, snap back before attempting ground drop
            if (!dropped && original_grid != -1) {
                show_debug_message("Invalid inventory drop for " + item_name + ", snapping back to original position [" + string(original_mx) + "," + string(original_my) + "] in " + inventory_type);
                inventory_add_at(original_mx, original_my, item_id, qty, original_grid);
                dropped = true; // Mark as dropped, but allow ground drop if intended
            }
        }

        // If not dropped in an inventory or snapped back, and mouse was outside inventories, try dropping on the ground near the player’s feet
        if (!dropped && instance_exists(obj_player)) {
            var world_x = round(obj_player.x); // Player’s x position, rounded to integer
            var world_y = round(obj_player.y); // Player’s y position, rounded to integer
            var search_dist = 32;              // Increase distance to search outward (32 pixels for wider spacing)
            var max_attempts = 24;             // Increase max attempts for larger search area
            var attempt = 0;
            var found_clear = false;
            var step = 0;
            var search_direction = 0;

            // Use dynamic item size from global.item_data (in pixels, assuming 16px per grid unit)
            var item_width = global.item_data[item_id][1] * 16;  // Width in pixels (e.g., 1 grid unit = 16px)
            var item_height = global.item_data[item_id][2] * 16; // Height in pixels
            show_debug_message("Initial drop position: [" + string(world_x) + "," + string(world_y) + "] for " + item_name + " (size: " + string(item_width) + "x" + string(item_height) + " pixels)");

            // Spiral search for a clear spot with increased spacing
            while (attempt < max_attempts && !found_clear) {
                var check_x = world_x + lengthdir_x(step * search_dist, search_direction);
                var check_y = world_y + lengthdir_y(step * search_dist, search_direction);
                check_x = round(check_x);
                check_y = round(check_y);

                // Define the bounding box for the item at this position, ensuring enough padding
                var padding = 16; // Additional padding to increase spacing between items
                var left = check_x - (item_width / 2) - padding;
                var top = check_y - (item_height / 2) - padding;
                var right = check_x + (item_width / 2) + padding - 1;
                var bottom = check_y + (item_height / 2) + padding - 1;

                show_debug_message("Checking position [" + string(check_x) + "," + string(check_y) + "] (attempt " + string(attempt) + ") with padding " + string(padding));

                // Check for collisions with items, containers, or walls in the expanded rectangle
                if (check_x >= 0 && check_x < room_width && check_y >= 0 && check_y < room_height &&
                    !collision_rectangle(left, top, right, bottom, obj_item, false, true) &&
                    !collision_rectangle(left, top, right, bottom, obj_container, false, true) &&
                    !collision_rectangle(left, top, right, bottom, obj_editor_wall, false, true)) {
                    found_clear = true;
                    world_x = check_x;
                    world_y = check_y;
                    show_debug_message("Found clear position at [" + string(world_x) + "," + string(world_y) + "] with distance " + string(point_distance(world_x, world_y, obj_player.x, obj_player.y)));
                } else {
                    search_direction = (search_direction + 45) % 360; // Rotate direction
                    if (attempt % 8 == 0) step += 1; // Increase step every 8 attempts
                    attempt += 1;
                    if (attempt >= max_attempts) {
                        show_debug_message("No clear position found after " + string(max_attempts) + " attempts - using player’s position");
                    }
                }
            }

            // Drop the item if a clear spot is found, or use player’s position as fallback
            if (found_clear) {
                var ground_item = instance_create_layer(world_x, world_y, "Instances", obj_item,
                    {
                        item_id: item_id
                    }
                );
                show_debug_message("Successfully dropped " + item_name + " on ground at [" + string(world_x) + "," + string(world_y) + "]");
                dropped = true;
            } else {
                // Fallback: Drop at player’s position, but check again to avoid immediate overlap
                var fallback_x = round(obj_player.x);
                var fallback_y = round(obj_player.y);
                var left = fallback_x - (item_width / 2);
                var top = fallback_y - (item_height / 2);
                var right = fallback_x + (item_width / 2) - 1;
                var bottom = fallback_y + (item_height / 2) - 1;

                if (fallback_x >= 0 && fallback_x < room_width && fallback_y >= 0 && fallback_y < room_height &&
                    !collision_rectangle(left, top, right, bottom, obj_item, false, true) &&
                    !collision_rectangle(left, top, right, bottom, obj_container, false, true) &&
                    !collision_rectangle(left, top, right, bottom, obj_editor_wall, false, true)) {
                    var ground_item = instance_create_layer(fallback_x, fallback_y, "Instances", obj_item,
                        {
                            item_id: item_id
                        }
                    );
                    show_debug_message("Fallback: Dropped " + item_name + " at player’s position [" + string(fallback_x) + "," + string(fallback_y) + "]");
                    dropped = true;
                } else {
                    show_debug_message("Fallback failed for " + item_name + " - no valid position at player’s feet");
                }
            }
        }

        // If no valid drop location is found (inventory, snap-back, or ground), snap back
        if (!dropped) {
            show_debug_message("Drop failed for " + item_name + ", snapping back to [" + string(original_mx) + "," + string(original_my) + "] in " + inventory_type);
            inventory_add_at(original_mx, original_my, item_id, qty, original_grid);
        }
        dragging = -1;
        global.dragging_inventory = -1;
    }
}