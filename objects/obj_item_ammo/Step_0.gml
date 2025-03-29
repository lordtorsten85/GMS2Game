// obj_item_ammo - Step Event
if (is_in_world && place_meeting(x, y, obj_player) && keyboard_check_pressed(ord("E"))) {
    if (ds_exists(obj_manager.ammo_counts, ds_type_map) && ammo_type != "") {
        var current_ammo = ds_map_find_value(obj_manager.ammo_counts, ammo_type);
        var max_ammo = ds_map_find_value(obj_manager.ammo_counts, ammo_type + "_max");
        if (current_ammo == undefined) current_ammo = 0;
        if (max_ammo == undefined) max_ammo = 50; // Default, override in child if needed
        var ammo_to_add = min(stack_quantity, max_ammo - current_ammo);
        var new_ammo = current_ammo + ammo_to_add;
        ds_map_replace(obj_manager.ammo_counts, ammo_type, new_ammo);

        // Update equipped weapon ammo if matching weapon is equipped
        if (instance_exists(global.equipment_slots) && ammo_weapon_id != -1) {
            var weapon_slot = global.equipment_slots.inventory[# 1, 0];
            if (is_array(weapon_slot) && weapon_slot[0] == ammo_weapon_id) {
                obj_manager.ammo_current = new_ammo;
                show_debug_message("Equipped " + global.item_data[ammo_weapon_id][0] + " ammo updated to: " + string(new_ammo));
            }
        }

        show_debug_message("Picked up " + string(ammo_to_add) + " " + global.item_data[item_id][0] + ". Total now: " + string(new_ammo) + "/" + string(max_ammo));

        if (stack_quantity > ammo_to_add) {
            stack_quantity -= ammo_to_add;
            show_debug_message("Excess " + global.item_data[item_id][0] + " remains: " + string(stack_quantity));
        } else {
            instance_destroy();
        }
    }
}