// Script: init_items
function initialize_item_data() {
    if (!variable_global_exists("ITEM")) {
        enum ITEM {
            NONE = -1,
            SYRINGE,
            SMALL_GUN,
            BIG_GUN,
            GREEN_KEYCARD,
            OPTICS,
            MOD_OPTICS_IR
        }

        enum ITEM_TYPE {
            GENERIC,
            UTILITY,
            WEAPON,
            MOD
        }
    }

    // [name, width, height, stackable, color, sprite, type, max stack, moddable, mod_width, mod_height, valid_mod_items]
    global.item_data = [];
    global.item_data[ITEM.SYRINGE] = ["Syringe", 1, 1, true, c_green, spr_equipment_proto, ITEM_TYPE.GENERIC, 10, false, 0, 0, []];
    global.item_data[ITEM.SMALL_GUN] = ["Small Gun", 2, 1, false, c_blue, spr_gun_laser, ITEM_TYPE.WEAPON, 1, true, 2, 2, []]; // Add specific mods later
    global.item_data[ITEM.BIG_GUN] = ["Big Gun", 3, 2, false, c_red, spr_gun_proto, ITEM_TYPE.WEAPON, 1, false, 0, 0, []];
    global.item_data[ITEM.GREEN_KEYCARD] = ["Green Keycard", 2, 1, false, c_green, spr_green_keycard, ITEM_TYPE.GENERIC, 1, false, 0, 0, []];
    global.item_data[ITEM.OPTICS] = ["Optics", 1, 2, false, c_green, spr_utility_test, ITEM_TYPE.UTILITY, 1, true, 1, 2, [ITEM.MOD_OPTICS_IR]]; // Only IR Mod
    global.item_data[ITEM.MOD_OPTICS_IR] = ["IR Mod", 1, 1, false, c_red, spr_mod_optics_IR, ITEM_TYPE.MOD, 1, false, 0, 0, []];

    if (!variable_global_exists("mod_inventories")) {
        global.mod_inventories = ds_map_create();
    }

    show_debug_message("Initialized item data and mod_inventories map.");
}