// obj_mod_inventory - Step Event
event_inherited();
if (!ds_exists(inventory, ds_type_grid)) exit;

var gui_mouse_x = device_mouse_x_to_gui(0);
var gui_mouse_y = device_mouse_y_to_gui(0);

var frame_padding = 8;
var frame_w = (grid_width * slot_size) + (frame_padding * 2);
var close_x = inv_gui_x + frame_w + 8;
var close_y = inv_gui_y;
var close_w = sprite_get_width(spr_help_close);
var close_h = sprite_get_height(spr_help_close);

if (mouse_check_button_pressed(mb_left) && point_in_rectangle(gui_mouse_x, gui_mouse_y, close_x, close_y, close_x + close_w, close_y + close_h)) {
    is_open = false;
}