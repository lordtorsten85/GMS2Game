// obj_manager - Draw GUI Event
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
                var total_width = item_width * inv.slot_size;
                var total_height = item_height * inv.slot_size;
                var scale_x = (total_width / sprite_get_width(sprite)) * 0.8;
                var scale_y = (total_height / sprite_get_height(sprite)) * 0.8;
                var draw_x = gui_mouse_x + inv.drag_offset_x;
                var draw_y = gui_mouse_y + inv.drag_offset_y;
                draw_sprite_ext(sprite, 0, draw_x, draw_y, scale_x, scale_y, 0, c_white, 1);
            }
        }
    }
}