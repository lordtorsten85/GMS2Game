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

// Set grid size from item data
grid_width = global.item_data[item_id][9];
grid_height = global.item_data[item_id][10];
inventory = ds_grid_create(grid_width, grid_height);
ds_grid_clear(inventory, -1);