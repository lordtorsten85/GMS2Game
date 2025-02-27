// scr_inventory_dragging
/// For dragging and dropping logic.

// scr_inventory_dragging - inventory_start_dragging
function inventory_start_dragging(inv) {
    var gui_mouse_x = device_mouse_x_to_gui(0);
    var gui_mouse_y = device_mouse_y_to_gui(0);
    var mx = floor((gui_mouse_x - inv.inv_gui_x) / inv.slot_size);
    var my = floor((gui_mouse_y - inv.inv_gui_y) / inv.slot_size);
    
    if (mx >= 0 && mx < inv.grid_width && my >= 0 && my < inv.grid_height) {
        var slot = inv.inventory[# mx, my];
        if (slot != -1 && is_array(slot)) {
            var item_id = slot[0];
            var qty = slot[2];
            inv.dragging = [item_id, slot[1], qty];
            inv.drag_offset_x = (inv.inv_gui_x + mx * inv.slot_size) - gui_mouse_x;
            inv.drag_offset_y = (inv.inv_gui_y + my * inv.slot_size) - gui_mouse_y;
            inv.original_mx = mx;
            inv.original_my = my;
            inv.original_grid = inv.inventory;
            inventory_remove(mx, my, inv.inventory);
            show_debug_message("Started dragging " + global.item_data[item_id][0]);
        }
    }
}

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

    // Check if the item fits
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