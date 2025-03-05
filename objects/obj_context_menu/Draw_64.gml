// obj_context_menu - Draw GUI Event
// Description: Draws the context menu in GUI space with options, styled for a retro look, with hover highlighting and larger clickable areas.

var gui_mouse_x = device_mouse_x_to_gui(0);
var gui_mouse_y = device_mouse_y_to_gui(0);

draw_set_color(c_black);
draw_set_alpha(0.8);
draw_rectangle(menu_x, menu_y, menu_x + menu_width, menu_y + menu_height, false);

draw_set_color(c_white);
draw_set_alpha(1.0);
draw_set_font(-1); // Default font
var option_height = 30;
for (var i = 0; i < array_length(options); i++) {
    var option_y = menu_y + (i * option_height);
    var is_hovered = point_in_rectangle(gui_mouse_x, gui_mouse_y, menu_x, option_y, menu_x + menu_width, option_y + option_height);
    if (is_hovered) {
        draw_set_color(c_yellow); // Highlight background
        draw_rectangle(menu_x, option_y, menu_x + menu_width, option_y + option_height, false);
        draw_set_color(c_black); // Text color for contrast
    } else {
        draw_set_color(c_white); // Normal text color
    }
    draw_text(menu_x + 10, option_y + 5, options[i]);
}

draw_set_color(c_white); // Reset color
draw_set_alpha(1.0);     // Reset alpha