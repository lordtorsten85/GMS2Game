// Object: obj_enemy_parent
// Event: Clean Up
// Description: Frees resources when instance is destroyed.

path_delete(path);
if (grid != noone) mp_grid_destroy(grid);