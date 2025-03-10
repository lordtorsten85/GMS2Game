// obj_mod_inventory - Step Event
event_inherited();
if (!ds_exists(inventory, ds_type_grid)) exit;

var gui_mouse_x = device_mouse_x_to_gui(0);
var gui_mouse_y = device_mouse_y_to_gui(0);

var backpack_right = global.backpack.inv_gui_x + (global.backpack.grid_width * global.backpack.slot_size); // e.g., 64 + (4 * 64) = 320
var grid_x = backpack_right + 288;
var frame_y = frame_gui_y; // Align with backpack's top edge
var frame_padding = 8;
var frame_w = 256 + (grid_width * slot_size) + 32;
var close_x = grid_x + (grid_width * slot_size) + 48;
var close_y = frame_y - 32;
var close_w = sprite_get_width(spr_help_close);
var close_h = sprite_get_height(spr_help_close);

if (mouse_check_button_pressed(mb_left) && point_in_rectangle(gui_mouse_x, gui_mouse_y, close_x, close_y, close_x + close_w, close_y + close_h)) {
    is_open = false;
}