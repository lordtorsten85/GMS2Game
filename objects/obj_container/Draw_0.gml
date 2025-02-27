// obj_container - Draw Event
// Draws the container sprite in world space at its position.
// Uses debug text as a fallback if no sprite is assigned (remove after testing).

if (sprite_index != -1) {
    draw_sprite(sprite_index, image_index, x, y);
} else {
    show_debug_message("obj_container at [" + string(x) + "," + string(y) + "] has no sprite assigned");
    draw_text(x, y, "Container");
}