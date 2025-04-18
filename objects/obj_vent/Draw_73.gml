if(distance_to_object(obj_player) < 10)
{
			var text = "'E' - Enter Vent"; // Adjust to "E" if preferred
            var scale = 0.7; // 30% smaller (70% of original size)
            var text_width = string_width(text) * scale;
            var text_height = string_height(text) * scale;
            var prompt_x = x - text_width / 2; // Center horizontally above container
            var prompt_y = y - 40; // 40 pixels above container (adjust as needed)

            // Draw black box background (semi-transparent, scaled to fit text)
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
}