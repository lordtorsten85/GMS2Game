// obj_context_menu
// Event: Create
// Description: Initializes a context menu instance for right-clicked inventory items, reading the item and inventory details from variable definitions to set options. Handles Green Keycard (generic, non-stackable, multi-cell) and adds Split Stack for stackable items. Note: inventory, item_id, slot_x, slot_y, menu_x, and menu_y are defined in the object editor and set via instance_create_layer. Depth is set to ensure visibility above other GUI elements.
// Variable Definitions:
// - inventory: instance (The obj_inventory instance the menu is attached to, defined in object editor with default noone)
// - item_id: real (The ID of the clicked item from the ITEM enum, defined in object editor with default -1)
// - slot_x: real (X position of the clicked slot in the inventory grid, defined in object editor with default -1)
// - slot_y: real (Y position of the clicked slot in the inventory grid, defined in object editor with default -1)
// - menu_x: real (GUI X position of the menu, defined in object editor with default 0)
// - menu_y: real (GUI Y position of the menu, defined in object editor with default 0)
// - menu_width: real (Width of the menu in pixels, default 100)
// - menu_height: real (Height of the menu in pixels, default 90 for up to 3 options)
// - options: array (Array of option strings, e.g., ["Drop", "Split Stack", "Take"])

menu_width = 100;
menu_height = 90; // Increased to accommodate up to 3 options (Drop, Split Stack, Take)
options = [];

if (inventory != noone && ds_exists(inventory.inventory, ds_type_grid) && item_id != ITEM.NONE && item_id >= 0 && item_id < array_length(global.item_data)) {
    var item_type = global.item_data[item_id][6]; // Get item type (e.g., ITEM_TYPE.GENERIC)
    var is_stackable = global.item_data[item_id][3]; // Check if stackable
    var qty = 0;
    var slot = inventory.inventory[# slot_x, slot_y];
    if (slot != -1 && is_array(slot)) {
        qty = slot[2]; // Get the stack quantity
    }

    if (item_type == ITEM_TYPE.GENERIC) {
        if (inventory.inventory_type == "backpack") {
            if (is_stackable && qty > 1) {
                options = ["Drop", "Split Stack"]; // Add Split Stack for stackable items with qty > 1
            } else {
                options = ["Drop"]; // Non-stackable or single-stack items
            }
        } else if (inventory.inventory_type == "container") {
            if (is_stackable && qty > 1) {
                options = ["Take"]; // For now, only Take the full stack (can expand later)
            } else {
                options = ["Take"]; // Non-stackable or single-stack items
            }
        }
    }
}

show_debug_message("Created context menu for " + (inventory.inventory_type != "" ? inventory.inventory_type : "unknown") + " with Item ID: " + string(item_id) + " at slot [" + string(slot_x) + "," + string(slot_y) + "] at GUI [" + string(menu_x) + "," + string(menu_y) + "]");