// obj_context_menu
// Event: Step
// Description: Handles context menu interaction, processes options including Equip/Unequip with swapping, and centers split stacks with timer.

var gui_mouse_x = device_mouse_x_to_gui(0);
var gui_mouse_y = device_mouse_y_to_gui(0);

// Close menu on left-click outside
if (mouse_check_button_pressed(mb_left)) {
    if (!point_in_rectangle(gui_mouse_x, gui_mouse_y, menu_x, menu_y, menu_x + menu_width, menu_y + menu_height)) {
        instance_destroy();
        global.mouse_input_delay = 10;
        show_debug_message("Closed context menu for " + (inventory.inventory_type != "" ? inventory.inventory_type : "unknown") + " with mouse input delay");
    }
}

// Handle option selection with larger clickable area
if (mouse_check_button_pressed(mb_left) && point_in_rectangle(gui_mouse_x, gui_mouse_y, menu_x, menu_y, menu_x + menu_width, menu_y + menu_height)) {
    var option_height = 30;
    var option_index = floor((gui_mouse_y - menu_y) / option_height);
    if (option_index >= 0 && option_index < array_length(options)) {
        var option = options[option_index];
        var qty = 0;
        var top_left_x = slot_x;
        var top_left_y = slot_y;
        var item_width = 1;
        var item_height = 1;

        if (inventory != noone && ds_exists(inventory.inventory, ds_type_grid)) {
            var slot = inventory.inventory[# slot_x, slot_y];
            if (slot != -1 && is_array(slot)) {
                var placement_id = slot[1];
                qty = slot[2];

                // Find the top-left cell of the multi-cell item
                top_left_x = slot_x;
                top_left_y = slot_y;
                while (top_left_x > 0 && is_array(inventory.inventory[# top_left_x - 1, slot_y]) && inventory.inventory[# top_left_x - 1, slot_y][1] == placement_id) top_left_x -= 1;
                while (top_left_y > 0 && is_array(inventory.inventory[# slot_x, top_left_y - 1]) && inventory.inventory[# slot_x, top_left_y - 1][1] == placement_id) top_left_y -= 1;

                item_width = global.item_data[item_id][1];
                item_height = global.item_data[item_id][2];
            }
        }

        if (option == "Drop" && (inventory.inventory_type == "backpack" || inventory.inventory_type == "equipment_slots") && item_id != ITEM.NONE) {
            var world_x = obj_player.x + irandom_range(-8, 8);
            var world_y = obj_player.y + irandom_range(-8, 8);
            var dropped_item = instance_create_layer(world_x, world_y, "Instances", obj_item, { item_id: item_id, stack_quantity: qty });

            if (inventory.inventory_type == "backpack") {
                for (var i = top_left_x; i < top_left_x + item_width && i < inventory.grid_width; i++) {
                    for (var j = top_left_y; j < top_left_y + item_height && j < inventory.grid_height; j++) {
                        inventory.inventory[# i, j] = -1;
                    }
                }
            } else if (inventory.inventory_type == "equipment_slots") {
                inventory.inventory[# slot_x, 0] = -1;
            }
            show_debug_message("Dropped " + string(qty) + " " + global.item_data[item_id][0] + " on ground at [" + string(world_x) + "," + string(world_y) + "] with stack_quantity: " + string(dropped_item.stack_quantity));
        } else if (option == "Split Stack" && inventory.inventory_type == "backpack" && item_id != ITEM.NONE) {
            if (qty > 1) {
                var keep_qty = floor(qty / 2);
                var drag_qty = qty - keep_qty;

                var slot = inventory.inventory[# slot_x, slot_y];
                if (slot != -1 && is_array(slot)) {
                    slot[2] = keep_qty;
                    inventory.inventory[# slot_x, slot_y] = slot;
                    show_debug_message("Kept " + string(keep_qty) + " " + global.item_data[item_id][0] + " at [" + string(slot_x) + "," + string(slot_y) + "]");
                }

                if (inventory.dragging == -1 && global.dragging_inventory == -1) {
                    inventory.dragging = [item_id, slot[1], drag_qty];
                    global.dragging_inventory = inventory;
                    inventory.drag_offset_x = -((item_width * inventory.slot_size * 0.8) / 2);
                    inventory.drag_offset_y = -((item_height * inventory.slot_size * 0.8) / 2);
                    inventory.original_mx = slot_x;
                    inventory.original_my = slot_y;
                    inventory.original_grid = inventory.inventory;
                    inventory.just_split_timer = 60;
                    show_debug_message("Started dragging " + string(drag_qty) + " " + global.item_data[item_id][0] + " from [" + string(slot_x) + "," + string(slot_y) + "] in " + inventory.inventory_type + " (split stack, centered)");
                } else {
                    show_debug_message("Cannot split stack: Dragging already active (local: " + string(inventory.dragging) + ", global: " + string(global.dragging_inventory) + ")");
                }
            } else {
                show_debug_message("Cannot split stack: Quantity " + string(qty) + " is too low");
            }
        } else if (option == "Take" && inventory.inventory_type == "container" && item_id != ITEM.NONE) {
            var success = inventory_add_item(global.backpack, item_id, qty, false);
            if (success) {
                for (var i = top_left_x; i < top_left_x + item_width && i < inventory.grid_width; i++) {
                    for (var j = top_left_y; j < top_left_y + item_height && j < inventory.grid_height; j++) {
                        inventory.inventory[# i, j] = -1;
                    }
                }
                show_debug_message("Took " + string(qty) + " " + global.item_data[item_id][0] + " from " + inventory.inventory_type + " into backpack at [" + string(top_left_x) + "," + string(top_left_y) + "]");
            } else {
                show_debug_message("Backpack full - cannot take " + string(qty) + " " + global.item_data[item_id][0] + " from " + inventory.inventory_type);
            }
        } else if (option == "Equip" && inventory.inventory_type == "backpack" && item_id != ITEM.NONE) {
            var item_type = global.item_data[item_id][6];
            var target_slot = (item_type == ITEM_TYPE.UTILITY) ? 0 : 1;
            var equip_inv = global.equipment_slots;

            if (equip_inv.inventory[# target_slot, 0] == -1) {
                equip_inv.inventory[# target_slot, 0] = [item_id, slot[1], qty];
                for (var i = top_left_x; i < top_left_x + item_width && i < inventory.grid_width; i++) {
                    for (var j = top_left_y; j < top_left_y + item_height && j < inventory.grid_height; j++) {
                        inventory.inventory[# i, j] = -1;
                    }
                }
                show_debug_message("Equipped " + global.item_data[item_id][0] + " to slot " + string(target_slot));
            } else {
                var current_item = equip_inv.inventory[# target_slot, 0];
                var current_id = current_item[0];
                var current_qty = current_item[2];
                var current_width = global.item_data[current_id][1];
                var current_height = global.item_data[current_id][2];

                var temp_space = array_create(item_width * item_height, -1);
                var temp_index = 0;
                for (var i = top_left_x; i < top_left_x + item_width && i < inventory.grid_width; i++) {
                    for (var j = top_left_y; j < top_left_y + item_height && j < inventory.grid_height; j++) {
                        temp_space[temp_index] = inventory.inventory[# i, j];
                        inventory.inventory[# i, j] = -1;
                        temp_index++;
                    }
                }

                var can_swap = false;
                var swap_x = -1;
                var swap_y = -1;
                for (var i = 0; i <= inventory.grid_width - current_width; i++) {
                    for (var j = 0; j <= inventory.grid_height - current_height; j++) {
                        if (can_place_item(inventory.inventory, i, j, current_width, current_height)) {
                            can_swap = true;
                            swap_x = i;
                            swap_y = j;
                            break;
                        }
                    }
                    if (can_swap) break;
                }

                if (can_swap) {
                    equip_inv.inventory[# target_slot, 0] = [item_id, slot[1], qty];
                    inventory_add_at(swap_x, swap_y, current_id, current_qty, inventory.inventory);
                    global.backpack.just_swap_timer = 15;
                    show_debug_message("Swapped " + global.item_data[item_id][0] + " into slot " + string(target_slot) + ", moved " + global.item_data[current_id][0] + " to backpack at [" + string(swap_x) + "," + string(swap_y) + "] with drag delay");
                } else {
                    temp_index = 0;
                    for (var i = top_left_x; i < top_left_x + item_width && i < inventory.grid_width; i++) {
                        for (var j = top_left_y; j < top_left_y + item_height && j < inventory.grid_height; j++) {
                            inventory.inventory[# i, j] = temp_space[temp_index];
                            temp_index++;
                        }
                    }
                    show_debug_message("Cannot equip " + global.item_data[item_id][0] + " - no space in backpack for " + global.item_data[current_id][0]);
                }
            }
        } else if (option == "Unequip" && inventory.inventory_type == "equipment_slots" && item_id != ITEM.NONE) {
            var success = inventory_add(global.backpack, item_id, qty);
            if (success) {
                inventory.inventory[# slot_x, 0] = -1;
                show_debug_message("Unequipped " + global.item_data[item_id][0] + " from slot " + string(slot_x) + " to backpack");
            } else {
                show_debug_message("Cannot unequip " + global.item_data[item_id][0] + " - backpack full");
            }
        } else if (option == "Mod" && (inventory.inventory_type == "backpack" || inventory.inventory_type == "equipment_slots") && item_id != ITEM.NONE) {
            if (global.item_data[item_id][8]) { // Check if moddable
                // Create the mod background, which will spawn the mod inventory
                var mod_bg = instance_create_layer(0, 0, "GUI", obj_mod_background, {
                    parent_item_id: item_id,
                    parent_inventory: inventory,
                    parent_slot_x: top_left_x,
                    parent_slot_y: (inventory.inventory_type == "equipment_slots" ? 0 : top_left_y)
                });
                show_debug_message("Created mod background for " + global.item_data[item_id][0]);
            } else {
                show_debug_message("Cannot mod " + global.item_data[item_id][0] + " - item is not moddable");
            }
        }
        instance_destroy();
        global.mouse_input_delay = 10;
        show_debug_message("Closed context menu after selecting '" + option + "' with mouse input delay");
    }
}