// obj_player - Animation End Event
// Description: Resets punching state and updates sprite based on movement and crouch state

if (sprite_index == spr_rattler_punch || sprite_index == spr_rattler_punch_up || sprite_index == spr_rattler_punch_down) {
    is_punching = false;
    has_hit = false;
    var h_input = (keyboard_check(vk_right) || keyboard_check(ord("D"))) - (keyboard_check(vk_left) || keyboard_check(ord("A")));
    var v_input = (keyboard_check(vk_down) || keyboard_check(ord("S"))) - (keyboard_check(vk_up) || keyboard_check(ord("W")));
    var moving = (h_input != 0 || v_input != 0);

    if (is_crouching) {
        if (last_direction == 90) {
            sprite_index = moving ? spr_rattler_prone_up_crawl : spr_rattler_prone_up_idle;
            image_xscale = 1;
            image_yscale = 1;
        } else if (last_direction == 270) {
            sprite_index = moving ? spr_rattler_prone_down_crawl : spr_rattler_prone_down_idle;
            image_xscale = 1;
            image_yscale = 1;
        } else {
            sprite_index = moving ? spr_rattler_prone_side_crawl : spr_rattler_prone_side_idle;
            image_xscale = (last_direction == 0) ? 1 : -1;
            last_xscale = image_xscale;
            image_yscale = 1;
        }
        image_speed = moving ? 0.3 : 0.15; // 0.3 for crawling, 0.15 for prone idle
    } else {
        if (h_input != 0 || v_input != 0) {
            if (v_input < 0) {
                sprite_index = spr_rattler_run_up;
                image_xscale = 1;
                image_yscale = 1;
                last_direction = 90;
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
                image_xscale = last_xscale;
                image_yscale = 1;
            }
        }
        image_speed = moving ? 0.4 : 0.2; // 0.4 for walking, 0.2 for walking idle
    }
}