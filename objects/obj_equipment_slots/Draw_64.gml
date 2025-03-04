// obj_equipment_slots
// Event: Draw GUI
// Description: Renders equipment slots with strictly 1x1 drop feedback, no inheritance.
// Variable Definitions:
// - Inherited from obj_inventory
// - slot_types: array (Type requirements per slot)
// - spacing: real (Pixel gap between slots)

if (is_open) {
    if (!ds_exists(inventory, ds_type_grid)) {
        show_debug_message("Error: Equipment slots grid does not exist");
        return;
    }

    var frame_width = grid_width * slot_size + (grid_width - 1) * spacing;
    var frame_height = slot_size;
    var frame_x = inv_gui_x - 24;
    var frame_y = inv_gui_y - 24;
    draw_sprite_stretched(spr_inventory_frame, 0, frame_x, frame_y, frame_width + 48, frame_height + 48);

    draw_set_alpha(0.3);
    draw_set_color(c_gray);
    for (var i = 0; i < grid_width; i++) {
        var slot_x = inv_gui_x + i * (slot_size + spacing);
        var slot_y = inv_gui_y;
        draw_rectangle(slot_x, slot_y, slot_x + slot_size - 1, slot_y + slot_size - 1, false);
    }

    draw_set_alpha(1.0);
    draw_set_color(c_white);
    for (var i = 0; i < grid_width; i++) {
        var slot_x = inv_gui_x + i * (slot_size + spacing);
        var slot_y = inv_gui_y;
        draw_rectangle(slot_x, slot_y, slot_x + slot_size - 1, slot_y + slot_size - 1, true);
    }

    for (var i = 0; i < grid_width; i++) {
        var slot = inventory[# i, 0];
        if (slot != -1 && is_array(slot)) {
            var item_id = slot[0];
            var sprite = global.item_data[item_id][5];
            if (sprite_exists(sprite)) {
                var scale = slot_size / max(sprite_get_width(sprite), sprite_get_height(sprite));
                var slot_x = inv_gui_x + i * (slot_size + spacing);
                var slot_y = inv_gui_y;
                draw_sprite_ext(sprite, 0, slot_x, slot_y, scale, scale, 0, c_white, 1);
            }
        }
    }

    var gui_mouse_x = device_mouse_x_to_gui(0);
    var gui_mouse_y = device_mouse_y_to_gui(0);
    if (global.dragging_inventory != -1 && instance_exists(global.dragging_inventory)) {
        var dragging_inv = global.dragging_inventory;
        if (dragging_inv.dragging != -1 && is_array(dragging_inv.dragging)) {
            var item_id = dragging_inv.dragging[0];
            var item_type = global.item_data[item_id][6];
            if (point_in_rectangle(gui_mouse_x, gui_mouse_y, inv_gui_x, inv_gui_y, inv_gui_x + grid_width * slot_size + (grid_width - 1) * spacing, inv_gui_y + slot_size)) {
                var drop_x = floor((gui_mouse_x - inv_gui_x) / (slot_size + spacing));
                if (drop_x >= 0 && drop_x < grid_width) {
                    var can_drop = (item_type == slot_types[drop_x] && inventory[# drop_x, 0] == -1);
                    draw_set_color(can_drop ? c_lime : c_red);
                    draw_set_alpha(0.5);
                    var slot_x = inv_gui_x + drop_x * (slot_size + spacing);
                    var slot_y = inv_gui_y;
                    draw_rectangle(slot_x, slot_y, slot_x + slot_size - 1, slot_y + slot_size - 1, false); // Hard 1x1 box, no inheritance
                    draw_set_alpha(1.0);
                    draw_set_color(c_white);
                }
            }
        }
    }
}