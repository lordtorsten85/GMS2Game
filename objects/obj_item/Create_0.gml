// obj_item - Create Event
if (!variable_instance_exists(id, "item_id")) item_id = ITEM.NONE;
if (!variable_instance_exists(id, "stack_quantity")) stack_quantity = 1;
if (!variable_instance_exists(id, "contained_items")) contained_items = [];
if (!variable_instance_exists(id, "placement_id")) placement_id = -1;
if (!variable_instance_exists(id, "is_in_world")) is_in_world = true;

if (item_id != ITEM.NONE && item_id >= 0 && item_id < array_length(global.item_data)) {
    sprite_index = global.item_data[item_id][5]; // Sprite at index 5
    image_xscale = 1;
    image_yscale = 1;
    
    // Only check moddable items if item_id is valid
    if (global.item_data[item_id][8] && placement_id != -1 && ds_map_exists(global.mod_inventories, placement_id)) {
        var mod_grid = global.mod_inventories[? placement_id];
        if (ds_exists(mod_grid, ds_type_grid) && array_length(contained_items) == 0) {
            contained_items = ds_grid_to_array(mod_grid);
            show_debug_message("Fallback: Set contained_items from mod grid for " + global.item_data[item_id][0] + " to: " + string(contained_items));
        }
    }
    show_debug_message("Created item " + global.item_data[item_id][0] + " at [" + string(x) + "," + string(y) + "] with contained_items: " + string(contained_items));
} else {
    sprite_index = -1;
    show_debug_message("Warning: Created item with invalid item_id: " + string(item_id));
}