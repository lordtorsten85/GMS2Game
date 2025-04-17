// obj_proximity_door - Step Event
trigger = false;

// Only check proximity if the door is not locked
if (!locked) {
    if (point_distance(x, y, obj_player.x, obj_player.y) < trigger_distance) {
        trigger = true;
    }
    if (instance_exists(obj_enemy_parent)) {
        with (obj_enemy_parent) {
            var dist = point_distance(x, y, other.x, other.y);
            if (dist < other.trigger_distance) {
                other.trigger = true;
                break;
            }
        }
    }
}

if (trigger) {
    if (image_index < image_number - 1) {
        image_speed = 1;
    }
    if (image_index >= image_number - 1) {
        image_speed = 0;
        image_index = image_number - 1;
        solid = false; // Allow passage when fully open
        if (locked) { // Only locked doors update grid (though this won't execute if locked)
            mp_grid_clear_rectangle(global.mp_grid, 
                x - sprite_width/2, y - sprite_height/2, 
                x + sprite_width/2, y + sprite_height/2);
            with (obj_enemy_parent) path_end();
        }
    }
} else {
    if (image_index > 0) {
        image_speed = -1;
    }
    if (image_index <= 0) {
        image_speed = 0;
        image_index = 0;
        solid = true; // Block passage when closed
        ////if (locked) { // Only locked doors update grid
        ////    mp_grid_add_rectangle(global.mp_grid, 
        ////        x - sprite_width/2, y - sprite_height/2, 
        ////        x + sprite_width/2, y + sprite_height/2);
        ////    with (obj_enemy_parent) path_end();
        //}
    }
}