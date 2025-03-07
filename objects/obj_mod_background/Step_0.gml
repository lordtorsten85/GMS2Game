// obj_mod_background - Step Event
// Description: Handles closing via the "X" button, saving mod inventory contents to the parent item's contained_items array, then destroying both the background and the mod inventory.

var gui_mouse_x = device_mouse_x_to_gui(0);
var gui_mouse_y = device_mouse_y_to_gui(0);
var padding = 16;
var close_x = frame_x + frame_width - padding; // Match Draw GUI Event
var close_y = frame_y + padding; // Match Draw GUI Event
var close_size = 48; // Match the drawn box size

if (mouse_check_button_pressed(mb_left) && point_in_rectangle(gui_mouse_x, gui_mouse_y, close_x, close_y, close_x + close_size, close_y + close_size)) {
    // Save mod inventory contents back to the parent item's contained_items array
    if (instance_exists(mod_inventory)) {
        show_debug_message("Attempting to save mod inventory for item " + string(parent_item_id));
        if (instance_exists(mod_inventory.parent_inventory) && ds_exists(mod_inventory.inventory, ds_type_grid)) {
            var slot = mod_inventory.parent_inventory.inventory[# mod_inventory.parent_slot_x, mod_inventory.parent_slot_y];
            if (is_array(slot)) {
                show_debug_message("Slot found at [" + string(mod_inventory.parent_slot_x) + "," + string(mod_inventory.parent_slot_y) + "]: " + string(slot));
                if (array_length(slot) >= 4) {
                    var contained_items = [];
                    var index = 0;
                    for (var i = 0; i < mod_inventory.grid_width; i++) {
                        for (var j = 0; j < mod_inventory.grid_height; j++) {
                            var grid_slot = mod_inventory.inventory[# i, j];
                            if (grid_slot != -1 && is_array(grid_slot)) {
                                contained_items[index] = [grid_slot[0], grid_slot[2]]; // [item_id, qty]
                                index++;
                            }
                        }
                    }
                    slot[3] = contained_items; // Assign directly to slot[3]
                    mod_inventory.parent_inventory.inventory[# mod_inventory.parent_slot_x, mod_inventory.parent_slot_y] = slot;
                    show_debug_message("Saved " + string(index) + " contained items for " + global.item_data[parent_item_id][0] + " to " + mod_inventory.parent_inventory.inventory_type + " slot [" + string(mod_inventory.parent_slot_x) + "," + string(mod_inventory.parent_slot_y) + "] - Contents: " + string(contained_items));
                } else {
                    show_debug_message("Slot array too short: " + string(array_length(slot)));
                }
            } else {
                show_debug_message("Slot is not an array at [" + string(mod_inventory.parent_slot_x) + "," + string(mod_inventory.parent_slot_y) + "]");
            }
        } else {
            show_debug_message("Parent inventory or grid invalid: parent_exists=" + string(instance_exists(mod_inventory.parent_inventory)) + ", grid_exists=" + string(ds_exists(mod_inventory.inventory, ds_type_grid)));
        }

        // Destroy the mod inventory
        instance_destroy(mod_inventory);
        show_debug_message("Destroyed mod inventory via mod background 'X' button");
    } else {
        show_debug_message("Mod inventory does not exist when closing");
    }
    // Destroy self
    instance_destroy();
    show_debug_message("Closed mod background via 'X' button at [" + string(close_x) + "," + string(close_y) + "]");
}