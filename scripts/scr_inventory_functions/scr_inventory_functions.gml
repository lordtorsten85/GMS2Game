// Script: scr_inventory_functions
function inventory_add_item(inventory_instance, item_id, qty, respect_max_stack, contained_items = undefined) {
    if (!instance_exists(inventory_instance) || !ds_exists(inventory_instance.inventory, ds_type_grid)) {
        show_debug_message("Error: Invalid inventory instance in inventory_add_item");
        return false;
    }
    if (item_id < 0 || item_id >= array_length(global.item_data)) {
        show_debug_message("Error: Invalid item_id " + string(item_id));
        return false;
    }

    var item_width = global.item_data[item_id][1];
    var item_height = global.item_data[item_id][2];
    var is_stackable = global.item_data[item_id][3];
    var max_stack = global.item_data[item_id][7];
    var contained = (contained_items != undefined && is_array(contained_items)) ? contained_items : [];

    var rounds_per_magazine = ds_map_exists(global.ammo_to_weapon, item_id) ? global.ammo_to_weapon[? item_id][2] : 1;
    var max_rounds = max_stack * rounds_per_magazine; // e.g., 10 * 10 = 100 for Small Gun Ammo

    show_debug_message("Adding " + string(qty) + " rounds of " + global.item_data[item_id][0] + " with max_rounds " + string(max_rounds));

    if (is_stackable && respect_max_stack) {
        for (var i = 0; i < inventory_instance.grid_width; i++) {
            for (var j = 0; j < inventory_instance.grid_height; j++) {
                var slot = inventory_instance.inventory[# i, j];
                if (slot != -1 && is_array(slot) && slot[0] == item_id) {
                    var current_qty = slot[2];
                    if (current_qty < max_rounds) {
                        var space_left = max_rounds - current_qty;
                        var qty_to_add = min(qty, space_left);
                        slot[2] = current_qty + qty_to_add;
                        inventory_instance.inventory[# i, j] = slot;
                        qty -= qty_to_add;
                        show_debug_message("Merged " + string(qty_to_add) + " rounds of " + global.item_data[item_id][0] + " at [" + string(i) + "," + string(j) + "]");
                        if (qty <= 0) return true;
                    }
                }
            }
        }
    }

    for (var i = 0; i <= inventory_instance.grid_width - item_width; i++) {
        for (var j = 0; j <= inventory_instance.grid_height - item_height; j++) {
            if (inventory_can_fit(i, j, item_width, item_height, inventory_instance.inventory)) {
                inventory_add_at(i, j, item_id, qty, inventory_instance.inventory, contained);
                return true;
            }
        }
    }
    show_debug_message("No space for " + string(qty) + " " + global.item_data[item_id][0] + " in " + inventory_instance.inventory_type);
    return false;
}

function inventory_add_at(x, y, item_id, qty, grid, contained_items = undefined) {
    if (!ds_exists(grid, ds_type_grid)) return;
    if (item_id < 0 || item_id >= array_length(global.item_data)) return;

    var item_width = global.item_data[item_id][1];
    var item_height = global.item_data[item_id][2];
    var is_stackable = global.item_data[item_id][3];
    var max_stack = global.item_data[item_id][7];
    var item_name = global.item_data[item_id][0];
    var placement_id = irandom(10000);
    var is_moddable = global.item_data[item_id][8];

    var slot = grid[# x, y];
    if (is_stackable && slot != -1 && is_array(slot) && slot[0] == item_id) {
        var current_qty = slot[2];
        if (current_qty < max_stack) {
            var add_qty = min(qty, max_stack - current_qty);
            slot[2] = current_qty + add_qty;
            show_debug_message("Merged " + string(add_qty) + " " + item_name + " into stack at [" + string(x) + "," + string(y) + "], now " + string(slot[2]) + "/" + string(max_stack));
            return;
        }
    }

    var contained = (contained_items != undefined && is_array(contained_items)) ? contained_items : [];

    for (var i = x; i < x + item_width; i++) {
        for (var j = y; j < y + item_height; j++) {
            grid[# i, j] = [item_id, placement_id, qty, contained];
        }
    }

    if (is_moddable) {
        var mod_width = global.item_data[item_id][9];
        var mod_height = global.item_data[item_id][10];
        var mod_grid = ds_grid_create(mod_width, mod_height);
        if (array_length(contained) > 0) {
            array_to_ds_grid(contained, mod_grid);
            show_debug_message("Restored mod grid for " + item_name + " at [" + string(x) + "," + string(y) + "] with contained_items: " + string(contained));
        } else {
            ds_grid_clear(mod_grid, -1);
            show_debug_message("Created empty mod grid for " + item_name + " with placement_id " + string(placement_id));
        }
        global.mod_inventories[? placement_id] = mod_grid;
    }

    show_debug_message("Placed " + string(qty) + " " + item_name + " at [" + string(x) + "," + string(y) + "] with placement_id " + string(placement_id) + ", contained_items: " + string(contained));
}

function inventory_remove(x, y, grid) {
    if (!ds_exists(grid, ds_type_grid)) return;
    var slot = grid[# x, y];
    if (slot == -1 || !is_array(slot)) return;
    var item_id = slot[0];
    var width = global.item_data[item_id][1];
    var height = global.item_data[item_id][2];
    for (var i = x; i < x + width; i++) {
        for (var j = y; j < y + height; j++) {
            grid[# i, j] = -1;
        }
    }
    show_debug_message("Removed item from [" + string(x) + "," + string(y) + "]");
}

function inventory_expand(inv_instance, new_width, new_height) {
    if (!instance_exists(inv_instance) || !ds_exists(inv_instance.inventory, ds_type_grid)) {
        show_debug_message("Error: Invalid inventory instance in inventory_expand");
        return false;
    }
    if (new_width <= 0 || new_height <= 0) {
        show_debug_message("Invalid dimensions for inventory expansion: " + string(new_width) + "x" + string(new_height));
        return false;
    }

    var old_grid = inv_instance.inventory;
    inv_instance.inventory = ds_grid_create(new_width, new_height);
    ds_grid_clear(inv_instance.inventory, -1);

    var min_width = min(ds_grid_width(old_grid), new_width);
    var min_height = min(ds_grid_height(old_grid), new_height);
    for (var i = 0; i < min_width; i++) {
        for (var j = 0; j < min_height; j++) {
            var slot = ds_grid_get(old_grid, i, j);
            if (slot != -1 && is_array(slot)) {
                ds_grid_set(inv_instance.inventory, i, j, slot);
            }
        }
    }

    inv_instance.grid_width = new_width;
    inv_instance.grid_height = new_height;
    ds_grid_destroy(old_grid);
    show_debug_message("Expanded inventory to " + string(new_width) + "x" + string(new_height) + " for " + inv_instance.inventory_type);
    return true;
}

function can_place_item(grid, x, y, w, h) {
    if (x + w > ds_grid_width(grid) || y + h > ds_grid_height(grid)) return false;
    for (var i = x; i < x + w; i++) {
        for (var j = y; j < y + h; j++) {
            if (grid[# i, j] != -1) return false;
        }
    }
    return true;
}

function inventory_can_fit(mx, my, width, height, grid) {
    if (!ds_exists(grid, ds_type_grid)) {
        show_debug_message("Error: Invalid grid in inventory_can_fit");
        return false;
    }
    if (mx < 0 || my < 0 || mx + width - 1 >= ds_grid_width(grid) || my + height - 1 >= ds_grid_height(grid)) return false;
    for (var i = mx; i < mx + width; i++) {
        for (var j = my; j < my + height; j++) {
            if (ds_grid_get(grid, i, j) != -1) return false;
        }
    }
    return true;
}

function ds_grid_to_array(grid) {
    var w = ds_grid_width(grid);
    var h = ds_grid_height(grid);
    var arr = [];
    for (var i = 0; i < w; i++) {
        for (var j = 0; j < h; j++) {
            var value = grid[# i, j];
            if (value != -1 && is_array(value)) {
                array_push(arr, [value[0], i, j, value[2]]);
            }
        }
    }
    return arr;
}

function array_to_ds_grid(arr, grid) {
    var w = ds_grid_width(grid);
    var h = ds_grid_height(grid);
    
    if (array_length(arr) == 0) {
        ds_grid_clear(grid, -1);
        show_debug_message("Warning: array_to_ds_grid received an empty array, grid cleared.");
        return;
    }
    
    ds_grid_clear(grid, -1);
    for (var i = 0; i < array_length(arr); i++) {
        var mod_data = arr[i];
        if (is_array(mod_data) && array_length(mod_data) >= 4) {
            var item_id = mod_data[0];
            var mx = mod_data[1];
            var my = mod_data[2];
            var qty = mod_data[3];
            if (mx >= 0 && mx < w && my >= 0 && my < h) {
                grid[# mx, my] = [item_id, irandom(10000), qty, []];
            }
        }
    }
}