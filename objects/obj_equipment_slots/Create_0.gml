// obj_console - Create Event
// Initializes the console inventory and sets up event triggering state.

// Call the parent (obj_inventory) Create Event to initialize inherited variables
event_inherited();

// Protect console-specific variable definitions (set defaults if not defined in the Object Editor)
if (!variable_instance_exists(id, "inventory_type")) inventory_type = "console";
if (!variable_instance_exists(id, "required_items")) required_items = [ [ITEM.GREEN_KEYCARD, 1] ];
if (!variable_instance_exists(id, "target_tag")) target_tag = "";
if (!variable_instance_exists(id, "reversible")) reversible = true;

// Console-specific state
is_activated = false; // Tracks whether the event has been triggered

// Ensure inherited variables are safe (optional, as event_inherited() should handle this)
if (!ds_exists(inventory, ds_type_grid)) {
    inventory = ds_grid_create(grid_width, grid_height);
    ds_grid_clear(inventory, -1);
}