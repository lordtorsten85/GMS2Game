// obj_mod_inventory - Draw GUI Event
if (!is_open || !ds_exists(inventory, ds_type_grid)) exit;

var grid_w = grid_width * slot_size;
var grid_h = grid_height * slot_size;
var frame_padding = 8;
var frame_x = inv_gui_x - frame_padding;
var frame_y = inv_gui_y - frame_padding;
var frame_w = grid_w + (frame_padding * 2);
var frame_h = grid_h + (frame_padding * 2);
var sprite_x = frame_x - 128 - 8;
var sprite_y = inv_gui_y;
var close_x = frame_x + frame_w + 8;
var close_y = inv_gui_y;

draw_sprite_stretched(spr_inventory_frame, 0, frame_x, frame_y, frame_w, frame_h);

if (item_id >= 0) {
    var item_sprite = global.item_data[item_id][5];
    draw_sprite_stretched(item_sprite, 0, sprite_x, sprite_y, 128, 128);
}

for (var i = 0; i < grid_width; i++) {
    for (var j = 0; j < grid_height; j++) {
        var slot_x = inv_gui_x + (i * slot_size);
        var slot_y = inv_gui_y + (j * slot_size);
        draw_rectangle(slot_x, slot_y, slot_x + slot_size, slot_y + slot_size, true);
        var slot = inventory[# i, j];
        if (slot != -1 && is_array(slot)) {
            var sprite = global.item_data[slot[0]][5];
            draw_sprite_stretched(sprite, 0, slot_x, slot_y, slot_size, slot_size);
            draw_set_color(c_white);
            draw_text(slot_x + 2, slot_y + slot_size - 12, string(slot[2]));
        }
    }
}

draw_sprite(spr_help_close, 0, close_x, close_y);