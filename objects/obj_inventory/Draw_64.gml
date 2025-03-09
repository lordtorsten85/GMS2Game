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

if (string_pos("mod_", inventory_type) == 1) {
    var frame_x = inv_gui_x - 10;
    var frame_y = inv_gui_y - 42;
    var frame_width = (grid_width * slot_size) + 20;
    var frame_height = (grid_height * slot_size) + 52;
    draw_sprite_stretched(spr_inventory_frame, 0, frame_x, frame_y, frame_width, frame_height);

    var item_name = string_replace(inventory_type, "mod_", "");
    var parent_item_id = -1;
    for (var i = 0; i < array_length(global.item_data); i++) {
        if (global.item_data[i] != undefined && global.item_data[i][0] == item_name) {
            parent_item_id = i;
            break;
        }
    }
    if (parent_item_id != -1) {
        var item_sprite = global.item_data[parent_item_id][5];
        draw_sprite_ext(item_sprite, 0, frame_x + 10, frame_y + 10, 0.8, 0.8, 0, c_white, 1);
    }

    var close_x = frame_x + frame_width - 34;
    var close_y = frame_y + 2;
    draw_sprite(spr_help_close, 0, close_x, close_y);
    if (mouse_check_button_pressed(mb_left) && point_in_rectangle(gui_mouse_x, gui_mouse_y, close_x, close_y, close_x + 32, close_y + 32)) {
        is_open = false;
        show_debug_message("Closed mod inventory via button");
    }
}