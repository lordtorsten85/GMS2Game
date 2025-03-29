// scr_utility_effects
// scr_utility_effects - Function (update_mod_effects)
// Description: Updates parent equipment slot when mods are added or removed from a mod inventory
function update_mod_effects(mod_inventory_instance) {
    if (!instance_exists(mod_inventory_instance) || !ds_exists(mod_inventory_instance.inventory, ds_type_grid)) {
        show_debug_message("Error: Invalid mod inventory instance in update_mod_effects");
        return;
    }

    if (string_pos("mod_", mod_inventory_instance.inventory_type) == 1 && 
        instance_exists(mod_inventory_instance.parent_inventory) && 
        ds_exists(mod_inventory_instance.parent_inventory.inventory, ds_type_grid)) {
        var slot = mod_inventory_instance.parent_inventory.inventory[# mod_inventory_instance.parent_slot_x, mod_inventory_instance.parent_slot_y];
        if (is_array(slot)) {
            var base_item_id = slot[0]; // Preserve the base item ID
            slot[3] = ds_grid_to_array(mod_inventory_instance.inventory);
            mod_inventory_instance.parent_inventory.inventory[# mod_inventory_instance.parent_slot_x, mod_inventory_instance.parent_slot_y] = slot;
            show_debug_message("Updated parent slot at [" + string(mod_inventory_instance.parent_slot_x) + "," + string(mod_inventory_instance.parent_slot_y) + "] to: " + string(slot));
            // Ensure global.equipment reflects the base item, not the mod
            var slot_col = (mod_inventory_instance.parent_inventory == global.equipment_slots) ? mod_inventory_instance.parent_slot_x : -1;
            if (slot_col != -1 && global.equipment[slot_col] != base_item_id) {
                global.equipment[slot_col] = base_item_id;
                show_debug_message("Corrected global.equipment[" + string(slot_col) + "] to base item ID: " + string(base_item_id));
            }
            apply_utility_effects();
        }
    }
}

function apply_utility_effects() {
    global.optics_enabled = false;
    global.optics_ir_enabled = false;

    if (instance_exists(global.equipment_slots) && ds_exists(global.equipment_slots.inventory, ds_type_grid)) {
        var optics_slot = global.equipment_slots.inventory[# 0, 0];
        if (is_array(optics_slot) && optics_slot[0] == ITEM.OPTICS) {
            global.optics_enabled = true;
            var contained_items = (array_length(optics_slot) > 3 && optics_slot[3] != undefined) ? optics_slot[3] : [];
            for (var i = 0; i < array_length(contained_items); i++) {
                if (is_array(contained_items[i]) && array_length(contained_items[i]) > 0 && contained_items[i][0] == ITEM.MOD_OPTICS_IR) {
                    global.optics_ir_enabled = true;
                    break;
                }
            }
        }
    }
    show_debug_message("Utility effects - Optics: " + string(global.optics_enabled) + ", IR: " + string(global.optics_ir_enabled));
}