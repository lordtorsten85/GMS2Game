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

menu_width = 128;
menu_height = 0; // Will be set based on options
options = [];

if (inventory.inventory_type == "backpack") {
    var item_type = global.item_data[item_id][6];
    if (item_type == ITEM_TYPE.GENERIC) {
        options = ["Drop", "Split Stack"];
    } else if (item_type == ITEM_TYPE.UTILITY || item_type == ITEM_TYPE.WEAPON) {
        options = ["Equip", "Drop", "Mod"];
    }
} else if (inventory.inventory_type == "equipment_slots") { // Updated from "equipment"
    options = ["Unequip", "Drop", "Mod"];
} else if (inventory.inventory_type == "container") {
    options = ["Take"];
}

menu_height = array_length(options) * 30; // 30px per option
// Clamp menu position to stay within GUI viewport
var gui_width = display_get_gui_width();
var gui_height = display_get_gui_height();
menu_x = clamp(menu_x, 0, gui_width - menu_width);
menu_y = clamp(menu_y, 0, gui_height - menu_height);

show_debug_message("Created context menu for " + inventory.inventory_type + " with Item ID: " + string(item_id) + " at slot [" + string(slot_x) + "," + string(slot_y) + "] at GUI [" + string(menu_x) + "," + string(menu_y) + "] with options: " + string(options));