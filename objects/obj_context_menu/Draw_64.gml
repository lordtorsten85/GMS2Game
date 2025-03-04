// obj_context_menu
// Event: Draw GUI
// Description: Draws the context menu in GUI space with options for the right-clicked item, styled for a retro look, with larger clickable areas and highlighting for hovered options. Updated to improve usability with visual feedback for stackable items, without debug logging for drawing.
// Variable Definitions:
// - inventory: instance (The obj_inventory instance the menu is attached to)
// - item_id: real (The ID of the clicked item from the ITEM enum)
// - slot_x: real (X position of the clicked slot in the inventory grid)
// - slot_y: real (Y position of the clicked slot in the inventory grid)
// - menu_x: real (GUI X position of the menu)
// - menu_y: real (GUI Y position of the menu)
// - menu_width: real (Width of the menu in pixels)
// - menu_height: real (Height of the menu in pixels)
// - options: array (Array of option strings, e.g., ["Drop", "Split Stack", "Take"])
//hello
if (inventory != noone && item_id != ITEM.NONE) {
    // Draw menu background (semi-transparent box)
    draw_set_alpha(0.8);
    draw_set_color(c_black);
    draw_rectangle(menu_x, menu_y, menu_x + menu_width, menu_y + menu_height, false);
    draw_set_alpha(1.0); // Reset alpha

    // Draw options with highlighting for hovered option
    draw_set_font(-1); // Default font; replace with your retro font if set
    var gui_mouse_x = device_mouse_x_to_gui(0);
    var gui_mouse_y = device_mouse_y_to_gui(0);
    var option_height = 30; // Larger clickable area (30 pixels per option)
    var option_y = menu_y + 10;

    for (var i = 0; i < array_length(options); i++) {
        // Check if mouse is hovering over this option (using larger clickable area)
        if (point_in_rectangle(gui_mouse_x, gui_mouse_y, menu_x, option_y, menu_x + menu_width, option_y + option_height)) {
            // Draw highlight (semi-transparent yellow box for retro feedback)
            draw_set_alpha(0.4);
            draw_set_color(c_yellow);
            draw_rectangle(menu_x, option_y, menu_x + menu_width, option_y + option_height, false);
            draw_set_alpha(1.0); // Reset alpha
        }

        // Draw option text
        draw_set_color(c_white);
        draw_text(menu_x + 10, option_y + (option_height - string_height(options[i])) / 2, options[i]); // Center text vertically
        option_y += option_height;
    }

    draw_set_color(c_white); // Reset color
}