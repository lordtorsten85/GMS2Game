// obj_proximity_door create event

event_inherited(); // Inherit from obj_collision_parent

image_speed = 0;
is_opening = false;
trigger_distance = 100;
trigger = false;

// Define unlock function
function unlock() {
    if (locked) {
        locked = false;
        // Clear the grid and update paths for affected enemies
        mp_grid_clear_rectangle(global.mp_grid, 
            x - sprite_width/2, y - sprite_height/2, 
            x + sprite_width/2, y + sprite_height/2);
        with (obj_enemy_parent) {
            // Check if any nav points are within the door's grid rectangle
            var door_left = other.x - other.sprite_width/2;
            var door_right = other.x + other.sprite_width/2;
            var door_top = other.y - other.sprite_height/2;
            var door_bottom = other.y + other.sprite_height/2;
            var affected = false;
            for (var i = 0; i < array_length(patrol_points); i++) {
                var nav_x = patrol_points[i].x;
                var nav_y = patrol_points[i].y;
                if (nav_x >= door_left && nav_x <= door_right && nav_y >= door_top && nav_y <= door_bottom) {
                    affected = true;
                    break;
                }
            }
            if (affected) {
                path_end(); // Force path re-evaluation
                show_debug_message("Enemy " + point_owner + " path ended due to door unlock");
            }
        }
        show_debug_message("Proximity door unlocked; grid cleared at (" + string(x) + "," + string(y) + ")");
    }
};

// Only locked doors block the grid initially
if (locked) {
    solid = true; // For locked doors with keys
    mp_grid_add_rectangle(global.mp_grid, 
        x - sprite_width/2, y - sprite_height/2, 
        x + sprite_width/2, y + sprite_height/2);
    show_debug_message("Proximity door locked; grid blocked at (" + string(x) + "," + string(y) + ")");
} else {
    solid = false; // Unlocked doors don’t need this, but we’ll keep it for compatibility
    mp_grid_clear_rectangle(global.mp_grid, 
        x - sprite_width/2, y - sprite_height/2, 
        x + sprite_width/2, y + sprite_height/2);
    show_debug_message("Proximity door unlocked; grid cleared at (" + string(x) + "," + string(y) + ")");
}