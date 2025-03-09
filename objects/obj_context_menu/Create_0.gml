// obj_context_menu - Create Event
// Description: Initializes the context menu with default properties for inventory interactions.
// Variable Definitions (set in object editor):
// - inventory - asset: Reference to the target inventory instance
// - item_id - real: ID of the selected item
// - slot_x - real: Grid X position of the selected item
// - slot_y - real: Grid Y position of the selected item
// - menu_x - real: GUI X position of the menu
// - menu_y - real: GUI Y position of the menu

options = [];
menu_width = 120;
menu_height = 0; // Set dynamically in Step Event