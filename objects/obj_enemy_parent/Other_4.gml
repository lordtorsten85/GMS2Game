// Object: obj_enemy_parent
// Event: Room Start
// Description: Collects nav points, sets up motion planning grid, and initializes patrol.

patrol_points = []; // Reset array
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
grid = mp_grid_create(0, 0, room_width div 32, room_height div 32, 32, 32); // 32x32 cells, adjust if needed
mp_grid_add_instances(grid, obj_collision_parent, false); // Mark collision objects as obstacles

// Set initial target if points exist
if (array_length(patrol_points) > 0) {
    current_target = patrol_points[0];
    if (mp_grid_path(grid, path, x, y, current_target.x, current_target.y, true)) {
        path_x = path_get_point_x(path, 1); // First point after start
        path_y = path_get_point_y(path, 1);
    } else {
        path_x = x; // Fallback if no path found
        path_y = y;
    }
    patrol_index = 0;
} else {
    current_target = noone; // No points found, stay still
}