// Define item enums and data
enum ITEM {
    NONE = -1,
    SYRINGE,
    SMALL_GUN,
    BIG_GUN
}

enum ITEM_TYPE {
    GENERIC,
    UTILITY,
    WEAPON
}

// Initialize global.item_data if not already set
if (!variable_global_exists("item_data") || !is_array(global.item_data)) {
    global.item_data = [];
}

// Define item properties: [name, width, height, stackable, color, sprite, type]
global.item_data[ITEM.SYRINGE] = ["Syringe", 1, 1, true, c_green, spr_equipment_proto, ITEM_TYPE.UTILITY];
global.item_data[ITEM.SMALL_GUN] = ["Small Gun", 2, 1, false, c_blue, spr_gun_laser, ITEM_TYPE.WEAPON];
global.item_data[ITEM.BIG_GUN] = ["Big Gun", 3, 2, false, c_red, spr_gun_proto, ITEM_TYPE.WEAPON];