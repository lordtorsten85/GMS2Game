// obj_mod_inventory - Create Event
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
// Verify: inv_gui_y should be global.backpack.inv_gui_y - 34 if offsets are -42 and -8