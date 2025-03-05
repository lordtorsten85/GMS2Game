// Script: scr_inventory_dragging
// Description: Contains functions for handling inventory drag-and-drop mechanics.

// Function: start_inventory_drag
// Description: Initiates dragging an item from an inventory, centering it under the mouse.
function start_inventory_drag(inv) {
    if (inv.dragging == -1 && global.dragging_inventory == -1) {
        var gui_mouse_x = device_mouse_x_to_gui(0);
        var gui_mouse_y = device_mouse_y_to_gui(0);
        var mx = floor((gui_mouse_x - inv.inv_gui_x) / (inv.object_index == obj_equipment_slots ? inv.slot_size + inv.spacing : inv.slot_size));
        var my = floor((gui_mouse_y - inv.inv_gui_y) / inv.slot_size);

        if (mx >= 0 && mx < inv.grid_width && my >= 0 && my < inv.grid_height) {
            var slot = inv.inventory[# mx, my];
            if (slot != -1 && is_array(slot)) {
                var item_id = slot[0];
                var placement_id = slot[1];
                var qty = slot[2];
                var item_name = global.item_data[item_id][0];
                var item_width = global.item_data[item_id][1];
                var item_height = global.item_data[item_id][2];

                var top_left_x = mx;
                var top_left_y = my;
                if (inv.object_index != obj_equipment_slots) {
                    while (top_left_x > 0 && is_array(inv.inventory[# top_left_x - 1, my]) && inv.inventory[# top_left_x - 1, my][1] == placement_id) top_left_x -= 1;
                    while (top_left_y > 0 && is_array(inv.inventory[# mx, top_left_y - 1]) && inv.inventory[# mx, top_left_y - 1][1] == placement_id) top_left_y -= 1;
                }

                inv.dragging = [item_id, placement_id, qty];
                // Center the item under the mouse
                var center_x = top_left_x + (item_width / 2); // Grid center X
                var center_y = top_left_y + (item_height / 2); // Grid center Y
                inv.drag_offset_x = -((item_width * inv.slot_size * 0.8) / 2); // Offset to center (80% scale)
                inv.drag_offset_y = -((item_height * inv.slot_size * 0.8) / 2);
                inv.original_mx = top_left_x;
                inv.original_my = top_left_y;
                inv.original_grid = inv.inventory;

                if (inv.object_index == obj_equipment_slots) {
                    inv.inventory[# mx, my] = -1;
                } else {
                    inventory_remove(top_left_x, top_left_y, inv.inventory);
                }
                global.dragging_inventory = inv;
                show_debug_message("Started dragging " + string(qty) + " " + item_name + " from [" + string(top_left_x) + "," + string(top_left_y) + "] in " + inv.inventory_type + " (centered)");
            }
        }
    }
}

// Function: inventory_handle_drop (unchanged, included for completeness)
function inventory_handle_drop(target_inventory) {
    if (!instance_exists(target_inventory) || !ds_exists(target_inventory.inventory, ds_type_grid)) return false;
    if (target_inventory.dragging == -1 || !is_array(target_inventory.dragging)) return false;

    var item_id = target_inventory.dragging[0];
    var qty = target_inventory.dragging[2];
    var item_width = global.item_data[item_id][1];
    var item_height = global.item_data[item_id][2];

    var gui_mouse_x = device_mouse_x_to_gui(0);
    var gui_mouse_y = device_mouse_y_to_gui(0);
    var mx = floor((gui_mouse_x - target_inventory.inv_gui_x) / target_inventory.slot_size);
    var my = floor((gui_mouse_y - target_inventory.inv_gui_y) / target_inventory.slot_size);

    if (mx >= 0 && mx <= target_inventory.grid_width - item_width && my >= 0 && my <= target_inventory.grid_height - item_height) {
        var can_place = true;
        for (var i = mx; i < mx + item_width; i++) {
            for (var j = my; j < my + item_height; j++) {
                if (ds_grid_get(target_inventory.inventory, i, j) != -1) can_place = false;
            }
        }
        if (can_place) {
            inventory_add_at(mx, my, item_id, qty, target_inventory.inventory);
            target_inventory.dragging = -1;
            return true;
        }
    }
    return false;
}