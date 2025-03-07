// Script: scr_inventory_functions
// Description: Contains utility functions for inventory management, including adding, removing, and checking item placement.

// Function: inventory_add_item
// Description: Adds an item to an inventory, merging with existing stacks if possible, with an optional drop-on-ground fallback.
// Parameters: inv_instance (target inventory), item_id, qty, drop_on_ground (boolean)
function inventory_add_item(inv_instance, item_id, qty, drop_on_ground = false) {
    if (!instance_exists(inv_instance) || !ds_exists(inv_instance.inventory, ds_type_grid)) {
        show_debug_message("Error: Invalid inventory instance in inventory_add_item");
        return false;
    }
    if (item_id < 0 || item_id >= array_length(global.item_data)) {
        show_debug_message("Error: Invalid item_id " + string(item_id) + " in inventory_add_item");
        return false;
    }

    var item_width = global.item_data[item_id][1];
    var item_height = global.item_data[item_id][2];
    var is_stackable = global.item_data[item_id][3];
    var max_stack = global.item_data[item_id][7];
    var item_name = global.item_data[item_id][0];

    // Merge with existing stacks
    if (is_stackable) {
        for (var i = 0; i < inv_instance.grid_width; i++) {
            for (var j = 0; j < inv_instance.grid_height; j++) {
                var slot = inv_instance.inventory[# i, j];
                if (slot != -1 && is_array(slot) && slot[0] == item_id && slot[2] < max_stack) {
                    var add_qty = min(qty, max_stack - slot[2]);
                    slot[2] += add_qty;
                    qty -= add_qty;
                    show_debug_message("Merged " + string(add_qty) + " " + item_name + " at [" + string(i) + "," + string(j) + "]");
                    if (qty <= 0) return true;
                }
            }
        }
    }

    // Place new stack
    if (qty > 0) {
        var found_spot = false;
        for (var i = 0; i <= inv_instance.grid_width - item_width; i++) {
            for (var j = 0; j <= inv_instance.grid_height - item_height; j++) {
                if (can_place_item(inv_instance.inventory, i, j, item_width, item_height)) {
                    inventory_add_at(i, j, item_id, qty, inv_instance.inventory);
                    show_debug_message("Placed " + string(qty) + " " + item_name + " at [" + string(i) + "," + string(j) + "]");
                    return true;
                }
            }
        }
        if (!found_spot) {
            var grid_str = "";
            for (var j = 0; j < inv_instance.grid_height; j++) {
                for (var i = 0; i < inv_instance.grid_width; i++) {
                    var slot = inv_instance.inventory[# i, j];
                    grid_str += (slot == -1 ? "." : "X") + " ";
                }
                grid_str += "\n";
            }
            show_debug_message("No space for " + string(qty) + " " + item_name + " (" + string(item_width) + "x" + string(item_height) + ") in " + inv_instance.inventory_type + ":\n" + grid_str);
        }
        if (drop_on_ground && instance_exists(obj_player)) {
            var world_x = obj_player.x + irandom_range(-8, 8);
            var world_y = obj_player.y + irandom_range(-8, 8);
            instance_create_layer(world_x, world_y, "Instances", obj_item, { item_id: item_id, stack_quantity: qty });
            show_debug_message("Dropped " + string(qty) + " " + item_name + " on ground at [" + string(world_x) + "," + string(world_y) + "]");
            return true;
        }
        show_debug_message("No space for " + string(qty) + " " + item_name + " in " + inv_instance.inventory_type);
        return false;
    }
    return true;
}

// Function: inventory_add (Restored for compatibility)
// Description: Legacy function to add an item to an inventory instance’s grid, merging with stacks if stackable.
// Parameters: inv_instance, item_id, qty
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
    var is_stackable = global.item_data[item_id][3];
    var max_stack = global.item_data[item_id][7];
    var item_name = global.item_data[item_id][0];

    // Merge with existing stacks
    if (is_stackable) {
        for (var i = 0; i < inv_instance.grid_width; i++) {
            for (var j = 0; j < inv_instance.grid_height; j++) {
                var slot = inv_instance.inventory[# i, j];
                if (slot != -1 && is_array(slot) && slot[0] == item_id) {
                    var current_qty = slot[2];
                    if (current_qty < max_stack) {
                        var space_left = max_stack - current_qty;
                        var add_qty = min(qty, space_left);
                        slot[2] = current_qty + add_qty;
                        qty -= add_qty;
                        show_debug_message("Merged " + string(add_qty) + " " + item_name + " into stack at [" + string(i) + "," + string(j) + "], now " + string(slot[2]) + "/" + string(max_stack));
                        if (qty <= 0) return true;
                    }
                }
            }
        }
    }

    // Find a new spot for remaining items
    if (qty > 0) {
        for (var i = 0; i <= inv_instance.grid_width - item_width; i++) {
            for (var j = 0; j <= inv_instance.grid_height - item_height; j++) {
                if (can_place_item(inv_instance.inventory, i, j, item_width, item_height)) {
                    inventory_add_at(i, j, item_id, qty, inv_instance.inventory);
                    show_debug_message("Placed new stack of " + string(qty) + " " + item_name + " at [" + string(i) + "," + string(j) + "] in " + inv_instance.inventory_type);
                    return true;
                }
            }
        }
        show_debug_message("No space for " + string(qty) + " " + item_name + " in " + inv_instance.inventory_type);
    }
    return false;
}

// Function: inventory_add_at
// Description: Adds an item to a specific position in the grid, merging stacks if applicable, and initializes an empty contained_items array.
// Parameters: x, y, item_id, qty, grid
function inventory_add_at(x, y, item_id, qty, grid) {
    if (!ds_exists(grid, ds_type_grid)) return;
    if (item_id < 0 || item_id >= array_length(global.item_data)) return;

    var item_width = global.item_data[item_id][1];
    var item_height = global.item_data[item_id][2];
    var is_stackable = global.item_data[item_id][3];
    var max_stack = global.item_data[item_id][7];
    var item_name = global.item_data[item_id][0];
    var placement_id = irandom(10000);

    // Check if the target spot has the same stackable item
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

    // Initialize contained_items as an empty array
    var contained_items = [];

    // Place a new stack or overwrite with 4-element array
    for (var i = x; i < x + item_width; i++) {
        for (var j = y; j < y + item_height; j++) {
            grid[# i, j] = [item_id, placement_id, qty, contained_items];
        }
    }
    show_debug_message("Placed " + string(qty) + " " + item_name + " at [" + string(x) + "," + string(y) + "] with placement_id " + string(placement_id) + ", contained_items initialized empty");
}

// Function: inventory_remove
// Description: Removes an item from the specified grid position, clearing all occupied cells for multicell items
function inventory_remove(mx, my, grid) {
    if (!ds_exists(grid, ds_type_grid)) {
        show_debug_message("Error: Attempted to remove item from invalid grid");
        return;
    }
    var slot = grid[# mx, my];
    if (slot != -1 && is_array(slot)) {
        var item_id = slot[0];
        var placement_id = slot[1];
        var item_name = global.item_data[item_id][0];
        var width = global.item_data[item_id][1];
        var height = global.item_data[item_id][2];

        show_debug_message("Removing " + item_name + " (ID: " + string(item_id) + ", Placement ID: " + string(placement_id) + ") from [" + string(mx) + "," + string(my) + "] - Size: " + string(width) + "x" + string(height));

        for (var i = mx; i < mx + width; i++) {
            for (var j = my; j < my + height; j++) {
                if (i < ds_grid_width(grid) && j < ds_grid_height(grid)) {
                    grid[# i, j] = -1;
                }
            }
        }
        show_debug_message("Cleared " + item_name + " from grid at [" + string(mx) + "," + string(my) + "] to [" + string(mx + width - 1) + "," + string(my + height - 1) + "]");
    } else {
        show_debug_message("No valid item to remove at [" + string(mx) + "," + string(my) + "]");
    }
}

// Function: inventory_expand
// Description: Expands the inventory grid of the specified instance to new dimensions, preserving existing items.
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

// Function: can_place_item
// Description: Checks if an item can be placed at the given grid position.
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

// Function: inventory_can_fit (Restored for completeness)
// Description: Checks if an item can fit in the specified grid position based on its dimensions.
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