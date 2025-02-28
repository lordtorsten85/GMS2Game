// obj_inventory - Step Event
// Handles inventory interactions, including dragging and dropping items, with ground dropping support
// Drops items on the ground by the player’s feet using a trace collision check to avoid stacking, pushes outward until a clear spot is found, then spawns, without snapping back if initial drop fails

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

    // Handle dropping the item (in inventories or on ground by player’s feet)
    if (mouse_check_button_released(mb_left) && dragging != -1) {
        var dropped = false;
        var item_id = dragging[0];
        var qty = dragging[2];
        var item_name = global.item_data[item_id][0];

        // Calculate the item's current pixel bounds while dragging
        var item_x = gui_mouse_x + drag_offset_x; // Top-left X of the item sprite
        var item_y = gui_mouse_y + drag_offset_y; // Top-left Y of the item sprite

        // Check all open inventories for a valid drop position
        with (obj_inventory) {
            if (is_open) {
                if (point_in_rectangle(gui_mouse_x, gui_mouse_y, inv_gui_x, inv_gui_y, inv_gui_x + grid_width * slot_size, inv_gui_y + grid_height * slot_size)) {
                    var drop_x = floor((item_x - inv_gui_x) / slot_size);
                    var drop_y = floor((item_x - inv_gui_x) / slot_size);
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

        // If not dropped in an inventory, try dropping on the ground by player’s feet using trace collision
        if (!dropped && instance_exists(obj_player)) {
            var world_x = round(obj_player.x); // Initial drop at player’s x, rounded
            var world_y = round(obj_player.y); // Initial drop at player’s y, rounded
            var search_dist = 16; // Initial distance to search outward (one cell or sprite width, adjust as needed)
            var max_initial_attempts = 8; // Initial max search attempts
            var max_expanded_attempts = 32; // Expanded max attempts for persistent search
            var attempt = 0;
            var found_clear = false;
            var step = 0;
            var search_direction = 0;

            // Assume a default item size for collision checking (adjust based on your sprites)
            var item_width = 16;  // Example width in pixels (e.g., 32x32 Syringe, adjust for each item)
            var item_height = 16; // Example height in pixels

            // Pre-check for existing items at initial position
            show_debug_message("Pre-checking ground drop for " + item_name + " at player’s feet [" + string(world_x) + "," + string(world_y) + "] on Instances layer");
            var initial_collision = place_meeting(world_x, world_y, obj_item);
            show_debug_message("Initial collision with obj_item at [" + string(world_x) + "," + string(world_y) + "]: " + (initial_collision ? "Yes" : "No"));

            // Manually check for obj_item instances to debug position mismatch
            var colliding_items_manual = instance_place(world_x, world_y, obj_item);
            if (colliding_items_manual != noone) {
                show_debug_message("Manual check found obj_item at [" + string(colliding_items_manual.x) + "," + string(colliding_items_manual.y) + "] on Instances layer");
            } else {
                show_debug_message("Manual check found no obj_item at [" + string(world_x) + "," + string(world_y) + "] on Instances layer");
            }

            // Initial spiral search for a clear spot
            while (attempt < max_initial_attempts && !found_clear) {
                var check_x = world_x + lengthdir_x(step * search_dist, search_direction);
                var check_y = world_y + lengthdir_y(step * search_dist, search_direction);
                check_x = round(check_x);
                check_y = round(check_y);

                // Define the bounding box for the item at this position
                var left = check_x - (item_width / 2);
                var top = check_y - (item_height / 2);
                var right = check_x + (item_width / 2) - 1;
                var bottom = check_y + (item_height / 2) - 1;

                show_debug_message("Initial check: Position [" + string(check_x) + "," + string(check_y) + "] (attempt " + string(attempt) + ")");

                // Check for obj_item and obj_container in the rectangle
                if (check_x >= 0 && check_x < room_width && check_y >= 0 && check_y < room_height &&
                    !collision_rectangle(left, top, right, bottom, obj_item, false, true) &&
                    !collision_rectangle(left, top, right, bottom, obj_container, false, true)) {
                    found_clear = true;
                    world_x = check_x;
                    world_y = check_y;
                    show_debug_message("Found clear position at [" + string(world_x) + "," + string(world_y) + "]");
                } else {
                    search_direction = (search_direction + 45) % 360;
                    step = floor(attempt / 8); // Increase step every 8 directions (90-degree increments)
                    attempt += 1;
                    if (attempt >= max_initial_attempts) {
                        show_debug_message("No clear position found after " + string(max_initial_attempts) + " initial attempts, expanding search...");
                    }
                }
            }

            // If no clear spot found initially, expand search outward until a spot is found
            if (!found_clear) {
                attempt = 0;
                search_dist = 32; // Increase search distance for expanded search
                step = 0;
                search_direction = 0;

                show_debug_message("Starting expanded search for " + item_name + " with increased radius");

                while (!found_clear) {
                    var check_x = world_x + lengthdir_x(step * search_dist, search_direction);
                    var check_y = world_y + lengthdir_y(step * search_dist, search_direction);
                    check_x = round(check_x);
                    check_y = round(check_y);

                    // Define the bounding box for the item at this position
                    var left = check_x - (item_width / 2);
                    var top = check_y - (item_height / 2);
                    var right = check_x + (item_width / 2) - 1;
                    var bottom = check_y + (item_height / 2) - 1;

                    show_debug_message("Expanded check: Position [" + string(check_x) + "," + string(check_y) + "] (attempt " + string(attempt) + ")");

                    // Check for obj_item and obj_container in the rectangle
                    if (check_x >= 0 && check_x < room_width && check_y >= 0 && check_y < room_height &&
                        !collision_rectangle(left, top, right, bottom, obj_item, false, true) &&
                        !collision_rectangle(left, top, right, bottom, obj_container, false, true)) {
                        found_clear = true;
                        world_x = check_x;
                        world_y = check_y;
                        show_debug_message("Found clear position at [" + string(world_x) + "," + string(world_y) + "] after expanded search");
                    } else {
                        search_direction = (search_direction + 45) % 360;
                        step = floor(attempt / 8); // Increase step every 8 directions (90-degree increments)
                        attempt += 1;
                        if (attempt >= max_expanded_attempts) {
                            show_debug_message("No clear position found after " + string(max_expanded_attempts) + " expanded attempts - dropping at farthest valid position");
                            // Find the farthest valid position within room bounds
                            world_x = clamp(world_x, item_width / 2, room_width - item_width / 2);
                            world_y = clamp(world_y, item_height / 2, room_height - item_height / 2);
                            found_clear = true;
                        }
                    }
                }
            }

            // Drop the item if a clear spot is found (either initially or expanded)
            if (found_clear) {
                // Only spawn the item after finding a valid, collision-free position
                var ground_item = instance_create_layer(world_x, world_y, "Instances", obj_item,
                    {
                        item_id: item_id
                    }
                );
                show_debug_message("Successfully dropped " + item_name + " on ground at [" + string(world_x) + "," + string(world_y) + "] on Instances layer");
                dropped = true;
            }
        }

        // If not dropped in an inventory, ground drop is handled above and won’t snap back
        dragging = -1;
        global.dragging_inventory = -1;
    }
}