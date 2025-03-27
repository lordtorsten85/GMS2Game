// obj_minimap - Create Event
// Initializes the minimap surface and revealed areas.

// Minimap size (pixels)
map_width = 200;
map_height = 150;

// Position in GUI (top-right)
map_gui_x = display_get_gui_width() - map_width - 10;
map_gui_y = 10;

// Scale factors (room size to minimap size)
scale_x = map_width / room_width;
scale_y = map_height / room_height;

// Create surface for minimap
map_surface = surface_create(map_width, map_height);

// Store this instance’s ID for scope
obj_minimap_id = id;

// Track revealed rooms
if (!variable_global_exists("revealed_rooms")) {
    global.revealed_rooms = ds_map_create();
}