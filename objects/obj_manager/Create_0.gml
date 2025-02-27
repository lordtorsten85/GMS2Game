// Initialize the player's backpack inventory in the GUI layer with specific properties
global.backpack = instance_create_layer(0, 0, "GUI", obj_inventory, 
    {
        inventory_type: "backpack",
        grid_width: 4,  // Adjust to 2 for 4x2 UI layout if needed
        grid_height: 4, // Adjust to 1 for 4x2 UI layout if needed
        slot_size: 64,  // Pixel size of each slot (matches UI scaling)
        inv_gui_x: 64,  // GUI X position
        inv_gui_y: 256, // GUI Y position
        dragging: -1,   // Initialize dragging state
        drag_offset_x: 0,
        drag_offset_y: 0,
        original_grid: -1,
        original_mx: 0,
        original_my: 0,
        is_open: false  // Start closed
    }
);

// Initialize the inventory grid for the backpack
with (global.backpack) {
    inventory = ds_grid_create(grid_width, grid_height);
    ds_grid_clear(inventory, -1);
    show_debug_message("Initialized backpack inventory grid: " + string(grid_width) + "x" + string(grid_height));
}

depth = -12510; // Lower depth means it draws later, on top
global.dragging_inventory = -1;