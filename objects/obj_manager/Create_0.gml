// obj_manager - Create Event
global.backpack = instance_create_layer(0, 0, "GUI", obj_inventory, 
    {
        inventory_type: "backpack",
        grid_width: 4,
        grid_height: 4,
        slot_size: 64,
        inv_gui_x: 64,
        inv_gui_y: 256,
        dragging: -1,
        drag_offset_x: 0,
        drag_offset_y: 0,
        original_grid: -1,
        original_mx: 0,
        original_my: 0,
        is_open: false
    }
);

if (variable_global_exists("item_data") && is_array(global.item_data)) {
    show_debug_message("obj_manager confirms Syringe type: " + string(global.item_data[ITEM.SYRINGE][6]));
} else {
    show_debug_message("Error: item_data not initialized by obj_manager startup");
    initialize_item_data(); // Fallback, initializes ammo_types too
}

with (global.backpack) {
    inventory = ds_grid_create(grid_width, grid_height);
    ds_grid_clear(inventory, -1);
    show_debug_message("Initialized backpack inventory grid: " + string(grid_width) + "x" + string(grid_height));
}

global.equipment_slots = instance_create_layer(0, 0, "GUI", obj_equipment_slots, 
    {
        inventory_type: "equipment_slots",
        grid_width: 2,
        grid_height: 1,
        slot_size: 64,
        inv_gui_x: display_get_gui_width() - 128 - 400,
        inv_gui_y: display_get_gui_height() - 64 - 24,
        dragging: -1,
        drag_offset_x: 0,
        drag_offset_y: 0,
        original_grid: -1,
        original_mx: 0,
        original_my: 0,
        is_open: true,
        slot_types: [ITEM_TYPE.UTILITY, ITEM_TYPE.WEAPON],
        spacing: 64
    }
);

depth = -12610;
global.dragging_inventory = -1;

pause = false;
pause_seq = noone;
health_max = 100;
health_current = 100;

ammo_counts = ds_map_create();
ds_map_add(ammo_counts, "small_gun", 0); // Must be 0
ds_map_add(ammo_counts, "big_gun", 0);
ammo_current = 0;
ammo_max = 0; // Not used

enemies_alerted = false;
global.alert_timer = 0;
global.search_timer = 0;

global.hud = instance_create_layer(0, 0, "GUI", obj_hud);
global.equipment = array_create(2, -1);
global.current_room_tag = "none";

//Initialize utility variables
if (!variable_global_exists("optics_enabled")) global.optics_enabled = false;
if (!variable_global_exists("optics_ir_enabled")) global.optics_ir_enabled = false;