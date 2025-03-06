// obj_mod_background - Step Event
// Description: Handles closing via the "X" button, destroying both the background and the mod inventory.

var gui_mouse_x = device_mouse_x_to_gui(0);
var gui_mouse_y = device_mouse_y_to_gui(0);
var close_x = frame_x + frame_width - 32; // Inside frame, 32px from right edge
var close_y = frame_y; // Inside frame, aligned with top edge
var close_size = 32; // Size of the clickable area

if (mouse_check_button_pressed(mb_left) && point_in_rectangle(gui_mouse_x, gui_mouse_y, close_x, close_y, close_x + close_size, close_y + close_size)) {
    // Destroy the mod inventory first
    if (instance_exists(mod_inventory)) {
        instance_destroy(mod_inventory);
        show_debug_message("Destroyed mod inventory via mod background 'X' button");
    }
    // Destroy self
    instance_destroy();
    show_debug_message("Closed mod background via 'X' button at [" + string(close_x) + "," + string(close_y) + "]");
}