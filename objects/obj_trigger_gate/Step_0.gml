/// obj_trigger_gate - Step
if (state == "opening") {
    if (image_index >= image_number - 1) {
        image_speed = 0;
        image_index = image_number - 1;
        state = "open";
        solid = false; // Allow passage when fully open
        if (locked) { // Only locked gates update grid
            mp_grid_clear_rectangle(global.mp_grid, 
                x - sprite_width/2, y - sprite_height/2, 
                x + sprite_width/2, y + sprite_height/2);
            with (obj_enemy_parent) path_end();
        }
    }
} else if (state == "closing") {
    if (image_index <= 0) {
        image_speed = 0;
        image_index = 0;
        state = "closed";
        solid = true; // Block passage when closed
        if (locked) { // Only locked gates update grid
            mp_grid_add_rectangle(global.mp_grid, 
                x - sprite_width/2, y - sprite_height/2, 
                x + sprite_width/2, y + sprite_height/2);
            with (obj_enemy_parent) path_end();
        }
    }
}