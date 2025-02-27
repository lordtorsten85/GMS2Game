// scr_inventory_functions
// Checks if an item can fit in the specified grid position based on its dimensions.
// Returns true if the space is empty and within bounds, false otherwise.

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

// Adds an item to the inventory instance's grid at the first available position.
// Returns true if successful, false if no space is available.

function inventory_add(inv_instance, item_id, qty) {
    if (!instance_exists(inv_instance) || !ds_exists(inv_instance.inventory, ds_type_grid)) {
        show_debug_message("Error: Invalid inventory instance in inventory_add");
        return false;
    }
    if (item_id < 0 || item_id >= array_length(global.item_data)) {
        show_debug_message("Error: Invalid item_id " + string(item_id) + " in inventory_add");
        return false;
    }

    var item_width = global.item_data[item_id][1];
    var item_height = global.item_data[item_id][2];

    for (var i = 0; i <= inv_instance.grid_width - item_width; i++) {
        for (var j = 0; j <= inv_instance.grid_height - item_height; j++) {
            if (can_place_item(inv_instance.inventory, i, j, item_width, item_height)) {
                inventory_add_at(i, j, item_id, qty, inv_instance.inventory);
                show_debug_message("Placed " + global.item_data[item_id][0] + " at [" + string(i) + "," + string(j) + "] (Size: " + string(item_width) + "x" + string(item_height) + ") in " + inv_instance.inventory_type);
                return true;
            }
        }
    }
    show_debug_message("No space for " + global.item_data[item_id][0] + " in " + inv_instance.inventory_type);
    return false;
}

// Adds an item to a specific position in the grid.
// Uses a placement_id for multi-cell items.

function inventory_add_at(x, y, item_id, qty, grid) {
    if (!ds_exists(grid, ds_type_grid)) return;
    if (item_id < 0 || item_id >= array_length(global.item_data)) return;

    var item_width = global.item_data[item_id][1];
    var item_height = global.item_data[item_id][2];
    var placement_id = irandom(10000);

    for (var i = x; i < x + item_width; i++) {
        for (var j = y; j < y + item_height; j++) {
            grid[# i, j] = [item_id, placement_id, qty];
        }
    }
}
// Removes an item from the specified grid position, clearing all occupied cells.

function inventory_remove(mx, my, grid) {
    if (!ds_exists(grid, ds_type_grid)) return;
    var slot = grid[# mx, my];
    if (slot != -1 && is_array(slot)) {
        var item_id = slot[0];
        var width = global.item_data[item_id][1];
        var height = global.item_data[item_id][2];
        for (var i = mx; i < mx + width; i++) {
            for (var j = my; j < my + height; j++) {
                grid[# i, j] = -1;
            }
        }
    }
}

// Expands the inventory grid of the specified instance to new dimensions, preserving existing items.

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

// Checks if an item can be placed at the given grid position.
// Returns true if the space is empty and within bounds, false otherwise.

function can_place_item(grid, x, y, w, h) {
    if (x + w > ds_grid_width(grid) || y + h > ds_grid_height(grid)) return false;
    for (var i = x; i < x + w; i++) {
        for (var j = y; j < y + h; j++) {
            if (grid[# i, j] != -1) return false;
        }
    }
    return true;
}