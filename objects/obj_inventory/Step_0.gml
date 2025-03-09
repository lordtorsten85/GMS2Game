// obj_inventory - Step Event
// Description: Minimal logic, just timers
if (!ds_exists(inventory, ds_type_grid)) exit;

if (just_swap_timer > 0) just_swap_timer--;
if (just_split_timer > 0) just_split_timer--;