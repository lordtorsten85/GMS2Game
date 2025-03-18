// obj_enemy_parent - Room Start Event
// Description: Collects navigation points from obj_nav_point instances with detailed debugging

nav_points = [];
current_nav_index = 0;
var temp_points = ds_map_create();
show_debug_message("Enemy point_owner: " + point_owner); // Log the enemy's point_owner
with (obj_nav_point) {
    var nav_owner = variable_instance_exists(id, "point_owner") ? point_owner : "default";
    var enemy_owner = variable_instance_exists(other.id, "point_owner") ? other.point_owner : "default";
    show_debug_message("Nav point_owner: " + nav_owner + " at (" + string(x) + ", " + string(y) + ")"); // Log each nav point's owner
    if (nav_owner == enemy_owner) {
        ds_map_add(temp_points, point_index, [x, y]);
        show_debug_message("Found nav point for " + nav_owner + " at index " + string(point_index) + ": (" + string(x) + ", " + string(y) + ")");
    }
}
var max_index = ds_map_size(temp_points) - 1;
for (var i = 0; i <= max_index; i++) {
    if (ds_map_exists(temp_points, i)) {
        nav_points[i] = temp_points[? i];
    } else {
        show_debug_message("Missing nav point at index " + string(i) + " for " + point_owner);
    }
}
ds_map_destroy(temp_points);

show_debug_message("Total nav points for " + point_owner + ": " + string(array_length(nav_points)));
if (array_length(nav_points) == 0) {
    show_debug_message("Error: No nav points found for " + point_owner + ". Check Room Editor settings for point_owner match.");
}