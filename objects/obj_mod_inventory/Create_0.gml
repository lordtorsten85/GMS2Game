// obj_mod_inventory - Create Event
// Description: Initializes the mod inventory with dynamic grid size based on parent item, loads existing mods, and aligns UI with backpack
// Variable Definitions (set in object editor):
// - inventory_type - string - e.g., "mod_Optics"
// - grid_width - real - Width of mod grid (overridden by item data)
// - grid_height - real - Height of mod grid (overridden by item data)
// - slot_size - real - Size of each slot in pixels
// - inv_gui_x - real - X position on GUI layer
// - inv_gui_y - real - Y position on GUI layer
// - dragging - real - ID of item being dragged (-1 if none)
// - drag_offset_x - real - X offset for dragging
// - drag_offset_y - real - Y offset for dragging
// - original_grid - real - Grid where item was dragged from
// - original_mx - real - X slot where drag started
// - original_my - real - Y slot where drag started
// - is_open - boolean - Is inventory visible?
// - inventory - asset (ds_grid) - The mod inventory grid
// - just_split_timer - real - Cooldown for splitting stacks
// - parent_inventory - asset - Reference to parent inventory (e.g., equipment_slots)
// - item_id - real - ID of the parent item (e.g., ITEM.OPTICS)
// - parent_slot_x - real - X position in parent inventory
// - parent_slot_y - real - Y position in parent inventory

event_inherited();

if (!variable_instance_exists(id, "inventory_type")) inventory_type = "mod_default";
if (!variable_instance_exists(id, "grid_width")) grid_width = 2;
if (!variable_instance_exists(id, "grid_height")) grid_height = 2;
if (!variable_instance_exists(id, "slot_size")) slot_size = 32;
if (!variable_instance_exists(id, "inv_gui_x")) inv_gui_x = 0;
if (!variable_instance_exists(id, "inv_gui_y")) inv_gui_y = 0;
if (!variable_instance_exists(id, "is_open")) is_open = false;
if (!variable_instance_exists(id, "inventory")) inventory = -1;
if (!variable_instance_exists(id, "item_id")) item_id = -1;
if (!variable_instance_exists(id, "parent_inventory")) parent_inventory = noone;
if (!variable_instance_exists(id, "parent_slot_x")) parent_slot_x = 0;
if (!variable_instance_exists(id, "parent_slot_y")) parent_slot_y = 0;

grid_width = global.item_data[item_id][9];
grid_height = global.item_data[item_id][10];
inventory = ds_grid_create(grid_width, grid_height);
ds_grid_clear(inventory, -1);

// Load existing mods
if (ds_map_exists(global.mod_inventories, parent_inventory.inventory[# parent_slot_x, parent_slot_y][1])) {
    var mod_grid = global.mod_inventories[? parent_inventory.inventory[# parent_slot_x, parent_slot_y][1]];
    ds_grid_copy(inventory, mod_grid);
}

// Adjust inv_gui_y to align background sprite tops with backpack
backpack_background_top = global.backpack.inv_gui_y; // Top of backpack's spr_inventory_frame
mod_background_offset = 24; // Top offset of mod's spr_inventory_frame (from Draw GUI or Step Event)
frame_gui_y = backpack_background_top - mod_background_offset; // Align tops directly
