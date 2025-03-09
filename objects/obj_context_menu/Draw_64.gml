// obj_context_menu - Draw GUI Event
// Description: Renders the context menu with options and hover highlighting.
// Variable Definitions (set in object editor):
// - inventory - asset: Reference to the target inventory instance
// - item_id - real: ID of the selected item
// - slot_x - real: Grid X position of the selected item
// - slot_y - real: Grid Y position of the selected item
// - menu_x - real: GUI X position of the menu
// - menu_y - real: GUI Y position of the menu

draw_sprite_stretched(spr_inventory_frame, 0, menu_x, menu_y, menu_width, menu_height);

var gui_mouse_x = device_mouse_x_to_gui(0);
var gui_mouse_y = device_mouse_y_to_gui(0);
var option_height = 30;
var hover_index = floor((gui_mouse_y - menu_y) / option_height);
hover_index = clamp(hover_index, 0, array_length(options) - 1);

for (var i = 0; i < array_length(options); i++) {
    var option_y = menu_y + (i * option_height);
    if (point_in_rectangle(gui_mouse_x, gui_mouse_y, menu_x, option_y, menu_x + menu_width, option_y + option_height)) {
        draw_set_color(c_ltgray);
        draw_rectangle(menu_x, option_y, menu_x + menu_width, option_y + option_height - 1, false);
    }
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_text(menu_x + 10, option_y + (option_height / 2), options[i]);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);