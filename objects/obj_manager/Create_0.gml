// obj_manager - Create Event
// Description: Initializes global manager for pause state, health, ammo, inventory, and enemy alert systems
// Variable Definitions (set in object editor): None (persistent instance, declared here)
// - pause - boolean - Indicates if the game is paused
// - pause_seq - asset - Sequence for pause screen
// - health_max - real - Maximum player health (e.g., 100)
// - health_current - real - Current player health (e.g., 100)
// - ammo_counts - asset (ds_map) - Map of ammo types and counts (e.g., "small_gun" -> 30)
// - ammo_current - real - Current ammo for equipped weapon
// - ammo_max - real - Maximum ammo for equipped weapon
// - enemies_alerted - boolean - Global alert state for all enemies
// - alert_timer - real - Time (in steps) enemies stay alerted after losing player sight

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
    initialize_item_data(); // Fallback
}

// Initialize the inventory grid for the backpack
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

depth = -12510; // Lower depth means it draws later, on top
global.dragging_inventory = -1;

pause = false;
pause_seq = noone;
health_max = 100;
health_current = 100;
ammo_counts = ds_map_create();
ds_map_add(ammo_counts, "small_gun", 30); // Example: 30 rounds for small gun
ds_map_add(ammo_counts, "big_gun", 0);   // Example: 0 rounds for big gun
ammo_current = 0; // Initialize ammo
ammo_max = 0;     // Initialize max ammo

// Enemy alert system
enemies_alerted = false;
alert_timer = 0; // Will count down after player is lost

// Create HUD instance
global.hud = instance_create_layer(0, 0, "GUI", obj_hud);