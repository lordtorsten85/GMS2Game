// obj_item - Create Event
// Initializes an item instance on the ground with its item ID and sprite.
// Uses item_id from Room Editor or instance creation, defaults to ITEM.NONE if not set.

// Ensure item_id is defined; use ITEM.NONE (-1) if not set
if (!variable_instance_exists(id, "item_id")) {
    item_id = ITEM.NONE;
}

// Set sprite based on item_id from global.item_data
item_sprite = (item_id != ITEM.NONE) ? global.item_data[item_id][5] : -1;
show_debug_message("Created obj_item with item_id " + string(item_id) + ", item_sprite " + string(item_sprite));