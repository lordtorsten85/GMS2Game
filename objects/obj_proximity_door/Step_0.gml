// obj_proximity_door - Step Event
trigger = false;

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

if (trigger) {
    if (image_index < image_number - 1) {
        image_speed = 1;
    }
    if (image_index >= image_number - 1) {
        image_speed = 0;
        image_index = image_number - 1;
        if (locked && collision_active) { // Only locked doors update grid
            collision_active = false;
            mp_grid_clear_rectangle(global.mp_grid, 
                x - sprite_width/2, y - sprite_height/2, 
                x + sprite_width/2, y + sprite_height/2);
            with (obj_enemy_parent) path_end();
        }
    }
} else {
    if (image_index > 0) {
        if (locked && !collision_active) { // Only locked doors update grid
            collision_active = true;
            mp_grid_add_rectangle(global.mp_grid, 
                x - sprite_width/2, y - sprite_height/2, 
                x + sprite_width/2, y + sprite_height/2);
            with (obj_enemy_parent) path_end();
        }
        image_speed = -1;
    }
    if (image_index <= 0) {
        image_speed = 0;
        image_index = 0;
    }
}