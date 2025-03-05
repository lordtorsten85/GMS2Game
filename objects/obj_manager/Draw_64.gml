// obj_manager - Draw GUI
// Description: Central hub for drawing all inventories and dragged items, with hover, drop highlighting, stack quantity display, proper multicell sizing, and context menu highlight block.

with (obj_inventory) {
    if (is_open) {
        var padding = 24;
        var frame_width = (object_index == obj_equipment_slots ? grid_width * slot_size + (grid_width - 1) * spacing : grid_width * slot_size) + 2 * padding;
        var frame_height = (grid_height * slot_size) + 2 * padding;
        draw_sprite_stretched(spr_inventory_frame, 0, inv_gui_x - padding, inv_gui_y - padding, frame_width, frame_height);

        // Draw grid background
        draw_set_alpha(0.3);
        draw_set_color(c_gray);
        for (var i = 0; i < grid_width; i++) {
            for (var j = 0; j < grid_height; j++) {
                var slot_x = inv_gui_x + i * (object_index == obj_equipment_slots ? slot_size + spacing : slot_size);
                var slot_y = inv_gui_y + j * slot_size;
                draw_rectangle(slot_x, slot_y, slot_x + slot_size - 1, slot_y + slot_size - 1, false);
            }
        }

        // Draw grid borders
        draw_set_alpha(1.0);
        draw_set_color(c_white);
        for (var i = 0; i < grid_width; i++) {
            for (var j = 0; j < grid_height; j++) {
                var slot_x = inv_gui_x + i * (object_index == obj_equipment_slots ? slot_size + spacing : slot_size);
                var slot_y = inv_gui_y + j * slot_size;
                draw_rectangle(slot_x, slot_y, slot_x + slot_size - 1, slot_y + slot_size - 1, true);
            }
        }

        // Draw items and stack quantities
        for (var i = 0; i < grid_width; i++) {
            for (var j = 0; j < grid_height; j++) {
                var slot = inventory[# i, j];
                if (slot != -1 && is_array(slot)) {
                    var item_id = slot[0];
                    var placement_id = slot[1];
                    var qty = slot[2];
                    var sprite = global.item_data[item_id][5];
                    var item_width = global.item_data[item_id][1];
                    var item_height = global.item_data[item_id][2];
                    var slot_x = inv_gui_x + i * (object_index == obj_equipment_slots ? slot_size + spacing : slot_size);
                    var slot_y = inv_gui_y + j * slot_size;

                    if (i == 0 || !is_array(inventory[# i-1, j]) || inventory[# i-1, j][1] != placement_id) {
                        if (j == 0 || !is_array(inventory[# i, j-1]) || inventory[# i, j-1][1] != placement_id) {
                            var draw_width = (object_index == obj_equipment_slots ? slot_size : item_width * slot_size);
                            var draw_height = (object_index == obj_equipment_slots ? slot_size : item_height * slot_size);
                            var scale_x = draw_width / sprite_get_width(sprite);
                            var scale_y = draw_height / sprite_get_height(sprite);
                            draw_sprite_ext(sprite, 0, slot_x, slot_y, scale_x, scale_y, 0, c_white, 1);

                            if (global.item_data[item_id][3] && qty > 1) {
                                draw_set_font(-1);
                                draw_set_color(c_black);
                                draw_text(slot_x + 2, slot_y + 2, string(qty));
                                draw_set_color(c_white);
                                draw_text(slot_x, slot_y, string(qty));
                            }
                        }
                    }
                }
            }
        }

        var gui_mouse_x = device_mouse_x_to_gui(0);
        var gui_mouse_y = device_mouse_y_to_gui(0);

        // Hover highlight (disabled when context menu is open)
        if (global.dragging_inventory == -1 && !instance_exists(obj_context_menu) && point_in_rectangle(gui_mouse_x, gui_mouse_y, inv_gui_x, inv_gui_y, inv_gui_x + (object_index == obj_equipment_slots ? grid_width * (slot_size + spacing) - spacing : grid_width * slot_size), inv_gui_y + grid_height * slot_size)) {
            var mx = floor((gui_mouse_x - inv_gui_x) / (object_index == obj_equipment_slots ? slot_size + spacing : slot_size));
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
                    if (object_index != obj_equipment_slots) {
                        while (top_left_x > 0 && is_array(inventory[# top_left_x - 1, my]) && inventory[# top_left_x - 1, my][1] == placement_id) top_left_x -= 1;
                        while (top_left_y > 0 && is_array(inventory[# mx, top_left_y - 1]) && inventory[# mx, top_left_y - 1][1] == placement_id) top_left_y -= 1;
                    }

                    draw_set_color(c_yellow);
                    draw_set_alpha(0.4);
                    for (var i = top_left_x; i < top_left_x + item_width && i < grid_width; i++) {
                        for (var j = top_left_y; j < top_left_y + item_height && j < grid_height; j++) {
                            var slot_x = inv_gui_x + i * (object_index == obj_equipment_slots ? slot_size + spacing : slot_size);
                            var slot_y = inv_gui_y + j * slot_size;
                            draw_rectangle(slot_x, slot_y, slot_x + slot_size - 1, slot_y + slot_size - 1, false);
                        }
                    }
                    draw_set_alpha(1.0);
                    draw_set_color(c_white);
                }
            }
        }

        // Drop preview
        if (global.dragging_inventory != -1 && instance_exists(global.dragging_inventory)) {
            var dragging_inv = global.dragging_inventory;
            if (dragging_inv.dragging != -1 && is_array(dragging_inv.dragging) && point_in_rectangle(gui_mouse_x, gui_mouse_y, inv_gui_x, inv_gui_y, inv_gui_x + (object_index == obj_equipment_slots ? grid_width * (slot_size + spacing) - spacing : grid_width * slot_size), inv_gui_y + grid_height * slot_size)) {
                var item_id = dragging_inv.dragging[0];
                var dragged_qty = dragging_inv.dragging[2];
                var item_width = global.item_data[item_id][1];
                var item_height = global.item_data[item_id][2];
                var is_stackable = global.item_data[item_id][3];
                var max_stack = global.item_data[item_id][7];

                var item_x = gui_mouse_x + dragging_inv.drag_offset_x;
                var item_y = gui_mouse_y + dragging_inv.drag_offset_y;
                var drop_x = floor((item_x - inv_gui_x) / slot_size);
                var drop_y = floor((item_y - inv_gui_y) / slot_size);

                if (object_index == obj_equipment_slots) {
                    drop_y = 0;
                    drop_x = clamp(drop_x, 0, grid_width - 1);
                    var can_drop = (drop_x >= 0 && drop_x < grid_width && global.item_data[item_id][6] == slot_types[drop_x] && inventory[# drop_x, 0] == -1);
                    draw_set_color(can_drop ? c_lime : c_red);
                    draw_set_alpha(0.5);
                    var slot_x = inv_gui_x + drop_x * (slot_size + spacing);
                    var slot_y = inv_gui_y;
                    draw_rectangle(slot_x, slot_y, slot_x + slot_size - 1, slot_y + slot_size - 1, false);
                } else {
                    var x_offset = (item_x - inv_gui_x) % slot_size;
                    var y_offset = (item_y - inv_gui_y) % slot_size;
                    if (x_offset > slot_size * 0.75 && drop_x + item_width < grid_width) drop_x += 1;
                    if (y_offset > slot_size * 0.75 && drop_y + item_height < grid_height) drop_y += 1;
                    drop_x = clamp(drop_x, 0, grid_width - item_width);
                    drop_y = clamp(drop_y, 0, grid_height - item_height);

                    var can_drop = can_place_item(inventory, drop_x, drop_y, item_width, item_height);
                    var target_slot = inventory[# drop_x, drop_y];
                    if (is_stackable && target_slot != -1 && is_array(target_slot) && target_slot[0] == item_id) {
                        var current_qty = target_slot[2];
                        if (current_qty < max_stack) can_drop = true;
                    }

                    draw_set_color(can_drop ? c_lime : c_red);
                    draw_set_alpha(0.5);
                    for (var i = drop_x; i < drop_x + item_width && i < grid_width; i++) {
                        for (var j = drop_y; j < drop_y + item_height && j < grid_height; j++) {
                            var slot_x = inv_gui_x + i * slot_size;
                            var slot_y = inv_gui_y + j * slot_size;
                            draw_rectangle(slot_x, slot_y, slot_x + slot_size - 1, slot_y + slot_size - 1, false);
                        }
                    }
                }
                draw_set_alpha(1.0);
                draw_set_color(c_white);
            }
        }
    }
}

// Draw dragged items with 80% scaling
if (global.dragging_inventory != -1 && instance_exists(global.dragging_inventory)) {
    var inv = global.dragging_inventory;
    if (inv.dragging != -1 && is_array(inv.dragging)) {
        var item_id = inv.dragging[0];
        if (item_id >= 0 && item_id < array_length(global.item_data)) {
            var item_width = global.item_data[item_id][1];
            var item_height = global.item_data[item_id][2];
            var sprite = global.item_data[item_id][5];
            if (sprite_exists(sprite)) {
                var gui_mouse_x = device_mouse_x_to_gui(0);
                var gui_mouse_y = device_mouse_y_to_gui(0);
                var total_width = item_width * inv.slot_size * 0.8;
                var total_height = item_height * inv.slot_size * 0.8;
                var scale_x = total_width / sprite_get_width(sprite);
                var scale_y = total_height / sprite_get_height(sprite);
                var draw_x = gui_mouse_x + inv.drag_offset_x;
                var draw_y = gui_mouse_y + inv.drag_offset_y;
                draw_sprite_ext(sprite, 0, draw_x, draw_y, scale_x, scale_y, 0, c_white, 1);
            }
        }
    }
}

draw_set_color(c_white); // Reset draw settings
draw_set_alpha(1.0);