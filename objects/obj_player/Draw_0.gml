// obj_player - Draw Event
// Description: Draws the player sprite, equipped weapon, and text prompt above the nearest item if within range

// Draw player sprite
draw_self();

if (move_speed > default_move_speed) {
    draw_sprite_ext(sprite_index, image_index, xprevious, yprevious, image_xscale * 1.1, image_yscale * 1.1, 0, $FFFFFF & $ffffff, 0.2);
}

// Draw equipped weapon
if (instance_exists(global.equipment_slots)) {
    var weapon_slot = global.equipment_slots.inventory[# 1, 0]; // Weapon slot
    if (is_array(weapon_slot) && weapon_slot[0] != -1) {
        var weapon_id = weapon_slot[0];
        var weapon_sprite = global.item_data[weapon_id][5]; // Sprite at index 5
        var offset_x = lengthdir_x(16, input_direction); // Adjust offset based on your sprite
        var offset_y = lengthdir_y(16, input_direction);
        var weapon_sprite_width = sprite_get_width(weapon_sprite); // Width of the weapon sprite
        var weapon_sprite_height = sprite_get_height(weapon_sprite); // Height of the weapon sprite
        
        // Adjust weapon orientation based on facing direction, accounting for top-left origin
        var weapon_xscale = 1;
        var weapon_yscale = 1;
        var weapon_angle = input_direction;
        
        if (input_direction == 180) { // Facing left
            weapon_angle = 0; // Align with right-facing, flipped by xscale
            weapon_xscale = -1; // Flip horizontally for left-facing
            offset_x += weapon_sprite_width; // Shift to account for top-left origin flip
        } else if (input_direction == 0) { // Facing right
            weapon_angle = 0;
            weapon_xscale = 1;
        } else {
            weapon_angle = input_direction; // Up and down use natural rotation
            weapon_yscale = 1;
        }
        
        draw_sprite_ext(weapon_sprite, 0, x + offset_x, y + offset_y, weapon_xscale, weapon_yscale, weapon_angle, c_white, 1);
    }
}

// Draw text prompt above the nearest item
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
}

draw_set_color(c_white); // Reset color