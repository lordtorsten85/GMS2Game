// obj_mod_inventory - Create Event
// Description: Initializes a mod inventory tied to a specific item, inheriting from obj_inventory, and loads contained items into the grid.
// Variable Definitions (set via instance_create_layer):
// - parent_item_id: real (ID of the item being modded)
// - parent_inventory: instance (The inventory instance holding the item)
// - parent_slot_x: real (X slot of the item in the parent inventory)
// - parent_slot_y: real (Y slot of the item in the parent inventory, 0 for equipment slots)
// - inv_gui_x: real (Set by obj_mod_background)
// - inv_gui_y: real (Set by obj_mod_background)
// - Inherited from obj_inventory: inventory_type, grid_width, grid_height, slot_size, inv_gui_x, inv_gui_y, etc.

event_inherited();

inventory_type = "mod_inventory";

// Set by instance_create_layer, default if missing
if (!variable_instance_exists(id, "parent_item_id")) parent_item_id = ITEM.NONE;
if (!variable_instance_exists(id, "parent_inventory")) parent_inventory = noone;
if (!variable_instance_exists(id, "parent_slot_x")) parent_slot_x = -1;
if (!variable_instance_exists(id, "parent_slot_y")) parent_slot_y = -1;

// Override grid size based on the parent item's mod inventory dimensions
if (parent_item_id != ITEM.NONE) {
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
}

// Load contained items from the parent item's slot into the grid
if (instance_exists(parent_inventory) && ds_exists(parent_inventory.inventory, ds_type_grid)) {
    var slot = parent_inventory.inventory[# parent_slot_x, parent_slot_y];
    show_debug_message("Loading from slot [" + string(parent_slot_x) + "," + string(parent_slot_y) + "]: " + string(slot));
    if (is_array(slot) && array_length(slot) >= 4 && is_array(slot[3])) {
        var contained_items = slot[3];
        var index = 0;
        for (var i = 0; i < grid_width && index < array_length(contained_items); i++) {
            for (var j = 0; j < grid_height && index < array_length(contained_items); j++) {
                var item = contained_items[index];
                if (is_array(item)) { // Expecting [item_id, qty]
                    inventory[# i, j] = [item[0], irandom(10000), item[1]]; // New placement_id for UI
                    index++;
                }
            }
        }
        show_debug_message("Loaded " + string(index) + " contained items into mod inventory for " + global.item_data[parent_item_id][0] + " from " + parent_inventory.inventory_type + " slot [" + string(parent_slot_x) + "," + string(parent_slot_y) + "] - Contents: " + string(contained_items));
    } else {
        ds_grid_set_region(inventory, 0, 0, grid_width - 1, grid_height - 1, -1);
        show_debug_message("No contained items or invalid slot for " + global.item_data[parent_item_id][0] + " at " + parent_inventory.inventory_type + " slot [" + string(parent_slot_x) + "," + string(parent_slot_y) + "]");
    }
} else {
    ds_grid_set_region(inventory, 0, 0, grid_width - 1, grid_height - 1, -1);
    show_debug_message("No valid parent inventory or slot, initialized mod inventory empty");
}

is_open = true;