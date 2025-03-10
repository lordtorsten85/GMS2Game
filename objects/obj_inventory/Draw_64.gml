// obj_inventory - Draw GUI Event
if (!is_open || !ds_exists(inventory, ds_type_grid)) exit;

var gui_mouse_x = device_mouse_x_to_gui(0);
var gui_mouse_y = device_mouse_y_to_gui(0);
var hover_mx = floor((gui_mouse_x - inv_gui_x) / slot_size);
var hover_my = floor((gui_mouse_y - inv_gui_y) / slot_size);
var hover_valid = (hover_mx >= 0 && hover_mx < grid_width && hover_my >= 0 && hover_my < grid_height);

draw_set_color(c_gray);
for (var i = 0; i < grid_width; i++) {
    for (var j = 0; j < grid_height; j++) {
        var slot_x = inv_gui_x + (i * slot_size);
        var slot_y = inv_gui_y + (j * slot_size);

        if (hover_valid && hover_mx == i && hover_my == j && dragging == -1) {
            draw_set_color(c_ltgray);
            draw_rectangle(slot_x, slot_y, slot_x + slot_size - 1, slot_y + slot_size - 1, false);
            draw_set_color(c_gray);
        }
        draw_rectangle(slot_x, slot_y, slot_x + slot_size - 1, slot_y + slot_size - 1, true);

        var slot = inventory[# i, j];
        if (slot != -1 && is_array(slot)) {
            var item_id = slot[0];
            var sprite = global.item_data[item_id][5];
            var scale = (inventory_type == "equipment_slots") ? 0.5 : 0.8;
            draw_sprite_ext(sprite, 0, slot_x + (slot_size / 2), slot_y + (slot_size / 2), scale, scale, 0, c_white, 1);
            if (global.item_data[item_id][3] && slot[2] > 1) {
                draw_set_halign(fa_right);
                draw_set_valign(fa_bottom);
                draw_text(slot_x + slot_size - 2, slot_y + slot_size - 2, string(slot[2]));
            }
        }
    }
}

draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);