// Script: scr_pickup_ammo
// Arguments:
// - item_instance: The obj_item instance to process
// Returns: true if fully picked up, false if partial or no pickup
function scr_pickup_ammo(item_instance) {
    if (!instance_exists(item_instance)) {
        show_debug_message("Error: Invalid item instance passed to scr_pickup_ammo.");
        return false;
    }

    var item_id = item_instance.item_id;
    var stack_quantity = item_instance.stack_quantity;

    if (!variable_instance_exists(item_instance, "item_id") || item_id == ITEM.NONE || !ds_map_exists(global.ammo_types, item_id)) {
        show_debug_message("Warning: Item instance " + string(item_instance) + " has invalid or non-ammo item_id: " + string(item_id));
        return false;
    }

    var ammo_data = global.ammo_types[? item_id];
    var ammo_type = ammo_data[0];        // e.g., "small_gun"
    var weapon_id = ammo_data[1];        // e.g., ITEM.SMALL_GUN
    var max_ammo = ammo_data[2];         // e.g., 50

    if (!ds_exists(obj_manager.ammo_counts, ds_type_map)) {
        show_debug_message("Error: ammo_counts ds_map not found in obj_manager.");
        return false;
    }

    var current_ammo = ds_map_find_value(obj_manager.ammo_counts, ammo_type);
    if (current_ammo == undefined) current_ammo = 0;
    var ammo_to_add = min(stack_quantity, max_ammo - current_ammo);
    if (ammo_to_add <= 0) {
        show_debug_message("Ammo full for " + ammo_type + ": " + string(current_ammo) + "/" + string(max_ammo));
        return false;
    }

    var new_ammo = current_ammo + ammo_to_add;
    ds_map_replace(obj_manager.ammo_counts, ammo_type, new_ammo);

    // Update equipped ammo if the matching weapon is equipped
    if (instance_exists(global.equipment_slots)) {
        var weapon_slot = global.equipment_slots.inventory[# 1, 0];
        if (is_array(weapon_slot) && weapon_slot[0] == weapon_id) {
            obj_manager.ammo_current = new_ammo;
            show_debug_message("Equipped " + global.item_data[weapon_id][0] + " ammo updated to: " + string(new_ammo));
        }
    }

    show_debug_message("Picked up " + string(ammo_to_add) + " " + global.item_data[item_id][0] + ". Total now: " + string(new_ammo) + "/" + string(max_ammo));
    
    item_instance.stack_quantity -= ammo_to_add;
    return (item_instance.stack_quantity <= 0);
}