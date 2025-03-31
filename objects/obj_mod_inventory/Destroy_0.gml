// obj_mod_inventory - Destroy Event
// Description: Cleans up mod inventory and updates parent item on close
if (variable_instance_exists(id, "on_close")) {
    on_close();
}
if (ds_exists(inventory, ds_type_grid)) {
    ds_grid_destroy(inventory);
}
show_debug_message("Destroyed mod inventory for " + inventory_type);