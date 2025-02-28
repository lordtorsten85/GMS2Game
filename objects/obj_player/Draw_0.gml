// obj_player - draw event

draw_self();

if(move_speed > default_move_speed)
{
	draw_sprite_ext(sprite_index, image_index, xprevious, yprevious, image_xscale * 1.1, image_yscale * 1.1, 0, $FFFFFF & $ffffff, 0.2);
}

// Draw text prompt above the nearest item
if (nearest_item_to_pickup != noone) {
    var item_name = global.item_data[nearest_item_to_pickup.item_id][0];
    var text = "Press 'E' to Pick Up " + item_name;
    var prompt_x = nearest_item_to_pickup.x - string_width(text) / 2; // Center above item
    var prompt_y = nearest_item_to_pickup.y - 20; // 20 pixels above item
    
    draw_set_color(c_black); // Shadow for readability
    draw_text(prompt_x + 1, prompt_y + 1, text);
    draw_set_color(c_white); // Main text
    draw_text(prompt_x, prompt_y, text);
    
    show_debug_message("Prompt displayed: '" + text + "' at [" + string(prompt_x) + "," + string(prompt_y) + "]");
}