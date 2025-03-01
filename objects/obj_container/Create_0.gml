// obj_container - Create Event
// Initializes a container with an inventory grid, inheriting from obj_inventory
// Sets up container-specific properties, preloads an item, and prepares for collision

event_inherited();
inventory_type = "container";
grid_width = 4;
grid_height = 4;
slot_size = 64;
inv_gui_x = 640;  // Right side of screen
inv_gui_y = 256;
is_open = false;
image_speed = 0;

// Proximity and interaction variables
proximity_range = 64; // Reduced from 100 to 64 for tighter interaction
can_interact = false; // Tracks if player is in range

// Force create the grid
if (ds_exists(inventory, ds_type_grid)) {
    ds_grid_destroy(inventory); // Clean up if already exists
}
inventory = ds_grid_create(grid_width, grid_height);
ds_grid_set_region(inventory, 0, 0, grid_width - 1, grid_height - 1, -1);
show_debug_message("Force initialized container grid: 4x4");

// Collision setup (ensure sprite has a collision mask)
if (sprite_index == -1) {
    sprite_index = spr_container; // Assign a default sprite if none set (define this in your project)
    show_debug_message("Assigned default sprite to obj_container at [" + string(x) + "," + string(y) + "]");
}