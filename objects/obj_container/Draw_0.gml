// obj_container - Draw Event
// Draws the container sprite in world space with proximity feedback and interaction prompt
// Adds a scaled-down "Press 'E' to Open" above the container when in range and closed, with a black box background

if (sprite_index != -1) {
    draw_sprite(sprite_index, image_index, x, y); // Draw the base sprite once
    if (can_interact) {
        // Draw subtle proximity feedback (optional, adjust or remove)
        draw_set_alpha(0.5);
        draw_set_color(c_white);
        // Optional: draw_circle(x, y, proximity_range / 2, true); // Uncomment if you want a glow
        draw_set_alpha(1.0);

        // Draw interaction prompt (only when container is closed)
        if (!is_open) {
            var text = "Press 'E' to Open"; // Adjust to "E" if preferred
            var scale = 0.7; // 30% smaller (70% of original size)
            var text_width = string_width(text) * scale;
            var text_height = string_height(text) * scale;
            var prompt_x = x - text_width / 2; // Center horizontally above container
            var prompt_y = y - 40; // 40 pixels above container (adjust as needed)

            // Draw black box background (semi-transparent, scaled to fit text)
            draw_set_alpha(0.7); // Slightly transparent for retro feel
            draw_set_color(c_black);
            var box_padding = 4 * scale; // Scale padding with text
            draw_rectangle(prompt_x - box_padding, prompt_y - box_padding, 
                           prompt_x + text_width + box_padding, prompt_y + text_height + box_padding, false);

            // Draw text with shadow for readability, scaled down
            draw_set_alpha(1.0); // Full opacity for text
            draw_set_color(c_black);
            draw_text_transformed(prompt_x + 1, prompt_y + 1, text, scale, scale, 0); // Shadow
            draw_set_color(c_white);
            draw_text_transformed(prompt_x, prompt_y, text, scale, scale, 0); // Main text

            //show_debug_message("Displayed scaled prompt '" + text + "' above " + inventory_type + " at world [" + string(prompt_x) + "," + string(prompt_y) + "] (scale: " + string(scale) + ")");
        }
    }
} else {
    show_debug_message("obj_container at [" + string(x) + "," + string(y) + "] has no sprite assigned");
    draw_text(x, y, "Container");
}