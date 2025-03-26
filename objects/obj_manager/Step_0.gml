// obj_manager - Step Event
// Description: Manages global input, dragging, inventory closure, ammo updates, and enemy alert timer.
// Variable Definitions (set in Create event):
// - pause (boolean): Indicates if the game is paused
// - pause_seq (asset): Sequence for pause screen
// - health_max (real): Maximum player health
// - health_current (real): Current player health
// - ammo_counts (asset - ds_map): Map of ammo types and counts
// - ammo_current (real): Current ammo for equipped weapon
// - ammo_max (real): Maximum ammo for equipped weapon

if (global.mouse_input_delay > 0) {
    global.mouse_input_delay--;
    exit; // Block ALL input (including context menu) until delay clears
}

// Handle dragging start - Delayed to prevent immediate re-drag
if (mouse_check_button_pressed(mb_left) && global.mouse_input_delay <= 0 && !instance_exists(obj_context_menu)) {
    with (obj_inventory) {
        if (is_open && dragging == -1 && global.dragging_inventory == -1 && just_swap_timer == 0) {
            start_inventory_drag(id);
        }
    }
}

// Handle dragging release
if (mouse_check_button_released(mb_left) && global.dragging_inventory != -1 && global.mouse_input_delay <= 0) {
    var dragging_inv = global.dragging_inventory;
    var gui_mouse_x = device_mouse_x_to_gui(0);
    var gui_mouse_y = device_mouse_y_to_gui(0);
    var item_x = gui_mouse_x + dragging_inv.drag_offset_x;
    var item_y = gui_mouse_y + dragging_inv.drag_offset_y;
    var item_id = dragging_inv.dragging[0];
    var placement_id = dragging_inv.dragging[1];
    var qty = dragging_inv.dragging[2];
    var contained_items = (is_array(dragging_inv.dragging) && array_length(dragging_inv.dragging) > 3 && dragging_inv.dragging[3] != undefined) ? dragging_inv.dragging[3] : [];
    var item_width = global.item_data[item_id][1];
    var item_height = global.item_data[item_id][2];
    var max_stack = global.item_data[item_id][7];
    var is_moddable = global.item_data[item_id][8];
    var mod_grid_to_transfer = (is_moddable && ds_map_exists(global.mod_inventories, placement_id)) ? global.mod_inventories[? placement_id] : -1;

    show_debug_message("Before drop - Dragging: " + string(dragging_inv.dragging) + ", Contained items: " + string(contained_items));

    if (is_moddable && ds_exists(mod_grid_to_transfer, ds_type_grid) && array_length(contained_items) == 0) {
        contained_items = ds_grid_to_array(mod_grid_to_transfer);
        show_debug_message("Mod grid found for " + string(placement_id) + ", Updated contained_items: " + string(contained_items));
    } else if (is_moddable && array_length(contained_items) > 0) {
        show_debug_message("Fallback: Set contained_items from mod grid for " + global.item_data[item_id][0] + " to: " + string(contained_items));
    }

    var bounds_width = (dragging_inv.inventory_type == "equipment_slots") ? (dragging_inv.grid_width * dragging_inv.slot_size + (dragging_inv.grid_width - 1) * dragging_inv.spacing) : (dragging_inv.grid_width * dragging_inv.slot_size);
    if (point_in_rectangle(gui_mouse_x, gui_mouse_y, dragging_inv.inv_gui_x, dragging_inv.inv_gui_y, dragging_inv.inv_gui_x + bounds_width, dragging_inv.inv_gui_y + (dragging_inv.grid_height * dragging_inv.slot_size))) {
        var target_x = (dragging_inv.inventory_type == "equipment_slots") ? floor((gui_mouse_x - dragging_inv.inv_gui_x) / (dragging_inv.slot_size + dragging_inv.spacing)) : floor((item_x - dragging_inv.inv_gui_x) / dragging_inv.slot_size);
        var target_y = floor((item_y - dragging_inv.inv_gui_y) / dragging_inv.slot_size);

        if (dragging_inv.inventory_type != "equipment_slots") {
            var x_offset = (item_x - dragging_inv.inv_gui_x) % dragging_inv.slot_size;
            var y_offset = (item_y - dragging_inv.inv_gui_y) % dragging_inv.slot_size;
            if (x_offset > dragging_inv.slot_size * 0.75 && target_x + item_width < dragging_inv.grid_width) target_x += 1;
            if (y_offset > dragging_inv.slot_size * 0.75 && target_y + item_height < dragging_inv.grid_height) target_y += 1;
            target_x = clamp(target_x, 0, dragging_inv.grid_width - item_width);
            target_y = clamp(target_y, 0, dragging_inv.grid_height - item_height);
        } else {
            target_y = 0; // Force y to 0 for equipment slots (1D grid)
            target_x = clamp(target_x, 0, dragging_inv.grid_width - 1);
        }

        show_debug_message("Mouse GUI: [" + string(gui_mouse_x) + "," + string(gui_mouse_y) + "], Item: [" + string(item_x) + "," + string(item_y) + "], Target: [" + string(target_x) + "," + string(target_y) + "] in " + dragging_inv.inventory_type);

        if (target_x >= 0 && target_x < dragging_inv.grid_width && target_y >= 0 && target_y < dragging_inv.grid_height) {
            var target_slot = dragging_inv.inventory[# target_x, target_y];
            var can_drop = (dragging_inv.inventory_type == "equipment_slots") ? (global.item_data[item_id][6] == dragging_inv.slot_types[target_x] && target_slot == -1) : inventory_can_fit(target_x, target_y, item_width, item_height, dragging_inv.inventory);

            // Check if target slot is part of a matching stack (multi-cell aware)
            var merge_slot = -1;
            var merge_x = -1;
            var merge_y = -1;
            if (target_slot != -1 && is_array(target_slot) && target_slot[0] == item_id && global.item_data[item_id][3]) {
                var check_placement_id = target_slot[1];
                merge_x = target_x;
                merge_y = target_y;
                while (merge_x > 0 && is_array(dragging_inv.inventory[# merge_x - 1, merge_y]) && dragging_inv.inventory[# merge_x - 1, merge_y][1] == check_placement_id) merge_x -= 1;
                while (merge_y > 0 && is_array(dragging_inv.inventory[# merge_x, merge_y - 1]) && dragging_inv.inventory[# merge_x, merge_y - 1][1] == check_placement_id) merge_y -= 1;
                merge_slot = dragging_inv.inventory[# merge_x, merge_y];
            }

            if (merge_slot != -1 && is_array(merge_slot) && merge_slot[0] == item_id && target_x >= merge_x && target_x < merge_x + item_width && target_y >= merge_y && target_y < merge_y + item_height) {
                // Merge onto exact stack
                var current_qty = merge_slot[2];
                var space_left = max_stack - current_qty;
                if (space_left > 0 && qty > 0) {
                    var qty_to_add = min(qty, space_left);
                    merge_slot[2] = current_qty + qty_to_add;
                    for (var w = 0; w < item_width; w++) {
                        for (var h = 0; h < item_height; h++) {
                            dragging_inv.inventory[# merge_x + w, merge_y + h] = merge_slot;
                        }
                    }
                    qty -= qty_to_add;
                    if (qty > 0) {
                        dragging_inv.dragging[2] = qty;
                        show_debug_message("Merged " + string(qty_to_add) + " " + global.item_data[item_id][0] + " at [" + string(merge_x) + "," + string(merge_y) + "], " + string(qty) + " remain");
                    } else {
                        dragging_inv.dragging = -1;
                        global.dragging_inventory = -1;
                        show_debug_message("Merged " + string(qty_to_add) + " " + global.item_data[item_id][0] + " at [" + string(merge_x) + "," + string(merge_y) + "] fully");
                    }
                    global.mouse_input_delay = 15; // Restore delay to prevent immediate drop
                }
            } else if (can_drop) {
                // Place item at target slot
                dragging_inv.inventory[# target_x, target_y] = [item_id, placement_id, qty, contained_items];
                if (dragging_inv.inventory_type != "equipment_slots") {
                    for (var w = 0; w < item_width; w++) {
                        for (var h = 0; h < item_height; h++) {
                            if (w != 0 || h != 0) {
                                dragging_inv.inventory[# target_x + w, target_y + h] = [item_id, placement_id, qty, contained_items];
                            }
                        }
                    }
                }
                dragging_inv.dragging = -1;
                global.dragging_inventory = -1;
                global.mouse_input_delay = 15; // Restore delay to prevent immediate drop
                dragging_inv.just_split_timer = 0; // Reset to allow immediate context menu
                show_debug_message("Dropped " + string(qty) + " " + global.item_data[item_id][0] + " into " + dragging_inv.inventory_type + " at [" + string(target_x) + "," + string(target_y) + "] with contained_items: " + string(contained_items));
                qty = 0; // Ensure no remaining qty
            } else {
                // Return to original if no space
                dragging_inv.inventory[# dragging_inv.original_mx, dragging_inv.original_my] = [item_id, placement_id, qty, contained_items];
                if (dragging_inv.inventory_type != "equipment_slots") {
                    for (var w = 0; w < item_width; w++) {
                        for (var h = 0; h < item_height; h++) {
                            if (w != 0 || h != 0) {
                                dragging_inv.inventory[# dragging_inv.original_mx + w, dragging_inv.original_my + h] = [item_id, placement_id, qty, contained_items];
                            }
                        }
                    }
                }
                dragging_inv.dragging = -1;
                global.dragging_inventory = -1;
                global.mouse_input_delay = 15; // Restore delay to prevent immediate drop
                dragging_inv.just_split_timer = 0; // Reset to allow immediate context menu
                show_debug_message("Returned " + string(qty) + " " + global.item_data[item_id][0] + " to original [" + string(dragging_inv.original_mx) + "," + string(dragging_inv.original_my) + "] - no space");
                qty = 0; // Ensure no remaining qty
            }

            // Only handle remaining qty after partial merge
            if (qty > 0) {
                var placed = false;
                for (var i = 0; i < dragging_inv.grid_width - item_width + 1 && !placed; i++) {
                    for (var j = 0; j < dragging_inv.grid_height - item_height + 1 && !placed; j++) {
                        if (inventory_can_fit(i, j, item_width, item_height, dragging_inv.inventory)) {
                            dragging_inv.inventory[# i, j] = [item_id, placement_id, qty, contained_items];
                            for (var w = 0; w < item_width; w++) {
                                for (var h = 0; h < item_height; h++) {
                                    if (w != 0 || h != 0) {
                                        dragging_inv.inventory[# i + w, j + h] = [item_id, placement_id, qty, contained_items];
                                    }
                                }
                            }
                            show_debug_message("Placed remaining " + string(qty) + " " + global.item_data[item_id][0] + " at [" + string(i) + "," + string(j) + "] after partial merge");
                            placed = true;
                        }
                    }
                }
                if (!placed) {
                    dragging_inv.inventory[# dragging_inv.original_mx, dragging_inv.original_my] = [item_id, placement_id, qty, contained_items];
                    for (var w = 0; w < item_width; w++) {
                        for (var h = 0; h < item_height; h++) {
                            if (w != 0 || h != 0) {
                                dragging_inv.inventory[# dragging_inv.original_mx + w, dragging_inv.original_my + h] = [item_id, placement_id, qty, contained_items];
                            }
                        }
                    }
                    show_debug_message("Returned remaining " + string(qty) + " " + global.item_data[item_id][0] + " to original [" + string(dragging_inv.original_mx) + "," + string(dragging_inv.original_my) + "] after partial merge");
                }
                dragging_inv.dragging = -1;
                global.dragging_inventory = -1;
                global.mouse_input_delay = 15; // Restore delay to prevent immediate drop
                dragging_inv.just_split_timer = 0; // Reset to allow immediate context menu
            }
        }
    } else {
        var dropped = false;
        with (obj_inventory) {
            bounds_width = (inventory_type == "equipment_slots") ? (grid_width * slot_size + (grid_width - 1) * spacing) : (grid_width * slot_size);
            if (id != dragging_inv && is_open && point_in_rectangle(gui_mouse_x, gui_mouse_y, inv_gui_x, inv_gui_y, inv_gui_x + bounds_width, inv_gui_y + (grid_height * slot_size))) {
                var drop_x = (inventory_type == "equipment_slots") ? floor((gui_mouse_x - inv_gui_x) / (slot_size + spacing)) : floor((item_x - inv_gui_x) / slot_size);
                var drop_y = floor((item_y - inv_gui_y) / slot_size);

                if (inventory_type != "equipment_slots") {
                    var x_offset = (item_x - inv_gui_x) % slot_size;
                    var y_offset = (item_y - inv_gui_y) % slot_size;
                    if (x_offset > slot_size * 0.75 && drop_x + item_width < grid_width) drop_x += 1;
                    if (y_offset > slot_size * 0.75 && drop_y + item_height < grid_height) drop_y += 1;
                    drop_x = clamp(drop_x, 0, grid_width - item_width);
                    drop_y = clamp(drop_y, 0, grid_height - item_height);
                } else {
                    drop_y = 0; // Force y to 0 for equipment slots (1D grid)
                    drop_x = clamp(drop_x, 0, grid_width - 1);
                }

                show_debug_message("Cross-inventory: Mouse [" + string(gui_mouse_x) + "," + string(gui_mouse_y) + "], Item [" + string(item_x) + "," + string(item_y) + "], Drop [" + string(drop_x) + "," + string(drop_y) + "] in " + inventory_type);

                if (drop_x >= 0 && drop_x < grid_width && drop_y >= 0 && drop_y < grid_height) {
                    var target_slot = inventory[# drop_x, drop_y];
                    var can_drop = (inventory_type == "equipment_slots") ? (global.item_data[item_id][6] == slot_types[drop_x] && target_slot == -1) : inventory_can_fit(drop_x, drop_y, item_width, item_height, inventory);

                    if (can_drop && string_pos("mod_", inventory_type) == 1) {
                        var parent_item_id = id.item_id;
                        can_drop = can_accept_mod(parent_item_id, item_id);
                        if (!can_drop) {
                            show_debug_message("Cannot drop " + global.item_data[item_id][0] + " into " + global.item_data[parent_item_id][0] + " - incompatible mod type");
                            dragging_inv.inventory[# dragging_inv.original_mx, dragging_inv.original_my] = [item_id, placement_id, qty, contained_items];
                            if (dragging_inv.inventory_type != "equipment_slots") {
                                for (var w = 0; w < item_width; w++) {
                                    for (var h = 0; h < item_height; h++) {
                                        if (w != 0 || h != 0) {
                                            dragging_inv.inventory[# dragging_inv.original_mx + w, dragging_inv.original_my + h] = [item_id, placement_id, qty, contained_items];
                                        }
                                    }
                                }
                            }
                            dragging_inv.dragging = -1;
                            global.dragging_inventory = -1;
                            global.mouse_input_delay = 15; // Restore delay to prevent immediate drop
                            dropped = true;
                        }
                    }

                    if (can_drop) {
                        inventory[# drop_x, drop_y] = [item_id, placement_id, qty, contained_items];
                        global.equipment[drop_x] = item_id; // Sync global.equipment with the dropped item
                        if (inventory_type != "equipment_slots") {
                            for (var w = 0; w < item_width; w++) {
                                for (var h = 0; h < item_height; h++) {
                                    if (w != 0 || h != 0) {
                                        inventory[# drop_x + w, drop_y + h] = [item_id, placement_id, qty, contained_items];
                                    }
                                }
                            }
                        }
                        if (is_moddable && ds_exists(mod_grid_to_transfer, ds_type_grid)) {
                            var new_slot = inventory[# drop_x, drop_y];
                            var new_placement_id = new_slot[1];
                            if (new_placement_id != placement_id) {
                                ds_map_delete(global.mod_inventories, placement_id);
                                global.mod_inventories[? new_placement_id] = mod_grid_to_transfer;
                            }
                        }
                        dragging_inv.dragging = -1;
                        global.dragging_inventory = -1;
                        global.mouse_input_delay = 15; // Restore delay to prevent immediate drop
                        dragging_inv.just_split_timer = 0; // Reset to allow immediate context menu
                        dropped = true;
                        if (inventory_type == "equipment_slots") {
                            show_debug_message("Dropped " + global.item_data[item_id][0] + " into equipment slot at [" + string(drop_x) + ",0] from another inventory");
                        } else {
                            show_debug_message("Dropped " + global.item_data[item_id][0] + " into " + inventory_type + " at [" + string(drop_x) + "," + string(drop_y) + "] from another inventory");
                        }
                    }
                }
            }
        }
        if (!dropped) {
            instance_create_layer(obj_player.x + irandom_range(-8, 8), obj_player.y + irandom_range(-8, 8), "Instances", obj_item, {
                item_id: item_id,
                stack_quantity: qty,
                placement_id: placement_id,
                contained_items: contained_items
            });
            show_debug_message("Dropped " + global.item_data[item_id][0] + " on ground from " + dragging_inv.inventory_type + " with contained_items: " + string(contained_items));
            dragging_inv.dragging = -1;
            global.dragging_inventory = -1;
            global.mouse_input_delay = 15; // Restore delay to prevent immediate drop
            dragging_inv.just_split_timer = 0; // Reset to allow immediate context menu
        }
    }
}

// Handle context menu
if (mouse_check_button_pressed(mb_right) && global.dragging_inventory == -1 && !instance_exists(obj_context_menu) && !instance_exists(obj_mod_inventory) && global.mouse_input_delay <= 0) {
    var gui_mouse_x = device_mouse_x_to_gui(0);
    var gui_mouse_y = device_mouse_y_to_gui(0);
    var target_inventory = noone;
    with (obj_inventory) {
        if (is_open) {
            var bounds_width = (inventory_type == "equipment_slots") ? (grid_width * slot_size + (grid_width - 1) * spacing) : (grid_width * slot_size);
            var bounds_height = (inventory_type == "equipment_slots") ? slot_size : (grid_height * slot_size);
            if (point_in_rectangle(gui_mouse_x, gui_mouse_y, inv_gui_x, inv_gui_y, inv_gui_x + bounds_width, inv_gui_y + bounds_height)) {
                target_inventory = id;
                break; // Lock onto the first inventory with the mouse inside its bounds
            } else {
                show_debug_message("Mouse [" + string(gui_mouse_x) + "," + string(gui_mouse_y) + "] outside " + inventory_type + " bounds [" + string(inv_gui_x) + "," + string(inv_gui_y) + "] to [" + string(inv_gui_x + bounds_width) + "," + string(inv_gui_y + bounds_height) + "]");
            }
        }
    }

    if (target_inventory != noone) {
        with (target_inventory) {
            var mx = floor((gui_mouse_x - inv_gui_x) / slot_size);
            var my = floor((gui_mouse_y - inv_gui_y) / slot_size);
            if (mx >= 0 && mx < grid_width && my >= 0 && my < grid_height) {
                var slot = inventory[# mx, my];
                if (slot != -1 && is_array(slot)) {
                    var item_id = slot[0];
                    var placement_id = slot[1];
                    var item_width = global.item_data[item_id][1];
                    var item_height = global.item_data[item_id][2];
                    var top_left_x = mx;
                    var top_left_y = my;
                    if (inventory_type != "equipment_slots") {
                        while (top_left_x > 0 && is_array(inventory[# top_left_x - 1, my]) && inventory[# top_left_x - 1, my][1] == placement_id) top_left_x -= 1;
                        while (top_left_y > 0 && is_array(inventory[# mx, top_left_y - 1]) && inventory[# mx, top_left_y - 1][1] == placement_id) top_left_y -= 1;
                        if (mx >= top_left_x && mx < top_left_x + item_width && my >= top_left_y && my < top_left_y + item_height) {
                            show_debug_message("Attempting to spawn context menu for " + inventory_type + " item at [" + string(top_left_x) + "," + string(top_left_y) + "]");
                            instance_create_layer(0, 0, "GUI_Menu", obj_context_menu, {
                                menu_x: gui_mouse_x,
                                menu_y: gui_mouse_y,
                                slot_x: top_left_x,
                                slot_y: top_left_y,
                                inventory: id,
                                item_id: item_id
                            });
                        }
                    } else {
                        show_debug_message("Attempting to spawn context menu for equipment slot item at [" + string(mx) + "," + string(my) + "]");
                        instance_create_layer(0, 0, "GUI_Menu", obj_context_menu, {
                            menu_x: gui_mouse_x,
                            menu_y: gui_mouse_y,
                            slot_x: mx,
                            slot_y: my,
                            inventory: id,
                            item_id: item_id
                        });
                    }
                } else {
                    show_debug_message("No valid slot data at [" + string(mx) + "," + string(my) + "] in " + inventory_type);
                }
            } else {
                show_debug_message("Mouse coordinates [" + string(mx) + "," + string(my) + "] out of grid bounds [" + string(grid_width) + "," + string(grid_height) + "] in " + inventory_type);
            }
        }
    }
}

// Handle mod inventory closure
with (obj_inventory) {
    if (variable_instance_exists(id, "parent_inventory") && instance_exists(parent_inventory) && !is_open) {
        var mod_items = [];
        for (var i = 0; i < grid_width; i++) {
            for (var j = 0; j < grid_height; j++) {
                var slot = inventory[# i, j];
                if (slot != -1 && is_array(slot)) {
                    var slot_copy = [slot[0], i, j, slot[2]];
                    mod_items[array_length(mod_items)] = slot_copy;
                }
            }
        }
        var parent_slot = parent_inventory.inventory[# parent_slot_x, parent_slot_y];
        if (is_array(parent_slot)) {
            var parent_copy = array_create(4);
            array_copy(parent_copy, 0, parent_slot, 0, 3);
            parent_copy[3] = mod_items;
            for (var w = 0; w < global.item_data[parent_copy[0]][1]; w++) {
                for (var h = 0; h < global.item_data[parent_copy[0]][2]; h++) {
                    parent_inventory.inventory[# parent_slot_x + w, parent_slot_y + h] = parent_copy;
                }
            }
            if (ds_map_exists(global.mod_inventories, parent_copy[1])) {
                var mod_grid = global.mod_inventories[? parent_copy[1]];
                ds_grid_clear(mod_grid, -1);
                for (var m = 0; m < array_length(mod_items); m++) {
                    var mod_item = mod_items[m];
                    mod_grid[# mod_item[1], mod_item[2]] = [mod_item[0], parent_copy[1], mod_item[3], []];
                }
                show_debug_message("Updated mod grid for placement_id " + string(parent_copy[1]) + " with: " + string(ds_grid_to_array(mod_grid)));
            }
            if (array_length(mod_items) == 0 && ds_map_exists(global.mod_inventories, parent_copy[1])) {
                ds_grid_destroy(global.mod_inventories[? parent_copy[1]]);
                ds_map_delete(global.mod_inventories, parent_copy[1]);
                show_debug_message("Cleared empty mod grid for placement_id " + string(parent_copy[1]));
            }
            show_debug_message("Closed mod inventory, updated parent at [" + string(parent_slot_x) + "," + string(parent_slot_y) + "] with slot: " + string(parent_copy));
        }
        instance_destroy();
    }
}

// Update ammo based on equipped weapon (fixed to preserve current ammo)
if (instance_exists(global.equipment_slots)) {
    var weapon_slot = global.equipment_slots.inventory[# 1, 0]; // Weapon slot
    if (is_array(weapon_slot) && weapon_slot[0] != -1) {
        var weapon_id = weapon_slot[0];
        var weapon_name = string_lower(global.item_data[weapon_id][0]); // e.g., "small_gun"
        if (ds_exists(ammo_counts, ds_type_map)) {
            if (!ds_map_exists(ammo_counts, weapon_name)) {
                ds_map_add(ammo_counts, weapon_name, 30); // Default ammo on equip
                ds_map_add(ammo_counts, weapon_name + "_max", 50); // Default max
            }
            // Only update ammo_current if not already set or weapon changed
            if (ammo_current == 0 || !ds_map_exists(ammo_counts, "last_weapon") || ds_map_find_value(ammo_counts, "last_weapon") != weapon_name) {
                ammo_current = ds_map_find_value(ammo_counts, weapon_name);
                ammo_max = ds_map_find_value(ammo_counts, weapon_name + "_max");
                ds_map_add(ammo_counts, "last_weapon", weapon_name); // Track last weapon
            }
        } else {
            ammo_current = 0;
            ammo_max = 0;
        }
    } else {
        ammo_current = 0;
        ammo_max = 0;
    }
}

// Handle enemy alert timer
if (enemies_alerted && global.alert_timer > 0) {
    // Check if any enemy still sees the player
    var player_spotted = false;
    with (obj_enemy_parent) {
        if (state == "alert" && point_distance(x, y, obj_player.x, obj_player.y) <= detection_range) {
            var player_dir = point_direction(x, y, obj_player.x, obj_player.y);
            var angle_diff = abs(angle_difference(facing_direction, player_dir));
            if (angle_diff <= detection_angle / 2 && !collision_line(x, y, obj_player.x, obj_player.y, obj_collision_parent, true, true)) {
                player_spotted = true;
                break;
            }
        }
    }
    if (player_spotted) {
        global.alert_timer = 600; // Reset to 10 sec if player is spotted
        show_debug_message("Alert timer reset - player still spotted");
    } else {
        global.alert_timer--;
        if (global.alert_timer <= 0) {
            enemies_alerted = false;
            show_debug_message("Enemy alert state reset - all enemies now searching");
        }
    }
}

// Handle search timer when alert is off
if (!enemies_alerted) {
    global.search_timer = 0; // Reset unless an enemy is searching
    with (obj_enemy_parent) {
        if (state == "search" && search_timer > global.search_timer) {
            global.search_timer = search_timer; // Take the longest active search
        }
    }
}