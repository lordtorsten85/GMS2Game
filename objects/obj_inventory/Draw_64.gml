// obj_inventory
// Event: Draw GUI
// Description: Renders the inventory UI with a stretched frame, translucent gray grid slots, white borders, items, and stack quantity feedback. Displays hover highlights only when no item is being dragged globally (empty mouse), and drop validity (green/red) for dragged items, ensuring no overlap with items underneath during drags. Resets draw settings to prevent bleed-over.
// Variable Definitions:
// - inventory_type: string (e.g., "backpack")
// - grid_width: real (Number of slots wide)
// - grid_height: real (Number of slots tall)
// - slot_size: real (Pixel size of each slot)
// - inv_gui_x: real (GUI X position)
// - inv_gui_y: real (GUI Y position)
// - dragging: real (Array of [item_id, placement_id, qty] or -1)
// - inventory: asset (ds_grid for inventory slots)
// - is_open: boolean (Whether the inventory UI is visible)

if (is_open) {
    if (!ds_exists(inventory, ds_type_grid)) {
        show_debug_message("Error: Inventory grid does not exist for " + inventory_type);
        return;
    }

    var padding = 24;
    var frame_width = (grid_width * slot_size) + (2 * padding);
    var frame_height = (grid_height * slot_size) + (2 * padding);
    var frame_x = inv_gui_x - padding;
    var frame_y = inv_gui_y - padding;

    draw_sprite_stretched(spr_inventory_frame, 0, frame_x, frame_y, frame_width, frame_height);

    draw_set_alpha(0.3);
    draw_set_color(c_gray);
    for (var i = 0; i < grid_width; i++) {
        for (var j = 0; j < grid_height; j++) {
            var slot_x = inv_gui_x + i * slot_size;
            var slot_y = inv_gui_y + j * slot_size;
            draw_rectangle(slot_x, slot_y, slot_x + slot_size - 1, slot_y + slot_size - 1, false);
        }
    }

    draw_set_alpha(1.0); // Reset alpha for borders
    draw_set_color(c_white);
    for (var i = 0; i < grid_width; i++) {
        for (var j = 0; j < grid_height; j++) {
            var slot_x = inv_gui_x + i * slot_size;
            var slot_y = inv_gui_y + j * slot_size;
            draw_rectangle(slot_x, slot_y, slot_x + slot_size - 1, slot_y + slot_size - 1, true);
        }
    }

    var gui_mouse_x = device_mouse_x_to_gui(0);
    var gui_mouse_y = device_mouse_y_to_gui(0);

    // Draw items first, so highlights appear on top
    draw_set_alpha(1.0); // Reset alpha for items
    draw_set_color(c_white);
    for (var i = 0; i < grid_width; i++) {
        for (var j = 0; j < grid_height; j++) {
            var slot = inventory[# i, j];
            if (slot != -1 && is_array(slot)) {
                var item_id = slot[0];
                var placement_id = slot[1];
                if (i == 0 || !is_array(inventory[# i-1, j]) || inventory[# i-1, j][1] != placement_id) {
                    if (j == 0 || !is_array(inventory[# i, j-1]) || inventory[# i, j-1][1] != placement_id) {
                        var item_width = global.item_data[item_id][1];
                        var item_height = global.item_data[item_id][2];
                        var sprite = global.item_data[item_id][5];
                        var total_width = item_width * slot_size;
                        var total_height = item_height * slot_size;
                        var scale_x = total_width / sprite_get_width(sprite);
                        var scale_y = total_height / sprite_get_height(sprite);
                        var slot_x = inv_gui_x + i * slot_size;
                        var slot_y = inv_gui_y + j * slot_size;
                        draw_sprite_ext(sprite, 0, slot_x, slot_y, scale_x, scale_y, 0, c_white, 1);

                        // Draw stack quantity for stackable items
                        if (global.item_data[item_id][3]) { // Check if stackable
                            var qty = slot[2];
                            if (qty > 1) {
                                draw_set_font(-1); // Default font; replace with your font if set
                                draw_set_color(c_black); // Shadow for readability
                                draw_text(slot_x + 2, slot_y + 2, string(qty));
                                draw_set_color(c_white); // Main text
                                draw_text(slot_x, slot_y, string(qty));
                            }
                        }
                    }
                }
            }
        }
    }

    // Hover highlight only when no item is being dragged globally (empty mouse)
    if (global.dragging_inventory == -1 && point_in_rectangle(gui_mouse_x, gui_mouse_y, inv_gui_x, inv_gui_y, inv_gui_x + grid_width * slot_size, inv_gui_y + grid_height * slot_size)) {
        var mx = floor((gui_mouse_x - inv_gui_x) / slot_size);
        var my = floor((gui_mouse_y - inv_gui_y) / slot_size);
        if (mx >= 0 && mx < grid_width && my >= 0 && my < grid_height) {
            var slot = inventory[# mx, my];
            if (slot != -1 && is_array(slot)) {
                var item_id = slot[0];
                var placement_id = slot[1];
                var item_width = global.item_data[item_id][1];
                var item_height = global.item_data[item_id][2];

                var top_left_x = mx;
                var top_left_y = my;
                while (top_left_x > 0 && is_array(inventory[# top_left_x - 1, my]) && inventory[# top_left_x - 1, my][1] == placement_id) top_left_x -= 1;
                while (top_left_y > 0 && is_array(inventory[# mx, top_left_y - 1]) && inventory[# mx, top_left_y - 1][1] == placement_id) top_left_y -= 1;

                draw_set_color(c_yellow);
                draw_set_alpha(0.4);
                for (var i = top_left_x; i < top_left_x + item_width; i++) {
                    for (var j = top_left_y; j < top_left_y + item_height; j++) {
                        var slot_x = inv_gui_x + i * slot_size;
                        var slot_y = inv_gui_y + j * slot_size;
                        draw_rectangle(slot_x, slot_y, slot_x + slot_size - 1, slot_y + slot_size - 1, false);
                    }
                }
                draw_set_alpha(1.0); // Reset alpha after highlight
                draw_set_color(c_white); // Reset color after highlight
            }
        }
    }

    // Drop preview when dragging
    if (global.dragging_inventory != -1 && instance_exists(global.dragging_inventory)) {
        var dragging_inv = global.dragging_inventory;
        if (dragging_inv.dragging != -1 && is_array(dragging_inv.dragging)) { // Safety check
            var item_id = dragging_inv.dragging[0];
            var dragged_qty = dragging_inv.dragging[2];
            var item_width = global.item_data[item_id][1];
            var item_height = global.item_data[item_id][2];
            var is_stackable = global.item_data[item_id][3];
            var max_stack = global.item_data[item_id][7];

            if (point_in_rectangle(gui_mouse_x, gui_mouse_y, inv_gui_x, inv_gui_y, inv_gui_x + grid_width * slot_size, inv_gui_y + grid_height * slot_size)) {
                var item_x = gui_mouse_x + dragging_inv.drag_offset_x;
                var item_y = gui_mouse_y + dragging_inv.drag_offset_y;
                var drop_x = floor((item_x - inv_gui_x) / slot_size);
                var drop_y = floor((item_y - inv_gui_y) / slot_size);
                var x_offset = (item_x - inv_gui_x) % slot_size;
                var y_offset = (item_y - inv_gui_y) % slot_size;
                if (x_offset > slot_size / 2 && drop_x + item_width < grid_width) drop_x += 1;
                if (y_offset > slot_size / 2 && drop_y + item_height < grid_height) drop_y += 1;
                drop_x = clamp(drop_x, 0, grid_width - item_width);
                drop_y = clamp(drop_y, 0, grid_height - item_height);

                var can_drop = can_place_item(inventory, drop_x, drop_y, item_width, item_height);
                var target_slot = inventory[# drop_x, drop_y];
                if (is_stackable && target_slot != -1 && is_array(target_slot) && target_slot[0] == item_id) {
                    var current_qty = target_slot[2];
                    if (current_qty < max_stack) {
                        can_drop = true; // Merging is possible if there's any room
                        show_debug_message("Valid merge for " + global.item_data[item_id][0] + ": " + string(dragged_qty) + " onto " + string(current_qty) + "/" + string(max_stack) + " at [" + string(drop_x) + "," + string(drop_y) + "]");
                    }
                }

                draw_set_color(can_drop ? c_lime : c_red);
                draw_set_alpha(0.5);
                for (var i = drop_x; i < drop_x + item_width; i++) {
                    for (var j = drop_y; j < drop_y + item_height; j++) {
                        var slot_x = inv_gui_x + i * slot_size;
                        var slot_y = inv_gui_y + j * slot_size;
                        draw_rectangle(slot_x, slot_y, slot_x + slot_size - 1, slot_y + slot_size - 1, false);
                    }
                }
                draw_set_alpha(1.0); // Reset alpha after highlight
                draw_set_color(c_white); // Reset color after highlight
            }
        }
    }
}