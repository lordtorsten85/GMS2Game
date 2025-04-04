/// obj_trigger_gate - Step
if (state == "opening") {
    if (image_index >= image_number - 1) {
        image_speed = 0;
        image_index = image_number - 1;
        collision_active = false; // Allow passage when open
        state = "open";
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
        collision_active = true; // Block passage when closed
        state = "closed";
        if (locked) { // Only locked gates update grid
            mp_grid_add_rectangle(global.mp_grid, 
                x - sprite_width/2, y - sprite_height/2, 
                x + sprite_width/2, y + sprite_height/2);
            with (obj_enemy_parent) path_end();
        }
    }
}