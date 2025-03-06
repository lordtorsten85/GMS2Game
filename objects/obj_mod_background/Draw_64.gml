// obj_mod_background - Draw GUI Event
// Description: Draws the stretched background frame, item sprite on the left, and an "X" button to close.

// Draw the background frame first
draw_sprite_stretched(spr_inventory_frame, 0, frame_x, frame_y, frame_width, frame_height);
show_debug_message("Drawing mod background frame at [" + string(frame_x) + "," + string(frame_y) + "]");

// Draw the item sprite on top of the frame, scaled
if (item_sprite != -1 && sprite_exists(item_sprite)) {
    var sprite_x = frame_x + 24; // 24px padding from left edge of the frame
    var sprite_y = frame_y + (frame_height - (sprite_get_height(item_sprite) * sprite_scale)) / 2; // Center vertically, account for scaled height
    draw_sprite_ext(item_sprite, 0, sprite_x, sprite_y, sprite_scale, sprite_scale, 0, c_white, 1.0);
    show_debug_message("Drawing item sprite at [" + string(sprite_x) + "," + string(sprite_y) + "] with scale " + string(sprite_scale));
} else {
    show_debug_message("Warning: Failed to draw item sprite - item_sprite is " + string(item_sprite));
}

// Draw the "X" button on top
var close_x = frame_x + frame_width - 32; // Inside frame, 32px from right edge
var close_y = frame_y; // Inside frame, aligned with top edge
var close_size = 32; // Size of the button (32x32)

draw_set_color(c_dkgray); // Dark gray background to match theme
draw_set_alpha(0.8);
draw_rectangle(close_x, close_y, close_x + close_size, close_y + close_size, false);

draw_set_color(c_aqua); // Light blue "X" to match UI
draw_set_alpha(1.0);
draw_line_width(close_x + 8, close_y + 8, close_x + close_size - 8, close_y + close_size - 8, 4); // Diagonal \
draw_line_width(close_x + 8, close_y + close_size - 8, close_x + close_size - 8, close_y + 8, 4); // Diagonal /

draw_set_color(c_white);
draw_set_alpha(1.0);

// Debug: Log the "X" position
show_debug_message("Drawing 'X' at GUI [" + string(close_x) + "," + string(close_y) + "] for mod background at [" + string(inv_gui_x) + "," + string(inv_gui_y) + "]");