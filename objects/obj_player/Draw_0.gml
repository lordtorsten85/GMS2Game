// obj_player
// Event: Draw
// Description: Draws the player sprite and text prompt above the nearest item if within range and valid, with safety checks for invalid or missing item instances using ITEM.NONE (-1).
// Variable Definitions:
// - move_speed: real (Movement speed in pixels per frame)
// - default_move_speed: real (Default movement speed)
// - input_direction: real (Initial movement direction)
// - depth: real (Drawing depth)
// - nearest_item_to_pickup: instance (Tracks the nearest obj_item instance)
// - pickup_cooldown: real (Optional cooldown timer)

draw_self();

if (move_speed > default_move_speed) {
    draw_sprite_ext(sprite_index, image_index, xprevious, yprevious, image_xscale * 1.1, image_yscale * 1.1, 0, $FFFFFF & $ffffff, 0.2);
}

// Draw text prompt above the nearest item, with safety check for item_id and instance existence
if (nearest_item_to_pickup != noone && instance_exists(nearest_item_to_pickup)) {
    var item_id = nearest_item_to_pickup.item_id;
    var item_name = (item_id != ITEM.NONE && item_id >= 0 && item_id < array_length(global.item_data)) ? global.item_data[item_id][0] : "No Item";
    var text = "Press 'E' to Pick Up " + item_name;
    var prompt_x = nearest_item_to_pickup.x - string_width(text) / 2; // Center above item
    var prompt_y = nearest_item_to_pickup.y - 20; // 20 pixels above item

    draw_set_color(c_black); // Shadow for readability
    draw_text(prompt_x + 1, prompt_y + 1, text);
    draw_set_color(c_white); // Main text
    draw_text(prompt_x, prompt_y, text);

   // show_debug_message("Prompt displayed: '" + text + "' at [" + string(prompt_x) + "," + string(prompt_y) + "]");
}

draw_set_color(c_white); // Reset color