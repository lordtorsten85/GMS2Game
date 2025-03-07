// obj_mod_background - Draw GUI Event
// Description: Draws the mod background frame, item sprite, and close button ("X") matching the inventory theme.
// Variable Definitions:
// - frame_x: real (GUI X position of the frame)
// - frame_y: real (GUI Y position of the frame)
// - frame_width: real (Width of the frame in pixels)
// - frame_height: real (Height of the frame in pixels)
// - parent_item_id: real (ID of the item being modded)
// - mod_inventory: instance (Reference to the mod inventory instance)

var padding = 16;
var outer_padding = 64;
var sprite_area_size = mod_inventory.slot_size * 2; // Dynamic: 2 slots wide/tall

// Draw the frame
draw_sprite_stretched(spr_inventory_frame, 0, frame_x, frame_y, frame_width, frame_height);
show_debug_message("Drawing mod background frame at [" + string(frame_x) + "," + string(frame_y) + "] with size [" + string(frame_width) + "," + string(frame_height) + "]");

// Draw item sprite with consistent scaling (top-left anchor)
if (parent_item_id != ITEM.NONE) {
    var sprite = global.item_data[parent_item_id][5];
    var spr_width = sprite_get_width(sprite);
    var spr_height = sprite_get_height(sprite);
    var max_scale = min(sprite_area_size / spr_width, sprite_area_size / spr_height); // Fit within sprite area
    var scale = min(2.0, max_scale); // Allow slight upscale
    var sprite_x = frame_x + outer_padding; // Top-left anchor at start of sprite area
    var sprite_y = frame_y + outer_padding + ((frame_height - (outer_padding * 2) - (spr_height * scale)) / 2); // Center vertically
    draw_sprite_ext(sprite, 0, sprite_x, sprite_y, scale, scale, 0, c_white, 1);
    show_debug_message("Drawing item sprite at [" + string(sprite_x) + "," + string(sprite_y) + "] with scale " + string(scale));
}

// Draw close button ("X") as a larger, darker cyan box
var close_x = frame_x + frame_width - padding; // Push to right edge with padding
var close_y = frame_y + padding; // Align with top padding
var close_size = 48; // Increase size for visibility
var dark_cyan = make_color_rgb(0, 128, 128); // Darker cyan, same hue as c_aqua
draw_set_color(dark_cyan);
draw_rectangle(close_x, close_y, close_x + close_size, close_y + close_size, false);
draw_set_color(c_white);
draw_text(close_x + 12, close_y + 12, "X"); // Adjust text position for larger box
show_debug_message("Drawing 'X' clickable area at GUI [" + string(close_x) + "," + string(close_y) + "] to [" + string(close_x + close_size) + "," + string(close_y + close_size) + "]");
draw_set_color(c_white);