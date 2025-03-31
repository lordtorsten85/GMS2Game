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
				mp_grid_add_instances(grid, col, false );
                //show_debug_message("Grid updated - Enemy " + point_owner + " added collision at " + string(col.x) + "," + string(col.y) + " - Cells: (" + string(left_cell) + "," + string(top_cell) + ") to (" + string(right_cell) + "," + string(bottom_cell) + ")");
            } else {
                //show_debug_message("Grid updated - Enemy " + point_owner + " skipped collision at " + string(col.x) + "," + string(col.y) + " - collision_active is false");
            }
        }
    }
    //show_debug_message("Collision grid updated for all enemies");
}

function find_nearest_free_cell(grid, target_x, target_y) {
    var cell_x = floor(target_x / 32);
    var cell_y = floor(target_y / 32);
    if (mp_grid_get_cell(grid, cell_x, cell_y) == 0) { // 0 means free
        return {x: cell_x * 32 + 16, y: cell_y * 32 + 16};
    }
    for (var r = 1; r <= 5; r++) {
        for (var i = -r; i <= r; i++) {
            for (var j = -r; j <= r; j++) {
                var test_x = cell_x + i;
                var test_y = cell_y + j;
                if (test_x >= 0 && test_x < room_width / 32 && test_y >= 0 && test_y < room_height / 32) {
                    if (mp_grid_get_cell(grid, test_x, test_y) == 0) {
                        return {x: test_x * 32 + 16, y: test_y * 32 + 16};
                    }
                }
            }
        }
    }
    return {x: target_x, y: target_y}; // Fallback
}