// obj_console - Create Event
// Description: Initializes the console inventory and sets up trigger linkage
// Variable Definitions (set in object editor):
// - inventory_type - string - "console"
// - grid_width - real - Number of slots wide
// - grid_height - real - Number of slots tall
// - slot_size - real - Size of each slot in pixels
// - inv_gui_x - real - X position on GUI layer
// - inv_gui_y - real - Y position on GUI layer
// - dragging - real - ID of item being dragged (-1 if none)
// - drag_offset_x - real - X offset for dragging
// - drag_offset_y - real - Y offset for dragging
// - original_grid - real - Grid where item was dragged from
// - original_mx - real - X slot where drag started
// - original_my - real - Y slot where drag started
// - is_open - boolean - Is inventory visible?
// - inventory - asset (ds_grid) - The inventory grid
// - just_split_timer - real - Cooldown for splitting stacks
// - parent_inventory - asset - Parent inventory reference (unused here)
// - target_tag - string - Tag of the object to trigger (e.g., "gate_1")
// - required_items - array - Items needed to activate (e.g., [[ITEM.GREEN_KEYCARD, 1]])

event_inherited(); // Inherit from obj_inventory

// Protect variable definitions (set defaults if not in object editor)
if (!variable_instance_exists(id, "inventory_type")) inventory_type = "console";
if (!variable_instance_exists(id, "grid_width")) grid_width = 2;
if (!variable_instance_exists(id, "grid_height")) grid_height = 1;
if (!variable_instance_exists(id, "slot_size")) slot_size = 64;
if (!variable_instance_exists(id, "inv_gui_x")) inv_gui_x = 256;
if (!variable_instance_exists(id, "inv_gui_y")) inv_gui_y = 256;
if (!variable_instance_exists(id, "dragging")) dragging = -1;
if (!variable_instance_exists(id, "drag_offset_x")) drag_offset_x = 0;
if (!variable_instance_exists(id, "drag_offset_y")) drag_offset_y = 0;
if (!variable_instance_exists(id, "original_grid")) original_grid = -1;
if (!variable_instance_exists(id, "original_mx")) original_mx = -1;
if (!variable_instance_exists(id, "original_my")) original_my = -1;
if (!variable_instance_exists(id, "is_open")) is_open = false;
if (!variable_instance_exists(id, "just_split_timer")) just_split_timer = 0;
if (!variable_instance_exists(id, "parent_inventory")) parent_inventory = -1;
if (!variable_instance_exists(id, "target_tag")) target_tag = "gate_1";
if (!variable_instance_exists(id, "required_items")) required_items = [[ITEM.GREEN_KEYCARD, 1]];

// Ensure inventory is a valid ds_grid
if (!ds_exists(inventory, ds_type_grid)) {
    inventory = ds_grid_create(grid_width, grid_height);
    ds_grid_clear(inventory, -1);
}

// Additional variable for interaction
can_interact = false;