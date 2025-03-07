// obj_mod_background - Create Event
// Description: Initializes the mod background and spawns the associated mod inventory.
// Variable Definitions (set via instance_create_layer):
// - parent_item_id: real (ID of the item being modded)
// - parent_inventory: instance (The inventory instance holding the item)
// - parent_slot_x: real (X slot of the item in the parent inventory)
// - parent_slot_y: real (Y slot of the item in the parent inventory)

var padding = 16; // Inner padding between elements
var outer_padding = 64; // Outer padding from backpack and edges

var backpack_right = global.backpack.inv_gui_x + (global.backpack.grid_width * global.backpack.slot_size) + (padding * 2);
frame_x = backpack_right + outer_padding; // Start outer_padding right of backpack
frame_y = global.backpack.inv_gui_y; // Align top with backpack

// Sprite area should scale with slot_size (e.g., 2x2 slots)
var sprite_area_size = global.backpack.slot_size * 2; // Dynamic: 2 slots wide/tall

// Spawn the mod inventory, passing positioning info
mod_inventory = instance_create_layer(0, 0, "GUI", obj_mod_inventory, {
    parent_item_id: parent_item_id,
    parent_inventory: parent_inventory,
    parent_slot_x: parent_slot_x,
    parent_slot_y: parent_slot_y,
    slot_size: global.backpack.slot_size, // Use same slot size as backpack
    dragging: -1,
    drag_offset_x: 0,
    drag_offset_y: 0,
    original_grid: -1,
    original_mx: 0,
    original_my: 0,
    is_open: true,
    inv_gui_x: frame_x + outer_padding + sprite_area_size + padding, // Outer padding + sprite area + padding
    inv_gui_y: frame_y + outer_padding // Outer padding from top
});
show_debug_message("Spawned mod inventory for " + global.item_data[parent_item_id][0] + " with size " + string(global.item_data[parent_item_id][9]) + "x" + string(global.item_data[parent_item_id][10]) + " at GUI [" + string(mod_inventory.inv_gui_x) + "," + string(mod_inventory.inv_gui_y) + "]");

// Calculate frame dimensions dynamically
var mod_inv_width = mod_inventory.grid_width * mod_inventory.slot_size;
var mod_inv_height = mod_inventory.grid_height * mod_inventory.slot_size;
var mod_inv_right = mod_inventory.inv_gui_x + mod_inv_width;
frame_width = (mod_inv_right + padding + 32 + padding) - frame_x; // Mod inventory right + padding + "X" + padding - frame_x
frame_height = max(sprite_area_size, mod_inv_height) + (outer_padding * 2); // Max of sprite area or mod inventory + top/bottom padding