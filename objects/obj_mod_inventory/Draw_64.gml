// obj_mod_inventory - Draw GUI Event
if (!is_open || !ds_exists(inventory, ds_type_grid)) exit;

var gui_mouse_x = device_mouse_x_to_gui(0);
var gui_mouse_y = device_mouse_y_to_gui(0);

// Calculate positions
var backpack_right = global.backpack.inv_gui_x + (global.backpack.grid_width * global.backpack.slot_size); // e.g., 64 + (4 * 64) = 320
var frame_x = backpack_right + 64; // 64px from backpack's right edge, e.g., 384
var frame_y = frame_gui_y; // Align with backpack's top edge
var frame_w = 256 + (grid_width * slot_size) + 32; // Item (128) + gap (32) + grid + gap (32) + X (16) + padding (8)
var frame_h = 192;
var sprite_x = backpack_right + 96;
var sprite_y = frame_y + ((frame_h - 128) / 2); // Center vertically
var grid_x = backpack_right + 288;
var grid_y = frame_y + ((frame_h - (grid_height * slot_size)) / 2); // Center grid vertically
var close_x = grid_x + (grid_width * slot_size) + 48; // 48px right of grid
var close_y = frame_y - 32; // Align with frame top + slight offset
var frame_h_adjusted = max(frame_h, 128); // Ensure frame is at least as tall as the sprite

// Draw big background frame first
draw_sprite_stretched(spr_inventory_frame, 0, frame_x, frame_y, frame_w, frame_h_adjusted);

// Draw modded item sprite with centered positioning
if (item_id >= 0) {
    var item_sprite = global.item_data[item_id][5];
    draw_sprite_stretched(item_sprite, 0, sprite_x, sprite_y, 128, 128);
}

// Rely on inherited obj_inventory Draw GUI for grid drawing
inv_gui_x = grid_x; // Align inherited grid with calculated grid_x
inv_gui_y = grid_y; // Align vertically

// Draw X button
draw_sprite_ext(spr_help_close, 0, close_x, close_y, 0.5, 0.5, 0, c_white, 1); // 16x16
