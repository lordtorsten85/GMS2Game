// Script: scr_update_collision_grid
// Description: Updates the mp_grid for all enemies based on current collision_active states, covering full bounding boxes.
function update_collision_grid() {
    with (obj_enemy_parent) {
        mp_grid_clear_all(grid);
        var collision_count = instance_number(obj_collision_parent);
        for (var i = 0; i < collision_count; i++) {
            var col = instance_find(obj_collision_parent, i);
            var is_active = true; // Default to blocking if collision_active isn’t set
            if (variable_instance_exists(col, "collision_active")) {
                is_active = col.collision_active;
            }
            if (is_active) {
                // Convert bounding box to grid cells
                var left_cell = col.bbox_left div 32;
                var top_cell = col.bbox_top div 32;
                var right_cell = col.bbox_right div 32;
                var bottom_cell = col.bbox_bottom div 32;
                // Mark all cells the instance overlaps
                for (var xx = left_cell; xx <= right_cell; xx++) {
                    for (var yy = top_cell; yy <= bottom_cell; yy++) {
                        mp_grid_add_cell(grid, xx, yy);
                    }
                }
                show_debug_message("Grid updated - Enemy " + point_owner + " added collision at " + string(col.x) + "," + string(col.y) + " - Cells: (" + string(left_cell) + "," + string(top_cell) + ") to (" + string(right_cell) + "," + string(bottom_cell) + ")");
            } else {
                show_debug_message("Grid updated - Enemy " + point_owner + " skipped collision at " + string(col.x) + "," + string(col.y) + " - collision_active is false");
            }
        }
    }
    show_debug_message("Collision grid updated for all enemies");
}