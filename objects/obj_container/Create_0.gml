// obj_container Create Event
event_inherited();
inventory_type = "container";
grid_width = 4;
grid_height = 4;
slot_size = 64;
inv_gui_x = 640;
inv_gui_y = 256;
is_open = false;
image_speed = 0;

// Force create the grid
if (ds_exists(inventory, ds_type_grid)) {
    ds_grid_destroy(inventory); // Clean up if already exists
}
inventory = ds_grid_create(grid_width, grid_height);
ds_grid_set_region(inventory, 0, 0, grid_width - 1, grid_height - 1, -1);
show_debug_message("Force initialized container grid: 4x4");