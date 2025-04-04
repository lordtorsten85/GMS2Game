// obj_enemy_parent - Room Start Event
patrol_points = [];
var nav_count = instance_number(obj_nav_point);
for (var i = 0; i < nav_count; i++) {
    var nav = instance_find(obj_nav_point, i);
    if (nav.point_owner == point_owner) {
        array_push(patrol_points, nav);
    }
}

array_sort(patrol_points, function(a, b) {
    return a.point_index - b.point_index;
});

grid = global.mp_grid; // Use the shared grid

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