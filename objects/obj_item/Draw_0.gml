// obj_item - Draw Event
// Description: Draws the item only when it’s physically in the world.

if (is_in_world && sprite_index != -1 && sprite_exists(sprite_index)) {
    draw_self();
	    // Draw stack quantity if more than 1
    if (stack_quantity > 1) {
        draw_set_font(-1); // Default font; replace with your retro font if set
        draw_set_color(c_black); // Shadow for readability
        draw_text(x + 2, y - 12, string(stack_quantity)); // 12 pixels above sprite center
        draw_set_color(c_white); // Main text
        draw_text(x, y - 10, string(stack_quantity)); // Slight offset for shadow effect
    }
} else if (!is_in_world) {
    // Skip drawing if picked up or dragged from inventory
} else {
    show_debug_message("Warning: No valid sprite to draw for item " + string(item_id));
}