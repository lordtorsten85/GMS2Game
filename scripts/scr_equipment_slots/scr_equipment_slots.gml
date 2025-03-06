// scr_equipment_slots - Function (equip_unequip_item)
// Handles equipping or unequipping items via context menu, compatible with drag-and-drop logic
// Parameters: item_id (item to equip/unequip), slot_type (ITEM_TYPE.UTILITY or ITEM_TYPE.WEAPON), action ("equip" or "unequip")

function equip_unequip_item(item_id, slot_type, action) {
    if (item_id == -1 || item_id == ITEM.NONE) {
        show_debug_message("Invalid item ID for equip/unequip");
        return false;
    }

    var item_name = global.item_data[item_id][0];
    var item_type = global.item_data[item_id][6]; // Assuming type is at index 6
    var slot_col = (slot_type == ITEM_TYPE.UTILITY) ? 0 : 1;
    var success = false;

    if (action == "equip") {
        if (item_type == slot_type) {
            // Check if slot is empty
            if (inventory[# slot_col, 0] == -1) {
                // Equip directly
                inventory[# slot_col, 0] = [item_id, instance_number(obj_item), 1]; // Use instance count as placement_id
                global.equipment[slot_col] = item_id;
                success = true;
                show_debug_message("Equipped " + item_name + " in " + (slot_type == ITEM_TYPE.UTILITY ? "utility" : "weapon") + " slot via menu");
            } else {
                // Try to swap with existing item
                var existing_item_id = global.equipment[slot_col];
                if (existing_item_id != "") {
                    var source_inv = global.backpack; // Default to backpack; adjust if other inventories are involved
                    if (instance_exists(source_inv) && can_place_item(source_inv.inventory, 0, 0, global.item_data[existing_item_id][1], global.item_data[existing_item_id][2])) {
                        inventory_add_at(0, 0, existing_item_id, 1, source_inv.inventory); // Place in first available spot or specific position
                        inventory[# slot_col, 0] = [item_id, instance_number(obj_item), 1];
                        global.equipment[slot_col] = item_id;
                        success = true;
                        show_debug_message("Swapped " + item_name + " with " + global.item_data[existing_item_id][0] + " via menu");
                    } else {
                        show_debug_message("No room in inventory to swap " + item_name);
                    }
                }
            }
        } else {
            show_debug_message("Cannot equip " + item_name + ": Wrong type for " + (slot_type == ITEM_TYPE.UTILITY ? "utility" : "weapon") + " slot");
        }
    } else if (action == "unequip") {
        if (global.equipment[slot_col] == item_id) {
            // Unequip to backpack (or other inventory)
            var target_inv = global.backpack;
            if (instance_exists(target_inv) && can_place_item(target_inv.inventory, 0, 0, global.item_data[item_id][1], global.item_data[item_id][2])) {
                inventory_add_at(0, 0, item_id, 1, target_inv.inventory);
                inventory[# slot_col, 0] = -1;
                global.equipment[slot_col] = "";
                success = true;
                show_debug_message("Unequipped " + item_name + " from " + (slot_type == ITEM_TYPE.UTILITY ? "utility" : "weapon") + " slot via menu");
            } else {
                show_debug_message("No room in inventory to unequip " + item_name);
            }
        } else {
            show_debug_message("Item " + item_name + " not equipped in " + (slot_type == ITEM_TYPE.UTILITY ? "utility" : "weapon") + " slot");
        }
    }

    return success;
}