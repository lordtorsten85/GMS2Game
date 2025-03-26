// obj_enemy_parent - Room Start Event
// Collects nav points and sets up motion planning grid with dynamic collisions.

// Variable Definitions:
// - point_owner (string): Unique identifier matching nav points to this enemy.

// Reset patrol points array
patrol_points = [];
var nav_count = instance_number(obj_nav_point);
for (var i = 0; i < nav_count; i++) {
    var nav = instance_find(obj_nav_point, i);
    if (nav.point_owner == point_owner) {
        array_push(patrol_points, nav);
    }
}

// Sort patrol_points by point_index
array_sort(patrol_points, function(a, b) {
    return a.point_index - b.point_index;
});

// Setup motion planning grid
if (grid != noone) mp_grid_destroy(grid);
grid = mp_grid_create(0, 0, room_width div 32, room_height div 32, 32, 32);

// Add active collisions to grid
var collision_count = instance_number(obj_collision_parent);
for (var i = 0; i < collision_count; i++) {
    var col = instance_find(obj_collision_parent, i);
    var is_active = true;
    if (variable_instance_exists(col, "collision_active")) {
        is_active = col.collision_active;
    }
    if (is_active) {
        var left_cell = col.bbox_left div 32;
        var top_cell = col.bbox_top div 32;
        var right_cell = col.bbox_right div 32;
        var bottom_cell = col.bbox_bottom div 32;
        for (var xx = left_cell; xx <= right_cell; xx++) {
            for (var yy = top_cell; yy <= bottom_cell; yy++) {
                mp_grid_add_cell(grid, xx, yy);
            }
        }
    }
}

// Set initial target
if (array_length(patrol_points) > 0) {
    target_x = patrol_points[current_point].x;
    target_y = patrol_points[current_point].y;
    if (!mp_grid_path(grid, path, x, y, target_x, target_y, true)) {
        target_x = x;
        target_y = y;
        show_debug_message("No initial path for " + point_owner);
    }
} else {
    target_x = x;
    target_y = y;
}