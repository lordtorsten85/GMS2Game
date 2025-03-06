// obj_container - Step Event
// Description: Handles proximity detection, inventory interactions, and stable collision with player. Opens/closes based on player distance, restricts dragging to range, blocks walk-through, and auto-opens player inventory.

if (instance_exists(obj_player)) {
    var dist = point_distance(x, y, obj_player.x, obj_player.y);
    can_interact = (dist <= proximity_range);

    // Toggle visibility when in range and 'E' is pressed
    if (can_interact && keyboard_check_pressed(ord("E"))) {
        is_open = !is_open;
        show_debug_message((is_open ? "Opened" : "Closed") + " " + inventory_type + " at world position [" + string(x) + "," + string(y) + "]");

        // Auto-open/close player's backpack when container opens/closes
        if (instance_exists(global.backpack)) {
            global.backpack.is_open = is_open;
            show_debug_message("Player's backpack " + (is_open ? "opened" : "closed") + " with container");
        } else {
            show_debug_message("Error: Player's backpack (global.backpack) not found");
        }
    }

    // Auto-close if player moves out of range
    if (!can_interact && is_open) {
        is_open = false;
        if (instance_exists(global.backpack)) {
            global.backpack.is_open = false;
            show_debug_message("Closed " + inventory_type + " and player's backpack - player out of range (distance: " + string(dist) + ")");
        }
    }

    // Stable collision handling to make container solid
    var player = instance_place(x, y, obj_player);
    if (player != noone) {
        with (player) {
            x = xprevious;
            y = yprevious;
        }
        show_debug_message("Player blocked by " + inventory_type + " at [" + string(x) + "," + string(y) + "]");
    }
}

// Inherit dragging/dropping logic, but restrict dragging start to proximity and block when context menu is open
if (is_open) {
    var gui_mouse_x = device_mouse_x_to_gui(0);
    var gui_mouse_y = device_mouse_y_to_gui(0);

    if (can_interact && point_in_rectangle(gui_mouse_x, gui_mouse_y, inv_gui_x, inv_gui_y, inv_gui_x + grid_width * slot_size, inv_gui_y + grid_height * slot_size)) {
        if (mouse_check_button_pressed(mb_left) && !instance_exists(obj_context_menu)) { // Block if context menu exists
            show_debug_message("Mouse clicked over " + inventory_type + " at GUI [" + string(gui_mouse_x) + "," + string(gui_mouse_y) + "]");
            if (instance_exists(id) && ds_exists(inventory, ds_type_grid)) {
                start_inventory_drag(id);
                if (dragging != -1) {
                    global.dragging_inventory = id;
                    show_debug_message("Dragging started for " + inventory_type);
                }
            } else {
                show_debug_message("Error: Invalid instance or grid for " + inventory_type);
            }
        }
    }

    // Inherited drop logic
    event_inherited();
}