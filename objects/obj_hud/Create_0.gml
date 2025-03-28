// obj_hud - Create Event
// Description: Initializes the HUD for health, ammo, and minimap display
// Variable Definitions (set in object editor): None (declared here)
// - health_current - real - Current player health
// - health_max - real - Maximum player health
// - ammo_current - real - Current ammo for equipped weapon
// - ammo_max - real - Maximum ammo for equipped weapon

health_current = 0;
health_max = 0;
ammo_current = 0;
ammo_max = 0;

// Minimap variables
minimap_width = 180;
minimap_height = 120; // Your tweak
minimap_gui_x = 0; // Will set in Draw GUI
minimap_gui_y = 0;
minimap_scale_x = minimap_width / room_width;
minimap_scale_y = minimap_height / room_height;
minimap_surface = surface_create(minimap_width, minimap_height);

// Track revealed rooms
if (!variable_global_exists("revealed_rooms")) {
    global.revealed_rooms = ds_map_create();
}

// Toggle for showing all enemies
if (!variable_global_exists("show_all_enemies")) {
    global.show_all_enemies = false;
}