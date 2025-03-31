// Script: scr_consumable_effects
// Function: use_consumable_item
// Description: Processes the effect of a consumable item and updates the inventory accordingly
// Parameters:
// - item_id: The ID of the consumable item (e.g., ITEM.SYRINGE)
// - inventory_instance: The inventory instance containing the item
// - slot_x: The top-left X coordinate of the item in the grid
// - slot_y: The top-left Y coordinate of the item in the grid
// Returns: true if used successfully, false otherwise
function use_consumable_item(item_id, inventory_instance, slot_x, slot_y) {
    if (!instance_exists(inventory_instance) || !ds_exists(inventory_instance.inventory, ds_type_grid)) {
        show_debug_message("Error: Invalid inventory instance in use_consumable_item");
        return false;
    }
    if (item_id < 0 || item_id >= array_length(global.item_data) || global.item_data[item_id][6] != ITEM_TYPE.CONSUMABLE) {
        show_debug_message("Error: Invalid or non-consumable item_id " + string(item_id));
        return false;
    }

    var slot = inventory_instance.inventory[# slot_x, slot_y];
    if (!is_array(slot) || slot[0] != item_id) {
        show_debug_message("Error: Slot at [" + string(slot_x) + "," + string(slot_y) + "] does not contain item " + string(item_id));
        return false;
    }

    var qty = slot[2];
    var item_name = global.item_data[item_id][0];
    var success = false;

    switch (item_id) {
        case ITEM.SYRINGE:
            if (instance_exists(obj_manager)) {
                var heal_amount = 20;
                var old_hp = obj_manager.health_current;
                obj_manager.health_current = min(obj_manager.health_current + heal_amount, obj_manager.health_max);
                var healed = obj_manager.health_current - old_hp;
                show_debug_message("Used " + item_name + ": Restored " + string(healed) + " HP. Current HP: " + string(obj_manager.health_current) + "/" + string(obj_manager.health_max));
                success = true;
            } else {
                show_debug_message("Error: obj_manager not found for health update");
            }
            break;
        // Add more consumables here in the future, e.g.:
        // case ITEM.ENERGY_DRINK:
        //     // Add stamina boost or other effect
        //     success = true;
        //     break;
        default:
            show_debug_message("No effect defined for consumable " + item_name);
            return false;
    }

    if (success) {
        // Reduce stack by 1 or remove if last item
        if (qty > 1) {
            slot[2] = qty - 1;
            inventory_instance.inventory[# slot_x, slot_y] = slot;
            show_debug_message("Reduced " + item_name + " stack to " + string(qty - 1));
        } else {
            inventory_remove(slot_x, slot_y, inventory_instance.inventory);
            show_debug_message("Consumed last " + item_name + " and removed from inventory");
        }
    }

    return success;
}