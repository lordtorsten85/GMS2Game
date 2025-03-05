// obj_inventory - Create Event
// Initialize inventory properties, using values passed at creation or setting defaults if not provided
// Variable definitions are used in the GameMaker 2 object editor to set variables when using instance_create_layer()
// Variable definitions:
// inventory_type - string
// grid_width - real
// grid_height - real
// slot_size - real
// inv_gui_x - real
// inv_gui_y - real
// dragging - real
// drag_offset_x - real
// drag_offset_y - real
// original_grid - real
// original_mx - real
// original_my - real
// is_open - boolean
// inventory - asset (ds_grid)

// Set defaults for any missing variables
if (!variable_instance_exists(id, "inventory_type")) inventory_type = "generic"; // e.g., "backpack", "container"
if (!variable_instance_exists(id, "grid_width")) grid_width = 4;              // Number of slots wide
if (!variable_instance_exists(id, "grid_height")) grid_height = 4;            // Number of slots tall
if (!variable_instance_exists(id, "slot_size")) slot_size = 64;               // Pixel size of each slot
if (!variable_instance_exists(id, "inv_gui_x")) inv_gui_x = 0;                // GUI X position
if (!variable_instance_exists(id, "inv_gui_y")) inv_gui_y = 0;                // GUI Y position
if (!variable_instance_exists(id, "is_open")) is_open = false;                // Whether the inventory UI is visible

// Initialize inventory grid
if (!variable_instance_exists(id, "inventory")) {
    inventory = ds_grid_create(grid_width, grid_height); // Create grid with specified size
    ds_grid_set_region(inventory, 0, 0, grid_width - 1, grid_height - 1, -1); // Initialize with -1 (empty)
    show_debug_message("Initialized " + inventory_type + " grid: " + string(grid_width) + "x" + string(grid_height));
}

// Drag-and-drop variables
if (!variable_instance_exists(id, "dragging")) dragging = -1;                // Array of [item_id, placement_id, qty] or -1 if not dragging
if (!variable_instance_exists(id, "drag_offset_x")) drag_offset_x = 0;      // Offset for dragging in GUI X
if (!variable_instance_exists(id, "drag_offset_y")) drag_offset_y = 0;      // Offset for dragging in GUI Y
if (!variable_instance_exists(id, "original_mx")) original_mx = -1;          // Original mouse X grid position
if (!variable_instance_exists(id, "original_my")) original_my = -1;          // Original mouse Y grid position
if (!variable_instance_exists(id, "original_grid")) original_grid = -1;      // Reference to the original inventory grid
if (!variable_instance_exists(id, "just_split")) just_split = false;         // Flag to skip drop logic after a split
if (!variable_instance_exists(id, "just_split_timer")) just_split_timer = 0; // Timer for split delay (60 frames = 1 second)
if (!variable_instance_exists(id, "just_swap_timer")) just_swap_timer = 0;   // Timer for swap delay (60 frames = 1 second)
