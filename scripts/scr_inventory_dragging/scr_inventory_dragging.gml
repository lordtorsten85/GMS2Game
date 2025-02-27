// scr_inventory_dragging - inventory_start_dragging
// Initiates dragging an item from the inventory grid when clicked
// Handles multicell items by finding the top-left position and removing all linked cells

function inventory_start_dragging(inv) {
    var gui_mouse_x = device_mouse_x_to_gui(0);
    var gui_mouse_y = device_mouse_y_to_gui(0);
    var mx = floor((gui_mouse_x - inv.inv_gui_x) / inv.slot_size); // Mouse X grid position
    var my = floor((gui_mouse_y - inv.inv_gui_y) / inv.slot_size); // Mouse Y grid position

    // Check if click is within grid bounds
    if (mx >= 0 && mx < inv.grid_width && my >= 0 && my < inv.grid_height) {
        var slot = inv.inventory[# mx, my];
        if (slot != -1 && is_array(slot)) {
            var item_id = slot[0];          // Item ID from clicked cell
            var placement_id = slot[1];     // Unique ID linking all cells of this item
            var qty = slot[2];              // Quantity (usually 1 for non-stackable items)
            var item_name = global.item_data[item_id][0];
            var item_width = global.item_data[item_id][1];
            var item_height = global.item_data[item_id][2];

            show_debug_message("Clicked cell [" + string(mx) + "," + string(my) + "] with " + item_name + " (ID: " + string(item_id) + ", Placement ID: " + string(placement_id) + ")");

            // Find the top-left position of this multicell item
            var top_left_x = mx;
            var top_left_y = my;
            while (top_left_x > 0 && is_array(inv.inventory[# top_left_x - 1, my]) && inv.inventory[# top_left_x - 1, my][1] == placement_id) {
                top_left_x -= 1;
            }
            while (top_left_y > 0 && is_array(inv.inventory[# mx, top_left_y - 1]) && inv.inventory[# mx, top_left_y - 1][1] == placement_id) {
                top_left_y -= 1;
            }

            show_debug_message("Resolved top-left position of " + item_name + " to [" + string(top_left_x) + "," + string(top_left_y) + "]");

            // Set dragging data from the top-left position
            inv.dragging = [item_id, placement_id, qty];
            inv.drag_offset_x = (inv.inv_gui_x + top_left_x * inv.slot_size) - gui_mouse_x; // Offset from top-left
            inv.drag_offset_y = (inv.inv_gui_y + top_left_y * inv.slot_size) - gui_mouse_y;
            inv.original_mx = top_left_x;
            inv.original_my = top_left_y;
            inv.original_grid = inv.inventory;

            // Remove the entire item from the grid
            inventory_remove(top_left_x, top_left_y, inv.inventory);
            show_debug_message("Started dragging " + item_name + " (ID: " + string(item_id) + ") from [" + string(top_left_x) + "," + string(top_left_y) + "] - Size: " + string(item_width) + "x" + string(item_height));
        } else {
            show_debug_message("Clicked cell [" + string(mx) + "," + string(my) + "] is empty or invalid - no dragging started");
        }
    } else {
        show_debug_message("Click at [" + string(mx) + "," + string(my) + "] is outside grid bounds (" + string(inv.grid_width) + "x" + string(inv.grid_height) + ")");
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