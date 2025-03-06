// Script: init_items
// Description: Defines and initializes all item data for the game, including enums and properties, to be called at game startup.

function initialize_item_data() {
    // Define enums (only once, globally)
    if (!variable_global_exists("ITEM")) {
        enum ITEM {
            NONE = -1,
            SYRINGE,
            SMALL_GUN,
            BIG_GUN,
            GREEN_KEYCARD,
            OPTICS
        }

        enum ITEM_TYPE {
            GENERIC,
            UTILITY,
            WEAPON
        }
    }

    // Initialize item data array with properties: [name, width, height, stackable, color, sprite, type, max stack, moddable, mod_inventory_width, mod_inventory_height]
    global.item_data = [];
    global.item_data[ITEM.SYRINGE] = ["Syringe", 1, 1, true, c_green, spr_equipment_proto, ITEM_TYPE.GENERIC, 10, false, 0, 0];
    global.item_data[ITEM.SMALL_GUN] = ["Small Gun", 2, 1, false, c_blue, spr_gun_laser, ITEM_TYPE.WEAPON, 1, true, 2, 2]; // Moddable, 2x2 mod inventory
    global.item_data[ITEM.BIG_GUN] = ["Big Gun", 3, 2, false, c_red, spr_gun_proto, ITEM_TYPE.WEAPON, 1, false, 0, 0];
    global.item_data[ITEM.GREEN_KEYCARD] = ["Green Keycard", 2, 1, false, c_green, spr_green_keycard, ITEM_TYPE.GENERIC, 1, false, 0, 0];
    global.item_data[ITEM.OPTICS] = ["Optics", 1, 2, false, c_green, spr_utility_test, ITEM_TYPE.UTILITY, 1, true, 1, 2]; // Moddable, 1x2 mod inventory
    show_debug_message("Initialized item data. Syringe type: " + string(global.item_data[ITEM.SYRINGE][6]));
}