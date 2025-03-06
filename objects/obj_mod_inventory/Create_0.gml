// obj_mod_inventory - Create Event
// Description: Initializes a mod inventory tied to a specific item, inheriting from obj_inventory.
// Variable Definitions (set via instance_create_layer):
// - parent_item_id: real (ID of the item being modded)
// - Inherited from obj_inventory: inventory_type, grid_width, grid_height, slot_size, inv_gui_x, inv_gui_y, etc.

event_inherited();

inventory_type = "mod_inventory";

// Override grid size based on the parent item's mod inventory dimensions
if (variable_instance_exists(id, "parent_item_id") && parent_item_id != ITEM.NONE) {
    grid_width = global.item_data[parent_item_id][9];  // mod_inventory_width
    grid_height = global.item_data[parent_item_id][10]; // mod_inventory_height
    show_debug_message("Set mod inventory size to " + string(grid_width) + "x" + string(grid_height) + " for item " + global.item_data[parent_item_id][0]);
} else {
    grid_width = 1;  // Fallback size
    grid_height = 1;
    show_debug_message("Warning: No valid parent_item_id for mod inventory, defaulting to 1x1");
}

// Initialize the grid
if (!ds_exists(inventory, ds_type_grid)) {
    inventory = ds_grid_create(grid_width, grid_height);
    ds_grid_set_region(inventory, 0, 0, grid_width - 1, grid_height - 1, -1);
    show_debug_message("Initialized mod inventory grid: " + string(grid_width) + "x" + string(grid_height));
}

// Position after the backpack with padding, plus sprite area and extra spacing
if (instance_exists(global.backpack)) {
    var backpack_right = global.backpack.inv_gui_x + (global.backpack.grid_width * global.backpack.slot_size) + 24 * 2;
    var sprite_area_width = 112; // Must match the scaled sprite_area_width in obj_mod_background
    var extra_spacing = 80; // Reduced from 96 to shift slots 16px to the left
    inv_gui_x = backpack_right + 64 + sprite_area_width + extra_spacing; // Shift right by backpack width + 64px + sprite area + extra spacing
    inv_gui_y = global.backpack.inv_gui_y; // Align vertically
    is_open = true; // Start open
    show_debug_message("Positioned mod inventory at GUI [" + string(inv_gui_x) + "," + string(inv_gui_y) + "]");
} else {
    inv_gui_x = 64 + 80 + 96; // Fallback position, adjusted for sprite area and extra spacing
    inv_gui_y = 256;
    show_debug_message("Warning: Backpack not found, using fallback position for mod inventory");
}