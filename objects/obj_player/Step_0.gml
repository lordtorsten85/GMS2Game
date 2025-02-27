// obj_player - Step Event
// Handle player movement and inventory interactions in the game world

// Toggle backpack inventory with Tab (using instance-specific positions)
if (keyboard_check_pressed(vk_tab)) {
    if (instance_exists(global.backpack)) {
        global.backpack.is_open = !global.backpack.is_open;
        show_debug_message((global.backpack.is_open ? "Opened" : "Closed") + " backpack at GUI position [" + string(global.backpack.inv_gui_x) + "," + string(global.backpack.inv_gui_y) + "]");
    } else {
        show_debug_message("Error: Backpack instance not found");
    }
}