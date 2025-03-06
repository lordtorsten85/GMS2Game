// obj_mod_background - Create Event
// Description: Initializes the mod background with a stretched frame and item sprite.
// Variable Definitions (set via instance_create_layer):
// - parent_item_id: real (ID of the item being modded)
// - mod_inventory: instance (the associated mod inventory instance)

if (variable_instance_exists(id, "parent_item_id") && parent_item_id != ITEM.NONE) {
    item_sprite = global.item_data[parent_item_id][5]; // Sprite of the item
    // Scale the sprite by 2x for display
    var scale = 2;
    var scaled_width = sprite_get_width(item_sprite) * scale;
    var scaled_height = sprite_get_height(item_sprite) * scale;
    sprite_area_width = scaled_width + 48; // Scaled width + padding (24px on each side)
    sprite_scale = scale; // Store the scale for drawing
    show_debug_message("Set item_sprite for mod background to " + string(item_sprite) + " with sprite_area_width " + string(sprite_area_width));
} else {
    item_sprite = -1;
    sprite_area_width = 64; // Fallback
    sprite_scale = 1; // Fallback scale
    show_debug_message("Warning: No valid parent_item_id for mod background, using fallback sprite_area_width");
}

// Get the mod inventory dimensions to calculate frame size
if (variable_instance_exists(id, "mod_inventory") && instance_exists(mod_inventory)) {
    grid_width = mod_inventory.grid_width;
    grid_height = mod_inventory.grid_height;
    slot_size = mod_inventory.slot_size;
    // Position the background to start after the backpack
    if (instance_exists(global.backpack)) {
        // Backpack's right edge: inv_gui_x + (grid_width * slot_size) + 2 * padding
        var backpack_right = global.backpack.inv_gui_x + (global.backpack.grid_width * global.backpack.slot_size) + 24 * 2;
        // Desired frame_x = backpack_right + 64
        var desired_frame_x = backpack_right + 64;
        // frame_x = inv_gui_x - padding - sprite_area_width
        // inv_gui_x = desired_frame_x + padding + sprite_area_width
        padding = 24; // Define padding here for clarity
        inv_gui_x = desired_frame_x + padding + sprite_area_width;
        inv_gui_y = global.backpack.inv_gui_y; // Align vertically
        show_debug_message("Backpack right edge: " + string(backpack_right) + ", desired frame_x: " + string(desired_frame_x));
    } else {
        inv_gui_x = 64; // Fallback position
        inv_gui_y = 256;
    }
} else {
    grid_width = 1; // Fallback
    grid_height = 1;
    slot_size = 64;
    inv_gui_x = 64; // Fallback position
    inv_gui_y = 256;
    show_debug_message("Warning: No valid mod_inventory instance for mod background, using fallback values");
}

padding = 24; // Match obj_inventory's frame padding
frame_width = sprite_area_width + (grid_width * slot_size) + (2 * padding) + 96; // Extra 96px spacing between sprite and slots
frame_height = (grid_height * slot_size) + (2 * padding);
frame_x = inv_gui_x - padding - sprite_area_width; // Start left of the sprite area
frame_y = inv_gui_y - padding;

// Debug position
show_debug_message("Positioned mod background at GUI [" + string(inv_gui_x) + "," + string(inv_gui_y) + "] with frame_x [" + string(frame_x) + "] and frame width " + string(frame_width));