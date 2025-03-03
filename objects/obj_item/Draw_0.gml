// obj_item
// Event: Draw
// Description: Draws the item sprite on the ground, displaying stack quantity if greater than 1. Uses cached item_sprite for efficient drawing, handling invalid item_ids (ITEM.NONE, -1) gracefully.
// Variable Definitions:
// - item_id: real (The ID of the item from the ITEM enum)
// - item_sprite: real (The sprite index for the item, or -1 if none)
// - stack_quantity: real (The number of items in the stack)

if (item_sprite != -1 && sprite_exists(item_sprite)) {
    draw_sprite(item_sprite, 0, x, y);
    
    // Draw stack quantity if more than 1
    if (stack_quantity > 1) {
        draw_set_font(-1); // Default font; replace with your retro font if set
        draw_set_color(c_black); // Shadow for readability
        draw_text(x + 2, y - 12, string(stack_quantity)); // 12 pixels above sprite center
        draw_set_color(c_white); // Main text
        draw_text(x, y - 10, string(stack_quantity)); // Slight offset for shadow effect
    }
} else {
    show_debug_message("obj_item at [" + string(x) + "," + string(y) + "] has invalid item_sprite: " + string(item_sprite) + " - not drawing");
}

draw_set_font(-1); // Reset font
draw_set_color(c_white); // Reset color