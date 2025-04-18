// obj_player animation end event

if (sprite_index == spr_rattler_punch || sprite_index == spr_rattler_punch_up || sprite_index == spr_rattler_punch_down) {
    show_debug_message("Punch animation ended, resetting is_punching");
    is_punching = false;
    has_hit = false; // Reset has_hit for next punch
    image_speed = 1; // Restore for movement sprites
    // Recompute sprite based on current input
    var h_input = (keyboard_check(vk_right) || keyboard_check(ord("D"))) - (keyboard_check(vk_left) || keyboard_check(ord("A")));
    var v_input = (keyboard_check(vk_down) || keyboard_check(ord("S"))) - (keyboard_check(vk_up) || keyboard_check(ord("W")));

    if (h_input != 0 || v_input != 0) {
        // Prioritize vertical movement for sprite (including diagonals)
        if (v_input < 0) {
            sprite_index = spr_rattler_run_up;
            image_xscale = 1;
            image_yscale = 1;
            last_direction = 90; // Update last direction
        } else if (v_input > 0) {
            sprite_index = spr_rattler_run_down;
            image_xscale = 1;
            image_yscale = 1;
            last_direction = 270;
        } else if (h_input != 0) {
            sprite_index = spr_rattler_walk;
            image_xscale = (h_input > 0) ? 1 : -1;
            last_xscale = image_xscale;
            last_direction = (h_input > 0) ? 0 : 180;
            image_yscale = 1;
        }
    } else {
        // Select idle sprite based on last_direction
        if (last_direction == 90) {
            sprite_index = spr_rattler_idle_up;
            image_xscale = 1;
            image_yscale = 1;
        } else if (last_direction == 270) {
            sprite_index = spr_rattler_idle_down;
            image_xscale = 1;
            image_yscale = 1;
        } else {
            sprite_index = spr_rattler_idle;
            image_xscale = last_xscale; // Maintain last facing direction for left/right
            image_yscale = 1;
        }
    }
}