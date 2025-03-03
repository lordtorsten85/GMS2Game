// obj_inventory
// Event: Step
// Description: Handles drag-and-drop with ground drop outside inventories and snap-back on invalid drops. Updated to drop stacked items on the ground with their full quantity, ensuring item_id and stack_quantity are valid and logged for debugging.
// Variable Definitions:
// - inventory_type: string (e.g., "backpack")
// - grid_width: real (Number of slots wide)
// - grid_height: real (Number of slots tall)
// - slot_size: real (Pixel size of each slot)
// - inv_gui_x: real (GUI X position)
// - inv_gui_y: real (GUI Y position)
// - dragging: real (Array of [item_id, placement_id, qty] or -1)
// - drag_offset_x: real (Offset for dragging in GUI X)
// - drag_offset_y: real (Offset for dragging in GUI Y)
// - original_mx: real (Original X grid position)
// - original_my: real (Original Y grid position)
// - original_grid: real (Reference to original grid)
// - is_open: boolean (Whether the inventory UI is visible)
// - inventory: asset (ds_grid for inventory slots)

if (is_open) {
    var gui_mouse_x = device_mouse_x_to_gui(0);
    var gui_mouse_y = device_mouse_y_to_gui(0);

    // Start dragging
    var bounds_width = (object_index == obj_equipment_slots ? grid_width * slot_size + (grid_width - 1) * spacing : grid_width * slot_size);
    if (point_in_rectangle(gui_mouse_x, gui_mouse_y, inv_gui_x, inv_gui_y, inv_gui_x + bounds_width, inv_gui_y + grid_height * slot_size)) {
        if (mouse_check_button_pressed(mb_left) && dragging == -1) {
            show_debug_message("Mouse clicked over inventory type: " + inventory_type + " at GUI [" + string(gui_mouse_x) + "," + string(gui_mouse_y) + "]");
            if (instance_exists(id) && ds_exists(inventory, ds_type_grid)) {
                var slot_x = floor((gui_mouse_x - inv_gui_x) / (object_index == obj_equipment_slots ? slot_size + spacing : slot_size));
                var slot_y = floor((gui_mouse_y - inv_gui_y) / slot_size);
                slot_x = clamp(slot_x, 0, grid_width - 1);
                slot_y = clamp(slot_y, 0, grid_height - 1);
                var slot = inventory[# slot_x, slot_y];
                if (slot != -1 && is_array(slot)) {
                    var item_id = slot[0];
                    var placement_id = slot[1];
                    var item_width = global.item_data[item_id][1];
                    var item_height = global.item_data[item_id][2];
                    var top_left_x = slot_x;
                    var top_left_y = slot_y;
                    if (object_index != obj_equipment_slots) {
                        while (top_left_x > 0 && is_array(inventory[# top_left_x - 1, slot_y]) && inventory[# top_left_x - 1, slot_y][1] == placement_id) top_left_x -= 1;
                        while (top_left_y > 0 && is_array(inventory[# slot_x, top_left_y - 1]) && inventory[# slot_x, top_left_y - 1][1] == placement_id) top_left_y -= 1;
                    }

                    dragging = slot;
                    global.dragging_inventory = id;
                    drag_offset_x = (inv_gui_x + top_left_x * (object_index == obj_equipment_slots ? slot_size + spacing : slot_size)) - gui_mouse_x;
                    drag_offset_y = (inv_gui_y + top_left_y * slot_size) - gui_mouse_y;
                    original_mx = top_left_x;
                    original_my = top_left_y;
                    original_grid = inventory;
                    if (object_index == obj_equipment_slots) {
                        inventory[# slot_x, slot_y] = -1;
                    } else {
                        for (var i = top_left_x; i < min(top_left_x + item_width, grid_width); i++) {
                            for (var j = top_left_y; j < min(top_left_y + item_height, grid_height); j++) {
                                inventory[# i, j] = -1;
                            }
                        }
                    }
                    show_debug_message("Started dragging " + global.item_data[item_id][0] + " (ID: " + string(item_id) + ") from [" + string(top_left_x) + "," + string(top_left_y) + "] in " + inventory_type);
                } else {
                    show_debug_message("Clicked cell [" + string(slot_x) + "," + string(slot_y) + "] is empty or invalid - no dragging started");
                }
            } else {
                show_debug_message("Error: Invalid instance or grid for " + inventory_type);
            }
        }
    }

    // Handle dropping
    if (mouse_check_button_released(mb_left) && global.dragging_inventory != -1) {
        var origin_inv = global.dragging_inventory;
        var item_id = origin_inv.dragging[0];
        var qty = origin_inv.dragging[2]; // Get the full stack quantity
        var item_name = (item_id != ITEM.NONE && item_id >= 0 && item_id < array_length(global.item_data)) ? global.item_data[item_id][0] : "No Item";
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
                    var item_width = global.item_data[item_id][1];
                    var item_height = global.item_data[item_id][2];
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

                    show_debug_message("Checking drop for " + item_name + " at [" + string(drop_x) + "," + string(drop_y) + "] in " + inventory_type);

                    if (object_index == obj_equipment_slots) {
                        if (drop_x >= 0 && drop_x < grid_width && global.item_data[item_id][6] == slot_types[drop_x] && inventory[# drop_x, 0] == -1) {
                            inventory[# drop_x, 0] = origin_inv.dragging;
                            origin_inv.dragging = -1;
                            global.dragging_inventory = -1;
                            show_debug_message("Dropped " + item_name + " into slot " + string(drop_x) + " in " + inventory_type);
                            drop_valid = true;
                            break;
                        } else {
                            show_debug_message("Blocked: Type mismatch or occupied - " + item_name + " (Type " + string(global.item_data[item_id][6]) + ") ≠ Slot " + string(drop_x) + " (Type " + string(slot_types[drop_x]) + ") in " + inventory_type);
                        }
                    } else {
                        // Check if dropping onto a matching stackable item
                        var is_stackable = global.item_data[item_id][3];
                        var max_stack = global.item_data[item_id][7];
                        var target_slot = inventory[# drop_x, drop_y];
                        if (is_stackable && target_slot != -1 && is_array(target_slot) && target_slot[0] == item_id) {
                            var current_qty = target_slot[2];
                            if (current_qty < max_stack) {
                                var space_left = max_stack - current_qty;
                                var add_qty = min(qty, space_left);
                                target_slot[2] = current_qty + add_qty;
                                qty -= add_qty;
                                show_debug_message("Merged " + string(add_qty) + " " + item_name + " into stack at [" + string(drop_x) + "," + string(drop_y) + "] in " + inventory_type + ", now " + string(target_slot[2]) + "/" + string(max_stack));
                                if (qty <= 0) {
                                    origin_inv.dragging = -1;
                                    global.dragging_inventory = -1;
                                    drop_valid = true;
                                    break;
                                }
                            }
                        }
                        // If not fully merged or not stackable, check for empty space
                        if (qty > 0 && can_place_item(inventory, drop_x, drop_y, item_width, item_height)) {
                            inventory_add_at(drop_x, drop_y, item_id, qty, inventory);
                            origin_inv.dragging = -1;
                            global.dragging_inventory = -1;
                            show_debug_message("Dropped " + string(qty) + " " + item_name + " at [" + string(drop_x) + "," + string(drop_y) + "] in " + inventory_type);
                            drop_valid = true;
                            break;
                        } else if (qty > 0) {
                            show_debug_message("Blocked: No space or partial merge at [" + string(drop_x) + "," + string(drop_y) + "] in " + inventory_type + " - " + string(qty) + " " + item_name + " remain");
                        }
                    }
                }
            }
        }

        // Handle drop outcome
        if (global.dragging_inventory != -1) {
            if (over_inventory && !drop_valid) {
                // Snap back to origin on invalid drop or partial merge
                show_debug_message("Invalid drop or partial merge, snapping " + string(qty) + " " + item_name + " back to [" + string(origin_inv.original_mx) + "," + string(origin_inv.original_my) + "] in " + origin_inv.inventory_type);
                if (qty > 0) inventory_add_at(origin_inv.original_mx, origin_inv.original_my, item_id, qty, origin_inv.original_grid);
                origin_inv.dragging = -1;
                global.dragging_inventory = -1;
            } else if (!over_inventory && instance_exists(obj_player)) {
                // Drop on ground if outside all inventories, preserving stack quantity, only if item_id is valid
                if (item_id != ITEM.NONE) {
                    var world_x = round(obj_player.x) + irandom_range(-8, 8); // Slight offset to avoid stacking
                    var world_y = round(obj_player.y) + irandom_range(-8, 8);
                    var dropped_item = instance_create_layer(world_x, world_y, "Instances", obj_item, { item_id: item_id, stack_quantity: qty });
                    show_debug_message("Dropped " + string(qty) + " " + item_name + " on ground at [" + string(world_x) + "," + string(world_y) + "] with stack_quantity: " + string(dropped_item.stack_quantity));
                    origin_inv.dragging = -1;
                    global.dragging_inventory = -1;
                } else {
                    show_debug_message("Cannot drop: Item has no valid item_id (ITEM.NONE)");
                    origin_inv.dragging = -1;
                    global.dragging_inventory = -1;
                }
            }
        }
    }
}