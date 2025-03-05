// obj_equipment_slots
// Event: Create
// Description: Sets up equipment slots HUD, inheriting from obj_inventory with type-specific slots.
// Variable Definitions:
// - Inherited from obj_inventory
// - slot_types: array (Type requirements per slot)
// - spacing: real (Pixel gap between slots)

event_inherited();

if (!ds_exists(inventory, ds_type_grid)) {
    inventory = ds_grid_create(grid_width, grid_height);
    ds_grid_clear(inventory, -1);
    show_debug_message("Initialized equipment_slots grid: " + string(grid_width) + "x" + string(grid_height));
}

just_split_timer = 0;
show_debug_message("Equipment slots at GUI [" + string(inv_gui_x) + "," + string(inv_gui_y) + "] with types: " + string(slot_types) + ", spacing: " + string(spacing));