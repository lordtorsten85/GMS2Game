// obj_mod_inventory - Step Event
// Description: Handles dragging and dropping of mods, updates parent slot on both addition and removal, and manages close button functionality
// Variable Definitions (inherited from obj_inventory, see Create Event)

event_inherited(); // Inherit base drag-drop behavior from obj_inventory
if (!ds_exists(inventory, ds_type_grid)) exit;

var gui_mouse_x = device_mouse_x_to_gui(0);
var gui_mouse_y = device_mouse_y_to_gui(0);

// Close button logic
var backpack_right = global.backpack.inv_gui_x + (global.backpack.grid_width * global.backpack.slot_size); // e.g., 64 + (4 * 64) = 320
var grid_x = backpack_right + 288;
var frame_y = frame_gui_y; // Align with backpack's top edge
var frame_padding = 8;
var frame_w = 256 + (grid_width * slot_size) + 32;
var close_x = grid_x + (grid_width * slot_size) + 48;
var close_y = frame_y - 32;
var close_w = sprite_get_width(spr_help_close);
var close_h = sprite_get_height(spr_help_close);

if (mouse_check_button_pressed(mb_left) && point_in_rectangle(gui_mouse_x, gui_mouse_y, close_x, close_y, close_x + close_w, close_y + close_h)) {
    is_open = false;
}

// Handle dropping the mod (both out to another inventory and in to this one)
if (mouse_check_button_released(mb_left) && global.dragging_inventory != -1 && dragging == -1) {
    var source_inventory = global.dragging_inventory;
    var item_id = source_inventory.dragging[0];
    var placement_id = source_inventory.dragging[1];
    var qty = source_inventory.dragging[2];
    var contained_items = (array_length(source_inventory.dragging) > 3 && source_inventory.dragging[3] != undefined) ? source_inventory.dragging[3] : [];
    var item_width = global.item_data[item_id][1];
    var item_height = global.item_data[item_id][2];

    // Check if dropped into this mod inventory
    if (point_in_rectangle(gui_mouse_x, gui_mouse_y, inv_gui_x, inv_gui_y, inv_gui_x + grid_width * slot_size, inv_gui_y + grid_height * slot_size)) {
        var drop_x = floor((gui_mouse_x - inv_gui_x) / slot_size);
        var drop_y = floor((gui_mouse_y - inv_gui_y) / slot_size);
        
        if (drop_x >= 0 && drop_x <= grid_width - item_width && drop_y >= 0 && drop_y <= grid_height - item_height) {
            var can_drop = inventory_can_fit(drop_x, drop_y, item_width, item_height, inventory);
            if (can_drop && can_accept_mod(item_id, source_inventory.dragging[0])) {
                inventory_add_at(drop_x, drop_y, item_id, qty, inventory, contained_items);
                source_inventory.inventory[# source_inventory.original_mx, source_inventory.original_my] = -1;
                show_debug_message("Dropped " + global.item_data[item_id][0] + " into " + inventory_type + " at [" + string(drop_x) + "," + string(drop_y) + "]");

                // Update parent slot immediately
                if (instance_exists(parent_inventory) && ds_exists(parent_inventory.inventory, ds_type_grid)) {
                    var slot = parent_inventory.inventory[# parent_slot_x, parent_slot_y];
                    if (is_array(slot)) {
                        slot[3] = ds_grid_to_array(inventory);
                        parent_inventory.inventory[# parent_slot_x, parent_slot_y] = slot;
                        show_debug_message("Updated parent slot at [" + string(parent_slot_x) + "," + string(parent_slot_y) + "] to: " + string(slot));
                        apply_utility_effects(); // Force immediate effect update
                    }
                }

                source_inventory.dragging = -1;
                global.dragging_inventory = -1;
            }
        }
    }
    // Handle drop out to another inventory
    else {
        var target_inventory = -1;
        var drop_x = -1;
        var drop_y = -1;

        with (obj_inventory) {
            if (id != other.id && point_in_rectangle(gui_mouse_x, gui_mouse_y, inv_gui_x, inv_gui_y, inv_gui_x + grid_width * slot_size, inv_gui_y + grid_height * slot_size)) {
                target_inventory = id;
                drop_x = floor((gui_mouse_x - inv_gui_x) / slot_size);
                drop_y = floor((gui_mouse_y - inv_gui_y) / slot_size);
                break;
            }
        }

        if (target_inventory != -1 && ds_exists(target_inventory.inventory, ds_type_grid)) {
            if (drop_x >= 0 && drop_x <= target_inventory.grid_width - item_width && 
                drop_y >= 0 && drop_y <= target_inventory.grid_height - item_height) {
                var can_drop = inventory_can_fit(drop_x, drop_y, item_width, item_height, target_inventory.inventory);
                if (can_drop) {
                    inventory_add_at(drop_x, drop_y, item_id, qty, target_inventory.inventory, contained_items);
                    source_inventory.inventory[# source_inventory.original_mx, source_inventory.original_my] = -1;
                    show_debug_message("Dropped " + global.item_data[item_id][0] + " into " + target_inventory.inventory_type + " at [" + string(drop_x) + "," + string(drop_y) + "]");

                    // Update parent slot immediately
                    if (instance_exists(parent_inventory) && ds_exists(parent_inventory.inventory, ds_type_grid)) {
                        var slot = parent_inventory.inventory[# parent_slot_x, parent_slot_y];
                        if (is_array(slot)) {
                            slot[3] = ds_grid_to_array(inventory);
                            parent_inventory.inventory[# parent_slot_x, parent_slot_y] = slot;
                            show_debug_message("Updated parent slot at [" + string(parent_slot_x) + "," + string(parent_slot_y) + "] to: " + string(slot));
                            apply_utility_effects(); // Force immediate effect update
                        }
                    }

                    source_inventory.dragging = -1;
                    global.dragging_inventory = -1;
                }
            }
        }
    }
}