// obj_item - Draw Event
// Draws the item sprite in world space at its position.
// Uses debug text as a fallback if no sprite is assigned (remove after testing).

if (item_sprite != -1) {
    draw_sprite(item_sprite, 0, x, y); // Draw sprite at world position
} else {
    draw_text(x, y, "Item " + string(item_id) + " at " + string(x) + "," + string(y)); // Debug text if no sprite
}