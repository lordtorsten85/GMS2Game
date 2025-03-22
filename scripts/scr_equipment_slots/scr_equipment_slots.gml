// scr_equipment_slots - Function (equip_unequip_item)
// Handles equipping or unequipping items via context menu, compatible with drag-and-drop logic
// Parameters: item_id (item to equip/unequip), slot_type (ITEM_TYPE.UTILITY or ITEM_TYPE.WEAPON), action ("equip" or "unequip")

function equip_unequip_item(item_id, slot_type, action) {
    if (item_id == -1 || item_id == ITEM.NONE) {
        show_debug_message("Invalid item ID for equip/unequip");
        return false;
    }

    // Ensure global.equipment is initialized
    if (!variable_global_exists("equipment") || !is_array(global.equipment)) {
        global.equipment = array_create(2, -1); // Initialize if missing
        show_debug_message("Initialized global.equipment as [2, -1] array");
    }

    var item_name = global.item_data[item_id][0];
    var item_type = global.item_data[item_id][6]; // Assuming type is at index 6
    var slot_col = (slot_type == ITEM_TYPE.UTILITY) ? 0 : 1;
    var success = false;
    var equip_inv = global.equipment_slots;
    var backpack = global.backpack;

    if (!instance_exists(equip_inv) || !ds_exists(equip_inv.inventory, ds_type_grid) ||
        !instance_exists(backpack) || !ds_exists(backpack.inventory, ds_type_grid)) {
        show_debug_message("Error: Invalid inventory instances for equip/unequip");
        return false;
    }

    if (action == "equip") {
        if (item_type == slot_type) {
            // Find the source slot in the backpack
            var source_slot_x = -1;
            var source_slot_y = -1;
            with (backpack) {
                for (var i = 0; i < grid_width; i++) {
                    for (var j = 0; j < grid_height; j++) {
                        var slot = inventory[# i, j];
                        if (is_array(slot) && slot[0] == item_id) {
                            source_slot_x = i;
                            source_slot_y = j;
                            break;
                        }
                    }
                    if (source_slot_x != -1) break;
                }
            }

            if (source_slot_x == -1) {
                show_debug_message("Item " + item_name + " not found in backpack");
                return false;
            }

            // Safely retrieve the source slot from the ds_grid
            var source_slot = backpack.inventory[# source_slot_x, source_slot_y];
            if (!is_array(source_slot) || array_length(source_slot) < 1) {
                show_debug_message("Invalid source slot data for " + item_name);
                return false;
            }
            var source_qty = source_slot[2];
            var source_contained = (array_length(source_slot) > 3 && source_slot[3] != undefined) ? source_slot[3] : [];

            // Check if equipment slot is empty
            if (equip_inv.inventory[# slot_col, 0] == -1) {
                equip_inv.inventory[# slot_col, 0] = [item_id, irandom(10000), source_qty, source_contained];
                global.equipment[slot_col] = item_id; // Sync here
                inventory_remove(source_slot_x, source_slot_y, backpack.inventory);
                success = true;
                show_debug_message("Equipped " + item_name + " in " + (slot_type == ITEM_TYPE.UTILITY ? "utility" : "weapon") + " slot via menu");
            } else {
                // Try to swap with existing item
                var existing_slot = equip_inv.inventory[# slot_col, 0];
                if (!is_array(existing_slot) || array_length(existing_slot) < 1) {
                    show_debug_message("Invalid existing slot data at [" + string(slot_col) + ",0]");
                    return false;
                }
                var existing_item_id = existing_slot[0];
                var existing_width = global.item_data[existing_item_id][1];
                var existing_height = global.item_data[existing_item_id][2];
                var existing_qty = existing_slot[2];
                var existing_contained = (array_length(existing_slot) > 3 && existing_slot[3] != undefined) ? existing_slot[3] : [];

                // Temporarily remove the source item to simulate freed space
                inventory_remove(source_slot_x, source_slot_y, backpack.inventory);

                var can_swap = false;
                var swap_x = -1;
                var swap_y = -1;

                with (backpack) {
                    for (var i = 0; i <= grid_width - existing_width; i++) {
                        for (var j = 0; j <= grid_height - existing_height; j++) {
                            if (inventory_can_fit(i, j, existing_width, existing_height, inventory)) {
                                can_swap = true;
                                swap_x = i;
                                swap_y = j;
                                break;
                            }
                        }
                        if (can_swap) break;
                    }
                }

                if (can_swap) {
                    inventory_add_at(swap_x, swap_y, existing_item_id, existing_qty, backpack.inventory, existing_contained);
                    equip_inv.inventory[# slot_col, 0] = [item_id, irandom(10000), source_qty, source_contained];
                    global.equipment[slot_col] = item_id; // Sync here
                    success = true;
                    show_debug_message("Swapped " + item_name + " with " + global.item_data[existing_item_id][0]);
                } else {
                    // Rollback if no space
                    inventory_add_at(source_slot_x, source_slot_y, item_id, source_qty, backpack.inventory, source_contained);
                    show_debug_message("No room to swap " + item_name + ", rolled back");
                }
            }
        } else {
            show_debug_message("Cannot equip " + item_name + ": Wrong type for slot");
        }
    } else if (action == "unequip") {
        // Ensure slot_col is valid
        if (slot_col < 0 || slot_col >= array_length(global.equipment)) {
            show_debug_message("Invalid slot_col " + string(slot_col) + " for unequip");
            return false;
        }

        if (global.equipment[slot_col] == item_id) { // Line 122 - now safe
            var existing_slot = equip_inv.inventory[# slot_col, 0];
            if (!is_array(existing_slot) || array_length(existing_slot) < 1) {
                show_debug_message("Invalid existing slot data at [" + string(slot_col) + ",0]");
                return false;
            }
            var existing_item_id = existing_slot[0];
            var existing_qty = existing_slot[2];
            var existing_contained = (array_length(existing_slot) > 3 && existing_slot[3] != undefined) ? existing_slot[3] : [];
            var existing_width = global.item_data[existing_item_id][1];
            var existing_height = global.item_data[existing_item_id][2];

            var can_unequip = false;
            var unequip_x = -1;
            var unequip_y = -1;

            with (backpack) {
                for (var i = 0; i <= grid_width - existing_width; i++) {
                    for (var j = 0; j <= grid_height - existing_height; j++) {
                        if (inventory_can_fit(i, j, existing_width, existing_height, inventory)) {
                            can_unequip = true;
                            unequip_x = i;
                            unequip_y = j;
                            break;
                        }
                    }
                    if (can_unequip) break;
                }
            }

            if (can_unequip) {
                inventory_add_at(unequip_x, unequip_y, existing_item_id, existing_qty, backpack.inventory, existing_contained);
                equip_inv.inventory[# slot_col, 0] = -1;
                global.equipment[slot_col] = -1; // Sync here (changed from "" to -1 for consistency)
                success = true;
                show_debug_message("Unequipped " + item_name + " to [" + string(unequip_x) + "," + string(unequip_y) + "]");
            } else {
                show_debug_message("No room in inventory to unequip " + item_name);
            }
        } else {
            show_debug_message("Item " + item_name + " not equipped in slot " + string(slot_col));
        }
    }

    return success;
}