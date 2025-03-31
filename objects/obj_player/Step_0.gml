// obj_player - Step Event
var pickup_range = 48;

// Movement with arrow keys and WASD
var h_input = (keyboard_check(vk_right) || keyboard_check(ord("D"))) - (keyboard_check(vk_left) || keyboard_check(ord("A")));
var v_input = (keyboard_check(vk_down) || keyboard_check(ord("S"))) - (keyboard_check(vk_up) || keyboard_check(ord("W")));

if (h_input != 0 || v_input != 0) {
    var dir = point_direction(0, 0, h_input, v_input);
    input_direction = dir;
    x += lengthdir_x(move_speed, dir);
    y += lengthdir_y(move_speed, dir);

    if (input_direction == 0) { // Right
        sprite_index = spr_player_walk_side;
        image_xscale = 1;
        image_yscale = 1;
    } else if (input_direction == 180) { // Left
        sprite_index = spr_player_walk_side;
        image_xscale = -1;
        image_yscale = 1;
    } else if (input_direction == 90) { // Up
        sprite_index = spr_player_walk_up;
        image_xscale = 1;
        image_yscale = 1;
    } else if (input_direction == 270) { // Down
        sprite_index = spr_player_walk_down;
        image_xscale = 1;
        image_yscale = 1;
    }
} else {
    sprite_index = spr_player_idle;
}

image_index += 0;

// Fire weapon on space bar press
if (keyboard_check_pressed(vk_space)) {
    if (instance_exists(global.equipment_slots)) {
        var weapon_slot = global.equipment_slots.inventory[# 1, 0];
        if (is_array(weapon_slot) && weapon_slot[0] != -1 && obj_manager.ammo_current > 0) {
            var weapon_id = weapon_slot[0];
            var ammo_item_id = -1;
            var ammo_key = ds_map_find_first(global.ammo_to_weapon);
            while (!is_undefined(ammo_key)) {
                var ammo_data = global.ammo_to_weapon[? ammo_key];
                if (ammo_data[1] == weapon_id) {
                    ammo_item_id = ammo_key;
                    break;
                }
                ammo_key = ds_map_find_next(global.ammo_to_weapon, ammo_key);
            }

            if (ammo_item_id != -1) {
                var ammo_type = global.ammo_to_weapon[? ammo_item_id][0];
                
                if (obj_manager.ammo_current > 0) {
                    obj_manager.ammo_current -= 1;
                    ds_map_replace(obj_manager.ammo_counts, ammo_type, obj_manager.ammo_current);

                    var smallest_stack = -1;
                    var smallest_rounds = 9999;
                    var smallest_i = -1;
                    var smallest_j = -1;
                    for (var i = 0; i < ds_grid_width(global.backpack.inventory); i++) {
                        for (var j = 0; j < ds_grid_height(global.backpack.inventory); j++) {
                            var slot = global.backpack.inventory[# i, j];
                            if (is_array(slot) && slot[0] == ammo_item_id && slot[2] > 0 && slot[2] < smallest_rounds) {
                                smallest_stack = slot;
                                smallest_rounds = slot[2];
                                smallest_i = i;
                                smallest_j = j;
                            }
                        }
                    }

                    if (smallest_stack != -1) {
                        smallest_stack[2] -= 1;
                        if (smallest_stack[2] <= 0) {
                            inventory_remove(smallest_i, smallest_j, global.backpack.inventory);
                            show_debug_message("Removed empty " + global.item_data[ammo_item_id][0] + " stack at [" + string(smallest_i) + "," + string(smallest_j) + "]");
                        } else {
                            global.backpack.inventory[# smallest_i, smallest_j] = smallest_stack;
                        }
                    }

                    var bullet = instance_create_layer(x, y, "Instances", obj_bullet);
                    bullet.direction = input_direction;
                    bullet.image_angle = input_direction;
                    bullet.creator = id;
                    show_debug_message("Fired " + global.item_data[weapon_id][0] + ", rounds left: " + string(obj_manager.ammo_current));
                } else {
                    show_debug_message("No ammo left for " + global.item_data[weapon_id][0]);
                }
            }
        }
    }
}

// Inventory and pickup logic
if (!variable_instance_exists(id, "pickup_cooldown")) pickup_cooldown = 0;
if (pickup_cooldown > 0) pickup_cooldown--;

nearest_item_to_pickup = noone;
var min_dist = pickup_range;
with (obj_item) {
    var dist = point_distance(x, y, other.x, other.y);
    if (dist <= min_dist) {
        other.nearest_item_to_pickup = id;
        min_dist = dist;
    }
}

if (keyboard_check_pressed(vk_tab)) {
    if (instance_exists(global.backpack)) {
        global.backpack.is_open = !global.backpack.is_open;
        show_debug_message((global.backpack.is_open ? "Opened" : "Closed") + " backpack at GUI position [64,256]");
    }
}

if (keyboard_check_pressed(ord("E")) && pickup_cooldown == 0 && nearest_item_to_pickup != noone) {
    with (nearest_item_to_pickup) {
        var my_item_id = item_id;
        if (my_item_id != ITEM.NONE) {
            var rounds_per_magazine = ds_map_exists(global.ammo_to_weapon, my_item_id) ? global.ammo_to_weapon[? my_item_id][2] : 1;
            var rounds_to_add = stack_quantity * rounds_per_magazine; // Dynamic rounds per magazine
            show_debug_message("Picking up " + global.item_data[my_item_id][0] + ": stack_quantity=" + string(stack_quantity) + ", rounds_to_add=" + string(rounds_to_add));
            var success = inventory_add_item(global.backpack, my_item_id, rounds_to_add, true, contained_items);
            if (success) {
                is_in_world = false;
                var placement_id = -1;
                for (var i = 0; i < ds_grid_width(global.backpack.inventory); i++) {
                    for (var j = 0; j < ds_grid_height(global.backpack.inventory); j++) {
                        var slot = global.backpack.inventory[# i, j];
                        if (is_array(slot) && slot[0] == my_item_id && slot[2] == rounds_to_add) {
                            placement_id = slot[1];
                            break;
                        }
                    }
                    if (placement_id != -1) break;
                }
                if (global.item_data[my_item_id][8] && placement_id != -1) {
                    var mod_width = global.item_data[my_item_id][9];
                    var mod_height = global.item_data[my_item_id][10];
                    var mod_grid = ds_grid_create(mod_width, mod_height);
                    if (array_length(contained_items) > 0) {
                        array_to_ds_grid(contained_items, mod_grid);
                        show_debug_message("Restored mod inventory for " + global.item_data[my_item_id][0] + " with placement_id " + string(placement_id) + " and contained_items: " + string(contained_items));
                    } else {
                        ds_grid_clear(mod_grid, -1);
                    }
                    global.mod_inventories[? placement_id] = mod_grid;
                }
                show_debug_message("Picked up " + global.item_data[my_item_id][0] + " with " + string(rounds_to_add) + " rounds");
                instance_destroy();
                other.pickup_cooldown = 15;
            } else {
                show_debug_message("Failed to pick up " + global.item_data[my_item_id][0] + " - backpack full or placement error");
            }
        }
    }
    nearest_item_to_pickup = noone;
}

