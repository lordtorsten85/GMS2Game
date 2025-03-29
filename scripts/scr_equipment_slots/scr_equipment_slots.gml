// scr_equipment_slots - Function (equip_unequip_item)
// Description: Handles equipping or unequipping items via context menu, compatible with drag-and-drop logic
// Parameters: item_id (item to equip/unequip), slot_type (ITEM_TYPE.UTILITY or ITEM_TYPE.WEAPON), action ("equip" or "unequip")

function equip_unequip_item(item_id, slot_type, action) {
    if (item_id == -1 || item_id == ITEM.NONE) {
        show_debug_message("Invalid item ID for equip/unequip: " + string(item_id));
        return false;
    }

    if (!variable_global_exists("equipment") || !is_array(global.equipment)) {
        global.equipment = array_create(2, -1);
        show_debug_message("Initialized global.equipment as [2, -1] array");
    }

    var item_name = global.item_data[item_id][0];
    var item_type = global.item_data[item_id][6];
    var slot_col = (slot_type == ITEM_TYPE.UTILITY) ? 0 : 1;
    var success = false;
    var equip_inv = global.equipment_slots;
    var backpack = global.backpack;

    if (!instance_exists(equip_inv) || !ds_exists(equip_inv.inventory, ds_type_grid) ||
        !instance_exists(backpack) || !ds_exists(backpack.inventory, ds_type_grid)) {
        show_debug_message("Error: Invalid inventory instances for equip/unequip - equip_inv: " + string(instance_exists(equip_inv)) + ", backpack: " + string(instance_exists(backpack)));
        return false;
    }

    if (action == "equip") {
        if (item_type == slot_type) {
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

            var source_slot = backpack.inventory[# source_slot_x, source_slot_y];
            if (!is_array(source_slot) || array_length(source_slot) < 1) {
                show_debug_message("Invalid source slot data for " + item_name + " at [" + string(source_slot_x) + "," + string(source_slot_y) + "]");
                return false;
            }
            var source_qty = source_slot[2];
            var source_contained = (array_length(source_slot) > 3 && source_slot[3] != undefined) ? source_slot[3] : [];

            if (equip_inv.inventory[# slot_col, 0] == -1) {
                equip_inv.inventory[# slot_col, 0] = [item_id, irandom(10000), source_qty, source_contained];
                global.equipment[slot_col] = item_id;
                inventory_remove(source_slot_x, source_slot_y, backpack.inventory);
                success = true;
                show_debug_message("Equipped " + item_name + " in " + (slot_type == ITEM_TYPE.UTILITY ? "utility" : "weapon") + " slot via menu");
            } else {
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
                    global.equipment[slot_col] = item_id;
                    success = true;
                    show_debug_message("Swapped " + item_name + " with " + global.item_data[existing_item_id][0]);
                } else {
                    inventory_add_at(source_slot_x, source_slot_y, item_id, source_qty, backpack.inventory, source_contained);
                    show_debug_message("No room to swap " + item_name + ", rolled back");
                }
            }
        } else {
            show_debug_message("Cannot equip " + item_name + ": Wrong type for slot - Expected " + string(slot_type) + ", Got " + string(item_type));
        }
    } else if (action == "unequip") {
        if (slot_col < 0 || slot_col >= array_length(global.equipment)) {
            show_debug_message("Invalid slot_col " + string(slot_col) + " for unequip");
            return false;
        }

        var current_slot = equip_inv.inventory[# slot_col, 0];
        if (!is_array(current_slot) || array_length(current_slot) < 1) {
            show_debug_message("Invalid existing slot data at [" + string(slot_col) + ",0] for unequip");
            return false;
        }

        var existing_item_id = current_slot[0];
        show_debug_message("Unequip attempt - Slot: " + string(current_slot) + ", global.equipment[" + string(slot_col) + "] = " + string(global.equipment[slot_col]));

        // Check the slot's base item ID, not just global.equipment
        if (existing_item_id == item_id) {
            var existing_qty = current_slot[2];
            var existing_contained = (array_length(current_slot) > 3 && current_slot[3] != undefined) ? current_slot[3] : [];
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
                global.equipment[slot_col] = -1;
                success = true;
                show_debug_message("Unequipped " + item_name + " to [" + string(unequip_x) + "," + string(unequip_y) + "]");
            } else {
                show_debug_message("No room in backpack to unequip " + item_name + " - dropping to ground");
                instance_create_layer(obj_player.x + irandom_range(-8, 8), obj_player.y + irandom_range(-8, 8), "Instances", obj_item, {
                    item_id: existing_item_id,
                    stack_quantity: existing_qty,
                    placement_id: current_slot[1],
                    contained_items: existing_contained
                });
                equip_inv.inventory[# slot_col, 0] = -1;
                global.equipment[slot_col] = -1;
                success = true;
                show_debug_message("Dropped " + item_name + " on ground near player");
            }
        } else {
            show_debug_message("Item " + item_name + " not equipped in slot " + string(slot_col) + " - Expected ID: " + string(item_id) + ", Found in slot: " + string(existing_item_id) + ", global.equipment: " + string(global.equipment[slot_col]));
        }
    }

    return success;
}