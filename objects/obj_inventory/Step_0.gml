// obj_inventory - Step Event
// Description: Handles drag-and-drop with ground drop outside inventories, snap-back on invalid drops, and spawns obj_context_menu on right-click. Updated for split delay and click-through block.

if (is_open) {
    var gui_mouse_x = device_mouse_x_to_gui(0);
    var gui_mouse_y = device_mouse_y_to_gui(0);

    // Start dragging (block if context menu is open)
    var bounds_width = (object_index == obj_equipment_slots ? grid_width * slot_size + (grid_width - 1) * spacing : grid_width * slot_size);
    if (point_in_rectangle(gui_mouse_x, gui_mouse_y, inv_gui_x, inv_gui_y, inv_gui_x + bounds_width, inv_gui_y + grid_height * slot_size)) {
        if (mouse_check_button_pressed(mb_left) && dragging == -1 && !instance_exists(obj_context_menu)) {
            show_debug_message("Mouse clicked over inventory type: " + inventory_type + " at GUI [" + string(gui_mouse_x) + "," + string(gui_mouse_y) + "]");
            if (instance_exists(id) && ds_exists(inventory, ds_type_grid)) {
                start_inventory_drag(id);
                if (dragging != -1) {
                    global.dragging_inventory = id;
                    just_split_timer = 0; // Reset timer when manually starting drag
                    show_debug_message("Dragging started for " + inventory_type);
                }
            } else {
                show_debug_message("Error: Invalid instance or grid for " + inventory_type);
            }
        }
    }

    // Spawn context menu on right-click
    if (mouse_check_button_pressed(mb_right) && point_in_rectangle(gui_mouse_x, gui_mouse_y, inv_gui_x, inv_gui_y, inv_gui_x + bounds_width, inv_gui_y + grid_height * slot_size)) {
        var slot_x = floor((gui_mouse_x - inv_gui_x) / (object_index == obj_equipment_slots ? slot_size + spacing : slot_size));
        var slot_y = floor((gui_mouse_y - inv_gui_y) / slot_size);
        slot_x = clamp(slot_x, 0, grid_width - 1);
        slot_y = clamp(slot_y, 0, grid_height - 1);
        var slot = inventory[# slot_x, slot_y];
        if (slot != -1 && is_array(slot)) {
            var item_id = slot[0];
            var item_type = global.item_data[item_id][6];
            if (item_type == ITEM_TYPE.GENERIC) {
                var menu = instance_create_layer(0, 0, "GUI_Menu", obj_context_menu, {
                    inventory: id,
                    item_id: item_id,
                    slot_x: slot_x,
                    slot_y: slot_y,
                    menu_x: gui_mouse_x,
                    menu_y: gui_mouse_y
                });
                show_debug_message("Spawned context menu for " + global.item_data[item_id][0] + " at slot [" + string(slot_x) + "," + string(slot_y) + "] in " + inventory_type);
            }
        }
    }

    // Handle dropping
    if (global.dragging_inventory != -1) {
        var origin_inv = global.dragging_inventory;
        var item_id = origin_inv.dragging[0];
        var qty = origin_inv.dragging[2];
        var item_name = (item_id != ITEM.NONE && item_id >= 0 && item_id < array_length(global.item_data)) ? global.item_data[item_id][0] : "No Item";
        var item_x = gui_mouse_x + origin_inv.drag_offset_x;
        var item_y = gui_mouse_y + origin_inv.drag_offset_y;
        var drop_valid = false;
        var over_inventory = false;

        // Manage split timer
        if (origin_inv.just_split_timer > 0) {
            origin_inv.just_split_timer -= 1;
            if (origin_inv.just_split_timer <= 0) {
                show_debug_message("Split delay ended for " + item_name + " - ready to drop");
            } else {
                show_debug_message("Split delay active for " + item_name + " (" + string(origin_inv.just_split_timer) + " frames left)");
            }
        }

        // Allow dropping after split timer ends or on release
        if (origin_inv.just_split_timer == 0 && mouse_check_button_released(mb_left) && !instance_exists(obj_context_menu)) {
            // Check all inventories for a valid drop
            with (obj_inventory) {
                if (is_open) {
                    var bounds_width = (object_index == obj_equipment_slots ? grid_width * slot_size + (grid_width - 1) * spacing : grid_width * slot_size);
                    if (point_in_rectangle(gui_mouse_x, gui_mouse_y, inv_gui_x, inv_gui_y, inv_gui_x + bounds_width, inv_gui_y + grid_height * slot_size)) {
                        over_inventory = true;
                        var drop_x = floor((object_index == obj_equipment_slots ? gui_mouse_x : item_x) - inv_gui_x) / (object_index == obj_equipment_slots ? slot_size + spacing : slot_size);
                        var drop_y = floor((object_index == obj_equipment_slots ? gui_mouse_y : item_y) - inv_gui_y) / slot_size;
                        var item_width = global.item_data[item_id][1];
                        var item_height = global.item_data[item_id][2];
                        var is_stackable = global.item_data[item_id][3];
                        var max_stack = global.item_data[item_id][7];

                        if (object_index == obj_equipment_slots) {
                            drop_x = clamp(drop_x, 0, grid_width - 1);
                            drop_y = 0;
                            if (drop_x >= 0 && drop_x < grid_width && global.item_data[item_id][6] == slot_types[drop_x] && inventory[# drop_x, 0] == -1) {
                                inventory[# drop_x, 0] = origin_inv.dragging;
                                origin_inv.dragging = -1;
                                global.dragging_inventory = -1;
                                show_debug_message("Dropped " + item_name + " into slot " + string(drop_x) + " in " + inventory_type);
                                drop_valid = true;
                            } else {
                                show_debug_message("Blocked: Type mismatch or occupied - " + item_name + " in " + inventory_type + " at slot " + string(drop_x));
                            }
                        } else {
                            var x_offset = (item_x - inv_gui_x) % slot_size;
                            var y_offset = (item_y - inv_gui_y) % slot_size;
                            if (x_offset > slot_size * 0.75 && drop_x + item_width < grid_width) drop_x += 1;
                            if (y_offset > slot_size * 0.75 && drop_y + item_height < grid_height) drop_y += 1;
                            drop_x = clamp(drop_x, 0, grid_width - item_width);
                            drop_y = clamp(drop_y, 0, grid_height - item_height);

                            var target_slot = inventory[# drop_x, drop_y];
                            if (is_stackable && target_slot != -1 && is_array(target_slot) && target_slot[0] == item_id) {
                                var current_qty = target_slot[2];
                                if (current_qty < max_stack) {
                                    var space_left = max_stack - current_qty;
                                    var add_qty = min(qty, space_left);
                                    target_slot[2] = current_qty + add_qty;
                                    qty -= add_qty;
                                    show_debug_message("Merged " + string(add_qty) + " " + item_name + " into stack at [" + string(drop_x) + "," + string(drop_y) + "]");
                                    if (qty <= 0) {
                                        origin_inv.dragging = -1;
                                        global.dragging_inventory = -1;
                                        drop_valid = true;
                                    }
                                }
                            }
                            if (qty > 0 && can_place_item(inventory, drop_x, drop_y, item_width, item_height)) {
                                inventory_add_at(drop_x, drop_y, item_id, qty, inventory);
                                origin_inv.dragging = -1;
                                global.dragging_inventory = -1;
                                show_debug_message("Dropped " + string(qty) + " " + item_name + " at [" + string(drop_x) + "," + string(drop_y) + "] in " + inventory_type);
                                drop_valid = true;
                            }
                        }
                        if (drop_valid) break;
                    }
                }
            }

            // Handle drop outcome
            if (global.dragging_inventory != -1) {
                if (over_inventory && !drop_valid) {
                    show_debug_message("Invalid drop, snapping " + string(qty) + " " + item_name + " back to [" + string(origin_inv.original_mx) + "," + string(origin_inv.original_my) + "] in " + origin_inv.inventory_type);
                    if (qty > 0) inventory_add_at(origin_inv.original_mx, origin_inv.original_my, item_id, qty, origin_inv.original_grid);
                    origin_inv.dragging = -1;
                    global.dragging_inventory = -1;
                } else if (!over_inventory && instance_exists(obj_player)) {
                    if (item_id != ITEM.NONE) {
                        var world_x = round(obj_player.x) + irandom_range(-8, 8);
                        var world_y = round(obj_player.y) + irandom_range(-8, 8);
                        var dropped_item = instance_create_layer(world_x, world_y, "Instances", obj_item, { item_id: item_id, stack_quantity: qty });
                        show_debug_message("Dropped " + string(qty) + " " + item_name + " on ground at [" + string(world_x) + "," + string(world_y) + "]");
                        origin_inv.dragging = -1;
                        global.dragging_inventory = -1;
                    }
                }
            }
        }
    }
}