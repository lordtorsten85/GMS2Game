// Script: init_items
function initialize_item_data() {
    if (!variable_global_exists("ITEM")) {
        enum ITEM {
            NONE = -1,
            SYRINGE,
            SMALL_GUN,
            BIG_GUN,
            GREEN_KEYCARD,
            RED_KEYCARD,
            OPTICS,
            MOD_OPTICS_IR,
            MOD_WEAPON_TEST,
            MOD_WEAPON_TEST_2,
            SMALL_GUN_AMMO,
            BIG_GUN_AMMO
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
    global.item_data[ITEM.SMALL_GUN] = ["Small Gun", 2, 1, false, c_blue, spr_gun_laser, ITEM_TYPE.WEAPON, 1, true, 2, 2, [ITEM.MOD_WEAPON_TEST, ITEM.MOD_WEAPON_TEST_2]];
    global.item_data[ITEM.BIG_GUN] = ["Big Gun", 3, 2, false, c_red, spr_gun_proto, ITEM_TYPE.WEAPON, 1, false, 0, 0, []];
    global.item_data[ITEM.GREEN_KEYCARD] = ["Green Keycard", 2, 1, false, c_green, spr_green_keycard, ITEM_TYPE.GENERIC, 1, false, 0, 0, []];
    global.item_data[ITEM.RED_KEYCARD] = ["Red Keycard", 2, 1, false, c_red, spr_red_keycard, ITEM_TYPE.GENERIC, 1, false, 0, 0, []];
    global.item_data[ITEM.OPTICS] = ["Optics", 1, 2, false, c_green, spr_utility_test, ITEM_TYPE.UTILITY, 1, true, 1, 2, [ITEM.MOD_OPTICS_IR]];
    global.item_data[ITEM.MOD_OPTICS_IR] = ["IR Mod", 1, 1, false, c_red, spr_mod_optics_IR, ITEM_TYPE.MOD, 1, false, 0, 0, []];
    global.item_data[ITEM.MOD_WEAPON_TEST] = ["Weapon Test Mod", 1, 1, false, c_red, spr_mod_weapon_test, ITEM_TYPE.MOD, 1, false, 0, 0, []];
    global.item_data[ITEM.MOD_WEAPON_TEST_2] = ["Weapon Test Mod 2", 1, 1, false, c_red, spr_mod_weapon_test_2, ITEM_TYPE.MOD, 1, false, 0, 0, []];
    global.item_data[ITEM.SMALL_GUN_AMMO] = ["Small Gun Ammo", 1, 1, true, c_orange, spr_ammo_small, ITEM_TYPE.GENERIC, 10, false, 0, 0, []];
    global.item_data[ITEM.BIG_GUN_AMMO] = ["Big Gun Ammo", 1, 1, true, c_orange, spr_ammo_large, ITEM_TYPE.GENERIC, 5, false, 0, 0, []];

    if (!variable_global_exists("mod_inventories")) {
        global.mod_inventories = ds_map_create();
    }

    if (!variable_global_exists("ammo_to_weapon")) {
        global.ammo_to_weapon = ds_map_create();
        ds_map_add(global.ammo_to_weapon, ITEM.SMALL_GUN_AMMO, ["small_gun", ITEM.SMALL_GUN, 10]); // 10 rounds per magazine
        ds_map_add(global.ammo_to_weapon, ITEM.BIG_GUN_AMMO, ["big_gun", ITEM.BIG_GUN, 5]);      // 5 rounds per magazine
    }

    show_debug_message("Initialized item data, mod_inventories, and ammo_to_weapon map.");
}